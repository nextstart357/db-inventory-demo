-- ============================================================================
-- CREATE DATABASE SCRIPT
-- ============================================================================
-- Version: 1.0
-- Created: 2026-02-18
-- Description: Script untuk membuat database mini inventory
-- Usage: psql -U postgres -f create-database.sql
-- Note: Jalankan script ini SEBELUM menjalankan mini-inventory.sql
-- ============================================================================

-- Terminate existing connections to the database (if any)
-- Uncomment baris berikut jika perlu force disconnect semua koneksi
-- SELECT pg_terminate_backend(pg_stat_activity.pid)
-- FROM pg_stat_activity
-- WHERE pg_stat_activity.datname = 'dbinv'
--   AND pid <> pg_backend_pid();

-- Drop database jika sudah ada (HATI-HATI: akan menghapus semua data!)
-- Uncomment baris berikut jika ingin recreate database dari awal
-- DROP DATABASE IF EXISTS dbinv;

-- Create database (menggunakan default parameter dari template1)
CREATE DATABASE dbinv;

-- Tambahkan deskripsi database
COMMENT ON DATABASE dbinv IS 'Mini Inventory Database';

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================

