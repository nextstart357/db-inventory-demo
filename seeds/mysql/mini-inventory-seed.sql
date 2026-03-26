-- ============================================================================
-- MINI INVENTORY SEED DATA (MySQL 8.0+)
-- ============================================================================
-- Version: 4.0
-- Created: 2025-12-10
-- Updated: 2026-02-17
-- Description: Sample/seed data for mini inventory database (Master-Detail)
-- Database: mini_inventory
-- Prerequisites: Run mini-inventory.sql schema first
-- MySQL Version: 8.0+ (requires recursive CTE support)
-- ============================================================================

-- ============================================================================
-- SAMPLE DATA - CATEGORIES
-- ============================================================================

INSERT INTO category (category_code, category_name, description, created_by) VALUES
('CAT001', 'Elektronik', 'Produk elektronik dan gadget seperti smartphone, laptop, tablet, dll', 'SYSTEM'),
('CAT002', 'Fashion', 'Produk pakaian dan aksesoris fashion', 'SYSTEM'),
('CAT003', 'Makanan', 'Produk makanan dan minuman', 'SYSTEM'),
('CAT004', 'Kesehatan', 'Produk kesehatan, vitamin, dan perawatan tubuh', 'SYSTEM'),
('CAT005', 'Rumah Tangga', 'Produk peralatan rumah tangga dan dapur', 'SYSTEM'),
('CAT006', 'Olahraga', 'Produk perlengkapan olahraga dan fitness', 'SYSTEM');

-- ============================================================================
-- SAMPLE DATA - CUSTOMERS
-- ============================================================================

INSERT INTO customer (customer_code, customer_name, contact_person, phone, email, city, register_date, amount_receivable, created_by) VALUES
('CST001', 'PT Pelanggan Setia', 'Ahmad Rizki', '021-11223344', 'ahmad@pelanggansetia.com', 'Jakarta', '2024-02-10', 12000000.00, 'SYSTEM'),
('CST002', 'CV Toko Makmur', 'Siti Rahayu', '031-55667788', 'siti@tokomakmur.com', 'Surabaya', '2024-04-15', 5500000.00, 'SYSTEM'),
('CST003', 'PT Retail Nusantara', 'Budi Santoso', '061-99887766', 'budi@retailnusantara.com', 'Medan', '2024-07-20', 18000000.00, 'SYSTEM');

-- ============================================================================
-- SAMPLE DATA - SUPPLIERS
-- ============================================================================

INSERT INTO supplier (supplier_code, supplier_name, contact_person, phone, email, city, register_date, amount_payable, created_by) VALUES
('SUP001', 'PT Supplier Utama', 'John Doe', '021-12345678', 'john@supplier1.com', 'Jakarta', '2024-01-15', 15000000.00, 'SYSTEM'),
('SUP002', 'CV Mitra Sejahtera', 'Jane Smith', '021-87654321', 'jane@mitra.com', 'Bandung', '2024-03-20', 8500000.00, 'SYSTEM'),
('SUP003', 'PT Global Teknologi', 'Michael Chen', '021-55667788', 'michael@globaltek.com', 'Jakarta', '2024-06-10', 25000000.00, 'SYSTEM');

-- ============================================================================
-- SAMPLE DATA - WAREHOUSES
-- ============================================================================

INSERT INTO warehouse (warehouse_code, warehouse_name, warehouse_type, city, capacity, created_by) VALUES
('WH001', 'Gudang Pusat Jakarta', 'main', 'Jakarta', 1000.00, 'SYSTEM'),
('WH002', 'Gudang Transit Surabaya', 'transit', 'Surabaya', 500.00, 'SYSTEM'),
('WH003', 'Gudang Konsinyasi Medan', 'consignment', 'Medan', 300.00, 'SYSTEM');

-- ============================================================================
-- SAMPLE DATA - ITEM PRODUCTS (600 Products)
-- ============================================================================
-- Using recursive CTE for efficient bulk insert (MySQL 8.0+)

INSERT INTO item_product (
    product_code, sku, product_name, category_id, brand, description,
    purchase_price, selling_price, stock, min_stock, uom, weight,
    is_active, show_in_store, barcode, shelf_location, notes, created_by
)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 600
),
product_data AS (
    SELECT
        n,
        -- Product Code: PRD-0001 to PRD-0600
        CONCAT('PRD-', LPAD(n, 4, '0')) AS product_code,
        -- SKU: SKU + 10 digit
        CONCAT('SKU', LPAD(n, 10, '0')) AS sku,
        -- Category index (0-5)
        (n - 1) MOD 6 AS cat_idx,
        -- Product index within category
        FLOOR((n - 1) / 6) MOD 20 AS prod_idx,
        -- Brand index
        FLOOR((n - 1) / 6) MOD 20 AS brand_idx,
        -- Variant index
        FLOOR((n - 1) / 120) AS variant_idx
    FROM numbers
)
SELECT
    product_code,
    sku,
    -- Product Name based on category
    CASE cat_idx
        WHEN 0 THEN CONCAT(
            ELT(prod_idx + 1,
                'Smartphone', 'Laptop', 'Tablet', 'Smartwatch', 'Earbuds TWS',
                'Power Bank', 'Charger Fast', 'Kabel USB-C', 'Mouse Wireless', 'Keyboard Mechanical',
                'Monitor LED', 'Webcam HD', 'Speaker Bluetooth', 'Headphone Gaming', 'SSD External',
                'Flash Drive', 'Router WiFi', 'Smart TV', 'Proyektor Mini', 'Drone Camera'
            ), ' ',
            ELT(brand_idx + 1,
                'Samsung', 'Apple', 'Xiaomi', 'Oppo', 'Vivo', 'Realme', 'Asus', 'Lenovo', 'HP', 'Dell',
                'LG', 'Sony', 'JBL', 'Logitech', 'Anker', 'SanDisk', 'TP-Link', 'TCL', 'ViewSonic', 'DJI'
            ), ' Series ', variant_idx + 1
        )
        WHEN 1 THEN CONCAT(
            ELT(prod_idx + 1,
                'Kaos Polos', 'Kemeja Formal', 'Celana Jeans', 'Celana Chino', 'Jaket Hoodie',
                'Sweater Knit', 'Dress Casual', 'Rok Mini', 'Blazer Slim', 'Cardigan',
                'Polo Shirt', 'Tank Top', 'Celana Pendek', 'Jumpsuit', 'Rompi Vest',
                'Jacket Denim', 'Celana Jogger', 'Atasan Blouse', 'Outer Kimono', 'Tunik Modern'
            ), ' ',
            ELT(brand_idx + 1,
                'Uniqlo', 'H&M', 'Zara', 'Cotton On', 'Pull&Bear', 'Bershka', 'Mango', 'GAP', 'Levi\'s', 'Guess',
                'Calvin Klein', 'Tommy Hilfiger', 'Lacoste', 'Ralph Lauren', 'Nike', 'Adidas', 'Puma', 'New Balance', 'Under Armour', 'Fila'
            ), ' ',
            ELT((variant_idx MOD 5) + 1, 'Premium', 'Basic', 'Classic', 'Modern', 'Slim Fit')
        )
        WHEN 2 THEN CONCAT(
            ELT(prod_idx + 1,
                'Mie Instan', 'Biskuit Kaleng', 'Kopi Sachet', 'Teh Celup', 'Susu UHT',
                'Sereal Box', 'Cokelat Bar', 'Keripik Kentang', 'Kacang Panggang', 'Wafer Cream',
                'Minuman Soda', 'Jus Buah', 'Air Mineral', 'Energy Drink', 'Yogurt Cup',
                'Es Krim', 'Roti Tawar', 'Selai Kacang', 'Madu Murni', 'Saus Sambal'
            ), ' ',
            ELT(brand_idx + 1,
                'Indomie', 'Khong Guan', 'Kapal Api', 'Sariwangi', 'Ultra Milk', 'Nestle', 'Cadbury', 'Lays', 'Garuda', 'Tango',
                'Coca Cola', 'Buavita', 'Aqua', 'Kratingdaeng', 'Cimory', 'Walls', 'Sari Roti', 'Skippy', 'Madu TJ', 'ABC'
            ), ' ',
            ELT((variant_idx MOD 5) + 1, 'Original', 'Special', 'Premium', 'Family Pack', 'Value Pack')
        )
        WHEN 3 THEN CONCAT(
            ELT(prod_idx + 1,
                'Vitamin C', 'Vitamin D3', 'Multivitamin', 'Omega 3', 'Probiotik',
                'Kolagen Drink', 'Masker Wajah', 'Serum Wajah', 'Sunscreen SPF50', 'Pelembab Kulit',
                'Sabun Mandi', 'Shampoo', 'Conditioner', 'Body Lotion', 'Parfum EDT',
                'Deodorant', 'Pasta Gigi', 'Obat Maag', 'Obat Flu', 'Plester Luka'
            ), ' ',
            ELT(brand_idx + 1,
                'Blackmores', 'Nature\'s Way', 'Centrum', 'Wellness', 'Youvit', 'Somethinc', 'Wardah', 'Emina', 'Skin Aqua', 'Cetaphil',
                'Dove', 'Pantene', 'TRESemme', 'Vaseline', 'Brasov', 'Rexona', 'Pepsodent', 'Promag', 'Panadol', 'Hansaplast'
            ), ' ', variant_idx + 1, '00mg'
        )
        WHEN 4 THEN CONCAT(
            ELT(prod_idx + 1,
                'Panci Set', 'Wajan Anti Lengket', 'Kompor Gas', 'Rice Cooker', 'Blender',
                'Mixer', 'Setrika', 'Vacuum Cleaner', 'Kipas Angin', 'AC Portable',
                'Dispenser', 'Kulkas Mini', 'Microwave', 'Oven Listrik', 'Air Fryer',
                'Piring Set', 'Gelas Set', 'Sendok Garpu Set', 'Toples Kaca', 'Rak Bumbu'
            ), ' ',
            ELT(brand_idx + 1,
                'Maxim', 'Kirin', 'Rinnai', 'Miyako', 'Philips', 'Signora', 'Panasonic', 'Sharp', 'Cosmos', 'Midea',
                'Sanken', 'Polytron', 'Samsung', 'LG', 'Oxone', 'IKEA', 'Tupperware', 'Oxo', 'Lock & Lock', 'Ace Hardware'
            ), ' ',
            ELT((variant_idx MOD 5) + 1, 'Basic', 'Standard', 'Premium', 'Pro', 'Elite')
        )
        ELSE CONCAT(
            ELT(prod_idx + 1,
                'Sepatu Running', 'Sepatu Futsal', 'Sepatu Basket', 'Raket Badminton', 'Raket Tenis',
                'Bola Sepak', 'Bola Basket', 'Bola Voli', 'Dumbbell Set', 'Barbell',
                'Matras Yoga', 'Resistance Band', 'Skipping Rope', 'Hand Grip', 'Gym Gloves',
                'Tas Gym', 'Botol Minum Sport', 'Kaos Olahraga', 'Celana Training', 'Jaket Windbreaker'
            ), ' ',
            ELT(brand_idx + 1,
                'Nike', 'Adidas', 'Puma', 'Yonex', 'Wilson', 'Mikasa', 'Molten', 'Kettler', 'Bowflex', 'Reebok',
                'Under Armour', 'Speedo', 'Arena', 'Decathlon', 'Li-Ning', 'Specs', 'Mizuno', 'Asics', 'New Balance', 'Columbia'
            ), ' ',
            ELT((variant_idx MOD 5) + 1, 'Lite', 'Pro', 'Elite', 'Max', 'Ultra')
        )
    END AS product_name,
    -- Category ID (lookup from category table)
    (SELECT category_id FROM category WHERE category_code = ELT(cat_idx + 1, 'CAT001', 'CAT002', 'CAT003', 'CAT004', 'CAT005', 'CAT006')) AS category_id,
    -- Brand based on category
    CASE cat_idx
        WHEN 0 THEN ELT(brand_idx + 1,
            'Samsung', 'Apple', 'Xiaomi', 'Oppo', 'Vivo', 'Realme', 'Asus', 'Lenovo', 'HP', 'Dell',
            'LG', 'Sony', 'JBL', 'Logitech', 'Anker', 'SanDisk', 'TP-Link', 'TCL', 'ViewSonic', 'DJI'
        )
        WHEN 1 THEN ELT(brand_idx + 1,
            'Uniqlo', 'H&M', 'Zara', 'Cotton On', 'Pull&Bear', 'Bershka', 'Mango', 'GAP', 'Levi\'s', 'Guess',
            'Calvin Klein', 'Tommy Hilfiger', 'Lacoste', 'Ralph Lauren', 'Nike', 'Adidas', 'Puma', 'New Balance', 'Under Armour', 'Fila'
        )
        WHEN 2 THEN ELT(brand_idx + 1,
            'Indomie', 'Khong Guan', 'Kapal Api', 'Sariwangi', 'Ultra Milk', 'Nestle', 'Cadbury', 'Lays', 'Garuda', 'Tango',
            'Coca Cola', 'Buavita', 'Aqua', 'Kratingdaeng', 'Cimory', 'Walls', 'Sari Roti', 'Skippy', 'Madu TJ', 'ABC'
        )
        WHEN 3 THEN ELT(brand_idx + 1,
            'Blackmores', 'Nature\'s Way', 'Centrum', 'Wellness', 'Youvit', 'Somethinc', 'Wardah', 'Emina', 'Skin Aqua', 'Cetaphil',
            'Dove', 'Pantene', 'TRESemme', 'Vaseline', 'Brasov', 'Rexona', 'Pepsodent', 'Promag', 'Panadol', 'Hansaplast'
        )
        WHEN 4 THEN ELT(brand_idx + 1,
            'Maxim', 'Kirin', 'Rinnai', 'Miyako', 'Philips', 'Signora', 'Panasonic', 'Sharp', 'Cosmos', 'Midea',
            'Sanken', 'Polytron', 'Samsung', 'LG', 'Oxone', 'IKEA', 'Tupperware', 'Oxo', 'Lock & Lock', 'Ace Hardware'
        )
        ELSE ELT(brand_idx + 1,
            'Nike', 'Adidas', 'Puma', 'Yonex', 'Wilson', 'Mikasa', 'Molten', 'Kettler', 'Bowflex', 'Reebok',
            'Under Armour', 'Speedo', 'Arena', 'Decathlon', 'Li-Ning', 'Specs', 'Mizuno', 'Asics', 'New Balance', 'Columbia'
        )
    END AS brand,
    -- Description
    'Produk berkualitas tinggi dengan garansi resmi. Cocok untuk kebutuhan sehari-hari.' AS description,
    -- Purchase Price (varies by category)
    CASE cat_idx
        WHEN 0 THEN CAST((500000 + (n * 1000) MOD 9500000) AS DECIMAL(15,2))  -- Elektronik: 500K - 10M
        WHEN 1 THEN CAST((50000 + (n * 100) MOD 450000) AS DECIMAL(15,2))     -- Fashion: 50K - 500K
        WHEN 2 THEN CAST((5000 + (n * 10) MOD 95000) AS DECIMAL(15,2))        -- Makanan: 5K - 100K
        WHEN 3 THEN CAST((25000 + (n * 50) MOD 475000) AS DECIMAL(15,2))      -- Kesehatan: 25K - 500K
        WHEN 4 THEN CAST((100000 + (n * 200) MOD 1900000) AS DECIMAL(15,2))   -- Rumah Tangga: 100K - 2M
        ELSE CAST((150000 + (n * 300) MOD 1350000) AS DECIMAL(15,2))          -- Olahraga: 150K - 1.5M
    END AS purchase_price,
    -- Selling Price (markup 20-40%)
    CASE cat_idx
        WHEN 0 THEN CAST(((500000 + (n * 1000) MOD 9500000) * (1.2 + (n MOD 21) * 0.01)) AS DECIMAL(15,2))
        WHEN 1 THEN CAST(((50000 + (n * 100) MOD 450000) * (1.25 + (n MOD 16) * 0.01)) AS DECIMAL(15,2))
        WHEN 2 THEN CAST(((5000 + (n * 10) MOD 95000) * (1.3 + (n MOD 11) * 0.01)) AS DECIMAL(15,2))
        WHEN 3 THEN CAST(((25000 + (n * 50) MOD 475000) * (1.25 + (n MOD 16) * 0.01)) AS DECIMAL(15,2))
        WHEN 4 THEN CAST(((100000 + (n * 200) MOD 1900000) * (1.2 + (n MOD 21) * 0.01)) AS DECIMAL(15,2))
        ELSE CAST(((150000 + (n * 300) MOD 1350000) * (1.25 + (n MOD 16) * 0.01)) AS DECIMAL(15,2))
    END AS selling_price,
    -- Stock (10 - 500)
    (10 + (n * 7) MOD 491) AS stock,
    -- Min Stock (5 - 50)
    (5 + (n MOD 46)) AS min_stock,
    -- UOM
    CASE
        WHEN cat_idx = 2 THEN ELT(((n / 6) MOD 5) + 1, 'pcs', 'box', 'pack', 'kg', 'liter')
        ELSE 'pcs'
    END AS uom,
    -- Weight in grams
    CASE cat_idx
        WHEN 0 THEN CAST((100 + (n * 10) MOD 4900) AS DECIMAL(10,2))   -- Elektronik: 100g - 5kg
        WHEN 1 THEN CAST((50 + (n * 5) MOD 450) AS DECIMAL(10,2))      -- Fashion: 50g - 500g
        WHEN 2 THEN CAST((50 + (n * 20) MOD 4950) AS DECIMAL(10,2))    -- Makanan: 50g - 5kg
        WHEN 3 THEN CAST((20 + (n * 5) MOD 480) AS DECIMAL(10,2))      -- Kesehatan: 20g - 500g
        WHEN 4 THEN CAST((200 + (n * 50) MOD 9800) AS DECIMAL(10,2))   -- Rumah Tangga: 200g - 10kg
        ELSE CAST((100 + (n * 30) MOD 4900) AS DECIMAL(10,2))          -- Olahraga: 100g - 5kg
    END AS weight,
    -- is_active (95% active)
    CASE WHEN n MOD 20 != 0 THEN 'true' ELSE 'false' END AS is_active,
    -- show_in_store (90% shown)
    CASE WHEN n MOD 10 != 0 THEN 'true' ELSE 'false' END AS show_in_store,
    -- Barcode: 899 + 10 digits
    CONCAT('899', LPAD(n, 10, '0')) AS barcode,
    -- Shelf Location: A-F + row 1-10 + column 01-20
    CONCAT(
        CHAR(65 + (n MOD 6)),
        FLOOR(n / 6) MOD 10 + 1,
        '-',
        LPAD(FLOOR(n / 60) MOD 20 + 1, 2, '0')
    ) AS shelf_location,
    -- Notes
    CASE
        WHEN n MOD 20 = 0 THEN 'Produk tidak aktif - discontinued'
        WHEN n MOD 15 = 0 THEN 'Best seller bulan ini'
        WHEN n MOD 10 = 0 THEN 'Stok terbatas'
        WHEN n MOD 7 = 0 THEN 'Produk baru'
        ELSE NULL
    END AS notes,
    -- created_by
    'SYSTEM' AS created_by
FROM product_data;

-- ============================================================================
-- SAMPLE DATA - STOCK INBOUND TRANSACTIONS (MASTER-DETAIL)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Transaction 1: INB/2026/001 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/001', '2026-01-02',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP001'),
    'PO/2026/001', 'Pembelian laptop dan monitor untuk kantor pusat',
    2, 30.000, 170000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/001'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    10.000, 'pcs', 12000000.00, 120000000.00,
    'Laptop untuk tim development', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/001'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0007'),
    20.000, 'pcs', 2500000.00, 50000000.00,
    'Monitor untuk workstation', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 2: INB/2026/002 - Single Item
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/002', '2026-01-03',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP001'),
    'PO/2026/002', 'Keyboard wireless untuk seluruh staff',
    1, 50.000, 22500000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
) VALUES (
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/002'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0013'),
    50.000, 'pcs', 450000.00, 22500000.00,
    'Keyboard untuk replacement', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 3: INB/2026/003 - Multiple Items (3 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/003', '2026-01-06',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH002'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP002'),
    'PO/2026/003', 'Peralatan peripheral untuk kantor cabang Surabaya',
    3, 70.000, 100500000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/003'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0019'),
    30.000, 'pcs', 1200000.00, 36000000.00,
    'Mouse ergonomic untuk designer', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/003'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0025'),
    25.000, 'pcs', 1500000.00, 37500000.00,
    'Webcam untuk meeting room', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/003'),
    3,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0031'),
    15.000, 'pcs', 1800000.00, 27000000.00,
    'Headset untuk customer service', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 4: INB/2026/004 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/004', '2026-01-09',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH003'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP003'),
    'PO/2026/004', 'Peralatan networking untuk kantor Medan',
    2, 52.000, 40400000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/004'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0037'),
    40.000, 'pcs', 650000.00, 26000000.00,
    'Router untuk setiap lantai', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/004'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0043'),
    12.000, 'pcs', 1200000.00, 14400000.00,
    'Switch untuk server room', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 5: INB/2026/005 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/005', '2026-01-10',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP003'),
    'PO/2026/005', 'UPS dan kabel untuk data center',
    2, 13.000, 29900000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/005'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0049'),
    8.000, 'pcs', 2800000.00, 22400000.00,
    'UPS untuk server rack', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/005'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0055'),
    5.000, 'box', 1500000.00, 7500000.00,
    'Kabel Cat6 untuk instalasi baru', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 6: INB/2026/006 - Draft Transaction (Multiple Items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/006', '2026-01-11',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH002'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP001'),
    'PO/2026/006', 'Pembelian laptop tambahan - belum dikonfirmasi',
    2, 15.000, 85000000.00,
    'draft', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/006'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    5.000, 'pcs', 12000000.00, 60000000.00,
    'Laptop untuk tim baru', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/006'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0007'),
    10.000, 'pcs', 2500000.00, 25000000.00,
    'Monitor untuk workstation baru', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 7: INB/2026/007 - Draft Transaction (Single Item)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/007', '2026-01-13',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP002'),
    'PO/2026/007', 'Webcam tambahan - menunggu approval',
    1, 10.000, 15000000.00,
    'draft', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
) VALUES (
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/007'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0025'),
    10.000, 'pcs', 1500000.00, 15000000.00,
    'Webcam untuk ekspansi meeting room', 'SYSTEM'
);

-- ============================================================================
-- SAMPLE DATA - STOCK OUTBOUND TRANSACTIONS (MASTER-DETAIL)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Transaction 1: OUT/2026/001 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/001', '2026-01-04',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST001'),
    'SO/2026/001', 'Pengiriman laptop dan mouse untuk PT Pelanggan Setia',
    2, 15.000, 90000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/001'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    5.000, 'pcs', 15000000.00, 75000000.00,
    'Laptop untuk kantor pusat client', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/001'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0019'),
    10.000, 'pcs', 1500000.00, 15000000.00,
    'Mouse wireless untuk staff client', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 2: OUT/2026/002 - Single Item
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/002', '2026-01-05',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST001'),
    'SO/2026/002', 'Pengiriman monitor tambahan',
    1, 8.000, 24000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
) VALUES (
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/002'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0007'),
    8.000, 'pcs', 3000000.00, 24000000.00,
    'Monitor LED untuk workstation client', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 3: OUT/2026/003 - Multiple Items (3 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/003', '2026-01-07',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH002'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST002'),
    'SO/2026/003', 'Pengiriman peralatan kantor cabang Surabaya',
    3, 45.000, 58000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/003'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0013'),
    20.000, 'pcs', 550000.00, 11000000.00,
    'Keyboard untuk seluruh staff', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/003'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0025'),
    15.000, 'pcs', 1800000.00, 27000000.00,
    'Webcam untuk meeting room', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/003'),
    3,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0031'),
    10.000, 'pcs', 2000000.00, 20000000.00,
    'Headphone untuk customer service', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 4: OUT/2026/004 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/004', '2026-01-09',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH003'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST003'),
    'SO/2026/004', 'Pengiriman networking equipment ke Medan',
    2, 25.000, 23500000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/004'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0037'),
    20.000, 'pcs', 800000.00, 16000000.00,
    'Router untuk setiap lantai gedung', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/004'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0043'),
    5.000, 'pcs', 1500000.00, 7500000.00,
    'Switch managed untuk server room', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 5: OUT/2026/005 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/005', '2026-01-11',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST003'),
    'SO/2026/005', 'Pengiriman storage dan kabel ke Medan',
    2, 18.000, 27000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/005'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0049'),
    3.000, 'pcs', 3500000.00, 10500000.00,
    'UPS untuk server rack client', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/005'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0055'),
    15.000, 'box', 1100000.00, 16500000.00,
    'Kabel Cat6 untuk instalasi gedung baru', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 6: OUT/2026/006 - Draft Transaction (Multiple Items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/006', '2026-01-12',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH002'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST001'),
    'SO/2026/006', 'Pengiriman tablet dan charger - belum dikonfirmasi',
    2, 22.000, 42000000.00,
    'draft', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
) VALUES
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/006'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    2.000, 'pcs', 15000000.00, 30000000.00,
    'Laptop untuk tim marketing client', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/006'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0013'),
    20.000, 'pcs', 600000.00, 12000000.00,
    'Keyboard untuk replacement', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- Transaction 7: OUT/2026/007 - Draft Transaction (Single Item)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/007', '2026-01-14',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST002'),
    'SO/2026/007', 'Pengiriman speaker - menunggu approval',
    1, 12.000, 21600000.00,
    'draft', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
) VALUES (
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/007'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0025'),
    12.000, 'pcs', 1800000.00, 21600000.00,
    'Webcam untuk ekspansi meeting room client', 'SYSTEM'
);

-- ============================================================================
-- PROCESSOR TEST DATA
-- ============================================================================
-- Data tambahan untuk menguji processor pada tutorial processor-tutorial.md
-- Meliputi: stock_beginning_balance, update stok produk untuk skenario
-- low-stock alert, dan transaksi tambahan Januari-Maret 2026.
-- ============================================================================

-- ============================================================================
-- UPDATE STOK PRODUK UNTUK SKENARIO TEST
-- ============================================================================

-- Produk dengan stok normal (untuk stock card, confirm, transfer)
UPDATE item_product SET stock = 100, min_stock = 10 WHERE product_code = 'PRD-0001';
UPDATE item_product SET stock = 75,  min_stock = 10 WHERE product_code = 'PRD-0007';
UPDATE item_product SET stock = 50,  min_stock = 10 WHERE product_code = 'PRD-0013';
UPDATE item_product SET stock = 120, min_stock = 15 WHERE product_code = 'PRD-0019';
UPDATE item_product SET stock = 60,  min_stock = 10 WHERE product_code = 'PRD-0025';

-- Produk dengan stok rendah (untuk low-stock alert)
UPDATE item_product SET stock = 0,   min_stock = 10 WHERE product_code = 'PRD-0031';  -- CRITICAL: stok habis
UPDATE item_product SET stock = 3,   min_stock = 15 WHERE product_code = 'PRD-0037';  -- WARNING: stok < min
UPDATE item_product SET stock = 5,   min_stock = 10 WHERE product_code = 'PRD-0043';  -- WARNING: stok <= min
UPDATE item_product SET stock = 8,   min_stock = 10 WHERE product_code = 'PRD-0049';  -- WARNING: stok < min

-- Produk dengan stok kecil (untuk test cancel-inbound gagal)
UPDATE item_product SET stock = 5,   min_stock = 10 WHERE product_code = 'PRD-0055';

-- ============================================================================
-- STOCK BEGINNING BALANCE
-- ============================================================================
-- Saldo awal untuk stock card processor (Contoh 1)

INSERT INTO stock_beginning_balance (item_product_id, warehouse_id, period_date, qty_beginning, notes, created_by)
VALUES
(
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    '2026-01-01', 50.000, 'Saldo awal Januari 2026', 'SYSTEM'
),
(
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0007'),
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    '2026-01-01', 30.000, 'Saldo awal Januari 2026', 'SYSTEM'
),
(
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0013'),
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    '2026-01-01', 20.000, 'Saldo awal Januari 2026', 'SYSTEM'
),
(
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH002'),
    '2026-01-01', 25.000, 'Saldo awal Januari 2026 - Transit', 'SYSTEM'
);

-- ============================================================================
-- STOCK INBOUND - TRANSAKSI JANUARI-MARET 2026
-- ============================================================================

-- ----------------------------------------------------------------------------
-- INB/2026/008: Confirmed, WH001, 15 Jan 2026 (3 items)
-- Test: Stock Card, Cancel Inbound (stok cukup)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/008', '2026-02-15',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP001'),
    'PO/2026/008', 'Penerimaan laptop dan monitor batch pertama',
    3, 75.000, 180000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/008'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    30.000, 'pcs', 12000000.00, 360000000.00,
    'Laptop batch 1', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/008'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0007'),
    25.000, 'pcs', 2500000.00, 62500000.00,
    'Monitor batch 1', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/008'),
    3,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0013'),
    20.000, 'pcs', 450000.00, 9000000.00,
    'Keyboard batch 1', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- INB/2026/009: Confirmed, WH001, 3 Feb 2026 (1 item)
-- Test: Stock Card (tambahan movement)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/009', '2026-03-03',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP002'),
    'PO/2026/009', 'Tambahan stok laptop',
    1, 25.000, 300000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
) VALUES (
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/009'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    25.000, 'pcs', 12000000.00, 300000000.00,
    'Laptop tambahan', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- INB/2026/010: Confirmed, WH001, 5 Mar 2026 (1 item)
-- Test: Stock Card (movement bulan Maret)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/010', '2026-04-05',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP001'),
    'PO/2026/010', 'Restok laptop Maret',
    1, 20.000, 240000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
) VALUES (
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/010'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    20.000, 'pcs', 12000000.00, 240000000.00,
    'Laptop restok Maret', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- INB/2026/011: Confirmed, WH002, 20 Jan 2026 (2 items)
-- Test: Stock Card (multi-warehouse), Stock Valuation (warehouse)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/011', '2026-02-20',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH002'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP003'),
    'PO/2026/011', 'Stok untuk gudang transit Surabaya',
    2, 45.000, 60000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/011'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    15.000, 'pcs', 12000000.00, 180000000.00,
    'Laptop untuk cabang Surabaya', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/011'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0019'),
    30.000, 'pcs', 1200000.00, 36000000.00,
    'Mouse untuk cabang Surabaya', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- INB/2026/012: Confirmed, WH001 (2 items)
-- Test: Cancel Inbound GAGAL (PRD-0055 stok=5, qty_received=20)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/012', '2026-03-10',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP001'),
    'PO/2026/012', 'Inbound yang stoknya sudah sebagian keluar',
    2, 35.000, 50000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/012'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0055'),
    20.000, 'pcs', 1500000.00, 30000000.00,
    'Kabel yang sebagian sudah dikirim', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/012'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0025'),
    15.000, 'pcs', 1500000.00, 22500000.00,
    'Webcam batch tambahan', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- INB/2026/013: Draft, WH001, 10 Mar 2026 (3 items)
-- Test: Confirm Inbound (skenario sukses)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/013', '2026-04-10',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP001'),
    'PO/2026/013', 'Penerimaan barang baru - menunggu konfirmasi',
    3, 55.000, 85000000.00,
    'draft', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
) VALUES
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/013'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    20.000, 'pcs', 12000000.00, 240000000.00,
    'Laptop untuk tim engineering', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/013'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0007'),
    15.000, 'pcs', 2500000.00, 37500000.00,
    'Monitor untuk workstation baru', 'SYSTEM'
),
(
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/013'),
    3,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0013'),
    20.000, 'pcs', 450000.00, 9000000.00,
    'Keyboard mechanical', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- INB/2026/014: Draft, WH002, 12 Mar 2026 (1 item)
-- Test: Confirm Inbound (skenario draft kedua)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'INB/2026/014', '2026-04-12',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH002'),
    (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP002'),
    'PO/2026/014', 'Stok mouse untuk transit - belum dikonfirmasi',
    1, 40.000, 48000000.00,
    'draft', 'SYSTEM'
);

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
) VALUES (
    (SELECT stock_inbound_id FROM stock_inbound WHERE inbound_number = 'INB/2026/014'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0019'),
    40.000, 'pcs', 1200000.00, 48000000.00,
    'Mouse ergonomic untuk cabang', 'SYSTEM'
);

-- ============================================================================
-- STOCK OUTBOUND - TRANSAKSI JANUARI-MARET 2026
-- ============================================================================

-- ----------------------------------------------------------------------------
-- OUT/2026/008: Confirmed, WH001, 10 Feb 2026 (2 items)
-- Test: Stock Card (outbound movement)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/008', '2026-03-10',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST001'),
    'SO/2026/008', 'Pengiriman ke PT Pelanggan Setia',
    2, 25.000, 90000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
) VALUES
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/008'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    15.000, 'pcs', 15000000.00, 225000000.00,
    'Laptop untuk kantor pusat client', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/008'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0007'),
    10.000, 'pcs', 3000000.00, 30000000.00,
    'Monitor untuk client', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- OUT/2026/009: Confirmed, WH001, 22 Feb 2026 (1 item)
-- Test: Stock Card (outbound kedua)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/009', '2026-03-22',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST002'),
    'SO/2026/009', 'Pengiriman ke CV Toko Makmur',
    1, 10.000, 150000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
) VALUES (
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/009'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    10.000, 'pcs', 15000000.00, 150000000.00,
    'Laptop batch kedua', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- OUT/2026/010: Confirmed, WH001, 12 Mar 2026 (2 items)
-- Test: Stock Card (outbound Maret)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/010', '2026-04-12',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST003'),
    'SO/2026/010', 'Pengiriman ke PT Retail Nusantara',
    2, 40.000, 90000000.00,
    'confirmed', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
) VALUES
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/010'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    35.000, 'pcs', 15000000.00, 525000000.00,
    'Laptop untuk ekspansi kantor', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/010'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0013'),
    5.000, 'pcs', 550000.00, 2750000.00,
    'Keyboard untuk staff baru', 'SYSTEM'
);

-- ----------------------------------------------------------------------------
-- OUT/2026/011: Draft, WH001, 13 Mar 2026 (2 items)
-- Test: Confirm Outbound (skenario sukses)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
) VALUES (
    'OUT/2026/011', '2026-04-13',
    (SELECT warehouse_id FROM warehouse WHERE warehouse_code = 'WH001'),
    (SELECT customer_id FROM customer WHERE customer_code = 'CST001'),
    'SO/2026/011', 'Pengiriman menunggu konfirmasi',
    2, 12.000, 42000000.00,
    'draft', 'SYSTEM'
);

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
) VALUES
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/011'),
    1,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0001'),
    5.000, 'pcs', 15000000.00, 75000000.00,
    'Laptop untuk client', 'SYSTEM'
),
(
    (SELECT stock_outbound_id FROM stock_outbound WHERE outbound_number = 'OUT/2026/011'),
    2,
    (SELECT item_product_id FROM item_product WHERE product_code = 'PRD-0019'),
    7.000, 'pcs', 1500000.00, 10500000.00,
    'Mouse untuk client', 'SYSTEM'
);

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
