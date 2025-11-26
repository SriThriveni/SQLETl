CREATE TABLE staging_sales (
    sale_id INT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    sale_date TEXT
);

INSERT INTO staging_sales VALUES
(1, 'Laptop', 2, 60000.00, '2025-10-01'),
(2, 'Mouse', NULL, 800.00, '2025-10-02'),
(3, '', 1, 2000.00, '2025-10-03'),
(4, 'Keyboard', 3, NULL, '2025-10-04');

SELECT * FROM staging_sales;

CREATE TABLE cleaned_sales AS
SELECT
    sale_id,
    TRIM(product_name) AS product_name,
    COALESCE(quantity, 1) AS quantity,      
    COALESCE(price, 0) AS price,            
    DATE(sale_date) AS sale_date
FROM staging_sales
WHERE product_name IS NOT NULL AND product_name != '';

CREATE TABLE production_sales (
    sale_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    sale_date DATE
);

INSERT INTO production_sales
SELECT
    sale_id,
    product_name,
    quantity,
    price,
    (quantity * price) AS total_amount,
    sale_date
FROM cleaned_sales;

SELECT * FROM production_sales;

CREATE TABLE etl_audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    process_name VARCHAR(255),
    rows_inserted INT,
    run_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO etl_audit_log (process_name, rows_inserted)
SELECT 'Sales ETL Load', COUNT(*) FROM production_sales;

DELIMITER $$

CREATE TRIGGER clean_staging_after_load
AFTER INSERT ON production_sales
FOR EACH ROW
BEGIN
    DELETE FROM staging_sales;
END$$

DELIMITER ;


