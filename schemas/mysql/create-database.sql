-- ============================================================================
-- CREATE DATABASE SCRIPT (MySQL)
-- ============================================================================
-- Version: 1.0
-- Created: 2026-02-18
-- Description: Script untuk membuat database mini inventory
-- Usage: mysql -u root -p < create-database.sql
-- Note: Jalankan script ini SEBELUM menjalankan mini-inventory.sql
-- ============================================================================

-- Drop database jika sudah ada (HATI-HATI: akan menghapus semua data!)
-- Uncomment baris berikut jika ingin recreate database dari awal
-- DROP DATABASE IF EXISTS dbinv;

-- Create database dengan character set utf8mb4 untuk support emoji dan karakter unicode
CREATE DATABASE IF NOT EXISTS dbinv
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Tampilkan konfirmasi
SELECT 'Database dbinv berhasil dibuat' AS status;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
