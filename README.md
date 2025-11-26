# SQLETL
# SQL ETL Pipeline Simulation Project

## 📌 Overview

This project demonstrates a complete **ETL (Extract–Transform–Load)** workflow using SQL.
It shows how raw data from a CSV dataset can be imported, cleaned, transformed, and loaded into a final production
table. It also includes an ETL audit logging system and optional automation using triggers.

---

## 🧱 Project Structure

The ETL pipeline consists of three major layers:

### 1. **Staging Layer (Extract)**

* Raw CSV file is imported into `staging_sales` table.
* No cleaning is applied here.
* Acts as the landing zone of the pipeline.

### 2. **Transformation Layer (Transform)**

* Data is cleaned and formatted.
* Null values replaced using `COALESCE()`.
* Empty product names removed.
* Dates formatted using `date()`.
* Result is stored in `cleaned_sales` table.

### 3. **Production Layer (Load)**

* Final table `production_sales` contains high-quality data.
* Additional derived column `total_amount` calculated.
* Suitable for reporting, dashboards, and analytics.

---

## 🧩 SQL Code

### **1. Create Staging Table (Extract)**

```
CREATE TABLE staging_sales (
    sale_id INTEGER,
    product_name TEXT,
    quantity INTEGER,
    price REAL,
    sale_date TEXT
);
```

### **2. Create Cleaned Table (Transform)**

```
CREATE TABLE cleaned_sales AS
SELECT
    sale_id,
    TRIM(product_name) AS product_name,
    COALESCE(quantity, 1) AS quantity,
    COALESCE(price, 0) AS price,
    date(sale_date) AS sale_date
FROM staging_sales
WHERE product_name IS NOT NULL AND product_name != '';
```

### **3. Create Production Table (Load)**

```
CREATE TABLE production_sales (
    sale_id INTEGER PRIMARY KEY,
    product_name TEXT,
    quantity INTEGER,
    price REAL,
    total_amount REAL,
    sale_date TEXT
);
```

### **4. Load Data into Production Table**

```
INSERT INTO production_sales
SELECT
    sale_id,
    product_name,
    quantity,
    price,
    quantity * price AS total_amount,
    sale_date
FROM cleaned_sales;
```

### **5. Create ETL Audit Log Table**

```
CREATE TABLE etl_audit_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    process_name TEXT,
    rows_inserted INTEGER,
    run_time TEXT DEFAULT (datetime('now'))
);
```

### **6. Insert Entry into Audit Log**

```
INSERT INTO etl_audit_log (process_name, rows_inserted)
SELECT 'Sales ETL Load', COUNT(*) FROM production_sales;
```

### **7. Trigger to Clean Staging Table**

DELIMITER $$


CREATE TRIGGER clean_staging_after_load
AFTER INSERT ON production_sales
FOR EACH ROW
BEGIN
DELETE FROM staging_sales;
END$$


DELIMITER ;
---

## 📊 Outputs Produced

* **staging_sales** – raw imported dataset
* **cleaned_sales** – cleaned and validated records
* **production_sales** – final high-quality dataset
* **etl_audit_log** – logs for ETL runs

---

## 🚀 How to Run This Project

1. Open **SQLite / DB Browser / DBeaver**.
2. Create a database.
3. Run the SQL scripts in order:

   * Create staging table
   * Import CSV data
   * Clean and transform
   * Load into production
   * Insert ETL audit log
4. Enable trigger for automatic cleanup.

---

## 🎯 Learning Outcomes

* Understanding of ETL workflow
* SQL data cleaning techniques
* Creating multi-layer data pipelines
* Audit logging for ETL jobs
* Using triggers for automation

---

## 📁 Extensions

You can extend this project by adding:

* Error handling tables
* Automated scheduling
* More datasets
* Aggregated reporting tables

---

