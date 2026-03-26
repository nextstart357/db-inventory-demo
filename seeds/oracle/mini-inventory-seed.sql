-- ============================================================================
-- MINI INVENTORY SEED DATA (ORACLE)
-- ============================================================================
-- Version: 4.0
-- Created: 2025-12-10
-- Updated: 2026-02-17
-- Description: Sample/seed data for mini inventory database (Master-Detail)
-- Platform: Oracle Database 12c+
-- Prerequisites: Run mini-inventory.sql schema first
-- ============================================================================

SET DEFINE OFF;

-- ============================================================================
-- SAMPLE DATA - CATEGORIES
-- ============================================================================

INSERT INTO category (category_code, category_name, description, created_by)
VALUES ('CAT001', 'Elektronik', 'Produk elektronik dan gadget seperti smartphone, laptop, tablet, dll', 'SYSTEM');

INSERT INTO category (category_code, category_name, description, created_by)
VALUES ('CAT002', 'Fashion', 'Produk pakaian dan aksesoris fashion', 'SYSTEM');

INSERT INTO category (category_code, category_name, description, created_by)
VALUES ('CAT003', 'Makanan', 'Produk makanan dan minuman', 'SYSTEM');

INSERT INTO category (category_code, category_name, description, created_by)
VALUES ('CAT004', 'Kesehatan', 'Produk kesehatan, vitamin, dan perawatan tubuh', 'SYSTEM');

INSERT INTO category (category_code, category_name, description, created_by)
VALUES ('CAT005', 'Rumah Tangga', 'Produk peralatan rumah tangga dan dapur', 'SYSTEM');

INSERT INTO category (category_code, category_name, description, created_by)
VALUES ('CAT006', 'Olahraga', 'Produk perlengkapan olahraga dan fitness', 'SYSTEM');

COMMIT;

-- ============================================================================
-- SAMPLE DATA - CUSTOMERS
-- ============================================================================

INSERT INTO customer (customer_code, customer_name, contact_person, phone, email, city, register_date, amount_receivable, created_by)
VALUES ('CST001', 'PT Pelanggan Setia', 'Ahmad Rizki', '021-11223344', 'ahmad@pelanggansetia.com', 'Jakarta', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 12000000.00, 'SYSTEM');

INSERT INTO customer (customer_code, customer_name, contact_person, phone, email, city, register_date, amount_receivable, created_by)
VALUES ('CST002', 'CV Toko Makmur', 'Siti Rahayu', '031-55667788', 'siti@tokomakmur.com', 'Surabaya', TO_DATE('2024-04-15', 'YYYY-MM-DD'), 5500000.00, 'SYSTEM');

INSERT INTO customer (customer_code, customer_name, contact_person, phone, email, city, register_date, amount_receivable, created_by)
VALUES ('CST003', 'PT Retail Nusantara', 'Budi Santoso', '061-99887766', 'budi@retailnusantara.com', 'Medan', TO_DATE('2024-07-20', 'YYYY-MM-DD'), 18000000.00, 'SYSTEM');

COMMIT;

-- ============================================================================
-- SAMPLE DATA - SUPPLIERS
-- ============================================================================

INSERT INTO supplier (supplier_code, supplier_name, contact_person, phone, email, city, register_date, amount_payable, created_by)
VALUES ('SUP001', 'PT Supplier Utama', 'John Doe', '021-12345678', 'john@supplier1.com', 'Jakarta', TO_DATE('2024-01-15', 'YYYY-MM-DD'), 15000000.00, 'SYSTEM');

INSERT INTO supplier (supplier_code, supplier_name, contact_person, phone, email, city, register_date, amount_payable, created_by)
VALUES ('SUP002', 'CV Mitra Sejahtera', 'Jane Smith', '021-87654321', 'jane@mitra.com', 'Bandung', TO_DATE('2024-03-20', 'YYYY-MM-DD'), 8500000.00, 'SYSTEM');

INSERT INTO supplier (supplier_code, supplier_name, contact_person, phone, email, city, register_date, amount_payable, created_by)
VALUES ('SUP003', 'PT Global Teknologi', 'Michael Chen', '021-55667788', 'michael@globaltek.com', 'Jakarta', TO_DATE('2024-06-10', 'YYYY-MM-DD'), 25000000.00, 'SYSTEM');

COMMIT;

-- ============================================================================
-- SAMPLE DATA - WAREHOUSES
-- ============================================================================

INSERT INTO warehouse (warehouse_code, warehouse_name, warehouse_type, city, capacity, created_by)
VALUES ('WH001', 'Gudang Pusat Jakarta', 'main', 'Jakarta', 1000.00, 'SYSTEM');

INSERT INTO warehouse (warehouse_code, warehouse_name, warehouse_type, city, capacity, created_by)
VALUES ('WH002', 'Gudang Transit Surabaya', 'transit', 'Surabaya', 500.00, 'SYSTEM');

INSERT INTO warehouse (warehouse_code, warehouse_name, warehouse_type, city, capacity, created_by)
VALUES ('WH003', 'Gudang Konsinyasi Medan', 'consignment', 'Medan', 300.00, 'SYSTEM');

COMMIT;

-- ============================================================================
-- SAMPLE DATA - ITEM PRODUCTS (600 Products using PL/SQL)
-- ============================================================================

DECLARE
    v_product_name VARCHAR2(200);
    v_category_id VARCHAR2(70);
    v_category_code VARCHAR2(20);
    v_brand VARCHAR2(50);
    v_purchase_price NUMBER(15,2);
    v_selling_price NUMBER(15,2);
    v_uom VARCHAR2(10);
    v_weight NUMBER(10,2);
    v_is_active VARCHAR2(5);
    v_show_in_store VARCHAR2(5);
    v_notes VARCHAR2(500);
    v_cat_idx NUMBER;
    v_brand_idx NUMBER;

    TYPE t_names IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
    TYPE t_brands IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
    TYPE t_variants IS TABLE OF VARCHAR2(20) INDEX BY PLS_INTEGER;
    TYPE t_category_codes IS TABLE OF VARCHAR2(20) INDEX BY PLS_INTEGER;

    v_category_codes t_category_codes;

    v_elektronik_names t_names;
    v_fashion_names t_names;
    v_makanan_names t_names;
    v_kesehatan_names t_names;
    v_rumah_tangga_names t_names;
    v_olahraga_names t_names;

    v_elektronik_brands t_brands;
    v_fashion_brands t_brands;
    v_makanan_brands t_brands;
    v_kesehatan_brands t_brands;
    v_rumah_tangga_brands t_brands;
    v_olahraga_brands t_brands;

    v_fashion_variants t_variants;
    v_makanan_variants t_variants;
    v_rumah_tangga_variants t_variants;
    v_olahraga_variants t_variants;
BEGIN
    -- Initialize elektronik names
    v_elektronik_names(1) := 'Smartphone'; v_elektronik_names(2) := 'Laptop'; v_elektronik_names(3) := 'Tablet';
    v_elektronik_names(4) := 'Smartwatch'; v_elektronik_names(5) := 'Earbuds TWS'; v_elektronik_names(6) := 'Power Bank';
    v_elektronik_names(7) := 'Charger Fast'; v_elektronik_names(8) := 'Kabel USB-C'; v_elektronik_names(9) := 'Mouse Wireless';
    v_elektronik_names(10) := 'Keyboard Mechanical'; v_elektronik_names(11) := 'Monitor LED'; v_elektronik_names(12) := 'Webcam HD';
    v_elektronik_names(13) := 'Speaker Bluetooth'; v_elektronik_names(14) := 'Headphone Gaming'; v_elektronik_names(15) := 'SSD External';
    v_elektronik_names(16) := 'Flash Drive'; v_elektronik_names(17) := 'Router WiFi'; v_elektronik_names(18) := 'Smart TV';
    v_elektronik_names(19) := 'Proyektor Mini'; v_elektronik_names(20) := 'Drone Camera';

    v_elektronik_brands(1) := 'Samsung'; v_elektronik_brands(2) := 'Apple'; v_elektronik_brands(3) := 'Xiaomi';
    v_elektronik_brands(4) := 'Oppo'; v_elektronik_brands(5) := 'Vivo'; v_elektronik_brands(6) := 'Realme';
    v_elektronik_brands(7) := 'Asus'; v_elektronik_brands(8) := 'Lenovo'; v_elektronik_brands(9) := 'HP';
    v_elektronik_brands(10) := 'Dell'; v_elektronik_brands(11) := 'LG'; v_elektronik_brands(12) := 'Sony';
    v_elektronik_brands(13) := 'JBL'; v_elektronik_brands(14) := 'Logitech'; v_elektronik_brands(15) := 'Anker';
    v_elektronik_brands(16) := 'SanDisk'; v_elektronik_brands(17) := 'TP-Link'; v_elektronik_brands(18) := 'TCL';
    v_elektronik_brands(19) := 'ViewSonic'; v_elektronik_brands(20) := 'DJI';

    -- Initialize fashion names
    v_fashion_names(1) := 'Kaos Polos'; v_fashion_names(2) := 'Kemeja Formal'; v_fashion_names(3) := 'Celana Jeans';
    v_fashion_names(4) := 'Celana Chino'; v_fashion_names(5) := 'Jaket Hoodie'; v_fashion_names(6) := 'Sweater Knit';
    v_fashion_names(7) := 'Dress Casual'; v_fashion_names(8) := 'Rok Mini'; v_fashion_names(9) := 'Blazer Slim';
    v_fashion_names(10) := 'Cardigan'; v_fashion_names(11) := 'Polo Shirt'; v_fashion_names(12) := 'Tank Top';
    v_fashion_names(13) := 'Celana Pendek'; v_fashion_names(14) := 'Jumpsuit'; v_fashion_names(15) := 'Rompi Vest';
    v_fashion_names(16) := 'Jacket Denim'; v_fashion_names(17) := 'Celana Jogger'; v_fashion_names(18) := 'Atasan Blouse';
    v_fashion_names(19) := 'Outer Kimono'; v_fashion_names(20) := 'Tunik Modern';

    v_fashion_brands(1) := 'Uniqlo'; v_fashion_brands(2) := 'H&M'; v_fashion_brands(3) := 'Zara';
    v_fashion_brands(4) := 'Cotton On'; v_fashion_brands(5) := 'Pull&Bear'; v_fashion_brands(6) := 'Bershka';
    v_fashion_brands(7) := 'Mango'; v_fashion_brands(8) := 'GAP'; v_fashion_brands(9) := 'Levis';
    v_fashion_brands(10) := 'Guess'; v_fashion_brands(11) := 'Calvin Klein'; v_fashion_brands(12) := 'Tommy Hilfiger';
    v_fashion_brands(13) := 'Lacoste'; v_fashion_brands(14) := 'Ralph Lauren'; v_fashion_brands(15) := 'Nike';
    v_fashion_brands(16) := 'Adidas'; v_fashion_brands(17) := 'Puma'; v_fashion_brands(18) := 'New Balance';
    v_fashion_brands(19) := 'Under Armour'; v_fashion_brands(20) := 'Fila';

    v_fashion_variants(1) := 'Premium'; v_fashion_variants(2) := 'Basic'; v_fashion_variants(3) := 'Classic';
    v_fashion_variants(4) := 'Modern'; v_fashion_variants(5) := 'Slim Fit';

    -- Initialize makanan names
    v_makanan_names(1) := 'Mie Instan'; v_makanan_names(2) := 'Biskuit Kaleng'; v_makanan_names(3) := 'Kopi Sachet';
    v_makanan_names(4) := 'Teh Celup'; v_makanan_names(5) := 'Susu UHT'; v_makanan_names(6) := 'Sereal Box';
    v_makanan_names(7) := 'Cokelat Bar'; v_makanan_names(8) := 'Keripik Kentang'; v_makanan_names(9) := 'Kacang Panggang';
    v_makanan_names(10) := 'Wafer Cream'; v_makanan_names(11) := 'Minuman Soda'; v_makanan_names(12) := 'Jus Buah';
    v_makanan_names(13) := 'Air Mineral'; v_makanan_names(14) := 'Energy Drink'; v_makanan_names(15) := 'Yogurt Cup';
    v_makanan_names(16) := 'Es Krim'; v_makanan_names(17) := 'Roti Tawar'; v_makanan_names(18) := 'Selai Kacang';
    v_makanan_names(19) := 'Madu Murni'; v_makanan_names(20) := 'Saus Sambal';

    v_makanan_brands(1) := 'Indomie'; v_makanan_brands(2) := 'Khong Guan'; v_makanan_brands(3) := 'Kapal Api';
    v_makanan_brands(4) := 'Sariwangi'; v_makanan_brands(5) := 'Ultra Milk'; v_makanan_brands(6) := 'Nestle';
    v_makanan_brands(7) := 'Cadbury'; v_makanan_brands(8) := 'Lays'; v_makanan_brands(9) := 'Garuda';
    v_makanan_brands(10) := 'Tango'; v_makanan_brands(11) := 'Coca Cola'; v_makanan_brands(12) := 'Buavita';
    v_makanan_brands(13) := 'Aqua'; v_makanan_brands(14) := 'Kratingdaeng'; v_makanan_brands(15) := 'Cimory';
    v_makanan_brands(16) := 'Walls'; v_makanan_brands(17) := 'Sari Roti'; v_makanan_brands(18) := 'Skippy';
    v_makanan_brands(19) := 'Madu TJ'; v_makanan_brands(20) := 'ABC';

    v_makanan_variants(1) := 'Original'; v_makanan_variants(2) := 'Special'; v_makanan_variants(3) := 'Premium';
    v_makanan_variants(4) := 'Family Pack'; v_makanan_variants(5) := 'Value Pack';

    -- Initialize kesehatan names
    v_kesehatan_names(1) := 'Vitamin C'; v_kesehatan_names(2) := 'Vitamin D3'; v_kesehatan_names(3) := 'Multivitamin';
    v_kesehatan_names(4) := 'Omega 3'; v_kesehatan_names(5) := 'Probiotik'; v_kesehatan_names(6) := 'Kolagen Drink';
    v_kesehatan_names(7) := 'Masker Wajah'; v_kesehatan_names(8) := 'Serum Wajah'; v_kesehatan_names(9) := 'Sunscreen SPF50';
    v_kesehatan_names(10) := 'Pelembab Kulit'; v_kesehatan_names(11) := 'Sabun Mandi'; v_kesehatan_names(12) := 'Shampoo';
    v_kesehatan_names(13) := 'Conditioner'; v_kesehatan_names(14) := 'Body Lotion'; v_kesehatan_names(15) := 'Parfum EDT';
    v_kesehatan_names(16) := 'Deodorant'; v_kesehatan_names(17) := 'Pasta Gigi'; v_kesehatan_names(18) := 'Obat Maag';
    v_kesehatan_names(19) := 'Obat Flu'; v_kesehatan_names(20) := 'Plester Luka';

    v_kesehatan_brands(1) := 'Blackmores'; v_kesehatan_brands(2) := 'Natures Way'; v_kesehatan_brands(3) := 'Centrum';
    v_kesehatan_brands(4) := 'Wellness'; v_kesehatan_brands(5) := 'Youvit'; v_kesehatan_brands(6) := 'Somethinc';
    v_kesehatan_brands(7) := 'Wardah'; v_kesehatan_brands(8) := 'Emina'; v_kesehatan_brands(9) := 'Skin Aqua';
    v_kesehatan_brands(10) := 'Cetaphil'; v_kesehatan_brands(11) := 'Dove'; v_kesehatan_brands(12) := 'Pantene';
    v_kesehatan_brands(13) := 'TRESemme'; v_kesehatan_brands(14) := 'Vaseline'; v_kesehatan_brands(15) := 'Brasov';
    v_kesehatan_brands(16) := 'Rexona'; v_kesehatan_brands(17) := 'Pepsodent'; v_kesehatan_brands(18) := 'Promag';
    v_kesehatan_brands(19) := 'Panadol'; v_kesehatan_brands(20) := 'Hansaplast';

    -- Initialize rumah_tangga names
    v_rumah_tangga_names(1) := 'Panci Set'; v_rumah_tangga_names(2) := 'Wajan Anti Lengket'; v_rumah_tangga_names(3) := 'Kompor Gas';
    v_rumah_tangga_names(4) := 'Rice Cooker'; v_rumah_tangga_names(5) := 'Blender'; v_rumah_tangga_names(6) := 'Mixer';
    v_rumah_tangga_names(7) := 'Setrika'; v_rumah_tangga_names(8) := 'Vacuum Cleaner'; v_rumah_tangga_names(9) := 'Kipas Angin';
    v_rumah_tangga_names(10) := 'AC Portable'; v_rumah_tangga_names(11) := 'Dispenser'; v_rumah_tangga_names(12) := 'Kulkas Mini';
    v_rumah_tangga_names(13) := 'Microwave'; v_rumah_tangga_names(14) := 'Oven Listrik'; v_rumah_tangga_names(15) := 'Air Fryer';
    v_rumah_tangga_names(16) := 'Piring Set'; v_rumah_tangga_names(17) := 'Gelas Set'; v_rumah_tangga_names(18) := 'Sendok Garpu Set';
    v_rumah_tangga_names(19) := 'Toples Kaca'; v_rumah_tangga_names(20) := 'Rak Bumbu';

    v_rumah_tangga_brands(1) := 'Maxim'; v_rumah_tangga_brands(2) := 'Kirin'; v_rumah_tangga_brands(3) := 'Rinnai';
    v_rumah_tangga_brands(4) := 'Miyako'; v_rumah_tangga_brands(5) := 'Philips'; v_rumah_tangga_brands(6) := 'Signora';
    v_rumah_tangga_brands(7) := 'Panasonic'; v_rumah_tangga_brands(8) := 'Sharp'; v_rumah_tangga_brands(9) := 'Cosmos';
    v_rumah_tangga_brands(10) := 'Midea'; v_rumah_tangga_brands(11) := 'Sanken'; v_rumah_tangga_brands(12) := 'Polytron';
    v_rumah_tangga_brands(13) := 'Samsung'; v_rumah_tangga_brands(14) := 'LG'; v_rumah_tangga_brands(15) := 'Oxone';
    v_rumah_tangga_brands(16) := 'IKEA'; v_rumah_tangga_brands(17) := 'Tupperware'; v_rumah_tangga_brands(18) := 'Oxo';
    v_rumah_tangga_brands(19) := 'Lock N Lock'; v_rumah_tangga_brands(20) := 'Ace Hardware';

    v_rumah_tangga_variants(1) := 'Basic'; v_rumah_tangga_variants(2) := 'Standard'; v_rumah_tangga_variants(3) := 'Premium';
    v_rumah_tangga_variants(4) := 'Pro'; v_rumah_tangga_variants(5) := 'Elite';

    -- Initialize olahraga names
    v_olahraga_names(1) := 'Sepatu Running'; v_olahraga_names(2) := 'Sepatu Futsal'; v_olahraga_names(3) := 'Sepatu Basket';
    v_olahraga_names(4) := 'Raket Badminton'; v_olahraga_names(5) := 'Raket Tenis'; v_olahraga_names(6) := 'Bola Sepak';
    v_olahraga_names(7) := 'Bola Basket'; v_olahraga_names(8) := 'Bola Voli'; v_olahraga_names(9) := 'Dumbbell Set';
    v_olahraga_names(10) := 'Barbell'; v_olahraga_names(11) := 'Matras Yoga'; v_olahraga_names(12) := 'Resistance Band';
    v_olahraga_names(13) := 'Skipping Rope'; v_olahraga_names(14) := 'Hand Grip'; v_olahraga_names(15) := 'Gym Gloves';
    v_olahraga_names(16) := 'Tas Gym'; v_olahraga_names(17) := 'Botol Minum Sport'; v_olahraga_names(18) := 'Kaos Olahraga';
    v_olahraga_names(19) := 'Celana Training'; v_olahraga_names(20) := 'Jaket Windbreaker';

    v_olahraga_brands(1) := 'Nike'; v_olahraga_brands(2) := 'Adidas'; v_olahraga_brands(3) := 'Puma';
    v_olahraga_brands(4) := 'Yonex'; v_olahraga_brands(5) := 'Wilson'; v_olahraga_brands(6) := 'Mikasa';
    v_olahraga_brands(7) := 'Molten'; v_olahraga_brands(8) := 'Kettler'; v_olahraga_brands(9) := 'Bowflex';
    v_olahraga_brands(10) := 'Reebok'; v_olahraga_brands(11) := 'Under Armour'; v_olahraga_brands(12) := 'Speedo';
    v_olahraga_brands(13) := 'Arena'; v_olahraga_brands(14) := 'Decathlon'; v_olahraga_brands(15) := 'Li-Ning';
    v_olahraga_brands(16) := 'Specs'; v_olahraga_brands(17) := 'Mizuno'; v_olahraga_brands(18) := 'Asics';
    v_olahraga_brands(19) := 'New Balance'; v_olahraga_brands(20) := 'Columbia';

    v_olahraga_variants(1) := 'Lite'; v_olahraga_variants(2) := 'Pro'; v_olahraga_variants(3) := 'Elite';
    v_olahraga_variants(4) := 'Max'; v_olahraga_variants(5) := 'Ultra';

    -- Initialize category codes (index 0-5 maps to CAT001-CAT006)
    v_category_codes(0) := 'CAT001'; -- elektronik
    v_category_codes(1) := 'CAT002'; -- fashion
    v_category_codes(2) := 'CAT003'; -- makanan
    v_category_codes(3) := 'CAT004'; -- kesehatan
    v_category_codes(4) := 'CAT005'; -- rumah_tangga
    v_category_codes(5) := 'CAT006'; -- olahraga

    FOR n IN 1..600 LOOP
        v_cat_idx := MOD(n, 6);
        v_brand_idx := MOD(TRUNC(n / 6), 20) + 1;

        -- Determine category_code and lookup category_id
        v_category_code := v_category_codes(v_cat_idx);
        SELECT category_id INTO v_category_id FROM category WHERE category_code = v_category_code;

        -- Determine product name based on category
        CASE v_cat_idx
            WHEN 0 THEN
                v_product_name := v_elektronik_names(v_brand_idx) || ' ' || v_elektronik_brands(v_brand_idx) || ' Series ' || TO_CHAR(TRUNC(n / 120) + 1);
                v_brand := v_elektronik_brands(v_brand_idx);
                v_purchase_price := 500000 + MOD(n * 1000, 9500000);
                v_weight := 100 + MOD(n * 10, 4900);
            WHEN 1 THEN
                v_product_name := v_fashion_names(v_brand_idx) || ' ' || v_fashion_brands(v_brand_idx) || ' ' || v_fashion_variants(MOD(TRUNC(n / 120), 5) + 1);
                v_brand := v_fashion_brands(v_brand_idx);
                v_purchase_price := 50000 + MOD(n * 100, 450000);
                v_weight := 50 + MOD(n * 5, 450);
            WHEN 2 THEN
                v_product_name := v_makanan_names(v_brand_idx) || ' ' || v_makanan_brands(v_brand_idx) || ' ' || v_makanan_variants(MOD(TRUNC(n / 120), 5) + 1);
                v_brand := v_makanan_brands(v_brand_idx);
                v_purchase_price := 5000 + MOD(n * 10, 95000);
                v_weight := 50 + MOD(n * 20, 4950);
            WHEN 3 THEN
                v_product_name := v_kesehatan_names(v_brand_idx) || ' ' || v_kesehatan_brands(v_brand_idx) || ' ' || TO_CHAR(TRUNC(n / 120) + 1) || '00mg';
                v_brand := v_kesehatan_brands(v_brand_idx);
                v_purchase_price := 25000 + MOD(n * 50, 475000);
                v_weight := 20 + MOD(n * 5, 480);
            WHEN 4 THEN
                v_product_name := v_rumah_tangga_names(v_brand_idx) || ' ' || v_rumah_tangga_brands(v_brand_idx) || ' ' || v_rumah_tangga_variants(MOD(TRUNC(n / 120), 5) + 1);
                v_brand := v_rumah_tangga_brands(v_brand_idx);
                v_purchase_price := 100000 + MOD(n * 200, 1900000);
                v_weight := 200 + MOD(n * 50, 9800);
            ELSE
                v_product_name := v_olahraga_names(v_brand_idx) || ' ' || v_olahraga_brands(v_brand_idx) || ' ' || v_olahraga_variants(MOD(TRUNC(n / 120), 5) + 1);
                v_brand := v_olahraga_brands(v_brand_idx);
                v_purchase_price := 150000 + MOD(n * 300, 1350000);
                v_weight := 100 + MOD(n * 30, 4900);
        END CASE;

        -- Calculate selling price with markup (per category, same as PostgreSQL/MySQL)
        CASE v_cat_idx
            WHEN 0 THEN v_selling_price := ROUND(v_purchase_price * (1.2  + MOD(n, 21) * 0.01), 2);  -- Elektronik
            WHEN 1 THEN v_selling_price := ROUND(v_purchase_price * (1.25 + MOD(n, 16) * 0.01), 2);  -- Fashion
            WHEN 2 THEN v_selling_price := ROUND(v_purchase_price * (1.3  + MOD(n, 11) * 0.01), 2);  -- Makanan
            WHEN 3 THEN v_selling_price := ROUND(v_purchase_price * (1.25 + MOD(n, 16) * 0.01), 2);  -- Kesehatan
            WHEN 4 THEN v_selling_price := ROUND(v_purchase_price * (1.2  + MOD(n, 21) * 0.01), 2);  -- Rumah Tangga
            ELSE        v_selling_price := ROUND(v_purchase_price * (1.25 + MOD(n, 16) * 0.01), 2);  -- Olahraga
        END CASE;

        -- UOM
        IF v_cat_idx = 2 THEN
            CASE MOD(TRUNC(n / 6), 5)
                WHEN 0 THEN v_uom := 'pcs';
                WHEN 1 THEN v_uom := 'box';
                WHEN 2 THEN v_uom := 'pack';
                WHEN 3 THEN v_uom := 'kg';
                ELSE v_uom := 'liter';
            END CASE;
        ELSE
            v_uom := 'pcs';
        END IF;

        -- is_active (95% active)
        IF MOD(n, 20) = 0 THEN
            v_is_active := 'false';
        ELSE
            v_is_active := 'true';
        END IF;

        -- show_in_store (90% shown)
        IF MOD(n, 10) = 0 THEN
            v_show_in_store := 'false';
        ELSE
            v_show_in_store := 'true';
        END IF;

        -- Notes
        IF MOD(n, 20) = 0 THEN
            v_notes := 'Produk tidak aktif - discontinued';
        ELSIF MOD(n, 15) = 0 THEN
            v_notes := 'Best seller bulan ini';
        ELSIF MOD(n, 10) = 0 THEN
            v_notes := 'Stok terbatas';
        ELSIF MOD(n, 7) = 0 THEN
            v_notes := 'Produk baru';
        ELSE
            v_notes := NULL;
        END IF;

        INSERT INTO item_product (
            product_code, sku, product_name, category_id, brand, description,
            purchase_price, selling_price, stock, min_stock, uom, weight,
            is_active, show_in_store, barcode, shelf_location, notes, created_by
        ) VALUES (
            'PRD-' || LPAD(TO_CHAR(n), 4, '0'),
            'SKU' || LPAD(TO_CHAR(n), 10, '0'),
            v_product_name,
            v_category_id,
            v_brand,
            'Produk berkualitas tinggi dengan garansi resmi. Cocok untuk kebutuhan sehari-hari.',
            v_purchase_price,
            v_selling_price,
            10 + MOD(n * 7, 491),
            5 + MOD(n, 46),
            v_uom,
            v_weight,
            v_is_active,
            v_show_in_store,
            '899' || LPAD(TO_CHAR(n), 10, '0'),
            CHR(65 + MOD(n, 6)) || TO_CHAR(MOD(TRUNC(n / 6), 10) + 1) || '-' || LPAD(TO_CHAR(MOD(TRUNC(n / 60), 20) + 1), 2, '0'),
            v_notes,
            'SYSTEM'
        );

        -- Commit every 100 records
        IF MOD(n, 100) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;

    COMMIT;
END;
/

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
)
SELECT
    'INB/2026/001', TO_DATE('2026-01-02', 'YYYY-MM-DD'),
    w.warehouse_id,
    s.supplier_id,
    'PO/2026/001', 'Pembelian laptop dan monitor untuk kantor pusat',
    2, 30.000, 170000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 1, ip.item_product_id,
    10.000, 'pcs', 12000000.00, 120000000.00,
    'Laptop untuk tim development', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/001' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 2, ip.item_product_id,
    20.000, 'pcs', 2500000.00, 50000000.00,
    'Monitor untuk workstation', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/001' AND ip.product_code = 'PRD-0007';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 2: INB/2026/002 - Single Item
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/002', TO_DATE('2026-01-03', 'YYYY-MM-DD'),
    w.warehouse_id,
    s.supplier_id,
    'PO/2026/002', 'Keyboard wireless untuk seluruh staff',
    1, 50.000, 22500000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 1, ip.item_product_id,
    50.000, 'pcs', 450000.00, 22500000.00,
    'Keyboard untuk replacement', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/002' AND ip.product_code = 'PRD-0013';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 3: INB/2026/003 - Multiple Items (3 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/003', TO_DATE('2026-01-06', 'YYYY-MM-DD'),
    w.warehouse_id,
    s.supplier_id,
    'PO/2026/003', 'Peralatan peripheral untuk kantor cabang Surabaya',
    3, 70.000, 100500000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH002' AND s.supplier_code = 'SUP002';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 1, ip.item_product_id,
    30.000, 'pcs', 1200000.00, 36000000.00,
    'Mouse ergonomic untuk designer', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/003' AND ip.product_code = 'PRD-0019';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 2, ip.item_product_id,
    25.000, 'pcs', 1500000.00, 37500000.00,
    'Webcam untuk meeting room', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/003' AND ip.product_code = 'PRD-0025';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 3, ip.item_product_id,
    15.000, 'pcs', 1800000.00, 27000000.00,
    'Headset untuk customer service', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/003' AND ip.product_code = 'PRD-0031';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 4: INB/2026/004 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/004', TO_DATE('2026-01-09', 'YYYY-MM-DD'),
    w.warehouse_id,
    s.supplier_id,
    'PO/2026/004', 'Peralatan networking untuk kantor Medan',
    2, 52.000, 40400000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH003' AND s.supplier_code = 'SUP003';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 1, ip.item_product_id,
    40.000, 'pcs', 650000.00, 26000000.00,
    'Router untuk setiap lantai', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/004' AND ip.product_code = 'PRD-0037';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 2, ip.item_product_id,
    12.000, 'pcs', 1200000.00, 14400000.00,
    'Switch untuk server room', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/004' AND ip.product_code = 'PRD-0043';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 5: INB/2026/005 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/005', TO_DATE('2026-01-10', 'YYYY-MM-DD'),
    w.warehouse_id,
    s.supplier_id,
    'PO/2026/005', 'UPS dan kabel untuk data center',
    2, 13.000, 29900000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP003';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 1, ip.item_product_id,
    8.000, 'pcs', 2800000.00, 22400000.00,
    'UPS untuk server rack', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/005' AND ip.product_code = 'PRD-0049';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 2, ip.item_product_id,
    5.000, 'box', 1500000.00, 7500000.00,
    'Kabel Cat6 untuk instalasi baru', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/005' AND ip.product_code = 'PRD-0055';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 6: INB/2026/006 - Draft Transaction (Multiple Items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/006', TO_DATE('2026-01-11', 'YYYY-MM-DD'),
    w.warehouse_id,
    s.supplier_id,
    'PO/2026/006', 'Pembelian laptop tambahan - belum dikonfirmasi',
    2, 15.000, 85000000.00,
    'draft', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH002' AND s.supplier_code = 'SUP001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 1, ip.item_product_id,
    5.000, 'pcs', 12000000.00, 60000000.00,
    'Laptop untuk tim baru', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/006' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 2, ip.item_product_id,
    10.000, 'pcs', 2500000.00, 25000000.00,
    'Monitor untuk workstation baru', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/006' AND ip.product_code = 'PRD-0007';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 7: INB/2026/007 - Draft Transaction (Single Item)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/007', TO_DATE('2026-01-13', 'YYYY-MM-DD'),
    w.warehouse_id,
    s.supplier_id,
    'PO/2026/007', 'Webcam tambahan - menunggu approval',
    1, 10.000, 15000000.00,
    'draft', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP002';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    si.stock_inbound_id, 1, ip.item_product_id,
    10.000, 'pcs', 1500000.00, 15000000.00,
    'Webcam untuk ekspansi meeting room', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/007' AND ip.product_code = 'PRD-0025';

COMMIT;

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
)
SELECT
    'OUT/2026/001', TO_DATE('2026-01-04', 'YYYY-MM-DD'),
    w.warehouse_id,
    c.customer_id,
    'SO/2026/001', 'Pengiriman laptop dan mouse untuk PT Pelanggan Setia',
    2, 15.000, 90000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH001' AND c.customer_code = 'CST001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 1, ip.item_product_id,
    5.000, 'pcs', 15000000.00, 75000000.00,
    'Laptop untuk kantor pusat client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/001' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 2, ip.item_product_id,
    10.000, 'pcs', 1500000.00, 15000000.00,
    'Mouse wireless untuk staff client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/001' AND ip.product_code = 'PRD-0019';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 2: OUT/2026/002 - Single Item
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/002', TO_DATE('2026-01-05', 'YYYY-MM-DD'),
    w.warehouse_id,
    c.customer_id,
    'SO/2026/002', 'Pengiriman monitor tambahan',
    1, 8.000, 24000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH001' AND c.customer_code = 'CST001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 1, ip.item_product_id,
    8.000, 'pcs', 3000000.00, 24000000.00,
    'Monitor LED untuk workstation client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/002' AND ip.product_code = 'PRD-0007';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 3: OUT/2026/003 - Multiple Items (3 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/003', TO_DATE('2026-01-07', 'YYYY-MM-DD'),
    w.warehouse_id,
    c.customer_id,
    'SO/2026/003', 'Pengiriman peralatan kantor cabang Surabaya',
    3, 45.000, 58000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH002' AND c.customer_code = 'CST002';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 1, ip.item_product_id,
    20.000, 'pcs', 550000.00, 11000000.00,
    'Keyboard untuk seluruh staff', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/003' AND ip.product_code = 'PRD-0013';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 2, ip.item_product_id,
    15.000, 'pcs', 1800000.00, 27000000.00,
    'Webcam untuk meeting room', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/003' AND ip.product_code = 'PRD-0025';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 3, ip.item_product_id,
    10.000, 'pcs', 2000000.00, 20000000.00,
    'Headphone untuk customer service', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/003' AND ip.product_code = 'PRD-0031';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 4: OUT/2026/004 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/004', TO_DATE('2026-01-09', 'YYYY-MM-DD'),
    w.warehouse_id,
    c.customer_id,
    'SO/2026/004', 'Pengiriman networking equipment ke Medan',
    2, 25.000, 23500000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH003' AND c.customer_code = 'CST003';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 1, ip.item_product_id,
    20.000, 'pcs', 800000.00, 16000000.00,
    'Router untuk setiap lantai gedung', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/004' AND ip.product_code = 'PRD-0037';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 2, ip.item_product_id,
    5.000, 'pcs', 1500000.00, 7500000.00,
    'Switch managed untuk server room', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/004' AND ip.product_code = 'PRD-0043';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 5: OUT/2026/005 - Multiple Items (2 items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/005', TO_DATE('2026-01-11', 'YYYY-MM-DD'),
    w.warehouse_id,
    c.customer_id,
    'SO/2026/005', 'Pengiriman storage dan kabel ke Medan',
    2, 18.000, 27000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH001' AND c.customer_code = 'CST003';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 1, ip.item_product_id,
    3.000, 'pcs', 3500000.00, 10500000.00,
    'UPS untuk server rack client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/005' AND ip.product_code = 'PRD-0049';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 2, ip.item_product_id,
    15.000, 'box', 1100000.00, 16500000.00,
    'Kabel Cat6 untuk instalasi gedung baru', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/005' AND ip.product_code = 'PRD-0055';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 6: OUT/2026/006 - Draft Transaction (Multiple Items)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/006', TO_DATE('2026-01-12', 'YYYY-MM-DD'),
    w.warehouse_id,
    c.customer_id,
    'SO/2026/006', 'Pengiriman tablet dan charger - belum dikonfirmasi',
    2, 22.000, 42000000.00,
    'draft', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH002' AND c.customer_code = 'CST001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 1, ip.item_product_id,
    2.000, 'pcs', 15000000.00, 30000000.00,
    'Laptop untuk tim marketing client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/006' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 2, ip.item_product_id,
    20.000, 'pcs', 600000.00, 12000000.00,
    'Keyboard untuk replacement', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/006' AND ip.product_code = 'PRD-0013';

COMMIT;

-- ----------------------------------------------------------------------------
-- Transaction 7: OUT/2026/007 - Draft Transaction (Single Item)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes,
    total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/007', TO_DATE('2026-01-14', 'YYYY-MM-DD'),
    w.warehouse_id,
    c.customer_id,
    'SO/2026/007', 'Pengiriman speaker - menunggu approval',
    1, 12.000, 21600000.00,
    'draft', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH001' AND c.customer_code = 'CST002';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount,
    notes, created_by
)
SELECT
    so.stock_outbound_id, 1, ip.item_product_id,
    12.000, 'pcs', 1800000.00, 21600000.00,
    'Webcam untuk ekspansi meeting room client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/007' AND ip.product_code = 'PRD-0025';

COMMIT;

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

COMMIT;

-- ============================================================================
-- STOCK BEGINNING BALANCE
-- ============================================================================
-- Saldo awal untuk stock card processor (Contoh 1)

INSERT INTO stock_beginning_balance (item_product_id, warehouse_id, period_date, qty_beginning, notes, created_by)
SELECT ip.item_product_id, w.warehouse_id, TO_DATE('2026-01-01', 'YYYY-MM-DD'), 50.000, 'Saldo awal Januari 2026', 'SYSTEM'
FROM item_product ip, warehouse w
WHERE ip.product_code = 'PRD-0001' AND w.warehouse_code = 'WH001';

INSERT INTO stock_beginning_balance (item_product_id, warehouse_id, period_date, qty_beginning, notes, created_by)
SELECT ip.item_product_id, w.warehouse_id, TO_DATE('2026-01-01', 'YYYY-MM-DD'), 30.000, 'Saldo awal Januari 2026', 'SYSTEM'
FROM item_product ip, warehouse w
WHERE ip.product_code = 'PRD-0007' AND w.warehouse_code = 'WH001';

INSERT INTO stock_beginning_balance (item_product_id, warehouse_id, period_date, qty_beginning, notes, created_by)
SELECT ip.item_product_id, w.warehouse_id, TO_DATE('2026-01-01', 'YYYY-MM-DD'), 20.000, 'Saldo awal Januari 2026', 'SYSTEM'
FROM item_product ip, warehouse w
WHERE ip.product_code = 'PRD-0013' AND w.warehouse_code = 'WH001';

INSERT INTO stock_beginning_balance (item_product_id, warehouse_id, period_date, qty_beginning, notes, created_by)
SELECT ip.item_product_id, w.warehouse_id, TO_DATE('2026-01-01', 'YYYY-MM-DD'), 25.000, 'Saldo awal Januari 2026 - Transit', 'SYSTEM'
FROM item_product ip, warehouse w
WHERE ip.product_code = 'PRD-0001' AND w.warehouse_code = 'WH002';

COMMIT;

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
)
SELECT
    'INB/2026/008', TO_DATE('2026-02-15', 'YYYY-MM-DD'),
    w.warehouse_id, s.supplier_id,
    'PO/2026/008', 'Penerimaan laptop dan monitor batch pertama',
    3, 75.000, 180000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 1, ip.item_product_id,
    30.000, 'pcs', 12000000.00, 360000000.00,
    'Laptop batch 1', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/008' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 2, ip.item_product_id,
    25.000, 'pcs', 2500000.00, 62500000.00,
    'Monitor batch 1', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/008' AND ip.product_code = 'PRD-0007';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 3, ip.item_product_id,
    20.000, 'pcs', 450000.00, 9000000.00,
    'Keyboard batch 1', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/008' AND ip.product_code = 'PRD-0013';

COMMIT;

-- ----------------------------------------------------------------------------
-- INB/2026/009: Confirmed, WH001, 3 Feb 2026 (1 item)
-- Test: Stock Card (tambahan movement)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/009', TO_DATE('2026-03-03', 'YYYY-MM-DD'),
    w.warehouse_id, s.supplier_id,
    'PO/2026/009', 'Tambahan stok laptop',
    1, 25.000, 300000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP002';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 1, ip.item_product_id,
    25.000, 'pcs', 12000000.00, 300000000.00,
    'Laptop tambahan', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/009' AND ip.product_code = 'PRD-0001';

COMMIT;

-- ----------------------------------------------------------------------------
-- INB/2026/010: Confirmed, WH001, 5 Mar 2026 (1 item)
-- Test: Stock Card (movement bulan Maret)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/010', TO_DATE('2026-04-05', 'YYYY-MM-DD'),
    w.warehouse_id, s.supplier_id,
    'PO/2026/010', 'Restok laptop Maret',
    1, 20.000, 240000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 1, ip.item_product_id,
    20.000, 'pcs', 12000000.00, 240000000.00,
    'Laptop restok Maret', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/010' AND ip.product_code = 'PRD-0001';

COMMIT;

-- ----------------------------------------------------------------------------
-- INB/2026/011: Confirmed, WH002, 20 Jan 2026 (2 items)
-- Test: Stock Card (multi-warehouse), Stock Valuation (warehouse)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/011', TO_DATE('2026-02-20', 'YYYY-MM-DD'),
    w.warehouse_id, s.supplier_id,
    'PO/2026/011', 'Stok untuk gudang transit Surabaya',
    2, 45.000, 60000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH002' AND s.supplier_code = 'SUP003';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 1, ip.item_product_id,
    15.000, 'pcs', 12000000.00, 180000000.00,
    'Laptop untuk cabang Surabaya', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/011' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 2, ip.item_product_id,
    30.000, 'pcs', 1200000.00, 36000000.00,
    'Mouse untuk cabang Surabaya', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/011' AND ip.product_code = 'PRD-0019';

COMMIT;

-- ----------------------------------------------------------------------------
-- INB/2026/012: Confirmed, WH001 (2 items)
-- Test: Cancel Inbound GAGAL (PRD-0055 stok=5, qty_received=20)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/012', TO_DATE('2026-03-10', 'YYYY-MM-DD'),
    w.warehouse_id, s.supplier_id,
    'PO/2026/012', 'Inbound yang stoknya sudah sebagian keluar',
    2, 35.000, 50000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 1, ip.item_product_id,
    20.000, 'pcs', 1500000.00, 30000000.00,
    'Kabel yang sebagian sudah dikirim', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/012' AND ip.product_code = 'PRD-0055';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 2, ip.item_product_id,
    15.000, 'pcs', 1500000.00, 22500000.00,
    'Webcam batch tambahan', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/012' AND ip.product_code = 'PRD-0025';

COMMIT;

-- ----------------------------------------------------------------------------
-- INB/2026/013: Draft, WH001, 10 Mar 2026 (3 items)
-- Test: Confirm Inbound (skenario sukses)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/013', TO_DATE('2026-04-10', 'YYYY-MM-DD'),
    w.warehouse_id, s.supplier_id,
    'PO/2026/013', 'Penerimaan barang baru - menunggu konfirmasi',
    3, 55.000, 85000000.00,
    'draft', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH001' AND s.supplier_code = 'SUP001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 1, ip.item_product_id,
    20.000, 'pcs', 12000000.00, 240000000.00,
    'Laptop untuk tim engineering', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/013' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 2, ip.item_product_id,
    15.000, 'pcs', 2500000.00, 37500000.00,
    'Monitor untuk workstation baru', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/013' AND ip.product_code = 'PRD-0007';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 3, ip.item_product_id,
    20.000, 'pcs', 450000.00, 9000000.00,
    'Keyboard mechanical', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/013' AND ip.product_code = 'PRD-0013';

COMMIT;

-- ----------------------------------------------------------------------------
-- INB/2026/014: Draft, WH002, 12 Mar 2026 (1 item)
-- Test: Confirm Inbound (skenario draft kedua)
-- ----------------------------------------------------------------------------
INSERT INTO stock_inbound (
    inbound_number, inbound_date, warehouse_id, supplier_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'INB/2026/014', TO_DATE('2026-04-12', 'YYYY-MM-DD'),
    w.warehouse_id, s.supplier_id,
    'PO/2026/014', 'Stok mouse untuk transit - belum dikonfirmasi',
    1, 40.000, 48000000.00,
    'draft', 'SYSTEM'
FROM warehouse w, supplier s
WHERE w.warehouse_code = 'WH002' AND s.supplier_code = 'SUP002';

INSERT INTO stock_inbound_item (
    stock_inbound_id, line_number, item_product_id,
    qty_received, uom, unit_price, total_amount, notes, created_by
)
SELECT si.stock_inbound_id, 1, ip.item_product_id,
    40.000, 'pcs', 1200000.00, 48000000.00,
    'Mouse ergonomic untuk cabang', 'SYSTEM'
FROM stock_inbound si, item_product ip
WHERE si.inbound_number = 'INB/2026/014' AND ip.product_code = 'PRD-0019';

COMMIT;

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
)
SELECT
    'OUT/2026/008', TO_DATE('2026-03-10', 'YYYY-MM-DD'),
    w.warehouse_id, c.customer_id,
    'SO/2026/008', 'Pengiriman ke PT Pelanggan Setia',
    2, 25.000, 90000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH001' AND c.customer_code = 'CST001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
)
SELECT so.stock_outbound_id, 1, ip.item_product_id,
    15.000, 'pcs', 15000000.00, 225000000.00,
    'Laptop untuk kantor pusat client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/008' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
)
SELECT so.stock_outbound_id, 2, ip.item_product_id,
    10.000, 'pcs', 3000000.00, 30000000.00,
    'Monitor untuk client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/008' AND ip.product_code = 'PRD-0007';

COMMIT;

-- ----------------------------------------------------------------------------
-- OUT/2026/009: Confirmed, WH001, 22 Feb 2026 (1 item)
-- Test: Stock Card (outbound kedua)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/009', TO_DATE('2026-03-22', 'YYYY-MM-DD'),
    w.warehouse_id, c.customer_id,
    'SO/2026/009', 'Pengiriman ke CV Toko Makmur',
    1, 10.000, 150000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH001' AND c.customer_code = 'CST002';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
)
SELECT so.stock_outbound_id, 1, ip.item_product_id,
    10.000, 'pcs', 15000000.00, 150000000.00,
    'Laptop batch kedua', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/009' AND ip.product_code = 'PRD-0001';

COMMIT;

-- ----------------------------------------------------------------------------
-- OUT/2026/010: Confirmed, WH001, 12 Mar 2026 (2 items)
-- Test: Stock Card (outbound Maret)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/010', TO_DATE('2026-04-12', 'YYYY-MM-DD'),
    w.warehouse_id, c.customer_id,
    'SO/2026/010', 'Pengiriman ke PT Retail Nusantara',
    2, 40.000, 90000000.00,
    'confirmed', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH001' AND c.customer_code = 'CST003';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
)
SELECT so.stock_outbound_id, 1, ip.item_product_id,
    35.000, 'pcs', 15000000.00, 525000000.00,
    'Laptop untuk ekspansi kantor', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/010' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
)
SELECT so.stock_outbound_id, 2, ip.item_product_id,
    5.000, 'pcs', 550000.00, 2750000.00,
    'Keyboard untuk staff baru', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/010' AND ip.product_code = 'PRD-0013';

COMMIT;

-- ----------------------------------------------------------------------------
-- OUT/2026/011: Draft, WH001, 13 Mar 2026 (2 items)
-- Test: Confirm Outbound (skenario sukses)
-- ----------------------------------------------------------------------------
INSERT INTO stock_outbound (
    outbound_number, outbound_date, warehouse_id, customer_id,
    reference_number, notes, total_items, total_qty, total_amount,
    status, created_by
)
SELECT
    'OUT/2026/011', TO_DATE('2026-04-13', 'YYYY-MM-DD'),
    w.warehouse_id, c.customer_id,
    'SO/2026/011', 'Pengiriman menunggu konfirmasi',
    2, 12.000, 42000000.00,
    'draft', 'SYSTEM'
FROM warehouse w, customer c
WHERE w.warehouse_code = 'WH001' AND c.customer_code = 'CST001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
)
SELECT so.stock_outbound_id, 1, ip.item_product_id,
    5.000, 'pcs', 15000000.00, 75000000.00,
    'Laptop untuk client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/011' AND ip.product_code = 'PRD-0001';

INSERT INTO stock_outbound_item (
    stock_outbound_id, line_number, item_product_id,
    qty_shipped, uom, unit_price, total_amount, notes, created_by
)
SELECT so.stock_outbound_id, 2, ip.item_product_id,
    7.000, 'pcs', 1500000.00, 10500000.00,
    'Mouse untuk client', 'SYSTEM'
FROM stock_outbound so, item_product ip
WHERE so.outbound_number = 'OUT/2026/011' AND ip.product_code = 'PRD-0019';

COMMIT;

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================

EXIT;
