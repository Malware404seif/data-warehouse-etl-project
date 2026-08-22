# Data Warehouse ETL Project

A comprehensive **SQL Server** data warehouse ETL project that ingests data from multiple source systems (CRM and ERP) and transforms it through a **medallion architecture** (Bronze → Silver → Gold) to deliver clean, business-ready analytical data.

## 🏗️ Architecture

The project follows a layered (medallion) architecture:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Source     │ ──▶ │   Bronze    │ ──▶ │   Silver    │ ──▶ │    Gold     │
│  Systems    │     │  (Raw)      │     │  (Cleaned)  │     │ (Business)  │
│  CRM / ERP  │     │             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Layers

| Layer | Purpose | Schema |
|-------|---------|--------|
| **Bronze** | Raw data ingestion directly from source systems (CRM & ERP) with no transformations | `bronze` |
| **Silver** | Data cleaning, standardization, and enrichment (deduplication, type casting, mapping codes to values) | `silver` |
| **Gold** | Business-level views (dimensions & facts) ready for analytics and reporting | `gold` |

## 📁 Project Structure

```
├── datasets/
│   ├── source_crm/          # CRM source data (CSV)
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/          # ERP source data (CSV)
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
├── scripts/
│   ├── bronze/              # Bronze layer scripts
│   │   ├── bronze_table_creationssql.sql   # Table DDL
│   │   └── bronze_table_insertion.sql      # load_bronze procedure
│   ├── silver/              # Silver layer scripts
│   │   ├── silver_table_creation.sql       # Table DDL
│   │   └── sliver_load_procedure.sql       # load_silver procedure
│   └── gold/                # Gold layer scripts
│       └── create_gold_view.sql            # Dimension & fact views
└── docs/                    # Project documentation & diagrams
    ├── data_architecture.png
    ├── data_catalog.md
    ├── data_flow.png
    ├── data_integration.png
    ├── data_layers.pdf
    ├── data_model.png
    ├── ETL.png
    ├── naming_conventions.md
    └── Project_Notes_Sketches.pdf
```

## 🚀 Getting Started

### Prerequisites

- **SQL Server** (2019 or later recommended)
- **SQL Server Management Studio (SSMS)** or any SQL client

### Setup & Execution

1. **Clone the repository**
   ```bash
   git clone https://github.com/Malware404seif/data-warehouse-etl-project.git
   ```

2. **Create the schemas** — Run the schema creation scripts in order:
   - `scripts/bronze/bronze_table_creationssql.sql`
   - `scripts/silver/silver_table_creation.sql`
   - `scripts/gold/create_gold_view.sql`

3. **Load the Bronze layer** — Execute the `load_bronze` stored procedure:
   ```sql
   EXEC bronze.load_bronze;
   ```
   > **Note:** Update the file paths in `bronze_table_insertion.sql` to point to your local `datasets/` folder.

4. **Load the Silver layer** — Execute the `load_silver` stored procedure:
   ```sql
   EXEC silver.load_silver;
   ```

5. **Query the Gold layer** — Use the business views for analytics:
   ```sql
   SELECT * FROM gold.dim_customer;
   SELECT * FROM gold.dim_products;
   SELECT * FROM gold.fact_sales;
   ```

## 🧠 ETL Process

### Bronze Layer (Raw Ingestion)
- Creates raw tables mirroring the source systems (`crm_*`, `erp_*`).
- Uses `BULK INSERT` to load CSV data from the `datasets/` folder.
- No transformations applied — data is stored as-is.

### Silver Layer (Cleaning & Standardization)
- **Deduplication** — Removes duplicate customer records using `ROW_NUMBER()`.
- **Data type casting** — Converts integer dates to proper `DATE` types.
- **Code mapping** — Maps codes to readable values (e.g., `M` → `Male`, `S` → `Single`).
- **Data quality** — Handles nulls, trims whitespace, and corrects invalid values.
- **Enrichment** — Derives category IDs and end dates from product data.

### Gold Layer (Business Views)
- **`gold.dim_customer`** — Customer dimension enriched with location & demographic data.
- **`gold.dim_products`** — Product dimension with category/subcategory attributes.
- **`gold.fact_sales`** — Sales fact table linking customers and products.

## 📚 Documentation

- [Data Catalog](docs/data_catalog.md) — Detailed column descriptions for the Gold layer.
- [Naming Conventions](docs/naming_conventions.md) — Standards for schemas, tables, and columns.
- Architecture & flow diagrams available in the `docs/` folder.

## 🛠️ Technologies

- **SQL Server** — Database engine
- **T-SQL** — Stored procedures, views, and DDL
- **BULK INSERT** — High-performance CSV loading
- **Medallion Architecture** — Bronze / Silver / Gold layered design

## 📄 License

This project is for educational purposes.