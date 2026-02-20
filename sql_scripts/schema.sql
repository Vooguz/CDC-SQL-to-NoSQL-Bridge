USE [OguzErenDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Customers](
    [customer_id] [int] NOT NULL,
    [name] [nvarchar](100) NULL,
    [email] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
    [customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[Orders](
    [order_id] [int] NOT NULL,
    [customer_id] [int] NULL,
    [product] [nvarchar](100) NULL,
    [amount] [decimal](10, 2) NULL,
    [status] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
    [order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


ALTER TABLE [dbo].[Orders]  WITH CHECK ADD FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO


CREATE TABLE [dbo].[Orders_Log](
    [log_id] [int] IDENTITY(1,1) NOT NULL,
    [operation_type] [nvarchar](10) NULL,
    [table_name] [nvarchar](50) NULL,
    [record_id] [int] NULL,
    [log_data] [nvarchar](max) NULL,
    [changed_at] [datetime] NULL,
    [is_processed] [bit] NULL,
    [data_json] [nvarchar](max) NULL,
    [created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
    [log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Orders_Log] ADD  DEFAULT (getdate()) FOR [changed_at]
GO
ALTER TABLE [dbo].[Orders_Log] ADD  DEFAULT ((0)) FOR [is_processed]
GO
ALTER TABLE [dbo].[Orders_Log] ADD  DEFAULT (getdate()) FOR [created_at]
GO