# Mini Inventory Seed Data - MySQL 8.0+

## Ikhtisar (Overview)

Sample data untuk database mini inventory yang mencakup:
- 6 kategori produk
- 3 supplier
- 3 warehouse
- 1000 produk (generated menggunakan recursive CTE)
- 7 transaksi stock inbound dengan 13 detail item

## Persyaratan (Requirements)

- MySQL 8.0 atau lebih tinggi (untuk recursive CTE support)
- Schema database sudah dibuat (`schemas/mysql/mini-inventory.sql` sudah dijalankan)
- Database `mini_inventory` sudah ada

## Cara Penggunaan (Usage)

### Via MySQL Command Line

```bash
mysql -u username -p mini_inventory < mini-inventory-seed.sql
```

### Via MySQL Client

```sql
USE mini_inventory;
SOURCE /path/to/seeds/mysql/mini-inventory-seed.sql;
```

### Via MySQL Workbench

1. Open MySQL Workbench
2. Connect ke server
3. Select database `mini_inventory`
4. File → Run SQL Script
5. Browse ke `mini-inventory-seed.sql`
6. Execute

## Data yang Di-generate

### Master Data

| Table | Jumlah Record | Keterangan |
|-------|---------------|------------|
| category | 6 | Elektronik, Fashion, Makanan, Kesehatan, Rumah Tangga, Olahraga |
| supplier | 3 | PT Supplier Utama, CV Mitra Sejahtera, PT Global Teknologi |
| warehouse | 3 | Jakarta (main), Surabaya (transit), Medan (consignment) |
| item_product | 1000 | Produk dari berbagai kategori dengan data lengkap |

### Transaction Data

| Table | Jumlah Record | Keterangan |
|-------|---------------|------------|
| stock_inbound | 7 | 5 transaksi confirmed, 2 transaksi draft |
| stock_inbound_item | 13 | Detail item dari 7 transaksi |

## Struktur Data Produk

Produk di-generate dengan pola sebagai berikut:

### Kategori dan Distribusi

- **Elektronik (CAT001)**: 167 produk
  - Smartphone, Laptop, Tablet, Monitor, dll
  - Brand: Samsung, Apple, Xiaomi, Asus, Lenovo, dll
  - Price range: Rp 500K - Rp 10M

- **Fashion (CAT002)**: 167 produk
  - Kaos, Kemeja, Celana, Jaket, dll
  - Brand: Uniqlo, H&M, Zara, Nike, Adidas, dll
  - Price range: Rp 50K - Rp 500K

- **Makanan (CAT003)**: 167 produk
  - Mie Instan, Biskuit, Kopi, Minuman, dll
  - Brand: Indomie, Nestle, Coca Cola, Aqua, dll
  - Price range: Rp 5K - Rp 100K

- **Kesehatan (CAT004)**: 166 produk
  - Vitamin, Suplemen, Skincare, dll
  - Brand: Blackmores, Centrum, Wardah, Emina, dll
  - Price range: Rp 25K - Rp 500K

- **Rumah Tangga (CAT005)**: 167 produk
  - Peralatan dapur dan elektronik rumah
  - Brand: Philips, Panasonic, Samsung, Oxone, dll
  - Price range: Rp 100K - Rp 2M

- **Olahraga (CAT006)**: 166 produk
  - Sepatu, Raket, Bola, Peralatan gym, dll
  - Brand: Nike, Adidas, Yonex, Wilson, dll
  - Price range: Rp 150K - Rp 1.5M

### Field Product yang Di-generate

- **product_code**: `PRD-0001` hingga `PRD-1000`
- **sku**: `SKU0000000001` hingga `SKU0000001000`
- **product_name**: Kombinasi nama produk + brand + variant
- **purchase_price**: Harga beli berdasarkan kategori
- **selling_price**: Markup 20-40% dari harga beli
- **stock**: Random 10-500 unit
- **min_stock**: Random 5-50 unit
- **weight**: Berat dalam gram berdasarkan kategori
- **barcode**: `899` + 10 digit nomor urut
- **shelf_location**: Format A-F + row 1-10 + column 01-20
- **is_active**: 95% active (5% discontinued)
- **show_in_store**: 90% shown (10% hidden)

## Transaksi Stock Inbound

### Confirmed Transactions (Status: confirmed)

1. **INB/2025/001** (WH001 - Jakarta)
   - Supplier: SUP001
   - Items: 2 (Laptop + Monitor)
   - Total Qty: 30 units
   - Total Amount: Rp 170,000,000

2. **INB/2025/002** (WH001 - Jakarta)
   - Supplier: SUP001
   - Items: 1 (Keyboard)
   - Total Qty: 50 units
   - Total Amount: Rp 22,500,000

3. **INB/2025/003** (WH002 - Surabaya)
   - Supplier: SUP002
   - Items: 3 (Mouse + Webcam + Headset)
   - Total Qty: 70 units
   - Total Amount: Rp 99,500,000

4. **INB/2025/004** (WH003 - Medan)
   - Supplier: SUP003
   - Items: 2 (Router + Switch)
   - Total Qty: 52 units
   - Total Amount: Rp 40,400,000

5. **INB/2025/005** (WH001 - Jakarta)
   - Supplier: SUP003
   - Items: 2 (UPS + Kabel)
   - Total Qty: 13 units
   - Total Amount: Rp 29,900,000

### Draft Transactions (Status: draft)

6. **INB/2025/006** (WH002 - Surabaya)
   - Supplier: SUP001
   - Items: 2 (Laptop + Monitor)
   - Total Qty: 15 units
   - Total Amount: Rp 75,000,000
   - Notes: Belum dikonfirmasi

7. **INB/2025/007** (WH001 - Jakarta)
   - Supplier: SUP002
   - Items: 1 (Webcam)
   - Total Qty: 10 units
   - Total Amount: Rp 15,000,000
   - Notes: Menunggu approval

## Teknik Generate Data

### Recursive CTE

MySQL 8.0+ mendukung recursive CTE yang digunakan untuk generate 1000 produk:

```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 1000
)
SELECT ... FROM numbers;
```

### Dynamic Product Names

Menggunakan kombinasi function:
- `ELT()` - Pilih element dari list
- `CONCAT()` - Gabungkan string
- `MOD` - Modulo untuk cycling
- `CASE` - Conditional logic

### Price Calculation

```sql
-- Purchase price varies by category
CASE cat_idx
    WHEN 0 THEN (500000 + (n * 1000) MOD 9500000)
    WHEN 1 THEN (50000 + (n * 100) MOD 450000)
    ...
END

-- Selling price with markup 20-40%
(purchase_price * (1.2 + (n MOD 21) * 0.01))
```

## Verifikasi Data

Setelah load seed data, verifikasi dengan query berikut:

```sql
-- Total records per table
SELECT
    'category' AS table_name,
    COUNT(*) AS total_records
FROM category
UNION ALL
SELECT 'supplier', COUNT(*) FROM supplier
UNION ALL
SELECT 'warehouse', COUNT(*) FROM warehouse
UNION ALL
SELECT 'item_product', COUNT(*) FROM item_product
UNION ALL
SELECT 'stock_inbound', COUNT(*) FROM stock_inbound
UNION ALL
SELECT 'stock_inbound_item', COUNT(*) FROM stock_inbound_item;
```

Expected result:
```
category                6
supplier                3
warehouse               3
item_product         1000
stock_inbound           7
stock_inbound_item     13
```

### Verifikasi Product Distribution

```sql
SELECT
    c.category_name,
    COUNT(ip.item_product_id) AS total_products,
    MIN(ip.purchase_price) AS min_price,
    MAX(ip.purchase_price) AS max_price,
    AVG(ip.stock) AS avg_stock
FROM category c
LEFT JOIN item_product ip ON c.category_id = ip.category_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_code;
```

### Verifikasi Transactions

```sql
-- Summary by status
SELECT
    status,
    COUNT(*) AS total_transactions,
    SUM(total_items) AS total_items,
    SUM(total_qty) AS total_qty,
    SUM(total_amount) AS total_amount
FROM stock_inbound
GROUP BY status;
```

## Reset Data

Untuk hapus semua data dan load ulang:

```sql
-- Disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

-- Truncate tables
TRUNCATE TABLE stock_inbound_item;
TRUNCATE TABLE stock_inbound;
TRUNCATE TABLE item_product;
TRUNCATE TABLE warehouse;
TRUNCATE TABLE supplier;
TRUNCATE TABLE category;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Load seed data again
SOURCE /path/to/mini-inventory-seed.sql;
```

## Customization

### Menambah Jumlah Produk

Edit query recursive CTE, ubah batas dari 1000 ke jumlah yang diinginkan:

```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 5000  -- Ubah dari 1000 ke 5000
)
```

### Menambah Transaksi

Copy-paste template transaksi dan sesuaikan:

```sql
INSERT INTO stock_inbound (...) VALUES (...);
INSERT INTO stock_inbound_item (...) VALUES (...);
```

### Custom Brand atau Product Names

Edit array di dalam function `ELT()`:

```sql
ELT(brand_idx + 1,
    'Brand1', 'Brand2', 'Brand3', ...
)
```

## Performance Notes

- Insert 1000 produk menggunakan single CTE query (~1-3 detik)
- Lebih cepat dibanding 1000x single INSERT
- Memory usage optimal karena streaming execution

## Troubleshooting

### Error: Recursive CTE not supported

MySQL version < 8.0 tidak support recursive CTE. Solusi:
1. Upgrade ke MySQL 8.0+
2. Atau gunakan alternative seed dengan stored procedure
3. Atau load data dari CSV file

### Error: Foreign key constraint fails

Pastikan schema sudah di-load terlebih dahulu sebelum seed data:

```bash
# Correct order
mysql < schemas/mysql/mini-inventory.sql
mysql < seeds/mysql/mini-inventory-seed.sql
```

### Performance lambat

Untuk large dataset, consider:
- Disable indexes sementara: `ALTER TABLE ... DISABLE KEYS;`
- Batch insert dengan transaction
- Adjust `max_allowed_packet` untuk large queries

## Referensi (Reference)

- [MySQL Recursive CTE](https://dev.mysql.com/doc/refman/8.0/en/with.html)
- [MySQL ELT Function](https://dev.mysql.com/doc/refman/8.0/en/string-functions.html#function_elt)
- [MySQL LOAD DATA](https://dev.mysql.com/doc/refman/8.0/en/load-data.html)

## Lisensi (License)

Sample data ini dibuat untuk keperluan pembelajaran dan development. Silakan digunakan dan dimodifikasi sesuai kebutuhan.
