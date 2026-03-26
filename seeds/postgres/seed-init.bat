@echo off
REM ============================================================================
REM MINI INVENTORY SEED DATA INITIALIZATION (POSTGRESQL)
REM ============================================================================
REM Version: 1.0
REM Created: 2025-12-10
REM Description: Load sample/seed data into mini inventory tables
REM Platform: Windows
REM Prerequisites:
REM   1. PostgreSQL client (psql) must be installed and in PATH
REM   2. Schema must be created first (run mini-inventory-init.bat)
REM ============================================================================

SETLOCAL EnableDelayedExpansion

REM ----------------------------------------------------------------------------
REM Database Configuration
REM ----------------------------------------------------------------------------
SET DB_HOST=127.0.0.1
SET DB_PORT=5432
SET DB_USER=postgres
SET DB_PASSWORD=postgres1234
SET DB_NAME=dbinv

REM ----------------------------------------------------------------------------
REM Add PostgreSQL to PATH
REM ----------------------------------------------------------------------------
SET PATH=%PATH%;C:\PostgreSQL\12\bin

REM ----------------------------------------------------------------------------
REM Script Paths
REM ----------------------------------------------------------------------------
SET SCRIPT_DIR=%~dp0
SET SEED_FILE=%SCRIPT_DIR%mini-inventory-seed.sql

REM ----------------------------------------------------------------------------
REM Display Configuration
REM ----------------------------------------------------------------------------
echo.
echo ============================================================================
echo MINI INVENTORY SEED DATA INITIALIZATION - POSTGRESQL
echo ============================================================================
echo.
echo Database Configuration:
echo   Host     : %DB_HOST%
echo   Port     : %DB_PORT%
echo   Database : %DB_NAME%
echo   User     : %DB_USER%
echo.
echo Files:
echo   Seed     : %SEED_FILE%
echo.
echo ============================================================================
echo.

REM ----------------------------------------------------------------------------
REM Verify Files Exist
REM ----------------------------------------------------------------------------
IF NOT EXIST "%SEED_FILE%" GOTO SEED_FILE_NOT_FOUND
GOTO SEED_FILE_OK

:SEED_FILE_NOT_FOUND
echo [ERROR] Seed file not found: %SEED_FILE%
echo Please ensure mini-inventory-seed.sql exists in the same directory.
pause
exit /b 1

:SEED_FILE_OK

REM ----------------------------------------------------------------------------
REM Verify psql is installed
REM ----------------------------------------------------------------------------
psql --version >nul 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO PSQL_NOT_FOUND
GOTO PSQL_OK

:PSQL_NOT_FOUND
echo [ERROR] PostgreSQL client (psql) not found in PATH.
echo Please install PostgreSQL client or add it to your PATH.
echo.
echo Common PostgreSQL bin paths:
echo   C:\Program Files\PostgreSQL\16\bin
echo   C:\Program Files\PostgreSQL\15\bin
echo   C:\Program Files\PostgreSQL\14\bin
pause
exit /b 1

:PSQL_OK

REM ----------------------------------------------------------------------------
REM Set PGPASSWORD environment variable (for non-interactive execution)
REM ----------------------------------------------------------------------------
SET PGPASSWORD=%DB_PASSWORD%

REM ----------------------------------------------------------------------------
REM Step 1: Test Database Connection
REM ----------------------------------------------------------------------------
echo [STEP 1/3] Testing database connection...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT version();" >nul 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO DB_CONNECTION_FAILED
echo [OK] Database connection successful.
echo.
GOTO DB_CONNECTION_OK

:DB_CONNECTION_FAILED
echo [ERROR] Cannot connect to database.
echo Please verify:
echo   - PostgreSQL server is running
echo   - Database '%DB_NAME%' exists
echo   - Credentials are correct
echo   - Host %DB_HOST%:%DB_PORT% is reachable
pause
exit /b 1

:DB_CONNECTION_OK

REM ----------------------------------------------------------------------------
REM Step 2: Verify Tables Exist
REM ----------------------------------------------------------------------------
echo [STEP 2/3] Verifying tables exist...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('supplier', 'warehouse', 'item_product', 'stock_inbound', 'stock_inbound_item');" -t -A >temp_count.txt
SET /P TABLE_COUNT=<temp_count.txt
DEL temp_count.txt

IF "%TABLE_COUNT%" NEQ "5" GOTO TABLES_NOT_FOUND
echo [OK] All required tables exist.
echo.
GOTO TABLES_EXIST

:TABLES_NOT_FOUND
echo [ERROR] Required tables not found in schema 'public'.
echo Expected 5 tables, found %TABLE_COUNT%.
echo.
echo Please run schema initialization first:
echo   ..\schemas\postgres\mini-inventory-init.bat
pause
exit /b 1

:TABLES_EXIST

REM ----------------------------------------------------------------------------
REM Step 3: Load Seed Data
REM ----------------------------------------------------------------------------
echo [STEP 3/3] Loading seed data...
echo.
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "%SEED_FILE%"
IF %ERRORLEVEL% NEQ 0 GOTO SEED_LOADING_FAILED
echo.
echo [OK] Seed data loaded successfully.
echo.
GOTO SEED_LOADING_OK

:SEED_LOADING_FAILED
echo.
echo [ERROR] Seed data loading failed.
echo Please check the error messages above.
pause
exit /b 1

:SEED_LOADING_OK

REM ----------------------------------------------------------------------------
REM Verification
REM ----------------------------------------------------------------------------
echo ============================================================================
echo VERIFICATION
echo ============================================================================
echo.
echo Counting records in tables...
echo.

SET PAGER=
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT 'Suppliers' as table_name, COUNT(*) as total FROM supplier UNION ALL SELECT 'Customers', COUNT(*) FROM customer UNION ALL SELECT 'Warehouses', COUNT(*) FROM warehouse UNION ALL SELECT 'Categories', COUNT(*) FROM category UNION ALL SELECT 'Item Products', COUNT(*) FROM item_product UNION ALL SELECT 'Beginning Balance', COUNT(*) FROM stock_beginning_balance UNION ALL SELECT 'Stock Inbound (Confirmed)', COUNT(*) FROM stock_inbound WHERE status = 'confirmed' UNION ALL SELECT 'Stock Inbound (Draft)', COUNT(*) FROM stock_inbound WHERE status = 'draft' UNION ALL SELECT 'Stock Inbound (Total)', COUNT(*) FROM stock_inbound UNION ALL SELECT 'Stock Inbound Items', COUNT(*) FROM stock_inbound_item UNION ALL SELECT 'Stock Outbound (Confirmed)', COUNT(*) FROM stock_outbound WHERE status = 'confirmed' UNION ALL SELECT 'Stock Outbound (Draft)', COUNT(*) FROM stock_outbound WHERE status = 'draft' UNION ALL SELECT 'Stock Outbound (Total)', COUNT(*) FROM stock_outbound UNION ALL SELECT 'Stock Outbound Items', COUNT(*) FROM stock_outbound_item ORDER BY table_name;"

echo.
echo ============================================================================
echo SEED DATA INITIALIZATION COMPLETE
echo ============================================================================
echo.
echo Sample data loaded:
echo   - 3 suppliers, 3 customers
echo   - 3 warehouses, 6 categories
echo   - 600 item products
echo   - 4 stock beginning balance
echo   - 14 stock inbound transactions (10 confirmed, 4 draft)
echo   - 26 stock inbound items
echo   - 11 stock outbound transactions (7 confirmed, 4 draft)
echo   - 18 stock outbound items
echo   - 10 products updated for low-stock test
echo.
echo Next steps:
echo   1. Query data: SELECT * FROM supplier;
echo   2. Query data: SELECT * FROM item_product LIMIT 20;
echo   3. Query data: SELECT * FROM stock_inbound WHERE inbound_number LIKE 'INB/2026%%';
echo.
echo To connect to database:
echo   psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME%
echo.

REM ----------------------------------------------------------------------------
REM Cleanup
REM ----------------------------------------------------------------------------
SET PGPASSWORD=

pause
exit /b 0
