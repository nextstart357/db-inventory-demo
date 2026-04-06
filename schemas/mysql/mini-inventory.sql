-- ============================================================================
-- MINI INVENTORY DATABASE SCHEMA (MySQL 8.0+)
-- ============================================================================
-- Version: 1.4
-- Created: 2025-12-10
-- Updated: 2026-02-22
-- Description: Simple inventory database schema with item, warehouse,
--              supplier, customer, stock inbound, stock outbound,
--              and stock beginning balance tables (Master-Detail structure)
-- Database: dbinv
-- Naming Convention: Following database-naming-convention-v3.md
-- MySQL Version: 8.0+
-- ============================================================================
-- Note: Jalankan create-database.sql terlebih dahulu sebelum script ini
-- ============================================================================

-- Drop tables if exists (in reverse order of dependencies)
DROP TABLE IF EXISTS stock_beginning_balance;
DROP TABLE IF EXISTS stock_outbound_item;
DROP TABLE IF EXISTS stock_outbound;
DROP TABLE IF EXISTS stock_inbound_item;
DROP TABLE IF EXISTS stock_inbound;
DROP TABLE IF EXISTS item_product;
DROP TABLE IF EXISTS warehouse;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS category;

-- ============================================================================
-- MASTER TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: supplier
-- Description: Master data supplier/vendor
-- ----------------------------------------------------------------------------
CREATE TABLE supplier (
    supplier_id         VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for supplier',
    supplier_code       VARCHAR(20) NOT NULL COMMENT 'Unique supplier code',
    supplier_name       VARCHAR(255) NOT NULL COMMENT 'Supplier company name',
    contact_person      VARCHAR(100) COMMENT 'Contact person name',
    phone               VARCHAR(20) COMMENT 'Contact phone number',
    email               VARCHAR(100) COMMENT 'Contact email address',
    address             TEXT COMMENT 'Full address',
    city                VARCHAR(100) NOT NULL COMMENT 'City name',
    country             VARCHAR(100) NOT NULL DEFAULT 'INDONESIA' COMMENT 'Country name',
    register_date       DATE COMMENT 'Supplier registration date',
    amount_payable      DECIMAL(15,2) DEFAULT 0 COMMENT 'Outstanding amount payable to supplier',
    is_active           VARCHAR(5) DEFAULT 'true' COMMENT 'Active status flag',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by          VARCHAR(70) COMMENT 'User who created this record',
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by          VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_supplier_code UNIQUE (supplier_code),
    INDEX idx_supplier_code (supplier_code),
    INDEX idx_supplier_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data supplier/vendor';

-- ----------------------------------------------------------------------------
-- Table: customer
-- Description: Master data customer/buyer
-- ----------------------------------------------------------------------------
CREATE TABLE customer (
    customer_id         VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for customer',
    customer_code       VARCHAR(20) NOT NULL COMMENT 'Unique customer code',
    customer_name       VARCHAR(255) NOT NULL COMMENT 'Customer company or individual name',
    contact_person      VARCHAR(100) COMMENT 'Contact person name',
    phone               VARCHAR(20) COMMENT 'Contact phone number',
    email               VARCHAR(100) COMMENT 'Contact email address',
    address             TEXT COMMENT 'Full address',
    city                VARCHAR(100) NOT NULL COMMENT 'City name',
    country             VARCHAR(100) NOT NULL DEFAULT 'INDONESIA' COMMENT 'Country name',
    register_date       DATE COMMENT 'Customer registration date',
    amount_receivable   DECIMAL(15,2) DEFAULT 0 COMMENT 'Outstanding amount receivable from customer',
    is_active           VARCHAR(5) DEFAULT 'true' COMMENT 'Active status flag',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by          VARCHAR(70) COMMENT 'User who created this record',
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by          VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_customer_code UNIQUE (customer_code),
    INDEX idx_customer_code (customer_code),
    INDEX idx_customer_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data customer/buyer';

-- ----------------------------------------------------------------------------
-- Table: warehouse
-- Description: Master data warehouse/location
-- ----------------------------------------------------------------------------
CREATE TABLE warehouse (
    warehouse_id        VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for warehouse',
    warehouse_code      VARCHAR(20) NOT NULL COMMENT 'Unique warehouse code',
    warehouse_name      VARCHAR(255) NOT NULL COMMENT 'Warehouse display name',
    warehouse_type      VARCHAR(50) COMMENT 'Type of warehouse: main, transit, consignment, external',
    address             TEXT COMMENT 'Full address',
    city                VARCHAR(100) COMMENT 'City name',
    capacity            DECIMAL(15,2) COMMENT 'Maximum capacity in cubic meters or square meters',
    is_active           VARCHAR(5) DEFAULT 'true' COMMENT 'Active status flag',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by          VARCHAR(70) COMMENT 'User who created this record',
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by          VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_warehouse_code UNIQUE (warehouse_code),
    CONSTRAINT chk_warehouse_type CHECK (warehouse_type IN ('main', 'transit', 'consignment', 'external')),
    INDEX idx_warehouse_code (warehouse_code),
    INDEX idx_warehouse_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data warehouse/storage location';

-- ----------------------------------------------------------------------------
-- Table: category
-- Description: Master data product category
-- ----------------------------------------------------------------------------
CREATE TABLE category (
    category_id         VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for category',
    category_code       VARCHAR(20) NOT NULL COMMENT 'Unique category code',
    category_name       VARCHAR(100) NOT NULL COMMENT 'Category display name',
    description         VARCHAR(500) COMMENT 'Category description',
    is_active           VARCHAR(5) DEFAULT 'true' COMMENT 'Category active status',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by          VARCHAR(70) COMMENT 'User who created this record',
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by          VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_category_code UNIQUE (category_code),
    INDEX idx_category_code (category_code),
    INDEX idx_category_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data product category';

-- ----------------------------------------------------------------------------
-- Table: item_product
-- Description: Master data item/product
-- ----------------------------------------------------------------------------
CREATE TABLE item_product (
    item_product_id     VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for item product',
    product_code        VARCHAR(20) NOT NULL COMMENT 'Unique product code (e.g., PRD-001)',
    sku                 VARCHAR(20) NOT NULL COMMENT 'Stock Keeping Unit - unique identifier for inventory',
    product_name        VARCHAR(100) NOT NULL COMMENT 'Product display name',
    category_id         VARCHAR(70) NOT NULL COMMENT 'Foreign key to category table',
    brand               VARCHAR(50) COMMENT 'Product brand name',
    description         VARCHAR(500) COMMENT 'Product description',
    purchase_price      DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'Purchase/buy price from supplier',
    selling_price       DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'Selling price to customer',
    stock               DECIMAL(15,3) NOT NULL DEFAULT 0 COMMENT 'Current stock quantity',
    min_stock           DECIMAL(15,3) DEFAULT 10 COMMENT 'Minimum stock threshold for alert',
    uom                 VARCHAR(10) DEFAULT 'pcs' COMMENT 'Unit of measure: pcs, box, kg, liter, meter, pack, set, lusin',
    weight              DECIMAL(10,2) DEFAULT 0 COMMENT 'Product weight in grams',
    is_active           VARCHAR(5) DEFAULT 'true' COMMENT 'Product active status',
    show_in_store       VARCHAR(5) DEFAULT 'true' COMMENT 'Display product in store/catalog',
    barcode             VARCHAR(20) COMMENT 'Product barcode number',
    shelf_location      VARCHAR(20) COMMENT 'Physical shelf location in warehouse (e.g., A1-01)',
    notes               VARCHAR(500) COMMENT 'Internal notes for product',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by          VARCHAR(70) COMMENT 'User who created this record',
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by          VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_item_product_code UNIQUE (product_code),
    CONSTRAINT uq_item_product_sku UNIQUE (sku),
    CONSTRAINT fk_item_product_category FOREIGN KEY (category_id)
        REFERENCES category(category_id) ON DELETE RESTRICT,
    CONSTRAINT chk_item_product_uom CHECK (uom IN ('pcs', 'box', 'kg', 'liter', 'meter', 'pack', 'set', 'lusin')),
    CONSTRAINT chk_item_product_purchase_price CHECK (purchase_price >= 0),
    CONSTRAINT chk_item_product_selling_price CHECK (selling_price >= 0),
    CONSTRAINT chk_item_product_weight CHECK (weight >= 0),
    INDEX idx_item_product_code (product_code),
    INDEX idx_item_product_sku (sku),
    INDEX idx_item_product_category_id (category_id),
    INDEX idx_item_product_is_active (is_active),
    INDEX idx_item_product_barcode (barcode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data item/product';

-- ============================================================================
-- TRANSACTION TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: stock_inbound
-- Description: Stock inbound header - master record for receiving transactions
-- ----------------------------------------------------------------------------
CREATE TABLE stock_inbound (
    stock_inbound_id    VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for inbound transaction',
    inbound_number      VARCHAR(50) NOT NULL COMMENT 'Unique inbound document number',
    inbound_date        DATE NOT NULL DEFAULT (CURRENT_DATE) COMMENT 'Date of receiving',
    warehouse_id        VARCHAR(70) NOT NULL COMMENT 'Destination warehouse for received items',
    supplier_id         VARCHAR(70) COMMENT 'Supplier/vendor reference (optional)',
    reference_number    VARCHAR(50) COMMENT 'External reference (PO number, delivery note, etc)',
    notes               TEXT COMMENT 'Transaction notes',
    total_items         INTEGER DEFAULT 0 COMMENT 'Total number of distinct items',
    total_qty           DECIMAL(15,3) DEFAULT 0 COMMENT 'Total quantity of all items',
    total_amount        DECIMAL(15,2) DEFAULT 0 COMMENT 'Total amount of all items (summary)',
    status              VARCHAR(20) DEFAULT 'draft' COMMENT 'Transaction status: draft, confirmed, closed, cancelled',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by          VARCHAR(70) COMMENT 'User who created this record',
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by          VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_stock_inbound_number UNIQUE (inbound_number),
    CONSTRAINT fk_stock_inbound_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
    CONSTRAINT fk_stock_inbound_supplier FOREIGN KEY (supplier_id)
        REFERENCES supplier(supplier_id) ON DELETE SET NULL,
    CONSTRAINT chk_stock_inbound_status CHECK (status IN ('draft', 'confirmed', 'closed', 'cancelled')),
    INDEX idx_stock_inbound_number (inbound_number),
    INDEX idx_stock_inbound_date (inbound_date),
    INDEX idx_stock_inbound_warehouse_id (warehouse_id),
    INDEX idx_stock_inbound_supplier_id (supplier_id),
    INDEX idx_stock_inbound_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stock inbound header - master record for receiving transactions';

-- ----------------------------------------------------------------------------
-- Table: stock_inbound_item
-- Description: Stock inbound items - list of items received in each transaction
-- ----------------------------------------------------------------------------
CREATE TABLE stock_inbound_item (
    stock_inbound_item_id   VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for inbound item line',
    stock_inbound_id        VARCHAR(70) NOT NULL COMMENT 'Foreign key to stock_inbound',
    line_number             INTEGER NOT NULL COMMENT 'Line sequence number within the transaction',
    item_product_id         VARCHAR(70) NOT NULL COMMENT 'Foreign key to item_product',
    qty_received            DECIMAL(15,3) NOT NULL DEFAULT 0 COMMENT 'Quantity received for this item',
    uom                     VARCHAR(10) DEFAULT 'pcs' COMMENT 'Unit of measure: pcs, box, kg, liter, meter, pack, set, lusin',
    unit_price              DECIMAL(15,2) DEFAULT 0 COMMENT 'Unit price for this item',
    total_amount            DECIMAL(15,2) DEFAULT 0 COMMENT 'Line total amount (qty_received x unit_price), populated by application',
    notes                   TEXT COMMENT 'Line item notes',
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by              VARCHAR(70) COMMENT 'User who created this record',
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by              VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_stock_inbound_item_line UNIQUE (stock_inbound_id, line_number),
    CONSTRAINT fk_stock_inbound_item_header FOREIGN KEY (stock_inbound_id)
        REFERENCES stock_inbound(stock_inbound_id) ON DELETE CASCADE,
    CONSTRAINT fk_stock_inbound_item_product FOREIGN KEY (item_product_id)
        REFERENCES item_product(item_product_id) ON DELETE RESTRICT,
    CONSTRAINT chk_stock_inbound_item_line_number CHECK (line_number > 0),
    CONSTRAINT chk_stock_inbound_item_unit_price CHECK (unit_price >= 0),
    INDEX idx_stock_inbound_item_inbound_id (stock_inbound_id),
    INDEX idx_stock_inbound_item_product_id (item_product_id),
    INDEX idx_stock_inbound_item_inbound_product (stock_inbound_id, item_product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stock inbound items - list of items received in each transaction';

-- ----------------------------------------------------------------------------
-- Table: stock_outbound
-- Description: Stock outbound header - master record for shipping/delivery transactions
-- ----------------------------------------------------------------------------
CREATE TABLE stock_outbound (
    stock_outbound_id   VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for outbound transaction',
    outbound_number     VARCHAR(50) NOT NULL COMMENT 'Unique outbound document number',
    outbound_date       DATE NOT NULL DEFAULT (CURRENT_DATE) COMMENT 'Date of shipping/delivery',
    warehouse_id        VARCHAR(70) NOT NULL COMMENT 'Source warehouse for shipped items',
    customer_id         VARCHAR(70) COMMENT 'Customer/buyer reference (optional)',
    reference_number    VARCHAR(50) COMMENT 'External reference (SO number, delivery order, etc)',
    notes               TEXT COMMENT 'Transaction notes',
    total_items         INTEGER DEFAULT 0 COMMENT 'Total number of distinct items',
    total_qty           DECIMAL(15,3) DEFAULT 0 COMMENT 'Total quantity of all items',
    total_amount        DECIMAL(15,2) DEFAULT 0 COMMENT 'Total amount of all items (summary)',
    status              VARCHAR(20) DEFAULT 'draft' COMMENT 'Transaction status: draft, confirmed, closed, cancelled',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by          VARCHAR(70) COMMENT 'User who created this record',
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by          VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_stock_outbound_number UNIQUE (outbound_number),
    CONSTRAINT fk_stock_outbound_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
    CONSTRAINT fk_stock_outbound_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id) ON DELETE SET NULL,
    CONSTRAINT chk_stock_outbound_status CHECK (status IN ('draft', 'confirmed', 'closed', 'cancelled')),
    INDEX idx_stock_outbound_number (outbound_number),
    INDEX idx_stock_outbound_date (outbound_date),
    INDEX idx_stock_outbound_warehouse_id (warehouse_id),
    INDEX idx_stock_outbound_customer_id (customer_id),
    INDEX idx_stock_outbound_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stock outbound header - master record for shipping/delivery transactions';

-- ----------------------------------------------------------------------------
-- Table: stock_outbound_item
-- Description: Stock outbound items - list of items shipped in each transaction
-- ----------------------------------------------------------------------------
CREATE TABLE stock_outbound_item (
    stock_outbound_item_id  VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier for outbound item line',
    stock_outbound_id       VARCHAR(70) NOT NULL COMMENT 'Foreign key to stock_outbound',
    line_number             INTEGER NOT NULL COMMENT 'Line sequence number within the transaction',
    item_product_id         VARCHAR(70) NOT NULL COMMENT 'Foreign key to item_product',
    qty_shipped             DECIMAL(15,3) NOT NULL DEFAULT 0 COMMENT 'Quantity shipped for this item',
    uom                     VARCHAR(10) DEFAULT 'pcs' COMMENT 'Unit of measure: pcs, box, kg, liter, meter, pack, set, lusin',
    unit_price              DECIMAL(15,2) DEFAULT 0 COMMENT 'Unit price for this item',
    total_amount            DECIMAL(15,2) DEFAULT 0 COMMENT 'Line total amount (qty_shipped x unit_price), populated by application',
    notes                   TEXT COMMENT 'Line item notes',
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by              VARCHAR(70) COMMENT 'User who created this record',
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by              VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_stock_outbound_item_line UNIQUE (stock_outbound_id, line_number),
    CONSTRAINT fk_stock_outbound_item_header FOREIGN KEY (stock_outbound_id)
        REFERENCES stock_outbound(stock_outbound_id) ON DELETE CASCADE,
    CONSTRAINT fk_stock_outbound_item_product FOREIGN KEY (item_product_id)
        REFERENCES item_product(item_product_id) ON DELETE RESTRICT,
    CONSTRAINT chk_stock_outbound_item_line_number CHECK (line_number > 0),
    CONSTRAINT chk_stock_outbound_item_unit_price CHECK (unit_price >= 0),
    INDEX idx_stock_outbound_item_outbound_id (stock_outbound_id),
    INDEX idx_stock_outbound_item_product_id (item_product_id),
    INDEX idx_stock_outbound_item_outbound_product (stock_outbound_id, item_product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stock outbound items - list of items shipped in each transaction';

-- ----------------------------------------------------------------------------
-- Table: stock_beginning_balance
-- Description: Saldo awal stock per item per warehouse per periode
-- ----------------------------------------------------------------------------
CREATE TABLE stock_beginning_balance (
    stock_beginning_balance_id  VARCHAR(70) PRIMARY KEY COMMENT 'Primary key - unique identifier',
    item_product_id             VARCHAR(70) NOT NULL COMMENT 'Foreign key to item_product',
    warehouse_id                VARCHAR(70) NOT NULL COMMENT 'Foreign key to warehouse',
    period_date                 DATE NOT NULL COMMENT 'Tanggal efektif saldo awal (biasanya awal bulan/tahun)',
    qty_beginning               DECIMAL(15,3) NOT NULL DEFAULT 0 COMMENT 'Quantity saldo awal',
    notes                       TEXT COMMENT 'Catatan tambahan',
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    created_by                  VARCHAR(70) COMMENT 'User who created this record',
    updated_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    updated_by                  VARCHAR(70) COMMENT 'User who last updated this record',

    CONSTRAINT uq_stock_beginning_balance UNIQUE (item_product_id, warehouse_id, period_date),
    CONSTRAINT fk_stock_beginning_balance_item FOREIGN KEY (item_product_id)
        REFERENCES item_product(item_product_id) ON DELETE RESTRICT,
    CONSTRAINT fk_stock_beginning_balance_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
    INDEX idx_stock_beginning_balance_item_id (item_product_id),
    INDEX idx_stock_beginning_balance_warehouse_id (warehouse_id),
    INDEX idx_stock_beginning_balance_period (period_date),
    INDEX idx_stock_beginning_balance_item_warehouse (item_product_id, warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Saldo awal stock per item per warehouse per periode';

-- ============================================================================
-- TRIGGERS FOR UUID GENERATION
-- ============================================================================

DELIMITER $$

-- Trigger for supplier
CREATE TRIGGER trg_supplier_before_insert
BEFORE INSERT ON supplier
FOR EACH ROW
BEGIN
    IF NEW.supplier_id IS NULL OR NEW.supplier_id = '' THEN
        SET NEW.supplier_id = UUID();
    END IF;
END$$

-- Trigger for warehouse
CREATE TRIGGER trg_warehouse_before_insert
BEFORE INSERT ON warehouse
FOR EACH ROW
BEGIN
    IF NEW.warehouse_id IS NULL OR NEW.warehouse_id = '' THEN
        SET NEW.warehouse_id = UUID();
    END IF;
END$$

-- Trigger for category
CREATE TRIGGER trg_category_before_insert
BEFORE INSERT ON category
FOR EACH ROW
BEGIN
    IF NEW.category_id IS NULL OR NEW.category_id = '' THEN
        SET NEW.category_id = UUID();
    END IF;
END$$

-- Trigger for item_product
CREATE TRIGGER trg_item_product_before_insert
BEFORE INSERT ON item_product
FOR EACH ROW
BEGIN
    IF NEW.item_product_id IS NULL OR NEW.item_product_id = '' THEN
        SET NEW.item_product_id = UUID();
    END IF;
END$$

-- Trigger for stock_inbound
CREATE TRIGGER trg_stock_inbound_before_insert
BEFORE INSERT ON stock_inbound
FOR EACH ROW
BEGIN
    IF NEW.stock_inbound_id IS NULL OR NEW.stock_inbound_id = '' THEN
        SET NEW.stock_inbound_id = UUID();
    END IF;
END$$

-- Trigger for stock_inbound_item
CREATE TRIGGER trg_stock_inbound_item_before_insert
BEFORE INSERT ON stock_inbound_item
FOR EACH ROW
BEGIN
    IF NEW.stock_inbound_item_id IS NULL OR NEW.stock_inbound_item_id = '' THEN
        SET NEW.stock_inbound_item_id = UUID();
    END IF;
END$$

-- Trigger for customer
CREATE TRIGGER trg_customer_before_insert
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    IF NEW.customer_id IS NULL OR NEW.customer_id = '' THEN
        SET NEW.customer_id = UUID();
    END IF;
END$$

-- Trigger for stock_outbound
CREATE TRIGGER trg_stock_outbound_before_insert
BEFORE INSERT ON stock_outbound
FOR EACH ROW
BEGIN
    IF NEW.stock_outbound_id IS NULL OR NEW.stock_outbound_id = '' THEN
        SET NEW.stock_outbound_id = UUID();
    END IF;
END$$

-- Trigger for stock_outbound_item
CREATE TRIGGER trg_stock_outbound_item_before_insert
BEFORE INSERT ON stock_outbound_item
FOR EACH ROW
BEGIN
    IF NEW.stock_outbound_item_id IS NULL OR NEW.stock_outbound_item_id = '' THEN
        SET NEW.stock_outbound_item_id = UUID();
    END IF;
END$$

-- Trigger for stock_beginning_balance
CREATE TRIGGER trg_stock_beginning_balance_before_insert
BEFORE INSERT ON stock_beginning_balance
FOR EACH ROW
BEGIN
    IF NEW.stock_beginning_balance_id IS NULL OR NEW.stock_beginning_balance_id = '' THEN
        SET NEW.stock_beginning_balance_id = UUID();
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
