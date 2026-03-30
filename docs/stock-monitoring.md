# Stock Monitoring Endpoints
> **Project**: Mini Inventory Control  
> **Database**: PostgreSQL  
> **Schema Version**: 1.4  
> **Created**: 2026-02-23  
> **Tables Used**: `item_product`, `category`, `warehouse`, `supplier`, `customer`, `stock_inbound`, `stock_inbound_item`, `stock_outbound`, `stock_outbound_item`, `stock_beginning_balance`  
> **View Used**: `v_stock_mutation_all` — menyediakan kolom `qty_akhir` sebagai nilai stok aktual per item per gudang

---

## Formula Stok Aktual per Gudang

```
qty_akhir = qty_awal + qty_masuk - qty_keluar
```

Dihitung secara otomatis oleh view **`v_stock_mutation_all`**:
- `qty_awal` → saldo awal terbaru dari `stock_beginning_balance`
- `qty_masuk` → total `qty_received` dari `stock_inbound_item` (status `confirmed`/`closed`)
- `qty_keluar` → total `qty_shipped` dari `stock_outbound_item` (status `confirmed`/`closed`)

> ⚠️ Seluruh endpoint yang memerlukan jumlah stok aktual **menggunakan** `v_stock_mutation_all` bukan query manual.

---

## Grup 1 — Stock Summary (Ringkasan Stok)

---

### Endpoint 1 — GET /api/stock/summary

**Deskripsi**: Total keseluruhan stok aktif dari seluruh produk (`item_product.stock`), dilengkapi ringkasan nilai dan jumlah item.

#### SQL Query

```sql
-- Menggunakan v_stock_mutation_all untuk qty_akhir yang sudah dihitung otomatis
SELECT
    COUNT(DISTINCT v.item_product_id)               AS total_products,
    SUM(v.qty_akhir)                                AS total_stock_qty,
    SUM(v.qty_akhir * ip.purchase_price)            AS total_stock_value_purchase,
    SUM(v.qty_akhir * ip.selling_price)             AS total_stock_value_selling,
    MIN(v.qty_akhir)                                AS min_stock_qty,
    MAX(v.qty_akhir)                                AS max_stock_qty,
    ROUND(AVG(v.qty_akhir), 2)                      AS avg_stock_qty
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id;
```

#### Data Simulasi

| field | value |
|-------|------:|
| total_products | 570 |
| total_stock_qty | 172.290 |
| total_stock_value_purchase (Rp) | 27.840.000.000 |
| total_stock_value_selling (Rp) | 34.512.000.000 |
| min_stock_qty | 0 |
| max_stock_qty | 500 |
| avg_stock_qty | 302,26 |

**Keterangan kolom:**
- `total_products` — jumlah item produk aktif yang tercatat di view
- `total_stock_qty` — total kuantitas stok dari semua item (`SUM(qty_akhir)` dari view)
- `total_stock_value_purchase` — nilai modal seluruh stok = `SUM(qty_akhir × purchase_price)`, mencerminkan berapa biaya yang sudah dikeluarkan untuk stok yang ada
- `total_stock_value_selling` — potensi total pendapatan jika **seluruh** stok berhasil dijual = `SUM(qty_akhir × selling_price)`
- `min_stock_qty` — nilai `qty_akhir` paling kecil dari semua item (bisa 0 jika ada item yang stoknya habis)
- `max_stock_qty` — nilai `qty_akhir` terbesar dari semua item
- `avg_stock_qty` — rata-rata kuantitas stok per item di seluruh sistem

---

### Endpoint 2 — GET /api/stock/summary-by-category

**Deskripsi**: Total stok dikelompokkan per kategori produk.

#### SQL Query

```sql
-- Menggunakan v_stock_mutation_all; qty_akhir = stok aktual per item per gudang
SELECT
    c.category_code,
    c.category_name,
    COUNT(DISTINCT v.item_product_id)                       AS total_products,
    SUM(v.qty_akhir)                                        AS total_stock_qty,
    SUM(v.qty_akhir * ip.purchase_price)                    AS total_value_purchase,
    SUM(v.qty_akhir * ip.selling_price)                     AS total_value_selling,
    COUNT(DISTINCT v.item_product_id)
        FILTER (WHERE v.qty_akhir <= ip.min_stock)          AS low_stock_count
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id
JOIN category c ON c.category_id = ip.category_id
GROUP BY c.category_id, c.category_code, c.category_name
ORDER BY total_stock_qty DESC;
```

#### Data Simulasi

| category_code | category_name | total_products | total_stock_qty | total_value_purchase (Rp) | low_stock_count |
|---------------|---------------|---------------:|----------------:|--------------------------:|----------------:|
| CAT001 | Elektronik | 100 | 29.150 | 14.500.000.000 | 8 |
| CAT005 | Rumah Tangga | 100 | 29.300 | 4.100.000.000 | 7 |
| CAT004 | Kesehatan | 100 | 28.820 | 1.850.000.000 | 9 |
| CAT006 | Olahraga | 100 | 28.640 | 3.750.000.000 | 6 |
| CAT002 | Fashion | 100 | 28.470 | 3.200.000.000 | 10 |
| CAT003 | Makanan | 100 | 27.910 | 520.000.000 | 7 |

**Keterangan kolom:**
- `total_products` — jumlah item aktif yang masuk ke dalam kategori ini
- `total_stock_qty` — total kuantitas stok seluruh item dalam kategori (`SUM(qty_akhir)`)
- `total_value_purchase` — nilai modal stok kategori ini = `SUM(qty_akhir × purchase_price)`. Contoh: Elektronik Rp 14,5 miliar artinya modal yang tertanam dalam stok elektronik saat ini
- `low_stock_count` — jumlah item dalam kategori ini yang stoknya di bawah atau sama dengan `min_stock` (perlu segera di-restock)

---

### Endpoint 3 — GET /api/stock/summary-by-warehouse

**Deskripsi**: Total stok per gudang — diambil langsung dari kolom `qty_akhir` di `v_stock_mutation_all` yang sudah dihitung otomatis.

#### SQL Query

```sql
-- qty_akhir sudah mencakup: qty_awal + qty_masuk - qty_keluar
SELECT
    v.warehouse_code,
    w.warehouse_name,
    w.warehouse_type,
    w.city,
    SUM(v.qty_awal)     AS total_beginning,
    SUM(v.qty_masuk)    AS total_inbound,
    SUM(v.qty_keluar)   AS total_outbound,
    SUM(v.qty_akhir)    AS stock_current
FROM v_stock_mutation_all v
JOIN warehouse w ON w.warehouse_id = v.warehouse_id
GROUP BY v.warehouse_id, v.warehouse_code, w.warehouse_name, w.warehouse_type, w.city
ORDER BY stock_current DESC;
```

#### Data Simulasi

| warehouse_code | warehouse_name | warehouse_type | city | total_beginning | total_inbound | total_outbound | stock_current |
|----------------|----------------|----------------|------|----------------:|--------------:|---------------:|--------------:|
| WH001 | Gudang Pusat Jakarta | main | Jakarta | 0 | 93 | 26 | **67** |
| WH003 | Gudang Konsinyasi Medan | consignment | Medan | 0 | 52 | 25 | **27** |
| WH002 | Gudang Transit Surabaya | transit | Surabaya | 0 | 70 | 45 | **25** |

**Keterangan kolom:**
- `total_beginning` — saldo awal stok (`qty_awal`) yang dimasukkan via `stock_beginning_balance`, sebagai titik awal perhitungan
- `total_inbound` — total kuantitas barang yang masuk ke gudang ini dari transaksi `confirmed`/`closed`
- `total_outbound` — total kuantitas barang yang keluar dari gudang ini dari transaksi `confirmed`/`closed`
- `stock_current` — stok aktual saat ini = `qty_awal + total_inbound - total_outbound`. Diambil langsung dari `SUM(qty_akhir)` view

---

## Grup 2 — Low Stock & Alert

---

### Endpoint 4 — GET /api/stock/low-stock

**Deskripsi**: Daftar semua item yang stoknya sama dengan atau di bawah nilai `min_stock`.

**Query Parameter Opsional**: `?category_id=`, `?warehouse_code=`

#### SQL Query

```sql
-- qty_akhir dari view adalah stok aktual; dibandingkan dengan min_stock dari item_product
SELECT
    v.product_code,
    ip.sku,
    v.product_name,
    c.category_name,
    ip.brand,
    v.qty_akhir                         AS stock_current,
    ip.min_stock,
    (ip.min_stock - v.qty_akhir)        AS shortage,
    ip.uom,
    ip.shelf_location,
    v.warehouse_code
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id
JOIN category c ON c.category_id = ip.category_id
WHERE v.qty_akhir <= ip.min_stock
ORDER BY shortage DESC, v.product_code ASC;
```

#### Data Simulasi

| product_code | product_name | category_name | stock_current | min_stock | shortage | uom | shelf_location |
|--------------|-------------|---------------|:-------------:|:---------:|:--------:|-----|----------------|
| PRD-0021 | Smartphone Samsung Series 1 | Elektronik | 8 | 15 | **7** | pcs | A4-01 |
| PRD-0105 | Vitamin C Blackmores 100mg | Kesehatan | 5 | 10 | **5** | pcs | D1-01 |
| PRD-0063 | Kaos Polos Uniqlo Premium | Fashion | 6 | 9 | **3** | pcs | B1-02 |
| PRD-0081 | Madu Murni ABC Original | Makanan | 3 | 5 | **2** | pcs | C3-01 |
| PRD-0189 | Matras Yoga Decathlon Pro | Olahraga | 10 | 11 | **1** | pcs | F3-01 |

**Keterangan kolom:**
- `stock_current` — stok aktual saat ini dari `qty_akhir` di view (bukan dari kolom `stock` di tabel `item_product`)
- `min_stock` — batas minimum stok yang ditetapkan di master item. Jika `stock_current` menyentuh angka ini, item wajib di-restock
- `shortage` — selisih kekurangan = `min_stock - stock_current`. Semakin besar angkanya, semakin mendesak kebutuhan restocknya
- `shelf_location` — lokasi fisik item di rak gudang (contoh: `A4-01` = Baris A, Rak 4, Posisi 01). Berguna untuk tim gudang yang akan melakukan pengecekan langsung

---

### Endpoint 5 — GET /api/stock/out-of-stock

**Deskripsi**: Daftar item yang stoknya **nol** (habis).

#### SQL Query

```sql
-- qty_akhir = 0 berarti stok habis di gudang tersebut
SELECT
    v.product_code,
    ip.sku,
    v.product_name,
    c.category_name,
    ip.brand,
    ip.uom,
    ip.shelf_location,
    v.warehouse_code,
    ip.updated_at       AS last_updated
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id
JOIN category c ON c.category_id = ip.category_id
WHERE v.qty_akhir = 0
ORDER BY v.product_code ASC;
```

#### Data Simulasi

| product_code | product_name | category_name | brand | uom | shelf_location | last_updated |
|--------------|-------------|---------------|-------|-----|----------------|--------------|
| PRD-0120 | Earbuds TWS Sony Series 1 | Elektronik | Sony | pcs | A1-03 | 2025-12-10 |
| PRD-0360 | Sepatu Running Nike Lite | Olahraga | Nike | pcs | F1-01 | 2025-12-08 |

**Keterangan kolom:**
- `shelf_location` — lokasi rak fisik item di gudang, digunakan oleh tim gudang untuk pengecekan di lapangan
- `last_updated` — waktu terakhir data master item diperbarui (`updated_at` dari tabel `item_product`). Berguna untuk mengetahui kapan terakhir kali stok item ini berubah
- ⚠️ Satu item bisa muncul **beberapa baris** jika tersebar di beberapa gudang dan `qty_akhir = 0` di masing-masing gudang tersebut

---

### Endpoint 6 — GET /api/stock/low-stock-by-category

**Deskripsi**: Total item low-stock dikelompokkan per kategori (cocok untuk tampilan widget dashboard).

#### SQL Query

```sql
-- Menggunakan qty_akhir dari view untuk menentukan status stok setiap item
SELECT
    c.category_code,
    c.category_name,
    COUNT(DISTINCT v.item_product_id)
        FILTER (WHERE v.qty_akhir = 0)                          AS out_of_stock_count,
    COUNT(DISTINCT v.item_product_id)
        FILTER (WHERE v.qty_akhir > 0
                  AND v.qty_akhir <= ip.min_stock)              AS low_stock_count,
    COUNT(DISTINCT v.item_product_id)
        FILTER (WHERE v.qty_akhir > ip.min_stock)              AS normal_stock_count,
    COUNT(DISTINCT v.item_product_id)                           AS total_products
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id
JOIN category c ON c.category_id = ip.category_id
GROUP BY c.category_id, c.category_code, c.category_name
ORDER BY low_stock_count DESC;
```

#### Data Simulasi

| category_code | category_name | out_of_stock | low_stock | normal_stock | total_products |
|---------------|---------------|:------------:|:---------:|:------------:|:--------------:|
| CAT002 | Fashion | 1 | 10 | 89 | 100 |
| CAT004 | Kesehatan | 0 | 9 | 91 | 100 |
| CAT001 | Elektronik | 1 | 8 | 91 | 100 |
| CAT003 | Makanan | 0 | 7 | 93 | 100 |
| CAT005 | Rumah Tangga | 0 | 7 | 93 | 100 |
| CAT006 | Olahraga | 1 | 6 | 93 | 100 |

**Keterangan kolom:**
- `out_of_stock` — jumlah item dalam kategori dengan `qty_akhir = 0` (stok benar-benar habis)
- `low_stock` — jumlah item dengan `0 < qty_akhir <= min_stock` (stok ada tapi di bawah ambang batas minimum, butuh perhatian)
- `normal_stock` — jumlah item dengan `qty_akhir > min_stock` (stok aman)
- `total_products` — total item aktif dalam kategori (`out_of_stock + low_stock + normal_stock`). Kolom ini untuk memudahkan perhitungan persentase alert per kategori

---

### Endpoint 7 — GET /api/stock/low-stock-count

**Deskripsi**: Hanya mengembalikan angka total low-stock (untuk badge notifikasi/header counter).

#### SQL Query

```sql
-- Agregasi qty_akhir dari view, per item_product_id (SUM antar gudang jika multi-gudang)
SELECT
    COUNT(DISTINCT v.item_product_id)
        FILTER (WHERE v.qty_akhir = 0)                          AS out_of_stock_count,
    COUNT(DISTINCT v.item_product_id)
        FILTER (WHERE v.qty_akhir > 0
                  AND v.qty_akhir <= ip.min_stock)              AS low_stock_count,
    COUNT(DISTINCT v.item_product_id)
        FILTER (WHERE v.qty_akhir > ip.min_stock)              AS normal_count,
    COUNT(DISTINCT v.item_product_id)                           AS total_active_products
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id;
```

#### Data Simulasi

| out_of_stock_count | low_stock_count | normal_count | total_active_products |
|-------------------:|----------------:|-------------:|----------------------:|
| 2 | 47 | 521 | 570 |

**Keterangan kolom:**
- `out_of_stock_count` — total item yang `qty_akhir = 0` di seluruh gudang. Digunakan untuk badge merah 🔴 di header/menu
- `low_stock_count` — total item yang hampir habis (`0 < qty_akhir <= min_stock`). Digunakan untuk badge kuning 🟡
- `normal_count` — total item yang stoknya aman (`qty_akhir > min_stock`)
- `total_active_products` — total keseluruhan item aktif = `out_of_stock + low_stock + normal_count`

---

## Grup 3 — Stock Movement (Mutasi Stok)

---

### Endpoint 8 — GET /api/stock/movement?item_product_id={id}

**Deskripsi**: Histori mutasi keluar-masuk untuk satu item produk tertentu, diurutkan dari terbaru.

#### SQL Query

```sql
-- Inbound movement for a specific item
SELECT
    si.inbound_date       AS tanggal,
    'IN'                  AS tipe,
    si.inbound_number     AS nomor_dokumen,
    sup.supplier_name     AS pihak,
    w.warehouse_name      AS gudang,
    sii.qty_received      AS qty,
    sii.unit_price,
    sii.total_amount,
    si.status,
    sii.notes
FROM stock_inbound_item sii
JOIN stock_inbound si ON si.stock_inbound_id = sii.stock_inbound_id
JOIN warehouse w ON w.warehouse_id = si.warehouse_id
LEFT JOIN supplier sup ON sup.supplier_id = si.supplier_id
WHERE sii.item_product_id = :item_product_id

UNION ALL

-- Outbound movement for a specific item
SELECT
    so.outbound_date      AS tanggal,
    'OUT'                 AS tipe,
    so.outbound_number    AS nomor_dokumen,
    cust.customer_name    AS pihak,
    w.warehouse_name      AS gudang,
    soi.qty_shipped       AS qty,
    soi.unit_price,
    soi.total_amount,
    so.status,
    soi.notes
FROM stock_outbound_item soi
JOIN stock_outbound so ON so.stock_outbound_id = soi.stock_outbound_id
JOIN warehouse w ON w.warehouse_id = so.warehouse_id
LEFT JOIN customer cust ON cust.customer_id = so.customer_id
WHERE soi.item_product_id = :item_product_id

ORDER BY tanggal ASC, nomor_dokumen ASC;
```

#### Data Simulasi (item: PRD-0001 — Smartphone Samsung Series 1)

| tanggal | tipe | nomor_dokumen | pihak | gudang | qty | unit_price (Rp) | status |
|---------|------|---------------|-------|--------|----:|----------------:|--------|
| 2025-12-01 | **IN** | INB/2025/001 | PT Supplier Utama | Gudang Pusat Jakarta | +10 | 12.000.000 | confirmed |
| 2025-12-03 | **OUT** | OUT/2025/001 | PT Pelanggan Setia | Gudang Pusat Jakarta | -5 | 15.000.000 | confirmed |
| 2025-12-10 | OUT | OUT/2025/006 | PT Pelanggan Setia | Gudang Transit Surabaya | -2 | 15.000.000 | **draft** |

**Keterangan kolom:**
- `tipe` — arah mutasi stok: `IN` = barang masuk (inbound), `OUT` = barang keluar (outbound)
- `nomor_dokumen` — nomor referensi dokumen transaksi (`INB/...` untuk inbound, `OUT/...` untuk outbound)
- `pihak` — nama supplier jika tipe `IN`, atau nama customer jika tipe `OUT`
- `qty` — jumlah unit yang bergerak. Nilai positif untuk masuk, negatif untuk keluar
- `unit_price` — harga satuan pada transaksi tersebut (bisa berbeda dari `purchase_price`/`selling_price` di master item)
- `status` — status dokumen: `confirmed` = sudah berpengaruh ke stok aktual; `draft` = belum dikonfirmasi, belum mempengaruhi stok

---

### Endpoint 9 — GET /api/stock/movement?date_from={}&date_to={}

**Deskripsi**: Semua mutasi stok (inbound + outbound) dalam rentang tanggal tertentu, untuk semua produk.

#### SQL Query

```sql
SELECT
    movement_date,
    tipe,
    nomor_dokumen,
    product_code,
    product_name,
    category_name,
    gudang,
    qty,
    unit_price,
    total_amount,
    status
FROM (
    SELECT
        si.inbound_date          AS movement_date,
        'IN'                     AS tipe,
        si.inbound_number        AS nomor_dokumen,
        ip.product_code,
        ip.product_name,
        c.category_name,
        w.warehouse_name         AS gudang,
        sii.qty_received         AS qty,
        sii.unit_price,
        sii.total_amount,
        si.status
    FROM stock_inbound_item sii
    JOIN stock_inbound si ON si.stock_inbound_id = sii.stock_inbound_id
    JOIN item_product ip ON ip.item_product_id = sii.item_product_id
    JOIN category c ON c.category_id = ip.category_id
    JOIN warehouse w ON w.warehouse_id = si.warehouse_id
    WHERE si.inbound_date BETWEEN :date_from AND :date_to

    UNION ALL

    SELECT
        so.outbound_date         AS movement_date,
        'OUT'                    AS tipe,
        so.outbound_number       AS nomor_dokumen,
        ip.product_code,
        ip.product_name,
        c.category_name,
        w.warehouse_name         AS gudang,
        soi.qty_shipped          AS qty,
        soi.unit_price,
        soi.total_amount,
        so.status
    FROM stock_outbound_item soi
    JOIN stock_outbound so ON so.stock_outbound_id = soi.stock_outbound_id
    JOIN item_product ip ON ip.item_product_id = soi.item_product_id
    JOIN category c ON c.category_id = ip.category_id
    JOIN warehouse w ON w.warehouse_id = so.warehouse_id
    WHERE so.outbound_date BETWEEN :date_from AND :date_to
) combined
ORDER BY movement_date ASC, nomor_dokumen ASC;
```

#### Data Simulasi (`date_from=2025-12-01`, `date_to=2025-12-05`)

| tanggal | tipe | nomor_dokumen | product_code | product_name | gudang | qty | status |
|---------|------|---------------|--------------|-------------|--------|----:|--------|
| 2025-12-01 | IN | INB/2025/001 | PRD-0001 | Smartphone Samsung | Gudang Pusat Jakarta | +10 | confirmed |
| 2025-12-01 | IN | INB/2025/001 | PRD-0007 | Monitor LED Dell | Gudang Pusat Jakarta | +20 | confirmed |
| 2025-12-02 | IN | INB/2025/002 | PRD-0013 | Keyboard Mechanical | Gudang Pusat Jakarta | +50 | confirmed |
| 2025-12-03 | OUT | OUT/2025/001 | PRD-0001 | Smartphone Samsung | Gudang Pusat Jakarta | -5 | confirmed |
| 2025-12-03 | OUT | OUT/2025/001 | PRD-0019 | Mouse Wireless | Gudang Pusat Jakarta | -10 | confirmed |
| 2025-12-04 | OUT | OUT/2025/002 | PRD-0007 | Monitor LED Dell | Gudang Pusat Jakarta | -8 | confirmed |
| 2025-12-05 | IN | INB/2025/003 | PRD-0019 | Mouse Wireless | Gudang Transit Surabaya | +30 | confirmed |

**Keterangan kolom:**
- `tipe` — `IN` (barang masuk) atau `OUT` (barang keluar)
- `nomor_dokumen` — nomor dokumen sumber transaksi
- `qty` — kuantitas yang bergerak; satu item bisa muncul di dua baris berbeda jika masuk di satu gudang dan keluar di gudang lain
- `status` — hanya transaksi `confirmed` yang mempengaruhi `qty_akhir` di view

---

### Endpoint 10 — GET /api/stock/inbound-summary

**Deskripsi**: Ringkasan total transaksi inbound (barang masuk), dikelompokkan per status atau per bulan.

**Query Parameter Opsional**: `?group_by=status` atau `?group_by=month`

#### SQL Query (group by status)

```sql
SELECT
    si.status,
    COUNT(DISTINCT si.stock_inbound_id)     AS total_transactions,
    SUM(si.total_items)                     AS total_items,
    SUM(si.total_qty)                       AS total_qty,
    SUM(si.total_amount)                    AS total_amount,
    MIN(si.inbound_date)                    AS earliest_date,
    MAX(si.inbound_date)                    AS latest_date
FROM stock_inbound si
GROUP BY si.status
ORDER BY si.status;
```

#### Data Simulasi

| status | total_transactions | total_items | total_qty | total_amount (Rp) |
|--------|-------------------:|------------:|----------:|-----------------:|
| confirmed | 5 | 10 | 215 | 361.900.000 |
| draft | 2 | 3 | 25 | 90.000.000 |

**Keterangan kolom:**
- `total_transactions` — jumlah dokumen inbound (header) per status
- `total_items` — total baris item dari semua dokumen (misal 2 dokumen masing-masing berisi 5 item = 10)
- `total_qty` — total unit barang yang diterima dari seluruh dokumen berstatus tersebut
- `total_amount` — total nilai Rupiah dari seluruh transaksi inbound berstatus tersebut. Status `draft` belum mempengaruhi stok aktual

---

### Endpoint 11 — GET /api/stock/outbound-summary

**Deskripsi**: Ringkasan total transaksi outbound (barang keluar), dikelompokkan per status atau per bulan.

#### SQL Query (group by status)

```sql
SELECT
    so.status,
    COUNT(DISTINCT so.stock_outbound_id)    AS total_transactions,
    SUM(so.total_items)                     AS total_items,
    SUM(so.total_qty)                       AS total_qty,
    SUM(so.total_amount)                    AS total_amount,
    MIN(so.outbound_date)                   AS earliest_date,
    MAX(so.outbound_date)                   AS latest_date
FROM stock_outbound so
GROUP BY so.status
ORDER BY so.status;
```

#### Data Simulasi

| status | total_transactions | total_items | total_qty | total_amount (Rp) |
|--------|-------------------:|------------:|----------:|-----------------:|
| confirmed | 5 | 10 | 111 | 328.400.000 |
| draft | 2 | 3 | 34 | 63.600.000 |

**Keterangan kolom:**
- `total_transactions` — jumlah dokumen outbound (header) per status
- `total_items` — total baris item dari semua dokumen outbound
- `total_qty` — total unit barang yang dikirim keluar dari gudang berstatus tersebut
- `total_amount` — total nilai penjualan dari seluruh transaksi outbound. Status `confirmed` berarti barang sudah benar-benar keluar dari stok

---

## Grup 4 — Stock per Gudang (Warehouse View)

---

### Endpoint 12 — GET /api/stock/by-warehouse?warehouse_id={id}

**Deskripsi**: Daftar item beserta kuantitas stok aktual di gudang tertentu.

#### SQL Query

```sql
-- Filter berdasarkan warehouse_code dari v_stock_mutation_all
-- qty_akhir sudah mencerminkan stok aktual di gudang tersebut
SELECT
    v.product_code,
    ip.sku,
    v.product_name,
    c.category_name,
    ip.brand,
    ip.uom,
    ip.shelf_location,
    v.qty_awal      AS qty_beginning,
    v.qty_masuk     AS total_inbound,
    v.qty_keluar    AS total_outbound,
    v.qty_akhir     AS stock_current
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id
JOIN category c ON c.category_id = ip.category_id
WHERE v.warehouse_code = :warehouse_code
  AND (v.qty_awal > 0 OR v.qty_masuk > 0 OR v.qty_keluar > 0)
ORDER BY v.qty_akhir DESC;
```

#### Data Simulasi (warehouse: WH001 — Gudang Pusat Jakarta)

| product_code | product_name | category | uom | qty_beginning | total_inbound | total_outbound | stock_current |
|--------------|-------------|----------|-----|:-------------:|:-------------:|:--------------:|:-------------:|
| PRD-0013 | Keyboard Mechanical | Elektronik | pcs | 0 | 50 | 0 | **50** |
| PRD-0055 | Kabel USB-C Anker | Elektronik | box | 0 | 5 | 5 | **0** |
| PRD-0049 | Power Bank Vivo | Elektronik | pcs | 0 | 8 | 3 | **5** |
| PRD-0007 | Monitor LED Dell | Elektronik | pcs | 0 | 20 | 8 | **12** |
| PRD-0001 | Smartphone Samsung | Elektronik | pcs | 0 | 10 | 5 | **5** |
| PRD-0019 | Mouse Wireless Asus | Elektronik | pcs | 0 | 0 | 10 | **-10** |

**Keterangan kolom:**
- `qty_beginning` — saldo awal stok item di gudang ini (`qty_awal` dari view). Nilai 0 berarti tidak ada saldo awal yang diinput untuk periode ini
- `total_inbound` — total kuantitas yang masuk ke gudang ini (dari transaksi `confirmed`/`closed`)
- `total_outbound` — total kuantitas yang keluar dari gudang ini (dari transaksi `confirmed`/`closed`)
- `stock_current` — stok aktual = `qty_beginning + total_inbound - total_outbound`. Nilai **−10** pada PRD-0019 menandakan data tidak konsisten: ada transaksi keluar lebih besar dari yang pernah masuk (perlu investigasi atau input saldo awal)

---

### Endpoint 13 — GET /api/stock/warehouse-capacity

**Deskripsi**: Perbandingan kapasitas gudang vs jumlah transaksi yang terjadi, untuk memonitor utilitas gudang.

#### SQL Query

```sql
SELECT
    w.warehouse_code,
    w.warehouse_name,
    w.warehouse_type,
    w.city,
    w.capacity,
    COUNT(DISTINCT si.stock_inbound_id)     AS total_inbound_tx,
    COUNT(DISTINCT so.stock_outbound_id)    AS total_outbound_tx,
    COALESCE(SUM(si.total_qty), 0)          AS total_qty_in,
    COALESCE(SUM(so.total_qty), 0)          AS total_qty_out
FROM warehouse w
LEFT JOIN stock_inbound si
    ON si.warehouse_id = w.warehouse_id AND si.status = 'confirmed'
LEFT JOIN stock_outbound so
    ON so.warehouse_id = w.warehouse_id AND so.status = 'confirmed'
WHERE w.is_active = TRUE
GROUP BY w.warehouse_id, w.warehouse_code, w.warehouse_name,
         w.warehouse_type, w.city, w.capacity
ORDER BY w.warehouse_code;
```

#### Data Simulasi

| warehouse_code | warehouse_name | type | capacity (m²) | total_inbound_tx | total_outbound_tx | total_qty_in | total_qty_out |
|----------------|----------------|------|:-------------:|:----------------:|:-----------------:|:------------:|:-------------:|
| WH001 | Gudang Pusat Jakarta | main | 1.000 | 3 | 3 | 93 | 26 |
| WH002 | Gudang Transit Surabaya | transit | 500 | 1 | 1 | 70 | 45 |
| WH003 | Gudang Konsinyasi Medan | consignment | 300 | 1 | 1 | 52 | 25 |

**Keterangan kolom:**
- `capacity` — kapasitas maksimum gudang dalam m². Data dari kolom `warehouse.capacity`
- `total_inbound_tx` — jumlah dokumen inbound `confirmed` yang masuk ke gudang ini (bukan jumlah item-nya)
- `total_outbound_tx` — jumlah dokumen outbound `confirmed` yang keluar dari gudang ini
- `total_qty_in` — total unit barang yang masuk ke gudang ini (akumulasi dari semua transaksi confirmed)
- `total_qty_out` — total unit barang yang keluar dari gudang ini. Selisih `total_qty_in - total_qty_out` menggambarkan pergerakan neto gudang

---

### Endpoint 14 — GET /api/stock/balance-history?warehouse_id={id}&period={YYYY-MM}

**Deskripsi**: Histori saldo awal stok per item di gudang tertentu untuk periode tertentu.

#### SQL Query

```sql
SELECT
    sbb.period_date,
    w.warehouse_code,
    w.warehouse_name,
    ip.product_code,
    ip.product_name,
    c.category_name,
    ip.uom,
    sbb.qty_beginning,
    sbb.notes,
    sbb.created_at,
    sbb.created_by
FROM stock_beginning_balance sbb
JOIN warehouse w ON w.warehouse_id = sbb.warehouse_id
JOIN item_product ip ON ip.item_product_id = sbb.item_product_id
JOIN category c ON c.category_id = ip.category_id
WHERE sbb.warehouse_id = :warehouse_id
  AND TO_CHAR(sbb.period_date, 'YYYY-MM') = :period
ORDER BY ip.product_code ASC;
```

#### Data Simulasi (WH001, period: 2026-01)

| period_date | warehouse | product_code | product_name | uom | qty_beginning | notes |
|-------------|-----------|--------------|-------------|-----|:-------------:|-------|
| 2026-01-01 | Gudang Pusat Jakarta | PRD-0001 | Smartphone Samsung | pcs | 8 | Saldo awal Januari 2026 |
| 2026-01-01 | Gudang Pusat Jakarta | PRD-0007 | Monitor LED Dell | pcs | 22 | Saldo awal Januari 2026 |
| 2026-01-01 | Gudang Pusat Jakarta | PRD-0013 | Keyboard Mechanical | pcs | 50 | Saldo awal Januari 2026 |

**Keterangan kolom:**
- `period_date` — tanggal efektif saldo awal, biasanya diisi di awal bulan atau awal tahun sebagai titik nol perhitungan mutasi
- `qty_beginning` — jumlah stok item di gudang tersebut pada awal periode. Nilai ini digunakan sebagai `qty_awal` di view `v_stock_mutation_all`
- `notes` — keterangan bebas, umumnya berisi penjelasan periode (dari mana angka saldo awal ini berasal)

---

## Grup 5 — Stock Valuation (Nilai Stok)

---

### Endpoint 15 — GET /api/stock/valuation

**Deskripsi**: Nilai total stok seluruh produk aktif berdasarkan harga beli dan harga jual.

#### SQL Query

```sql
-- Menggunakan qty_akhir dari view sebagai jumlah stok yang dipakai untuk valuasi
SELECT
    v.product_code,
    v.product_name,
    c.category_name,
    ip.brand,
    SUM(v.qty_akhir)                                                        AS stock_qty,
    ip.uom,
    ip.purchase_price,
    ip.selling_price,
    SUM(v.qty_akhir) * ip.purchase_price                                    AS value_at_purchase,
    SUM(v.qty_akhir) * ip.selling_price                                     AS value_at_selling,
    (SUM(v.qty_akhir) * ip.selling_price)
        - (SUM(v.qty_akhir) * ip.purchase_price)                            AS potential_profit
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id
JOIN category c ON c.category_id = ip.category_id
GROUP BY v.item_product_id, v.product_code, v.product_name,
         c.category_name, ip.brand, ip.uom, ip.purchase_price, ip.selling_price
HAVING SUM(v.qty_akhir) > 0
ORDER BY value_at_purchase DESC;
```

#### Data Simulasi (5 teratas)

| product_code | product_name | category | stock | purchase_price (Rp) | selling_price (Rp) | value_at_purchase (Rp) | potential_profit (Rp) |
|--------------|-------------|----------|------:|--------------------:|-------------------:|------------------------:|----------------------:|
| PRD-0001 | Smartphone Samsung | Elektronik | 155 | 9.500.000 | 11.875.000 | 1.472.500.000 | 368.125.000 |
| PRD-0043 | Monitor LED DJI | Elektronik | 122 | 8.500.000 | 10.540.000 | 1.037.000.000 | 249.480.000 |
| PRD-0007 | Laptop Apple | Elektronik | 88 | 10.500.000 | 12.705.000 | 924.000.000 | 194.040.000 |
| PRD-0013 | AC Portable Sharp | Rumah Tangga | 204 | 1.900.000 | 2.280.000 | 387.600.000 | 77.520.000 |
| PRD-0019 | Dumbbell Set Bowflex | Olahraga | 176 | 1.500.000 | 1.875.000 | 264.000.000 | 66.000.000 |

**Keterangan kolom:**
- `purchase_price` — harga beli per unit dari supplier (dari master `item_product`), merepresentasikan modal per unit
- `selling_price` — harga jual per unit ke customer, sudah termasuk margin keuntungan
- `value_at_purchase` — nilai modal stok item ini = `stock_qty × purchase_price`. Contoh: 155 unit × Rp 9.500.000 = Rp 1,47 miliar modal yang tertanam
- `value_at_selling` — potensi total pendapatan jika seluruh stok item ini berhasil terjual = `stock_qty × selling_price`
- `potential_profit` — selisih keuntungan kotor potensial = `value_at_selling - value_at_purchase`. Belum memperhitungkan biaya operasional

---

### Endpoint 16 — GET /api/stock/valuation-by-category

**Deskripsi**: Nilai stok dikelompokkan per kategori (aggregat harga beli & jual).

#### SQL Query

```sql
-- qty_akhir dari view dipakai untuk menghitung nilai stok per kategori
SELECT
    c.category_code,
    c.category_name,
    COUNT(DISTINCT v.item_product_id)                                   AS total_products,
    SUM(v.qty_akhir)                                                    AS total_qty,
    SUM(v.qty_akhir * ip.purchase_price)                                AS total_value_purchase,
    SUM(v.qty_akhir * ip.selling_price)                                 AS total_value_selling,
    SUM(v.qty_akhir * ip.selling_price)
        - SUM(v.qty_akhir * ip.purchase_price)                          AS total_potential_profit,
    ROUND(
        AVG(ip.selling_price - ip.purchase_price)
        / NULLIF(AVG(ip.purchase_price), 0) * 100
    , 2)                                                                AS avg_margin_pct
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id
JOIN category c ON c.category_id = ip.category_id
GROUP BY c.category_id, c.category_code, c.category_name
HAVING SUM(v.qty_akhir) > 0
ORDER BY total_value_purchase DESC;
```

#### Data Simulasi

| category_code | category_name | total_products | total_qty | value_purchase (Rp) | value_selling (Rp) | margin (%) |
|---------------|---------------|---------------:|----------:|--------------------:|-------------------:|-----------:|
| CAT001 | Elektronik | 98 | 29.002 | 14.500.000.000 | 17.690.000.000 | 22,00% |
| CAT005 | Rumah Tangga | 99 | 29.300 | 4.100.000.000 | 4.961.000.000 | 21,00% |
| CAT006 | Olahraga | 98 | 28.500 | 3.750.000.000 | 4.687.500.000 | 25,00% |
| CAT002 | Fashion | 97 | 28.200 | 3.200.000.000 | 4.000.000.000 | 25,00% |
| CAT004 | Kesehatan | 99 | 28.820 | 1.850.000.000 | 2.313.000.000 | 25,00% |
| CAT003 | Makanan | 99 | 27.800 | 520.000.000 | 676.000.000 | 30,00% |

**Keterangan kolom:**
- `total_qty` — total kuantitas stok aktual seluruh item dalam kategori (`SUM(qty_akhir)`)
- `value_purchase` — total nilai modal stok kategori ini = `SUM(qty_akhir × purchase_price)`. Elektronik mendominasi dengan Rp 14,5 miliar
- `value_selling` — total potensi pendapatan jika seluruh stok kategori ini terjual = `SUM(qty_akhir × selling_price)`
- `margin (%)` — rata-rata margin keuntungan per kategori = `(selling_price - purchase_price) / purchase_price × 100`. Makanan memiliki margin tertinggi (30%) meski nilai stoknya paling kecil

---

### Endpoint 17 — GET /api/stock/top-value-items?limit=10

**Deskripsi**: Top N item dengan nilai stok tertinggi berdasarkan harga beli.

**Query Parameter**: `?limit=10` (default), `?sort_by=purchase` atau `?sort_by=selling`

#### SQL Query

```sql
-- qty_akhir dari view dipakai sebagai qty untuk ranking nilai stok
SELECT
    ROW_NUMBER() OVER (
        ORDER BY SUM(v.qty_akhir) * ip.purchase_price DESC
    )                                                   AS rank,
    v.product_code,
    ip.sku,
    v.product_name,
    c.category_name,
    ip.brand,
    SUM(v.qty_akhir)                                    AS stock_qty,
    ip.uom,
    ip.purchase_price,
    ip.selling_price,
    SUM(v.qty_akhir) * ip.purchase_price                AS value_at_purchase,
    SUM(v.qty_akhir) * ip.selling_price                 AS value_at_selling
FROM v_stock_mutation_all v
JOIN item_product ip ON ip.item_product_id = v.item_product_id
JOIN category c ON c.category_id = ip.category_id
GROUP BY v.item_product_id, v.product_code, v.product_name,
         c.category_name, ip.sku, ip.brand, ip.uom, ip.purchase_price, ip.selling_price
HAVING SUM(v.qty_akhir) > 0
ORDER BY value_at_purchase DESC
LIMIT :limit;
```

#### Data Simulasi (top 5)

| rank | product_code | product_name | category | stock | purchase_price (Rp) | value_at_purchase (Rp) |
|-----:|--------------|-------------|----------|------:|--------------------:|----------------------:|
| 1 | PRD-0001 | Smartphone Samsung Series 1 | Elektronik | 155 | 9.500.000 | 1.472.500.000 |
| 2 | PRD-0043 | Monitor LED DJI Elite | Elektronik | 122 | 8.500.000 | 1.037.000.000 |
| 3 | PRD-0007 | Laptop Apple Series 1 | Elektronik | 88 | 10.500.000 | 924.000.000 |
| 4 | PRD-0013 | AC Portable Sharp Pro | Rumah Tangga | 204 | 1.900.000 | 387.600.000 |
| 5 | PRD-0019 | Dumbbell Set Bowflex Ultra | Olahraga | 176 | 1.500.000 | 264.000.000 |

**Keterangan kolom:**
- `rank` — urutan peringkat berdasarkan nilai stok terbesar (`value_at_purchase` DESC). Item rank #1 adalah yang paling banyak modal tertanamnya
- `stock` — total stok aktual item ini (`SUM(qty_akhir)` dari view, agregat semua gudang)
- `purchase_price` — harga beli per unit dari master item
- `value_at_purchase` — nilai modal tertanam = `stock × purchase_price`. Digunakan sebagai dasar prioritas pengawasan stok karena mewakili risiko finansial tertinggi

---

## Grup 6 — Dashboard KPI

---

### Endpoint 18 — GET /api/stock/kpi

**Deskripsi**: Kumpulan angka KPI utama untuk ditampilkan di widget/card dashboard. Satu endpoint yang mengembalikan semua metrik sekaligus.

#### SQL Query

```sql
-- Bagian stock quantity & alert menggunakan v_stock_mutation_all
-- Bagian transaksi tetap dari tabel langsung
SELECT
    -- Product metrics (dari view)
    (SELECT COUNT(DISTINCT item_product_id) FROM v_stock_mutation_all)
        AS total_active_products,
    (SELECT COUNT(DISTINCT v.item_product_id)
     FROM v_stock_mutation_all v
     JOIN item_product ip ON ip.item_product_id = v.item_product_id
     WHERE v.qty_akhir = 0)
        AS out_of_stock_count,
    (SELECT COUNT(DISTINCT v.item_product_id)
     FROM v_stock_mutation_all v
     JOIN item_product ip ON ip.item_product_id = v.item_product_id
     WHERE v.qty_akhir > 0 AND v.qty_akhir <= ip.min_stock)
        AS low_stock_count,

    -- Stock quantity & value (dari view)
    (SELECT COALESCE(SUM(v.qty_akhir), 0)
     FROM v_stock_mutation_all v)
        AS total_stock_qty,
    (SELECT COALESCE(SUM(v.qty_akhir * ip.purchase_price), 0)
     FROM v_stock_mutation_all v
     JOIN item_product ip ON ip.item_product_id = v.item_product_id)
        AS total_stock_value_purchase,
    (SELECT COALESCE(SUM(v.qty_akhir * ip.selling_price), 0)
     FROM v_stock_mutation_all v
     JOIN item_product ip ON ip.item_product_id = v.item_product_id)
        AS total_stock_value_selling,

    -- Transaction pending (dari tabel langsung)
    (SELECT COUNT(*) FROM stock_inbound WHERE status = 'draft')
        AS pending_inbound,
    (SELECT COUNT(*) FROM stock_outbound WHERE status = 'draft')
        AS pending_outbound,

    -- Transaction confirmed (today)
    (SELECT COUNT(*) FROM stock_inbound WHERE status = 'confirmed' AND inbound_date = CURRENT_DATE)
        AS inbound_today,
    (SELECT COUNT(*) FROM stock_outbound WHERE status = 'confirmed' AND outbound_date = CURRENT_DATE)
        AS outbound_today;
```

#### Data Simulasi

| kpi_key | label | value | unit |
|---------|-------|------:|------|
| total_active_products | Total Produk Aktif | 570 | item |
| out_of_stock_count | Stok Habis | 2 | item |
| low_stock_count | Stok Rendah | 47 | item |
| total_stock_qty | Total Kuantitas Stok | 172.290 | pcs |
| total_stock_value_purchase | Nilai Stok (Harga Beli) | 27.840.000.000 | Rp |
| total_stock_value_selling | Nilai Stok (Harga Jual) | 34.512.000.000 | Rp |
| pending_inbound | Inbound Belum Konfirmasi | 2 | transaksi |
| pending_outbound | Outbound Belum Konfirmasi | 2 | transaksi |
| inbound_today | Inbound Dikonfirmasi Hari Ini | 0 | transaksi |
| outbound_today | Outbound Dikonfirmasi Hari Ini | 0 | transaksi |

**Keterangan kolom:**
- `total_active_products` — jumlah item produk yang terdaftar di view (aktif dan memiliki data stok)
- `out_of_stock_count` — item dengan `qty_akhir = 0`. Cocok untuk badge merah di navbar/dashboard
- `low_stock_count` — item hampir habis stok (`0 < qty_akhir <= min_stock`). Cocok untuk badge kuning/peringatan
- `total_stock_qty` — total semua unit stok yang ada di seluruh gudang saat ini
- `total_stock_value_purchase` — total modal yang tertanam dalam stok = `SUM(qty_akhir × purchase_price)`. Berguna untuk laporan keuangan dan asuransi
- `total_stock_value_selling` — total potensi pendapatan jika semua stok berhasil dijual. Selisih dengan `value_purchase` adalah potensi keuntungan kotor total
- `pending_inbound` — transaksi inbound masih `draft`, belum dikonfirmasi manajer. Stok belum bertambah
- `pending_outbound` — transaksi outbound masih `draft`, belum dikonfirmasi. Stok belum berkurang
- `inbound_today` / `outbound_today` — aktivitas transaksi yang terjadi hari ini (berguna untuk live monitoring)

---

### Endpoint 19 — GET /api/stock/trend?period=monthly&year=2025

**Deskripsi**: Tren pergerakan stok (inbound vs outbound) per bulan, untuk ditampilkan sebagai grafik garis/batang.

#### SQL Query

```sql
SELECT
    periode,
    COALESCE(SUM(total_in), 0)      AS total_inbound_qty,
    COALESCE(SUM(total_out), 0)     AS total_outbound_qty,
    COALESCE(SUM(amount_in), 0)     AS total_inbound_amount,
    COALESCE(SUM(amount_out), 0)    AS total_outbound_amount
FROM (
    SELECT
        TO_CHAR(si.inbound_date, 'YYYY-MM') AS periode,
        SUM(si.total_qty)                    AS total_in,
        0                                    AS total_out,
        SUM(si.total_amount)                 AS amount_in,
        0                                    AS amount_out
    FROM stock_inbound si
    WHERE si.status = 'confirmed'
      AND EXTRACT(YEAR FROM si.inbound_date) = :year
    GROUP BY TO_CHAR(si.inbound_date, 'YYYY-MM')

    UNION ALL

    SELECT
        TO_CHAR(so.outbound_date, 'YYYY-MM') AS periode,
        0                                     AS total_in,
        SUM(so.total_qty)                     AS total_out,
        0                                     AS amount_in,
        SUM(so.total_amount)                  AS amount_out
    FROM stock_outbound so
    WHERE so.status = 'confirmed'
      AND EXTRACT(YEAR FROM so.outbound_date) = :year
    GROUP BY TO_CHAR(so.outbound_date, 'YYYY-MM')
) combined
GROUP BY periode
ORDER BY periode ASC;
```

#### Data Simulasi (year=2025, status=confirmed)

| periode | total_inbound_qty | total_outbound_qty | total_inbound_amount (Rp) | total_outbound_amount (Rp) | net_flow |
|---------|------------------:|-------------------:|---------------------------:|---------------------------:|--------:|
| 2025-12 | 215 | 111 | 361.900.000 | 328.400.000 | **+104** |

**Keterangan kolom:**
- `periode` — bulan dalam format `YYYY-MM`. Setiap baris mewakili satu bulan aktivitas transaksi
- `total_inbound_qty` — total unit barang yang **masuk** ke gudang dalam bulan tersebut (status `confirmed`)
- `total_outbound_qty` — total unit barang yang **keluar** dari gudang dalam bulan tersebut (status `confirmed`)
- `total_inbound_amount` — total nilai pembelian/penerimaan barang bulan tersebut (Rupiah)
- `total_outbound_amount` — total nilai penjualan/pengiriman barang bulan tersebut (Rupiah)
- `net_flow` — selisih bersih = `total_inbound_qty - total_outbound_qty`. Nilai **positif** berarti stok bertambah, nilai negatif berarti stok berkurang di bulan tersebut

---

### Endpoint 20 — GET /api/stock/activity-log?limit=10

**Deskripsi**: 10 (atau N) transaksi stok terbaru dari inbound dan outbound, diurutkan dari yang terbaru. Cocok untuk feed aktivitas di dashboard.

#### SQL Query

```sql
SELECT
    activity_date,
    tipe,
    nomor_dokumen,
    pihak,
    w.warehouse_name    AS gudang,
    total_items,
    total_qty,
    total_amount,
    status,
    created_by,
    created_at
FROM (
    SELECT
        si.inbound_date     AS activity_date,
        'INBOUND'           AS tipe,
        si.inbound_number   AS nomor_dokumen,
        sup.supplier_name   AS pihak,
        si.warehouse_id,
        si.total_items,
        si.total_qty,
        si.total_amount,
        si.status,
        si.created_by,
        si.created_at
    FROM stock_inbound si
    LEFT JOIN supplier sup ON sup.supplier_id = si.supplier_id

    UNION ALL

    SELECT
        so.outbound_date    AS activity_date,
        'OUTBOUND'          AS tipe,
        so.outbound_number  AS nomor_dokumen,
        cust.customer_name  AS pihak,
        so.warehouse_id,
        so.total_items,
        so.total_qty,
        so.total_amount,
        so.status,
        so.created_by,
        so.created_at
    FROM stock_outbound so
    LEFT JOIN customer cust ON cust.customer_id = so.customer_id
) all_activity
JOIN warehouse w ON w.warehouse_id = all_activity.warehouse_id
ORDER BY activity_date DESC, created_at DESC
LIMIT :limit;
```

#### Data Simulasi (limit=10, order: newest first)

| activity_date | tipe | nomor_dokumen | pihak | gudang | total_items | total_qty | total_amount (Rp) | status |
|---------------|------|---------------|-------|--------|:-----------:|:---------:|-----------------:|--------|
| 2025-12-13 | OUTBOUND | OUT/2025/007 | CV Toko Makmur | Gudang Pusat Jakarta | 1 | 12 | 21.600.000 | **draft** |
| 2025-12-12 | INBOUND | INB/2025/007 | CV Mitra Sejahtera | Gudang Pusat Jakarta | 1 | 10 | 15.000.000 | **draft** |
| 2025-12-11 | OUTBOUND | OUT/2025/006 | PT Pelanggan Setia | Gudang Transit Surabaya | 2 | 22 | 42.000.000 | **draft** |
| 2025-12-10 | INBOUND | INB/2025/006 | PT Supplier Utama | Gudang Transit Surabaya | 2 | 15 | 75.000.000 | **draft** |
| 2025-12-10 | OUTBOUND | OUT/2025/005 | PT Retail Nusantara | Gudang Pusat Jakarta | 2 | 18 | 25.400.000 | confirmed |
| 2025-12-09 | INBOUND | INB/2025/005 | PT Global Teknologi | Gudang Pusat Jakarta | 2 | 13 | 29.900.000 | confirmed |
| 2025-12-08 | OUTBOUND | OUT/2025/004 | PT Retail Nusantara | Gudang Konsinyasi Medan | 2 | 25 | 31.500.000 | confirmed |
| 2025-12-08 | INBOUND | INB/2025/004 | PT Global Teknologi | Gudang Konsinyasi Medan | 2 | 52 | 40.400.000 | confirmed |
| 2025-12-06 | OUTBOUND | OUT/2025/003 | CV Toko Makmur | Gudang Transit Surabaya | 3 | 45 | 56.500.000 | confirmed |
| 2025-12-05 | INBOUND | INB/2025/003 | CV Mitra Sejahtera | Gudang Transit Surabaya | 3 | 70 | 99.500.000 | confirmed |

**Keterangan kolom:**
- `tipe` — `INBOUND` = barang masuk dari supplier, `OUTBOUND` = barang keluar ke customer
- `pihak` — nama supplier (untuk INBOUND) atau nama customer (untuk OUTBOUND). Sumber data dari tabel `supplier` atau `customer`
- `total_items` — jumlah baris item berbeda dalam satu dokumen transaksi (contoh: 3 = dokumen berisi 3 jenis produk)
- `total_qty` — total kuantitas unit seluruh item dalam dokumen tersebut
- `total_amount` — total nilai Rupiah dokumen tersebut (purchase amount untuk inbound, selling amount untuk outbound)
- `status` — `confirmed` berarti transaksi sudah sah dan mempengaruhi stok aktual; `draft` berarti masih menunggu konfirmasi dan **belum** mempengaruhi stok

---

## Ringkasan Seluruh Endpoint

| # | Endpoint | Method | Grup |
|---|----------|--------|------|
| 1 | `/api/stock/summary` | GET | Stock Summary |
| 2 | `/api/stock/summary-by-category` | GET | Stock Summary |
| 3 | `/api/stock/summary-by-warehouse` | GET | Stock Summary |
| 4 | `/api/stock/low-stock` | GET | Low Stock Alert |
| 5 | `/api/stock/out-of-stock` | GET | Low Stock Alert |
| 6 | `/api/stock/low-stock-by-category` | GET | Low Stock Alert |
| 7 | `/api/stock/low-stock-count` | GET | Low Stock Alert |
| 8 | `/api/stock/movement?item_product_id=` | GET | Stock Movement |
| 9 | `/api/stock/movement?date_from=&date_to=` | GET | Stock Movement |
| 10 | `/api/stock/inbound-summary` | GET | Stock Movement |
| 11 | `/api/stock/outbound-summary` | GET | Stock Movement |
| 12 | `/api/stock/by-warehouse?warehouse_id=` | GET | Warehouse View |
| 13 | `/api/stock/warehouse-capacity` | GET | Warehouse View |
| 14 | `/api/stock/balance-history` | GET | Warehouse View |
| 15 | `/api/stock/valuation` | GET | Stock Valuation |
| 16 | `/api/stock/valuation-by-category` | GET | Stock Valuation |
| 17 | `/api/stock/top-value-items?limit=10` | GET | Stock Valuation |
| 18 | `/api/stock/kpi` | GET | Dashboard KPI |
| 19 | `/api/stock/trend?period=monthly` | GET | Dashboard KPI |
| 20 | `/api/stock/activity-log?limit=10` | GET | Dashboard KPI |
