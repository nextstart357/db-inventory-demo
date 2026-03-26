-- ============================================================================
-- MINI INVENTORY DATABASE SCHEMA (ORACLE)
-- ============================================================================
-- Version: 1.4
-- Created: 2025-12-10
-- Updated: 2026-02-22
-- Description: Simple inventory database schema with item, warehouse,
--              supplier, customer, stock inbound, stock outbound,
--              and stock beginning balance tables (Master-Detail structure)
-- Platform: Oracle Database 12c+
-- Naming Convention: Following database-naming-convention-v3.md
-- ============================================================================

SET DEFINE OFF;

-- ============================================================================
-- DROP EXISTING OBJECTS (in reverse order of dependencies)
-- ============================================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE stock_beginning_balance CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE stock_outbound_item CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE stock_outbound CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE stock_inbound_item CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE stock_inbound CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE item_product CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE warehouse CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE customer CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE supplier CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE category CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ============================================================================
-- MASTER TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: supplier
-- Description: Master data supplier/vendor
-- ----------------------------------------------------------------------------
CREATE TABLE supplier (
    supplier_id         VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    supplier_code       VARCHAR2(20) NOT NULL CONSTRAINT uq_supplier_code UNIQUE,
    supplier_name       VARCHAR2(255) NOT NULL,
    contact_person      VARCHAR2(100),
    phone               VARCHAR2(20),
    email               VARCHAR2(100),
    address             VARCHAR2(4000),
    city                VARCHAR2(100) NOT NULL,
    country             VARCHAR2(100) DEFAULT 'INDONESIA' NOT NULL,
    register_date       DATE,
    amount_payable      NUMBER(15,2) DEFAULT 0,
    is_active           VARCHAR2(5) DEFAULT 'true' CONSTRAINT chk_supplier_is_active CHECK (is_active IN ('true', 'false')),
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by          VARCHAR2(70),
    updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by          VARCHAR2(70)
);

COMMENT ON TABLE supplier IS 'Master data supplier/vendor';
COMMENT ON COLUMN supplier.supplier_id IS 'Primary key - unique identifier for supplier';
COMMENT ON COLUMN supplier.supplier_code IS 'Unique supplier code';
COMMENT ON COLUMN supplier.supplier_name IS 'Supplier company name';
COMMENT ON COLUMN supplier.register_date IS 'Supplier registration date';
COMMENT ON COLUMN supplier.amount_payable IS 'Outstanding amount payable to supplier';

-- idx_supplier_code not needed (auto-created by UNIQUE constraint)
CREATE INDEX idx_supplier_is_active ON supplier(is_active);

-- ----------------------------------------------------------------------------
-- Table: customer
-- Description: Master data customer/buyer
-- ----------------------------------------------------------------------------
CREATE TABLE customer (
    customer_id         VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    customer_code       VARCHAR2(20) NOT NULL CONSTRAINT uq_customer_code UNIQUE,
    customer_name       VARCHAR2(255) NOT NULL,
    contact_person      VARCHAR2(100),
    phone               VARCHAR2(20),
    email               VARCHAR2(100),
    address             VARCHAR2(4000),
    city                VARCHAR2(100) NOT NULL,
    country             VARCHAR2(100) DEFAULT 'INDONESIA' NOT NULL,
    register_date       DATE,
    amount_receivable   NUMBER(15,2) DEFAULT 0,
    is_active           VARCHAR2(5) DEFAULT 'true' CONSTRAINT chk_customer_is_active CHECK (is_active IN ('true', 'false')),
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by          VARCHAR2(70),
    updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by          VARCHAR2(70)
);

COMMENT ON TABLE customer IS 'Master data customer/buyer';
COMMENT ON COLUMN customer.customer_id IS 'Primary key - unique identifier for customer';
COMMENT ON COLUMN customer.customer_code IS 'Unique customer code';
COMMENT ON COLUMN customer.customer_name IS 'Customer company or individual name';
COMMENT ON COLUMN customer.register_date IS 'Customer registration date';
COMMENT ON COLUMN customer.amount_receivable IS 'Outstanding amount receivable from customer';

-- idx_customer_code not needed (auto-created by UNIQUE constraint)
CREATE INDEX idx_customer_is_active ON customer(is_active);

-- ----------------------------------------------------------------------------
-- Table: warehouse
-- Description: Master data warehouse/location
-- ----------------------------------------------------------------------------
CREATE TABLE warehouse (
    warehouse_id        VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    warehouse_code      VARCHAR2(20) NOT NULL CONSTRAINT uq_warehouse_code UNIQUE,
    warehouse_name      VARCHAR2(255) NOT NULL,
    warehouse_type      VARCHAR2(50) CONSTRAINT chk_warehouse_type CHECK (warehouse_type IN ('main', 'transit', 'consignment', 'external')),
    address             VARCHAR2(4000),
    city                VARCHAR2(100),
    capacity            NUMBER(15,2),
    is_active           VARCHAR2(5) DEFAULT 'true' CONSTRAINT chk_warehouse_is_active CHECK (is_active IN ('true', 'false')),
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by          VARCHAR2(70),
    updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by          VARCHAR2(70)
);

COMMENT ON TABLE warehouse IS 'Master data warehouse/storage location';
COMMENT ON COLUMN warehouse.warehouse_id IS 'Primary key - unique identifier for warehouse';
COMMENT ON COLUMN warehouse.warehouse_code IS 'Unique warehouse code';
COMMENT ON COLUMN warehouse.warehouse_type IS 'Type of warehouse: main, transit, consignment, external';
COMMENT ON COLUMN warehouse.capacity IS 'Maximum capacity in cubic meters or square meters';

-- idx_warehouse_code not needed (auto-created by UNIQUE constraint)
CREATE INDEX idx_warehouse_is_active ON warehouse(is_active);

-- ----------------------------------------------------------------------------
-- Table: category
-- Description: Master data product category
-- ----------------------------------------------------------------------------
CREATE TABLE category (
    category_id         VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    category_code       VARCHAR2(20) NOT NULL CONSTRAINT uq_category_code UNIQUE,
    category_name       VARCHAR2(100) NOT NULL,
    description         VARCHAR2(500),
    is_active           VARCHAR2(5) DEFAULT 'true' CONSTRAINT chk_category_is_active CHECK (is_active IN ('true', 'false')),
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by          VARCHAR2(70),
    updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by          VARCHAR2(70)
);

COMMENT ON TABLE category IS 'Master data product category';
COMMENT ON COLUMN category.category_id IS 'Primary key - unique identifier for category';
COMMENT ON COLUMN category.category_code IS 'Unique category code';
COMMENT ON COLUMN category.category_name IS 'Category display name';
COMMENT ON COLUMN category.description IS 'Category description';
COMMENT ON COLUMN category.is_active IS 'Category active status';

-- idx_category_code not needed (auto-created by UNIQUE constraint)
CREATE INDEX idx_category_is_active ON category(is_active);

-- ----------------------------------------------------------------------------
-- Table: item_product
-- Description: Master data item/product
-- ----------------------------------------------------------------------------
CREATE TABLE item_product (
    item_product_id     VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    product_code        VARCHAR2(20) NOT NULL CONSTRAINT uq_item_product_code UNIQUE,
    sku                 VARCHAR2(20) NOT NULL CONSTRAINT uq_item_product_sku UNIQUE,
    product_name        VARCHAR2(100) NOT NULL,
    category_id         VARCHAR2(70) NOT NULL CONSTRAINT fk_item_product_category REFERENCES category(category_id),
    brand               VARCHAR2(50),
    description         VARCHAR2(500),
    purchase_price      NUMBER(15,2) DEFAULT 0 NOT NULL CONSTRAINT chk_item_product_purchase_price CHECK (purchase_price >= 0),
    selling_price       NUMBER(15,2) DEFAULT 0 NOT NULL CONSTRAINT chk_item_product_selling_price CHECK (selling_price >= 0),
    stock               NUMBER(10) DEFAULT 0 NOT NULL,
    min_stock           NUMBER(10) DEFAULT 10,
    uom                 VARCHAR2(10) DEFAULT 'pcs' CONSTRAINT chk_item_product_uom CHECK (uom IN ('pcs', 'box', 'kg', 'liter', 'meter', 'pack', 'set', 'lusin')),
    weight              NUMBER(10,2) DEFAULT 0 CONSTRAINT chk_item_product_weight CHECK (weight >= 0),
    is_active           VARCHAR2(5) DEFAULT 'true' CONSTRAINT chk_item_product_is_active CHECK (is_active IN ('true', 'false')),
    show_in_store       VARCHAR2(5) DEFAULT 'true' CONSTRAINT chk_item_product_show_in_store CHECK (show_in_store IN ('true', 'false')),
    barcode             VARCHAR2(20),
    shelf_location      VARCHAR2(20),
    notes               VARCHAR2(500),
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by          VARCHAR2(70),
    updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by          VARCHAR2(70)
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

-- idx_item_product_code not needed (auto-created by UNIQUE constraint)
-- idx_item_product_sku not needed (auto-created by UNIQUE constraint)
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
    stock_inbound_id    VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    inbound_number      VARCHAR2(50) NOT NULL CONSTRAINT uq_stock_inbound_number UNIQUE,
    inbound_date        DATE DEFAULT SYSDATE NOT NULL,
    warehouse_id        VARCHAR2(70) NOT NULL CONSTRAINT fk_stock_inbound_warehouse REFERENCES warehouse(warehouse_id),
    supplier_id         VARCHAR2(70) CONSTRAINT fk_stock_inbound_supplier REFERENCES supplier(supplier_id) ON DELETE SET NULL,
    reference_number    VARCHAR2(50),
    notes               VARCHAR2(4000),
    total_items         NUMBER(10) DEFAULT 0,
    total_qty           NUMBER(15,3) DEFAULT 0,
    total_amount        NUMBER(15,2) DEFAULT 0,
    status              VARCHAR2(20) DEFAULT 'draft' CONSTRAINT chk_stock_inbound_status CHECK (status IN ('draft', 'confirmed', 'closed', 'cancelled')),
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by          VARCHAR2(70),
    updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by          VARCHAR2(70)
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

-- idx_stock_inbound_number not needed (auto-created by UNIQUE constraint)
CREATE INDEX idx_stock_inbound_date ON stock_inbound(inbound_date);
CREATE INDEX idx_stock_inbound_warehouse_id ON stock_inbound(warehouse_id);
CREATE INDEX idx_stock_inbound_supplier_id ON stock_inbound(supplier_id);
CREATE INDEX idx_stock_inbound_status ON stock_inbound(status);

-- ----------------------------------------------------------------------------
-- Table: stock_inbound_item
-- Description: Stock inbound items - list of items received in each transaction
-- ----------------------------------------------------------------------------
CREATE TABLE stock_inbound_item (
    stock_inbound_item_id   VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    stock_inbound_id        VARCHAR2(70) NOT NULL CONSTRAINT fk_stock_inbound_item_header REFERENCES stock_inbound(stock_inbound_id) ON DELETE CASCADE,
    line_number             NUMBER(10) NOT NULL CONSTRAINT chk_stock_inbound_item_line_number CHECK (line_number > 0),
    item_product_id         VARCHAR2(70) NOT NULL CONSTRAINT fk_stock_inbound_item_product REFERENCES item_product(item_product_id),
    qty_received            NUMBER(15,3) DEFAULT 0 NOT NULL,
    uom                     VARCHAR2(10) DEFAULT 'pcs',
    unit_price              NUMBER(15,2) DEFAULT 0 CONSTRAINT chk_stock_inbound_item_unit_price CHECK (unit_price >= 0),
    total_amount            NUMBER(15,2) DEFAULT 0,
    notes                   VARCHAR2(4000),
    created_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by              VARCHAR2(70),
    updated_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by              VARCHAR2(70),
    CONSTRAINT uq_stock_inbound_item_line UNIQUE (stock_inbound_id, line_number)
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
    stock_outbound_id   VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    outbound_number     VARCHAR2(50) NOT NULL CONSTRAINT uq_stock_outbound_number UNIQUE,
    outbound_date       DATE DEFAULT SYSDATE NOT NULL,
    warehouse_id        VARCHAR2(70) NOT NULL CONSTRAINT fk_stock_outbound_warehouse REFERENCES warehouse(warehouse_id),
    customer_id         VARCHAR2(70) CONSTRAINT fk_stock_outbound_customer REFERENCES customer(customer_id) ON DELETE SET NULL,
    reference_number    VARCHAR2(50),
    notes               VARCHAR2(4000),
    total_items         NUMBER(10) DEFAULT 0,
    total_qty           NUMBER(15,3) DEFAULT 0,
    total_amount        NUMBER(15,2) DEFAULT 0,
    status              VARCHAR2(20) DEFAULT 'draft' CONSTRAINT chk_stock_outbound_status CHECK (status IN ('draft', 'confirmed', 'closed', 'cancelled')),
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by          VARCHAR2(70),
    updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by          VARCHAR2(70)
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

-- idx_stock_outbound_number not needed (auto-created by UNIQUE constraint)
CREATE INDEX idx_stock_outbound_date ON stock_outbound(outbound_date);
CREATE INDEX idx_stock_outbound_warehouse_id ON stock_outbound(warehouse_id);
CREATE INDEX idx_stock_outbound_customer_id ON stock_outbound(customer_id);
CREATE INDEX idx_stock_outbound_status ON stock_outbound(status);

-- ----------------------------------------------------------------------------
-- Table: stock_outbound_item
-- Description: Stock outbound items - list of items shipped in each transaction
-- ----------------------------------------------------------------------------
CREATE TABLE stock_outbound_item (
    stock_outbound_item_id  VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    stock_outbound_id       VARCHAR2(70) NOT NULL CONSTRAINT fk_stock_outbound_item_header REFERENCES stock_outbound(stock_outbound_id) ON DELETE CASCADE,
    line_number             NUMBER(10) NOT NULL CONSTRAINT chk_stock_outbound_item_line_number CHECK (line_number > 0),
    item_product_id         VARCHAR2(70) NOT NULL CONSTRAINT fk_stock_outbound_item_product REFERENCES item_product(item_product_id),
    qty_shipped             NUMBER(15,3) DEFAULT 0 NOT NULL,
    uom                     VARCHAR2(10) DEFAULT 'pcs',
    unit_price              NUMBER(15,2) DEFAULT 0 CONSTRAINT chk_stock_outbound_item_unit_price CHECK (unit_price >= 0),
    total_amount            NUMBER(15,2) DEFAULT 0,
    notes                   VARCHAR2(4000),
    created_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by              VARCHAR2(70),
    updated_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by              VARCHAR2(70),
    CONSTRAINT uq_stock_outbound_item_line UNIQUE (stock_outbound_id, line_number)
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
    stock_beginning_balance_id  VARCHAR2(70) DEFAULT SYS_GUID() PRIMARY KEY,
    item_product_id             VARCHAR2(70) NOT NULL CONSTRAINT fk_stock_beginning_balance_item REFERENCES item_product(item_product_id),
    warehouse_id                VARCHAR2(70) NOT NULL CONSTRAINT fk_stock_beginning_balance_wh REFERENCES warehouse(warehouse_id),
    period_date                 DATE NOT NULL,
    qty_beginning               NUMBER(15,3) DEFAULT 0 NOT NULL,
    notes                       VARCHAR2(4000),
    created_at                  TIMESTAMP DEFAULT SYSTIMESTAMP,
    created_by                  VARCHAR2(70),
    updated_at                  TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by                  VARCHAR2(70),
    CONSTRAINT uq_stock_beginning_balance UNIQUE (item_product_id, warehouse_id, period_date)
);

COMMENT ON TABLE stock_beginning_balance IS 'Saldo awal stock per item per warehouse per periode';
COMMENT ON COLUMN stock_beginning_balance.stock_beginning_balance_id IS 'Primary key - unique identifier';
COMMENT ON COLUMN stock_beginning_balance.item_product_id IS 'Foreign key to item_product';
COMMENT ON COLUMN stock_beginning_balance.warehouse_id IS 'Foreign key to warehouse';
COMMENT ON COLUMN stock_beginning_balance.period_date IS 'Tanggal efektif saldo awal (biasanya awal bulan/tahun)';
COMMENT ON COLUMN stock_beginning_balance.qty_beginning IS 'Quantity saldo awal';
COMMENT ON COLUMN stock_beginning_balance.notes IS 'Catatan tambahan';

CREATE INDEX idx_stock_beginning_balance_item_id ON stock_beginning_balance(item_product_id);
CREATE INDEX idx_stock_beginning_balance_wh_id ON stock_beginning_balance(warehouse_id);
CREATE INDEX idx_stock_beginning_balance_period ON stock_beginning_balance(period_date);
CREATE INDEX idx_stock_beginning_balance_item_wh ON stock_beginning_balance(item_product_id, warehouse_id);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

EXIT;
