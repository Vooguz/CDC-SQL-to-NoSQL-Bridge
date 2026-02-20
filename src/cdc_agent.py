import time
import json
import pyodbc
from pymongo import MongoClient
from datetime import datetime

# --- BAĞLANTI AYARLARI ---
# Kendi bilgisayarındaki SQLEXPRESS ve OguzErenDB veritabanı bilgilerini kullanır
SQL_CONN_STR = (
    r'Driver={SQL Server};'
    r'Server=.\SQLEXPRESS;' 
    r'Database=OguzErenDB;'
    r'Trusted_Connection=yes;'
)

MONGO_URI = "mongodb://localhost:27017/"
DB_NAME = "CompanyDB"
COLLECTION_NAME = "change_logs"

def get_sql_connection():
    return pyodbc.connect(SQL_CONN_STR)

def process_changes():
    """SQL'deki logları okuyup MongoDB'ye aktaran ve NULL kontrolleri yapılmış fonksiyon"""
    try:
        sql_conn = get_sql_connection()
        cursor = sql_conn.cursor()
        
        mongo_client = MongoClient(MONGO_URI)
        mongo_db = mongo_client[DB_NAME]
        mongo_collection = mongo_db[COLLECTION_NAME]

        print("\n>>> CDC AJANI BAŞLATILDI (Kaynak: OguzErenDB)... Dinleniyor...")
        print(">>> Durdurmak için CTRL+C yapabilirsin.\n")

        while True:
            # İşlenmemiş logları çekiyoruz
            cursor.execute("SELECT log_id, operation_type, table_name, record_id, log_data, changed_at FROM Orders_Log WHERE is_processed = 0")
            rows = cursor.fetchall()

            if rows:
                print(f"> {len(rows)} adet yeni değişiklik yakalandı.")
                
                for row in rows:
                    log_id = row.log_id
                    
                    # --- GÜVENLİ JSON OKUMA YAPISI ---
                    # row.log_data'nın None (NULL) olup olmadığını kontrol eder
                    if row.log_data is not None:
                        try:
                            log_details = json.loads(row.log_data)
                        except Exception as e:
                            print(f"!!! JSON Ayrıştırma Hatası (Log ID: {log_id}): {e}")
                            log_details = {"hata": "Gecersiz JSON Formati", "ham_veri": str(row.log_data)}
                    else:
                        # Eğer veri NULL ise programın çökmesini engellemek için boş bir sözlük atanır
                        log_details = {"bilgi": "Veri yok veya NULL"}

                    # MongoDB'ye gidecek döküman formatı
                    document = {
                        "operation": row.operation_type,
                        "table": row.table_name,
                        "record_id": row.record_id,
                        "details": log_details,
                        "changed_at": str(row.changed_at),
                        "transferred_to_nosql_at": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    }

                    # MongoDB'ye ekle
                    mongo_collection.insert_one(document)
                    print(f"  - Log ID: {log_id} ({row.operation_type}) -> MongoDB'ye başarıyla aktarıldı.")

                    # SQL tarafında 'işlendi' olarak işaretle
                    cursor.execute("UPDATE Orders_Log SET is_processed = 1 WHERE log_id = ?", log_id)
                    sql_conn.commit()
            
            # 10 saniyede bir kontrol et (Senin terminal akışındaki polling süresi)
            time.sleep(10) 

    except KeyboardInterrupt:
        print("\n>>> Dinleme modu kullanıcı tarafından durduruldu.")
    except Exception as e:
        print("\n!!! BİR HATA OLUŞTU !!!")
        print("Hata Detayı:", e)
    finally:
        if 'sql_conn' in locals(): sql_conn.close()
        if 'mongo_client' in locals(): mongo_client.close()

def generate_report():
    """MongoDB'deki verileri analiz eden rapor fonksiyonu"""
    try:
        client = MongoClient(MONGO_URI)
        db = client[DB_NAME]
        coll = db[COLLECTION_NAME]

        print("\n" + "="*45)
        print("       MONGODB CDC ANALİZ RAPORU")
        print("="*45)

        # 1. Son 10 Değişiklik
        print("\n[1] SON 10 DEĞİŞİKLİK (KRONOLOJİK):")
        print("-" * 35)
        last_changes = coll.find({}, {"_id": 0}).sort("transferred_to_nosql_at", -1).limit(10)
        
        count = 0
        for doc in last_changes:
            count += 1
            op = doc.get('operation', 'N/A')
            tbl = doc.get('table', 'N/A')
            t_date = doc.get('transferred_to_nosql_at', 'N/A')
            print(f"{count}. {t_date} | {op} -> {tbl} (ID: {doc.get('record_id')})")

        # 2. Tablo İstatistikleri
        print("\n[2] TABLO TABANLI DEĞİŞİKLİK SAYILARI:")
        print("-" * 35)
        pipeline_table = [
            {"$group": {"_id": "$table", "toplam": {"$sum": 1}}},
            {"$sort": {"toplam": -1}}
        ]
        for stat in coll.aggregate(pipeline_table):
            print(f"• {stat['_id']} Tablosu: {stat['toplam']} işlem")

        print("\n" + "="*45 + "\n")

    except Exception as e:
        print("Rapor oluşturulurken hata:", e)

if __name__ == "__main__":
    while True:
        print("\n--- CDC PROJE KONTROL PANELİ ---")
        print("1. CDC Ajanını Başlat (Sürekli İzleme)")
        print("2. Analiz Raporunu Göster (MongoDB Sorgusu)")
        print("3. Çıkış")
        
        secim = input("\nSeçiminiz (1-3): ")

        if secim == '1':
            process_changes()
        elif secim == '2':
            generate_report()
            input("Ana menüye dönmek için Enter'a bas...")
        elif secim == '3':
            print("Sistem kapatılıyor. İyi çalışmalar Oğuz Eren!")
            break
        else:
            print("Geçersiz seçim!")