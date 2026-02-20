# CDC-SQL-to-NoSQL-Bridge

# 🔄 Change Data Capture (CDC) Pipeline: SQL to NoSQL

![Python](https://img.shields.io/badge/Python-3.8%2B-blue?style=for-the-badge&logo=python&logoColor=white)
![SQL Server](https://img.shields.io/badge/MS_SQL_Server-2019%2B-red?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-Latest-green?style=for-the-badge&logo=mongodb&logoColor=white)

## 🎯 Project Overview
This project implements a custom **Change Data Capture (CDC)** architecture that captures real-time data modifications (INSERT, UPDATE, DELETE) from a Relational Database (MS SQL Server) and synchronizes them into a NoSQL environment (MongoDB) for logging and analytical purposes. 

Designed with a **Trigger + Polling** methodology, it bridges the gap between transactional systems and flexible analytical data stores.

## 🏗️ Architecture & Workflow

1. **Source Layer (SQL Server):** - Operations on the primary tables (`Orders`, `Customers`) fire database triggers.
   - Triggers package the row data into JSON and log the event into a staging table (`Orders_Log`).
2. **Integration Layer (Python CDC Agent):** - A continuously running Python daemon (`cdc_agent.py`) polls the staging table.
   - It safely parses JSON payloads, handles null constraints, and flags records as processed.
3. **Sink Layer (MongoDB):** - Processed events are inserted into a NoSQL collection as flexible documents.
   - Ready for high-speed querying and reporting.

## 🛠️ Technical Stack
* **Database (Relational):** MS SQL Server (`OguzErenDB`)
* **Database (NoSQL):** MongoDB
* **Language:** Python 
* **Key Libraries:** `pyodbc` (SQL Connection), `pymongo` (NoSQL Operations)

## 🚀 Key Features
* **Real-time Event Tracking:** Captures all DML operations precisely.
* **Safe JSON Parsing:** Robust error handling for dynamic database schemas.
* **Smart Polling:** Lightweight cursor-based polling mechanisms to reduce database load.
* **Interactive Control Panel:** CLI-based reporting module to view the top 10 recent changes and activity statistics grouped by tables.

## 💻 Setup & Installation

**1. Clone the Repository:**
```bash
git clone [https://github.com/Vooguz/CDC-SQL-to-NoSQL-Bridge.git](https://github.com/YourUsername/CDC-SQL-to-NoSQL-Bridge.git)
cd CDC-SQL-to-NoSQL-Bridge
```
2. Install Dependencies:

```Bash

pip install -r requirements.txt
```
3. Database Configuration:

* Execute sql_scripts/schema.sql in SSMS to create the tables.

* Execute sql_scripts/triggers.sql to bind the CDC triggers.

* Ensure MongoDB is running locally on port 27017.

4. Run the Agent:

```Bash

python src/cdc_agent.py
```
👨‍💻 Author: Oğuz Eren 

Computer Engineering Student @Uludağ University

Contact: oueren81@gmail.com
