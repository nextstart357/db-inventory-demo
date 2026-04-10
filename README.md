# Mini Inventory Database

## Ikhtisar (Overview)

Schema database inventory sederhana dengan pola Master-Detail untuk mengelola produk, gudang, supplier, customer, dan transaksi stock (inbound & outbound). Repository ini mendukung tiga platform database: **MySQL 8.0+**, **PostgreSQL**, dan **Oracle 12c+**.

Tujuan repository ini:

- **Starter kit** untuk project inventory management
- **Referensi implementasi (reference implementation)** dari database design dengan pola Master-Detail
- **Dukungan multi-database (multi-database support)** — demonstrasi portabilitas SQL di berbagai platform

## Fitur Utama (Key Features)

- Dukungan tiga platform database (MySQL, PostgreSQL, Oracle)
- Pola Master-Detail dengan referential integrity (foreign key constraints)
- UUID-based primary key di semua tabel
- Seed data generator untuk testing dan development
- Batch script (Windows) untuk inisialisasi schema dan seed data
- Python script untuk flexible seed generation (PostgreSQL)
- CHECK constraint untuk validasi data di level database
- Index strategy untuk optimasi query

## Struktur Direktori (Directory Structure)

```
database/
├── schemas/                          # Definisi schema database
│   ├── mysql/
│   │   ├── mini-inventory.sql        # Schema lengkap (tabel, trigger, index)
│   │   └── schema-init.bat           # Batch script inisialisasi database + schema
│   ├── postgres/
│   │   ├── mini-inventory.sql        # Schema lengkap PostgreSQL
│   │   └── schema-init.bat           # Batch script inisialisasi database + schema
│   └── oracle/
│       ├── mini-inventory.sql        # Schema lengkap Oracle
│       └── schema-init.bat           # Batch script inisialisasi schema
│
├── seeds/                            # Sample data untuk testing & development
│   ├── mysql/
│   │   ├── mini-inventory-seed.sql   # Seed data (recursive CTE, 1000 produk)
│   │   └── seed-init.bat             # Batch script load seed data
│   ├── postgres/
│   │   ├── mini-inventory-seed.sql   # Seed data dasar
│   │   ├── seed-inbound.py           # Generator transaksi inbound (Python)
│   │   ├── seed-outbound.py          # Generator transaksi outbound (Python)
│   │   ├── clear-inbound.py          # Utility hapus data inbound
│   │   ├── clear-outbound.py         # Utility hapus data outbound
│   │   ├── seed-init.bat             # Batch script load seed data
│   │   └── .env                      # Konfigurasi koneksi database
│   └── oracle/
│       ├── mini-inventory-seed.sql   # Seed data Oracle (PL/SQL block)
│       └── seed-init.bat             # Batch script load seed data
│
└── README.md                         # Dokumentasi ini
```

## Struktur Database (Database Schema)

### Master Tables

| Tabel | Deskripsi | Field Utama |
|-------|-----------|-------------|
| `supplier` | Master data supplier/vendor | supplier_code, supplier_name, contact_person, city, amount_payable |
| `customer` | Master data customer/buyer | customer_code, customer_name, contact_person, city, amount_receivable |
| `warehouse` | Master data gudang | warehouse_code, warehouse_name, warehouse_type, city, capacity |
| `category` | Master data kategori produk | category_code, category_name, description |
| `item_product` | Master data produk/item | product_code, sku, product_name, category_id (FK), purchase_price, selling_price, stock |

### Transaction Tables

| Tabel | Deskripsi | Field Utama |
|-------|-----------|-------------|
| `stock_inbound` | Header transaksi penerimaan barang | inbound_number, inbound_date, warehouse_id (FK), supplier_id (FK), status |
| `stock_inbound_item` | Detail item transaksi inbound | stock_inbound_id (FK), line_number, item_product_id (FK), qty_received, unit_price |
| `stock_outbound` | Header transaksi pengiriman barang | outbound_number, outbound_date, warehouse_id (FK), customer_id (FK), status |
| `stock_outbound_item` | Detail item transaksi outbound | stock_outbound_id (FK), line_number, item_product_id (FK), qty_shipped, unit_price |

### Tabel Tambahan (Additional Table)

| Tabel | Deskripsi | Field Utama |
|-------|-----------|-------------|
| `stock_beginning_balance` | Saldo awal stock per item per gudang per periode | item_product_id (FK), warehouse_id (FK), period_date, qty_beginning |

## Diagram Relasi (Entity Relationship)

```
                    ┌──────────────┐
                    │   category   │
                    └──────┬───────┘
                           │ 1
                           │
                           │ N
┌──────────────┐    ┌──────┴───────┐    ┌──────────────────────┐
│   supplier   │    │ item_product │    │ stock_beginning_     │
└──────┬───────┘    └──┬───────┬───┘    │ balance              │
       │ 1             │ N     │ N      └──────────────────────┘
       │               │       │               ▲ N       ▲ N
       │ N             │       │               │         │
┌──────┴───────┐  ┌────┴──────┐│        ┌──────┴──┐      │
│stock_inbound │  │  stock_   ││        │warehouse│      │
│              │  │  inbound_ ││        └──┬──┬───┘      │
└──────────────┘  │  item     ││           │  │          │
       ▲ 1        └───────────┘│           │  │          │
       │                       │        1  │  │ 1        │
       └───── FK ──────────────┘     ┌─────┘  └─────┐    │
                                     │ N          N  │    │
                               ┌─────┴──────┐ ┌─────┴────┴──┐
┌──────────────┐               │stock_      │ │stock_       │
│   customer   ├── FK ────────>│inbound     │ │outbound     │
└──────────────┘               └─────┬──────┘ └─────┬───────┘
                                  1  │           1   │
                                     │ N             │ N
                               ┌─────┴──────┐ ┌─────┴───────┐
                               │stock_      │ │stock_       │
                               │inbound_    │ │outbound_    │
                               │item        │ │item         │
                               └────────────┘ └─────────────┘
```

**Keterangan relasi:**

- `item_product` → `category`: RESTRICT (kategori tidak dapat dihapus jika masih ada produk)
- `stock_inbound` → `warehouse`: RESTRICT
- `stock_inbound` → `supplier`: SET NULL (supplier dihapus, referensi menjadi NULL)
- `stock_inbound_item` → `stock_inbound`: CASCADE (hapus header = hapus detail)
- `stock_inbound_item` → `item_product`: RESTRICT
- `stock_outbound` → `warehouse`: RESTRICT
- `stock_outbound` → `customer`: SET NULL
- `stock_outbound_item` → `stock_outbound`: CASCADE
- `stock_outbound_item` → `item_product`: RESTRICT

## Persyaratan (Requirements)

| Platform | Versi Minimum | Fitur yang Dibutuhkan |
|----------|---------------|----------------------|
| MySQL | 8.0.16+ | CHECK constraint, recursive CTE, trigger |
| PostgreSQL | 9.4+ | Extension `uuid-ossp` |
| Oracle | 12c+ | `SYS_GUID()`, PL/SQL |

Untuk seed data PostgreSQL berbasis Python:

- Python 3.x
- Library `psycopg2` (PostgreSQL adapter)
- Library `python-dotenv` (konfigurasi environment)

## Panduan Cepat (Quick Start)

### MySQL

```bash
# 1. Inisialisasi database + schema (cek, create/drop database, jalankan schema)
schemas/mysql/schema-init.bat

# 2. Load seed data
seeds/mysql/seed-init.bat
```

### PostgreSQL

```bash
# 1. Inisialisasi database + schema (cek, create/drop database, jalankan schema)
schemas/postgres/schema-init.bat

# 2. Load seed data
psql -U postgres -d dbinv -f seeds/postgres/mini-inventory-seed.sql
```

Untuk generate transaksi menggunakan Python:

```bash
cd seeds/postgres

# Generate transaksi inbound (contoh: 50 transaksi untuk Januari 2025)
python seed-inbound.py --periode=2025-01 --samples=50

# Generate transaksi outbound
python seed-outbound.py --periode=2025-01 --samples=50
```

### Oracle

```bash
# 1. Jalankan schema (melalui SQL*Plus)
sqlplus username/password@service @schemas/oracle/mini-inventory.sql

# 2. Load seed data
sqlplus username/password@service @seeds/oracle/mini-inventory-seed.sql
```

## Seed Data

Seed data menyediakan sample data untuk testing dan development:

Teknik generate data per platform:

- **MySQL**: Recursive CTE untuk bulk insert 1000 produk dalam satu query
- **PostgreSQL**: Python script dengan UUID deterministic (`uuid5`) untuk reproducible data
- **Oracle**: PL/SQL block untuk bulk product generation

## Perbandingan Platform (Platform Comparison)

| Fitur | MySQL 8.0 | PostgreSQL | Oracle 12c+ |
|-------|-----------|------------|-------------|
| UUID generation | Trigger `BEFORE INSERT` + `UUID()` | `DEFAULT uuid_generate_v4()::VARCHAR` | `DEFAULT SYS_GUID()` |
| Auto-update timestamp | `ON UPDATE CURRENT_TIMESTAMP` | Trigger required | Trigger required |
| Column comments | Inline `COMMENT` | `COMMENT ON TABLE/COLUMN` | `COMMENT ON TABLE/COLUMN` |
| Bulk data generation | Recursive CTE | Python script / `generate_series()` | PL/SQL block |
| Character encoding | UTF8MB4 | UTF-8 (default) | AL32UTF8 |
| Seed data format | Pure SQL | SQL + Python | Pure SQL (PL/SQL) |

## Lisensi (License)

Database schema dan seed data ini dibuat untuk keperluan pembelajaran dan development. Dapat digunakan dan dimodifikasi sesuai kebutuhan.
