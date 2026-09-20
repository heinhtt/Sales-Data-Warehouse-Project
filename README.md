# Data Warehouse and Analytics Project

This project showcases a complete data warehousing and analytics solution, including building a PostgreSQL data warehouse and generating insights from integrated data sources. Intended as a data engineering and analytics project, it highlights for e-commerce and retail industry.

---
## 🏗️ Data Architecture

The data architecture for this project follows the Medallion Architecture, comprising **Bronze**, **Silver**, and **Gold** layers:
1. **Bronze Layer**: Raw data is ingested from CSV files into the PostgreSQL databass and stores as raw data, originating from the source systems. 
2. **Silver Layer**: Involves data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Models the data into a star schema and houses as analytics-ready data for reporting and analytics.

![Data Architecture](docs/data_architecture.png)

---
## 📖 Project Overview

This project involves:
1. **Data Architecture**: Designing a Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables for efficient analytical queries.
4. **Data Analytics**: Using SQL queries for generating actionable insights.
 
---
## 🛠️ Tools:

- **[Datasets](datasets/):** Access to the project dataset (csv files).
- **[PostgreSQL](https://www.postgresql.org/download/)**: Open-source relational database for hosting the data warehouse.
- **[pgAdmin 4](https://www.pgadmin.org/download/pgadmin-4-windows/)**: A go-to GUI for PostgreSQL database management and executing SQL queries.
- **[DrawIO](https://www.drawio.com/):** Design data architecture, models, flows, and diagrams.
- **[Git Repository](https://github.com/):** Repository for managing, version control, and collaborate on the code efficiently.

---
## 🚀 Project Scopes

### Data Warehousing (Data Engineering)

#### Objective
Develop a modern data warehouse using PostgreSQL Database to consolidate sales data: 
- Cleansing and handling data quality issues before analysis.
- Enabling efficient data structure for analytical reporting.
- Providing the data model to support both business stakeholders and analytics teams.

---
### Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver granular insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.  

---
## 📂 Repository Structure
```
data-warehouse-and-analytics-project/
│
├── datasets/                       # Raw datasets used for the project 
│
├── docs/                           # Project documentation and architecture details
│   ├── data_architecture.png       # Medallion architecture (Bronze, Silver and Gold)
│   ├── data_flow.png               # Data flow diagram
│   ├── data_model.png              # Data model diagram, integrating the data tables into star schema
│
├── report/                         # SQL report queries
│   ├── analytics_queries.sql       # Scripts for exploratory data analysis
│
├── scripts/                        # SQL scripts for ETL pipeline
│   ├── bronze/                     # Scripts for extracting and loading raw data
│   ├── silver/                     # Scripts for cleansing and transforming data
│   ├── gold/                       # Scripts for modeling and loading analytics-ready data
│
├── tests/                          # Test scripts and quality control files
│
├── README.md                       # Project overview and instructions
├── LICENSE                         # License information for the repository
```

---
## 🛡️ License
This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.
