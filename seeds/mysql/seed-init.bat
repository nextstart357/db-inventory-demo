@echo off
REM ============================================================================
REM MINI INVENTORY SEED DATA INITIALIZATION - MySQL 8.0+
REM ============================================================================
REM Version: 1.0
REM Created: 2025-02-12
REM Description: Load sample/seed data into mini inventory tables
REM Platform: Windows
REM Prerequisites:
REM   1. MySQL client (mysql) must be installed and in PATH
REM   2. Schema must be created first (run schema-init.bat)
REM ============================================================================

SETLOCAL EnableDelayedExpansion

REM ----------------------------------------------------------------------------
REM Database Configuration
REM ----------------------------------------------------------------------------
SET DB_HOST=127.0.0.1
SET DB_PORT=3306
SET DB_USER=root
SET DB_PASSWORD=mysql1234
SET DB_NAME=dbinv

REM ----------------------------------------------------------------------------
REM Add MySQL to PATH (adjust to your MySQL installation)
REM ----------------------------------------------------------------------------
SET PATH=%PATH%;C:\Program Files\MySQL\MySQL Server 8.0\bin

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
echo MINI INVENTORY SEED DATA INITIALIZATION - MySQL 8.0+
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
REM Verify mysql is installed
REM ----------------------------------------------------------------------------
mysql --version >nul 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO MYSQL_NOT_FOUND
GOTO MYSQL_OK

:MYSQL_NOT_FOUND
echo [ERROR] MySQL client (mysql) not found in PATH.
echo Please install MySQL client or add it to your PATH.
echo.
echo Common MySQL bin paths:
echo   C:\Program Files\MySQL\MySQL Server 8.0\bin
echo   C:\Program Files\MySQL\MySQL Server 8.4\bin
echo   C:\xampp\mysql\bin
echo   C:\wamp64\bin\mysql\mysql8.0.x\bin
pause
exit /b 1

:MYSQL_OK

REM ----------------------------------------------------------------------------
REM Step 1: Test Database Connection
REM ----------------------------------------------------------------------------
echo [STEP 1/3] Testing database connection...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% -e "SELECT VERSION();" >nul 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO DB_CONNECTION_FAILED
echo [OK] Database connection successful.
echo.
GOTO DB_CONNECTION_OK

:DB_CONNECTION_FAILED
echo [ERROR] Cannot connect to MySQL server.
echo Please verify:
echo   - MySQL server is running
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
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% -N -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '%DB_NAME%' AND TABLE_NAME IN ('category', 'supplier', 'warehouse', 'item_product', 'stock_inbound', 'stock_inbound_item');" > temp_count.txt
SET /P TABLE_COUNT=<temp_count.txt
DEL temp_count.txt

REM Trim whitespace
SET TABLE_COUNT=%TABLE_COUNT: =%

IF "%TABLE_COUNT%" NEQ "6" GOTO TABLES_NOT_FOUND
echo [OK] All required tables exist.
echo.
GOTO TABLES_EXIST

:TABLES_NOT_FOUND
echo [ERROR] Required tables not found in database '%DB_NAME%'.
echo Expected 6 tables, found %TABLE_COUNT%.
echo.
echo Please run schema initialization first:
echo   ..\..\schemas\mysql\schema-init.bat
pause
exit /b 1

:TABLES_EXIST

REM ----------------------------------------------------------------------------
REM Step 3: Load Seed Data
REM ----------------------------------------------------------------------------
echo [STEP 3/3] Loading seed data (this may take a few seconds)...
echo.
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% < "%SEED_FILE%"
IF %ERRORLEVEL% NEQ 0 GOTO SEED_LOADING_FAILED
echo.
echo [OK] Seed data loaded successfully.
echo.
GOTO SEED_LOADING_OK

:SEED_LOADING_FAILED
echo.
echo [ERROR] Seed data loading failed.
echo Please check the error messages above.
echo.
echo Common issues:
echo   - Insufficient memory (1000 products require recursive CTE)
echo   - MySQL version ^< 8.0 (recursive CTE not supported)
echo   - Foreign key constraints (schema must be loaded first)
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

mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% -t -e "SELECT 'Categories' AS 'Table', COUNT(*) AS 'Total' FROM category UNION ALL SELECT 'Suppliers', COUNT(*) FROM supplier UNION ALL SELECT 'Warehouses', COUNT(*) FROM warehouse UNION ALL SELECT 'Item Products', COUNT(*) FROM item_product UNION ALL SELECT 'Stock Inbound (Confirmed)', COUNT(*) FROM stock_inbound WHERE status = 'confirmed' UNION ALL SELECT 'Stock Inbound (Draft)', COUNT(*) FROM stock_inbound WHERE status = 'draft' UNION ALL SELECT 'Stock Inbound (Total)', COUNT(*) FROM stock_inbound UNION ALL SELECT 'Stock Inbound Items', COUNT(*) FROM stock_inbound_item;"

echo.
echo Products by Category:
echo.

mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% -t -e "SELECT c.category_name AS 'Category', COUNT(ip.item_product_id) AS 'Total Products' FROM category c LEFT JOIN item_product ip ON c.category_id = ip.category_id GROUP BY c.category_id, c.category_name ORDER BY c.category_code;"

echo.
echo ============================================================================
echo SEED DATA INITIALIZATION COMPLETE
echo ============================================================================
echo.
echo Sample data loaded:
echo   - 6 categories
echo   - 3 suppliers
echo   - 3 warehouses
echo   - 600 item products
echo   - 7 stock inbound transactions (5 confirmed, 2 draft)
echo   - 13 stock inbound items
echo.
echo Next steps:
echo   1. Query data: SELECT * FROM category;
echo   2. Query data: SELECT * FROM item_product LIMIT 20;
echo   3. Query data: SELECT * FROM stock_inbound;
echo.
echo To connect to database:
echo   mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p %DB_NAME%
echo.

pause
exit /b 0
