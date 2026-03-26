# Mini Inventory Database Schema - MySQL 8.0+

## Ikhtisar (Overview)

Schema database inventory sederhana dengan struktur Master-Detail untuk mengelola produk, gudang, supplier, dan transaksi stock inbound.

## Persyaratan (Requirements)

- MySQL 8.0 atau lebih tinggi
- Support untuk:
  - CHECK constraint (MySQL 8.0.16+)
  - Recursive CTE (MySQL 8.0+)
  - Triggers untuk UUID generation

## Struktur Database

### Master Tables

1. **supplier** - Master data supplier/vendor
2. **warehouse** - Master data warehouse/storage location
3. **category** - Master data product category
4. **item_product** - Master data item/product

### Transaction Tables

1. **stock_inbound** - Header transaksi penerimaan barang
2. **stock_inbound_item** - Detail item yang diterima

## Instalasi (Installation)

### 1. Membuat Database

```sql
CREATE DATABASE mini_inventory
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE mini_inventory;
```

### 2. Menjalankan Schema

```bash
# Via command line
mysql -u username -p mini_inventory < mini-inventory.sql

# Atau via MySQL client
mysql> USE mini_inventory;
mysql> SOURCE /path/to/mini-inventory.sql;
```

### 3. Load Sample Data

```bash
# Via command line
mysql -u username -p mini_inventory < ../../seeds/mysql/mini-inventory-seed.sql

# Atau via MySQL client
mysql> USE mini_inventory;
mysql> SOURCE /path/to/seeds/mysql/mini-inventory-seed.sql;
```

## Fitur Khusus MySQL

### UUID Generation

Schema ini menggunakan trigger untuk auto-generate UUID pada setiap insert:

```sql
-- Contoh trigger untuk supplier table
CREATE TRIGGER trg_supplier_before_insert
BEFORE INSERT ON supplier
FOR EACH ROW
BEGIN
    IF NEW.supplier_id IS NULL OR NEW.supplier_id = '' THEN
        SET NEW.supplier_id = UUID();
    END IF;
END;
```

Setiap table memiliki trigger serupa untuk auto-generate primary key.

### Auto Update Timestamp

Column `updated_at` menggunakan `ON UPDATE CURRENT_TIMESTAMP`:

```sql
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
           ON UPDATE CURRENT_TIMESTAMP
```

### Recursive CTE untuk Bulk Insert

Seed data menggunakan recursive CTE untuk generate 1000 produk:

```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 1000
)
SELECT ... FROM numbers;
```

## Perbedaan dengan PostgreSQL

| Fitur | PostgreSQL | MySQL 8.0 |
|-------|-----------|-----------|
| UUID Extension | `CREATE EXTENSION "uuid-ossp"` | Native `UUID()` function |
| UUID Default | `DEFAULT uuid_generate_v4()::VARCHAR` | Trigger `BEFORE INSERT` |
| Auto Update | Trigger required | `ON UPDATE CURRENT_TIMESTAMP` |
| Comments | `COMMENT ON TABLE/COLUMN` | Inline `COMMENT` |
| Generate Series | `generate_series(1, 1000)` | Recursive CTE |
| Boolean Type | `BOOLEAN` | `BOOLEAN`/`TINYINT(1)` |

## Verifikasi Instalasi

Setelah menjalankan schema dan seed:

```sql
-- Check table count
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'mini_inventory';
-- Expected: 6 tables

-- Check triggers
SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'mini_inventory';
-- Expected: 6 triggers

-- Check sample data
SELECT
    (SELECT COUNT(*) FROM category) AS categories,
    (SELECT COUNT(*) FROM supplier) AS suppliers,
    (SELECT COUNT(*) FROM warehouse) AS warehouses,
    (SELECT COUNT(*) FROM item_product) AS products,
    (SELECT COUNT(*) FROM stock_inbound) AS inbounds,
    (SELECT COUNT(*) FROM stock_inbound_item) AS inbound_items;
-- Expected: 6, 3, 3, 1000, 7, 13
```

## Query Contoh (Sample Queries)

### Produk per Kategori

```sql
SELECT
    c.category_name,
    COUNT(ip.item_product_id) AS total_products,
    SUM(ip.stock) AS total_stock
FROM category c
LEFT JOIN item_product ip ON c.category_id = ip.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC;
```

### Stock Inbound dengan Detail

```sql
SELECT
    si.inbound_number,
    si.inbound_date,
    w.warehouse_name,
    s.supplier_name,
    si.total_items,
    si.total_qty,
    si.total_amount,
    si.status
FROM stock_inbound si
JOIN warehouse w ON si.warehouse_id = w.warehouse_id
LEFT JOIN supplier s ON si.supplier_id = s.supplier_id
ORDER BY si.inbound_date DESC;
```

### Detail Item per Transaksi

```sql
SELECT
    si.inbound_number,
    sii.line_number,
    ip.product_code,
    ip.product_name,
    sii.qty_received,
    sii.uom,
    sii.unit_price,
    sii.total_amount
FROM stock_inbound si
JOIN stock_inbound_item sii ON si.stock_inbound_id = sii.stock_inbound_id
JOIN item_product ip ON sii.item_product_id = ip.item_product_id
WHERE si.inbound_number = 'INB/2025/001'
ORDER BY sii.line_number;
```

## Performance Tuning

### Indexes

Schema sudah include index untuk:
- Primary keys (automatic)
- Foreign keys
- Frequently queried columns (code, status, is_active)
- Composite indexes untuk join optimization

### Query Optimization

```sql
-- Check index usage
SHOW INDEX FROM item_product;

-- Analyze query execution
EXPLAIN SELECT * FROM item_product
WHERE category_id = 'xxx' AND is_active = TRUE;

-- Update table statistics
ANALYZE TABLE item_product;
```

## Backup dan Restore

### Backup

```bash
# Full backup
mysqldump -u username -p mini_inventory > backup.sql

# Schema only
mysqldump -u username -p --no-data mini_inventory > schema.sql

# Data only
mysqldump -u username -p --no-create-info mini_inventory > data.sql

# Specific tables
mysqldump -u username -p mini_inventory supplier warehouse > masters.sql
```

### Restore

```bash
# Full restore
mysql -u username -p mini_inventory < backup.sql

# From compressed backup
gunzip < backup.sql.gz | mysql -u username -p mini_inventory
```

## Troubleshooting

### Error: CHECK constraint violated

MySQL 8.0.16+ diperlukan untuk CHECK constraint. Jika menggunakan versi lebih lama, hapus semua `CONSTRAINT chk_*` dari schema.

```sql
-- Check MySQL version
SELECT VERSION();
```

### Error: recursive CTE tidak didukung

MySQL 8.0+ diperlukan untuk recursive CTE di seed data. Alternative: gunakan stored procedure atau load data dari CSV.

### UUID format berbeda dengan PostgreSQL

MySQL `UUID()` menghasilkan format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (36 characters)
PostgreSQL format sama, namun implementasi berbeda.

Jika perlu compatibility, gunakan `REPLACE(UUID(), '-', '')` untuk format 32 characters.

## Migrasi dari PostgreSQL

Untuk migrasi data dari PostgreSQL ke MySQL:

1. Export data dari PostgreSQL dalam format CSV
2. Adjust column mapping jika diperlukan
3. Load ke MySQL menggunakan `LOAD DATA INFILE` atau import tool

```sql
-- Export dari PostgreSQL
\copy supplier TO '/tmp/supplier.csv' WITH CSV HEADER;

-- Import ke MySQL
LOAD DATA INFILE '/tmp/supplier.csv'
INTO TABLE supplier
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

## Referensi (Reference)

- [MySQL 8.0 Documentation](https://dev.mysql.com/doc/refman/8.0/en/)
- [MySQL CHECK Constraint](https://dev.mysql.com/doc/refman/8.0/en/create-table-check-constraints.html)
- [MySQL Recursive CTE](https://dev.mysql.com/doc/refman/8.0/en/with.html)
- [MySQL UUID Function](https://dev.mysql.com/doc/refman/8.0/en/miscellaneous-functions.html#function_uuid)

## Lisensi (License)

Database schema ini dibuat untuk keperluan pembelajaran dan development. Silakan digunakan dan dimodifikasi sesuai kebutuhan.
