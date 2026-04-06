-- ============================================================================
-- MINI INVENTORY DATABASE SCHEMA
-- ============================================================================
-- Version: 1.4
-- Created: 2025-12-10
-- Updated: 2026-02-22
-- Description: Simple inventory database schema with item, warehouse,
--              supplier, customer, stock inbound, stock outbound,
--              and stock beginning balance tables (Master-Detail structure)
-- Schema: public
-- Naming Convention: Following database-naming-convention-v3.md
-- ============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop tables if exists (in reverse order of dependencies)
DROP TABLE IF EXISTS stock_beginning_balance CASCADE;
DROP TABLE IF EXISTS stock_outbound_item CASCADE;
DROP TABLE IF EXISTS stock_outbound CASCADE;
DROP TABLE IF EXISTS stock_inbound_item CASCADE;
DROP TABLE IF EXISTS stock_inbound CASCADE;
DROP TABLE IF EXISTS item_product CASCADE;
DROP TABLE IF EXISTS warehouse CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;
DROP TABLE IF EXISTS category CASCADE;

-- ============================================================================
-- MASTER TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: supplier
-- Description: Master data supplier/vendor
-- ----------------------------------------------------------------------------
CREATE TABLE supplier (
    supplier_id         VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    supplier_code       VARCHAR(20) NOT NULL,
    supplier_name       VARCHAR(255) NOT NULL,
    contact_person      VARCHAR(100),
    phone               VARCHAR(20),
    email               VARCHAR(100),
    address             TEXT,
    city                VARCHAR(100) NOT NULL,
    country             VARCHAR(100) NOT NULL DEFAULT 'INDONESIA',
    register_date       DATE,
    amount_payable      DECIMAL(15,2) DEFAULT 0,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(70),
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR(70),

    CONSTRAINT uq_supplier_code UNIQUE (supplier_code)
);

COMMENT ON TABLE supplier IS 'Master data supplier/vendor';
COMMENT ON COLUMN supplier.supplier_id IS 'Primary key - unique identifier for supplier';
COMMENT ON COLUMN supplier.supplier_code IS 'Unique supplier code';
COMMENT ON COLUMN supplier.supplier_name IS 'Supplier company name';
COMMENT ON COLUMN supplier.register_date IS 'Supplier registration date';
COMMENT ON COLUMN supplier.amount_payable IS 'Outstanding amount payable to supplier';

CREATE INDEX idx_supplier_code ON supplier(supplier_code);
CREATE INDEX idx_supplier_is_active ON supplier(is_active);

-- ----------------------------------------------------------------------------
-- Table: customer
-- Description: Master data customer/buyer
-- ----------------------------------------------------------------------------
CREATE TABLE customer (
    customer_id         VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    customer_code       VARCHAR(20) NOT NULL,
    customer_name       VARCHAR(255) NOT NULL,
    contact_person      VARCHAR(100),
    phone               VARCHAR(20),
    email               VARCHAR(100),
    address             TEXT,
    city                VARCHAR(100) NOT NULL,
    country             VARCHAR(100) NOT NULL DEFAULT 'INDONESIA',
    register_date       DATE,
    amount_receivable   DECIMAL(15,2) DEFAULT 0,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(70),
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR(70),

    CONSTRAINT uq_customer_code UNIQUE (customer_code)
);

COMMENT ON TABLE customer IS 'Master data customer/buyer';
COMMENT ON COLUMN customer.customer_id IS 'Primary key - unique identifier for customer';
COMMENT ON COLUMN customer.customer_code IS 'Unique customer code';
COMMENT ON COLUMN customer.customer_name IS 'Customer company or individual name';
COMMENT ON COLUMN customer.register_date IS 'Customer registration date';
COMMENT ON COLUMN customer.amount_receivable IS 'Outstanding amount receivable from customer';

CREATE INDEX idx_customer_code ON customer(customer_code);
CREATE INDEX idx_customer_is_active ON customer(is_active);

-- ----------------------------------------------------------------------------
-- Table: warehouse
-- Description: Master data warehouse/location
-- ----------------------------------------------------------------------------
CREATE TABLE warehouse (
    warehouse_id        VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    warehouse_code      VARCHAR(20) NOT NULL,
    warehouse_name      VARCHAR(255) NOT NULL,
    warehouse_type      VARCHAR(50),
    address             TEXT,
    city                VARCHAR(100),
    capacity            DECIMAL(15,2),
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(70),
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR(70),

    CONSTRAINT uq_warehouse_code UNIQUE (warehouse_code),
    CONSTRAINT chk_warehouse_type CHECK (warehouse_type IN ('main', 'transit', 'consignment', 'external'))
);

COMMENT ON TABLE warehouse IS 'Master data warehouse/storage location';
COMMENT ON COLUMN warehouse.warehouse_id IS 'Primary key - unique identifier for warehouse';
COMMENT ON COLUMN warehouse.warehouse_code IS 'Unique warehouse code';
COMMENT ON COLUMN warehouse.warehouse_type IS 'Type of warehouse: main, transit, consignment, external';
COMMENT ON COLUMN warehouse.capacity IS 'Maximum capacity in cubic meters or square meters';

CREATE INDEX idx_warehouse_code ON warehouse(warehouse_code);
CREATE INDEX idx_warehouse_is_active ON warehouse(is_active);

-- ----------------------------------------------------------------------------
-- Table: category
-- Description: Master data product category
-- ----------------------------------------------------------------------------
CREATE TABLE category (
    category_id         VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    category_code       VARCHAR(20) NOT NULL,
    category_name       VARCHAR(100) NOT NULL,
    description         VARCHAR(500),
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(70),
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR(70),

    CONSTRAINT uq_category_code UNIQUE (category_code)
);

COMMENT ON TABLE category IS 'Master data product category';
COMMENT ON COLUMN category.category_id IS 'Primary key - unique identifier for category';
COMMENT ON COLUMN category.category_code IS 'Unique category code';
COMMENT ON COLUMN category.category_name IS 'Category display name';
COMMENT ON COLUMN category.description IS 'Category description';
COMMENT ON COLUMN category.is_active IS 'Category active status';

CREATE INDEX idx_category_code ON category(category_code);
CREATE INDEX idx_category_is_active ON category(is_active);

-- ----------------------------------------------------------------------------
-- Table: item_product
-- Description: Master data item/product
-- ----------------------------------------------------------------------------
CREATE TABLE item_product (
    item_product_id     VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    product_code        VARCHAR(20) NOT NULL,
    sku                 VARCHAR(20) NOT NULL,
    product_name        VARCHAR(100) NOT NULL,
    category_id         VARCHAR(70) NOT NULL,
    brand               VARCHAR(50),
    description         VARCHAR(500),
    purchase_price      DECIMAL(15,2) NOT NULL DEFAULT 0,
    selling_price       DECIMAL(15,2) NOT NULL DEFAULT 0,
    stock               DECIMAL(15,3) NOT NULL DEFAULT 0,
    min_stock           DECIMAL(15,3) DEFAULT 0,
    uom                 VARCHAR(10) DEFAULT 'pcs',
    weight              DECIMAL(10,2) DEFAULT 0,
    is_active           BOOLEAN DEFAULT TRUE,
    show_in_store       BOOLEAN DEFAULT TRUE,
    barcode             VARCHAR(20),
    shelf_location      VARCHAR(20),
    notes               VARCHAR(500),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(70),
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR(70),

    CONSTRAINT uq_item_product_code UNIQUE (product_code),
    CONSTRAINT uq_item_product_sku UNIQUE (sku),
    CONSTRAINT fk_item_product_category FOREIGN KEY (category_id)
        REFERENCES category(category_id) ON DELETE RESTRICT,
    CONSTRAINT chk_item_product_uom CHECK (uom IN ('pcs', 'box', 'kg', 'liter', 'meter', 'pack', 'set', 'lusin')),
    CONSTRAINT chk_item_product_purchase_price CHECK (purchase_price >= 0),
    CONSTRAINT chk_item_product_selling_price CHECK (selling_price >= 0),
    CONSTRAINT chk_item_product_weight CHECK (weight >= 0)
);

COMMENT ON TABLE item_product IS 'Master data item/product';
COMMENT ON COLUMN item_product.item_product_id IS 'Primary key - unique identifier for item product';
COMMENT ON COLUMN item_product.product_code IS 'Unique product code (e.g., PRD-001)';
COMMENT ON COLUMN item_product.sku IS 'Stock Keeping Unit - unique identifier for inventory';
COMMENT ON COLUMN item_product.product_name IS 'Product display name';
COMMENT ON COLUMN item_product.category_id IS 'Foreign key to category table';
COMMENT ON COLUMN item_product.brand IS 'Product brand name';
COMMENT ON COLUMN item_product.description IS 'Product description';
COMMENT ON COLUMN item_product.purchase_price IS 'Purchase/buy price from supplier';
COMMENT ON COLUMN item_product.selling_price IS 'Selling price to customer';
COMMENT ON COLUMN item_product.stock IS 'Current stock quantity';
COMMENT ON COLUMN item_product.min_stock IS 'Minimum stock threshold for alert';
COMMENT ON COLUMN item_product.uom IS 'Unit of measure: pcs, box, kg, liter, meter, pack, set, lusin';
COMMENT ON COLUMN item_product.weight IS 'Product weight in grams';
COMMENT ON COLUMN item_product.is_active IS 'Product active status';
COMMENT ON COLUMN item_product.show_in_store IS 'Display product in store/catalog';
COMMENT ON COLUMN item_product.barcode IS 'Product barcode number';
COMMENT ON COLUMN item_product.shelf_location IS 'Physical shelf location in warehouse (e.g., A1-01)';
COMMENT ON COLUMN item_product.notes IS 'Internal notes for product';

CREATE INDEX idx_item_product_code ON item_product(product_code);
CREATE INDEX idx_item_product_sku ON item_product(sku);
CREATE INDEX idx_item_product_category_id ON item_product(category_id);
CREATE INDEX idx_item_product_is_active ON item_product(is_active);
CREATE INDEX idx_item_product_barcode ON item_product(barcode);

-- ============================================================================
-- TRANSACTION TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: stock_inbound
-- Description: Stock inbound header - master record for receiving transactions
-- ----------------------------------------------------------------------------
CREATE TABLE stock_inbound (
    stock_inbound_id    VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    inbound_number      VARCHAR(50) NOT NULL,
    inbound_date        DATE NOT NULL DEFAULT CURRENT_DATE,
    warehouse_id        VARCHAR(70) NOT NULL,
    supplier_id         VARCHAR(70),
    reference_number    VARCHAR(50),
    notes               TEXT,
    total_items         INTEGER DEFAULT 0,
    total_qty           DECIMAL(15,3) DEFAULT 0,
    total_amount        DECIMAL(15,2) DEFAULT 0,
    status              VARCHAR(20) DEFAULT 'draft',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(70),
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR(70),

    CONSTRAINT uq_stock_inbound_number UNIQUE (inbound_number),
    CONSTRAINT fk_stock_inbound_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
    CONSTRAINT fk_stock_inbound_supplier FOREIGN KEY (supplier_id)
        REFERENCES supplier(supplier_id) ON DELETE SET NULL,
    CONSTRAINT chk_stock_inbound_status CHECK (status IN ('draft', 'confirmed', 'closed', 'cancelled'))
);

COMMENT ON TABLE stock_inbound IS 'Stock inbound header - master record for receiving transactions';
COMMENT ON COLUMN stock_inbound.stock_inbound_id IS 'Primary key - unique identifier for inbound transaction';
COMMENT ON COLUMN stock_inbound.inbound_number IS 'Unique inbound document number';
COMMENT ON COLUMN stock_inbound.inbound_date IS 'Date of receiving';
COMMENT ON COLUMN stock_inbound.warehouse_id IS 'Destination warehouse for received items';
COMMENT ON COLUMN stock_inbound.supplier_id IS 'Supplier/vendor reference (optional)';
COMMENT ON COLUMN stock_inbound.reference_number IS 'External reference (PO number, delivery note, etc)';
COMMENT ON COLUMN stock_inbound.total_items IS 'Total number of distinct items';
COMMENT ON COLUMN stock_inbound.total_qty IS 'Total quantity of all items';
COMMENT ON COLUMN stock_inbound.total_amount IS 'Total amount of all items (summary)';
COMMENT ON COLUMN stock_inbound.status IS 'Transaction status: draft, confirmed, closed, cancelled';

CREATE INDEX idx_stock_inbound_number ON stock_inbound(inbound_number);
CREATE INDEX idx_stock_inbound_date ON stock_inbound(inbound_date);
CREATE INDEX idx_stock_inbound_warehouse_id ON stock_inbound(warehouse_id);
CREATE INDEX idx_stock_inbound_supplier_id ON stock_inbound(supplier_id);
CREATE INDEX idx_stock_inbound_status ON stock_inbound(status);

-- ----------------------------------------------------------------------------
-- Table: stock_inbound_item
-- Description: Stock inbound items - list of items received in each transaction
-- ----------------------------------------------------------------------------
CREATE TABLE stock_inbound_item (
    stock_inbound_item_id   VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    stock_inbound_id        VARCHAR(70) NOT NULL,
    line_number             INTEGER NOT NULL,
    item_product_id         VARCHAR(70) NOT NULL,
    qty_received            DECIMAL(15,3) NOT NULL DEFAULT 0,
    uom                     VARCHAR(10) DEFAULT 'pcs',
    unit_price              DECIMAL(15,2) DEFAULT 0,
    total_amount            DECIMAL(15,2) DEFAULT 0,
    notes                   TEXT,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by              VARCHAR(70),
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by              VARCHAR(70),

    CONSTRAINT uq_stock_inbound_item_line UNIQUE (stock_inbound_id, line_number),
    CONSTRAINT fk_stock_inbound_item_header FOREIGN KEY (stock_inbound_id)
        REFERENCES stock_inbound(stock_inbound_id) ON DELETE CASCADE,
    CONSTRAINT fk_stock_inbound_item_product FOREIGN KEY (item_product_id)
        REFERENCES item_product(item_product_id) ON DELETE RESTRICT,
    CONSTRAINT chk_stock_inbound_item_line_number CHECK (line_number > 0),
    CONSTRAINT chk_stock_inbound_item_unit_price CHECK (unit_price >= 0)
);

COMMENT ON TABLE stock_inbound_item IS 'Stock inbound items - list of items received in each transaction';
COMMENT ON COLUMN stock_inbound_item.stock_inbound_item_id IS 'Primary key - unique identifier for inbound item line';
COMMENT ON COLUMN stock_inbound_item.stock_inbound_id IS 'Foreign key to stock_inbound';
COMMENT ON COLUMN stock_inbound_item.line_number IS 'Line sequence number within the transaction';
COMMENT ON COLUMN stock_inbound_item.item_product_id IS 'Foreign key to item_product';
COMMENT ON COLUMN stock_inbound_item.qty_received IS 'Quantity received for this item';
COMMENT ON COLUMN stock_inbound_item.uom IS 'Unit of measure: pcs, box, kg, liter, meter, pack, set, lusin';
COMMENT ON COLUMN stock_inbound_item.unit_price IS 'Unit price for this item';
COMMENT ON COLUMN stock_inbound_item.total_amount IS 'Line total amount (qty_received x unit_price), populated by application';

CREATE INDEX idx_stock_inbound_item_inbound_id ON stock_inbound_item(stock_inbound_id);
CREATE INDEX idx_stock_inbound_item_product_id ON stock_inbound_item(item_product_id);
CREATE INDEX idx_stock_inbound_item_inbound_product ON stock_inbound_item(stock_inbound_id, item_product_id);

-- ----------------------------------------------------------------------------
-- Table: stock_outbound
-- Description: Stock outbound header - master record for shipping/delivery transactions
-- ----------------------------------------------------------------------------
CREATE TABLE stock_outbound (
    stock_outbound_id   VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    outbound_number     VARCHAR(50) NOT NULL,
    outbound_date       DATE NOT NULL DEFAULT CURRENT_DATE,
    warehouse_id        VARCHAR(70) NOT NULL,
    customer_id         VARCHAR(70),
    reference_number    VARCHAR(50),
    notes               TEXT,
    total_items         INTEGER DEFAULT 0,
    total_qty           DECIMAL(15,3) DEFAULT 0,
    total_amount        DECIMAL(15,2) DEFAULT 0,
    status              VARCHAR(20) DEFAULT 'draft',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(70),
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR(70),

    CONSTRAINT uq_stock_outbound_number UNIQUE (outbound_number),
    CONSTRAINT fk_stock_outbound_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
    CONSTRAINT fk_stock_outbound_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id) ON DELETE SET NULL,
    CONSTRAINT chk_stock_outbound_status CHECK (status IN ('draft', 'confirmed', 'closed', 'cancelled'))
);

COMMENT ON TABLE stock_outbound IS 'Stock outbound header - master record for shipping/delivery transactions';
COMMENT ON COLUMN stock_outbound.stock_outbound_id IS 'Primary key - unique identifier for outbound transaction';
COMMENT ON COLUMN stock_outbound.outbound_number IS 'Unique outbound document number';
COMMENT ON COLUMN stock_outbound.outbound_date IS 'Date of shipping/delivery';
COMMENT ON COLUMN stock_outbound.warehouse_id IS 'Source warehouse for shipped items';
COMMENT ON COLUMN stock_outbound.customer_id IS 'Customer/buyer reference (optional)';
COMMENT ON COLUMN stock_outbound.reference_number IS 'External reference (SO number, delivery order, etc)';
COMMENT ON COLUMN stock_outbound.total_items IS 'Total number of distinct items';
COMMENT ON COLUMN stock_outbound.total_qty IS 'Total quantity of all items';
COMMENT ON COLUMN stock_outbound.total_amount IS 'Total amount of all items (summary)';
COMMENT ON COLUMN stock_outbound.status IS 'Transaction status: draft, confirmed, closed, cancelled';

CREATE INDEX idx_stock_outbound_number ON stock_outbound(outbound_number);
CREATE INDEX idx_stock_outbound_date ON stock_outbound(outbound_date);
CREATE INDEX idx_stock_outbound_warehouse_id ON stock_outbound(warehouse_id);
CREATE INDEX idx_stock_outbound_customer_id ON stock_outbound(customer_id);
CREATE INDEX idx_stock_outbound_status ON stock_outbound(status);

-- ----------------------------------------------------------------------------
-- Table: stock_outbound_item
-- Description: Stock outbound items - list of items shipped in each transaction
-- ----------------------------------------------------------------------------
CREATE TABLE stock_outbound_item (
    stock_outbound_item_id  VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    stock_outbound_id       VARCHAR(70) NOT NULL,
    line_number             INTEGER NOT NULL,
    item_product_id         VARCHAR(70) NOT NULL,
    qty_shipped             DECIMAL(15,3) NOT NULL DEFAULT 0,
    uom                     VARCHAR(10) DEFAULT 'pcs',
    unit_price              DECIMAL(15,2) DEFAULT 0,
    total_amount            DECIMAL(15,2) DEFAULT 0,
    notes                   TEXT,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by              VARCHAR(70),
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by              VARCHAR(70),

    CONSTRAINT uq_stock_outbound_item_line UNIQUE (stock_outbound_id, line_number),
    CONSTRAINT fk_stock_outbound_item_header FOREIGN KEY (stock_outbound_id)
        REFERENCES stock_outbound(stock_outbound_id) ON DELETE CASCADE,
    CONSTRAINT fk_stock_outbound_item_product FOREIGN KEY (item_product_id)
        REFERENCES item_product(item_product_id) ON DELETE RESTRICT,
    CONSTRAINT chk_stock_outbound_item_line_number CHECK (line_number > 0),
    CONSTRAINT chk_stock_outbound_item_unit_price CHECK (unit_price >= 0)
);

COMMENT ON TABLE stock_outbound_item IS 'Stock outbound items - list of items shipped in each transaction';
COMMENT ON COLUMN stock_outbound_item.stock_outbound_item_id IS 'Primary key - unique identifier for outbound item line';
COMMENT ON COLUMN stock_outbound_item.stock_outbound_id IS 'Foreign key to stock_outbound';
COMMENT ON COLUMN stock_outbound_item.line_number IS 'Line sequence number within the transaction';
COMMENT ON COLUMN stock_outbound_item.item_product_id IS 'Foreign key to item_product';
COMMENT ON COLUMN stock_outbound_item.qty_shipped IS 'Quantity shipped for this item';
COMMENT ON COLUMN stock_outbound_item.uom IS 'Unit of measure: pcs, box, kg, liter, meter, pack, set, lusin';
COMMENT ON COLUMN stock_outbound_item.unit_price IS 'Unit price for this item';
COMMENT ON COLUMN stock_outbound_item.total_amount IS 'Line total amount (qty_shipped x unit_price), populated by application';

CREATE INDEX idx_stock_outbound_item_outbound_id ON stock_outbound_item(stock_outbound_id);
CREATE INDEX idx_stock_outbound_item_product_id ON stock_outbound_item(item_product_id);
CREATE INDEX idx_stock_outbound_item_outbound_product ON stock_outbound_item(stock_outbound_id, item_product_id);

-- ----------------------------------------------------------------------------
-- Table: stock_beginning_balance
-- Description: Saldo awal stock per item per warehouse per periode
-- ----------------------------------------------------------------------------
CREATE TABLE stock_beginning_balance (
    stock_beginning_balance_id  VARCHAR(70) PRIMARY KEY DEFAULT uuid_generate_v4()::VARCHAR,
    item_product_id             VARCHAR(70) NOT NULL,
    warehouse_id                VARCHAR(70) NOT NULL,
    period_date                 DATE NOT NULL,
    qty_beginning               DECIMAL(15,3) NOT NULL DEFAULT 0,
    notes                       TEXT,
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by                  VARCHAR(70),
    updated_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by                  VARCHAR(70),

    CONSTRAINT uq_stock_beginning_balance UNIQUE (item_product_id, warehouse_id, period_date),
    CONSTRAINT fk_stock_beginning_balance_item FOREIGN KEY (item_product_id)
        REFERENCES item_product(item_product_id) ON DELETE RESTRICT,
    CONSTRAINT fk_stock_beginning_balance_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT
);

COMMENT ON TABLE stock_beginning_balance IS 'Saldo awal stock per item per warehouse per periode';
COMMENT ON COLUMN stock_beginning_balance.stock_beginning_balance_id IS 'Primary key - unique identifier';
COMMENT ON COLUMN stock_beginning_balance.item_product_id IS 'Foreign key to item_product';
COMMENT ON COLUMN stock_beginning_balance.warehouse_id IS 'Foreign key to warehouse';
COMMENT ON COLUMN stock_beginning_balance.period_date IS 'Tanggal efektif saldo awal (biasanya awal bulan/tahun)';
COMMENT ON COLUMN stock_beginning_balance.qty_beginning IS 'Quantity saldo awal';
COMMENT ON COLUMN stock_beginning_balance.notes IS 'Catatan tambahan';

CREATE INDEX idx_stock_beginning_balance_item_id ON stock_beginning_balance(item_product_id);
CREATE INDEX idx_stock_beginning_balance_warehouse_id ON stock_beginning_balance(warehouse_id);
CREATE INDEX idx_stock_beginning_balance_period ON stock_beginning_balance(period_date);
CREATE INDEX idx_stock_beginning_balance_item_warehouse ON stock_beginning_balance(item_product_id, warehouse_id);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
