# Project Requirements

## Building the Data Warehouse

### Objective

Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

### Specifications

- Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
- Data Quality: Cleanse and resolve data quality issues prior to analysis.
- Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
- Scope: Focus on the latest dataset only; historization of data is not required.
- Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics team.

## Project Overview

This project involves:

1. **Data Architecture:** Designing a Modern Data Warehouse using Medallion Architecture Bronze, Silver and Gold Layers.
2. **ETL Pipelines:** Extracting, Transforming and Loading data from source systems into the Warehouse.
3. **Data Modeling:** Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting:** Creating SQL-based reports and dashboards for actionable insights.

# General Principles

- Naming Convention: Use snake_case, with lowercase letters and underscores (_) to separate words.
- Language: English
- Do not use reserved SQL words as object names.

# Table Naming Conventions

## Bronze & Silver Rules

- Names must start with the source system name (e.g. crm, erp) and table names must match their original names without renaming.
- **sourcesystem_entity**
- Example: crm_sales_details - Sales details from the CRM system.

## Gold Rules

- All names must use mraningful, business-aligned names for tabless, starting with the category prefix.
- category_entity
    - category: Describes the role of the table, such as dim (dimension) or fact (fact table)
    - entity: Descriptive name of the table, aligned with the business domain (e.g. customers, products, sales)
    - Examples
        - dim_customers - Dimension table for customer data.
        - fact_sales - Fact table containing sales transactions.

### Glossary of Category Patterns

| Pattern | Meaning | Examples |
| --- | --- | --- |
| dim_ | Dimension table | dim_customer, dim_product |
| fact_ | Fact table | fact_sales |
| agg_ | Aggregated table | agg_customers, agg_sales_monthly |

# Column Naming Convention

## Surrogate Keys

- All primary keys in dimension tables must use the suffix _key
- table_name_key
    - table_name: Refers to the name of the table or entity the key belongs to.
    - _key: A suffix indicating that this column  is a surrogate key.
    - Example: customer_key - Surrogate key in the dim_customers table.

## Technical Columns

- All technical columns must start with the prefix dwh_, followed by a descriptive name indicating the column’s purpose.
- dwh_column_name
    - dwh: Prefix exclusively for system-generated metadata.
    - column_name: Descriptive name indincating the column’s purpose.
    - Example: dwh_load_date - System generated column used to store the date when the record was loaded.

# Stored Procedure

- All sored procedures used for loading data must follow the naming pattern: load_<layer>
    - layer: Represents the layer being loaded, such as bronze, silver or gold.
    - Example: load_bronze - Sored procedure for loading data into the Bronze layer.

# Data Architecture

Data Architecture for this project follows Medallion Architecture: Bronze, Silver and Gold Layers.

[Data Architecture.png](documents/Data Architecture.png)

1. **Bronze Layer:** Stores raw data as-is from the source systems. Data is ingested from CSV files into SQL Server Database.
2. **Silver Layer:** Includes data cleansing, standarization and normalization processes to prepare data for analysis.
3. **Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics.
