@echo off
REM ============================================================================
REM MINI INVENTORY SEED DATA INITIALIZATION (ORACLE)
REM ============================================================================
REM Version: 1.0
REM Created: 2025-12-10
REM Description: Load sample/seed data into mini inventory tables
REM Platform: Windows / Oracle Database
REM Prerequisites:
REM   1. Oracle client (sqlplus) must be installed and in PATH
REM   2. Schema must be created first (run mini-inventory-init.bat)
REM ============================================================================

SETLOCAL EnableDelayedExpansion

REM ----------------------------------------------------------------------------
REM Database Configuration
REM ----------------------------------------------------------------------------
SET DB_HOST=orcl-home.tamandua-owl.ts.net
SET DB_PORT=1521
SET DB_USER=dbinv
SET DB_PASSWORD=dbinv
SET DB_SERVICE=ORCL

REM ----------------------------------------------------------------------------
REM Add Oracle to PATH (adjust according to your installation)
REM ----------------------------------------------------------------------------
SET PATH=%PATH%;C:\oracle\product\19.0.0\client_1\bin

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
echo MINI INVENTORY SEED DATA INITIALIZATION - ORACLE
echo ============================================================================
echo.
echo Database Configuration:
echo   Host     : %DB_HOST%
echo   Port     : %DB_PORT%
echo   Service  : %DB_SERVICE%
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
REM Verify sqlplus is installed
REM ----------------------------------------------------------------------------
sqlplus -V >nul 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO SQLPLUS_NOT_FOUND
GOTO SQLPLUS_OK

:SQLPLUS_NOT_FOUND
echo [ERROR] Oracle client (sqlplus) not found in PATH.
echo Please install Oracle client or add it to your PATH.
echo.
echo Common Oracle bin paths:
echo   C:\oracle\product\19c\dbhome_1\bin
echo   C:\oracle\product\18c\dbhome_1\bin
echo   C:\oracle\instantclient_19_8
pause
exit /b 1

:SQLPLUS_OK

REM ----------------------------------------------------------------------------
REM Step 1: Test Database Connection
REM ----------------------------------------------------------------------------
echo [STEP 1/3] Testing database connection...
echo exit | sqlplus -S %DB_USER%/%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_SERVICE% >nul 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO DB_CONNECTION_FAILED
echo [OK] Database connection successful.
echo.
GOTO DB_CONNECTION_OK

:DB_CONNECTION_FAILED
echo [ERROR] Cannot connect to database.
echo Please verify:
echo   - Oracle server is running
echo   - Service '%DB_SERVICE%' exists
echo   - Credentials are correct
echo   - Host %DB_HOST%:%DB_PORT% is reachable
pause
exit /b 1

:DB_CONNECTION_OK

REM ----------------------------------------------------------------------------
REM Step 2: Verify Tables Exist
REM ----------------------------------------------------------------------------
echo [STEP 2/3] Verifying tables exist...
echo SET HEADING OFF > "%TEMP%\check_tables.sql"
echo SET FEEDBACK OFF >> "%TEMP%\check_tables.sql"
echo SELECT COUNT(*) FROM user_tables WHERE table_name IN ('SUPPLIER', 'WAREHOUSE', 'ITEM_PRODUCT', 'STOCK_INBOUND', 'STOCK_INBOUND_ITEM'); >> "%TEMP%\check_tables.sql"
echo EXIT; >> "%TEMP%\check_tables.sql"

sqlplus -S %DB_USER%/%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_SERVICE% @"%TEMP%\check_tables.sql" > "%TEMP%\table_count.txt"
del "%TEMP%\check_tables.sql" >nul 2>nul

FOR /F "tokens=*" %%i IN ('type "%TEMP%\table_count.txt"') DO SET TABLE_COUNT=%%i
SET TABLE_COUNT=%TABLE_COUNT: =%
del "%TEMP%\table_count.txt" >nul 2>nul

IF "%TABLE_COUNT%" NEQ "5" GOTO TABLES_NOT_FOUND
echo [OK] All required tables exist.
echo.
GOTO TABLES_EXIST

:TABLES_NOT_FOUND
echo [ERROR] Required tables not found.
echo Expected 5 tables, found %TABLE_COUNT%.
echo.
echo Please run schema initialization first:
echo   ..\schemas\oracle\mini-inventory-init.bat
pause
exit /b 1

:TABLES_EXIST

REM ----------------------------------------------------------------------------
REM Step 3: Load Seed Data
REM ----------------------------------------------------------------------------
echo [STEP 3/3] Loading seed data...
echo.
echo This may take a moment (inserting 1000 products)...
echo.
sqlplus -S %DB_USER%/%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_SERVICE% @"%SEED_FILE%"
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

echo SET LINESIZE 100 > "%TEMP%\verify_seed.sql"
echo SET PAGESIZE 50 >> "%TEMP%\verify_seed.sql"
echo COLUMN table_name FORMAT A30 >> "%TEMP%\verify_seed.sql"
echo COLUMN total FORMAT 999999 >> "%TEMP%\verify_seed.sql"
echo SELECT 'Suppliers' as table_name, COUNT(*) as total FROM supplier >> "%TEMP%\verify_seed.sql"
echo UNION ALL SELECT 'Warehouses', COUNT(*) FROM warehouse >> "%TEMP%\verify_seed.sql"
echo UNION ALL SELECT 'Item Products', COUNT(*) FROM item_product >> "%TEMP%\verify_seed.sql"
echo UNION ALL SELECT 'Stock Inbound (Confirmed)', COUNT(*) FROM stock_inbound WHERE status = 'confirmed' >> "%TEMP%\verify_seed.sql"
echo UNION ALL SELECT 'Stock Inbound (Draft)', COUNT(*) FROM stock_inbound WHERE status = 'draft' >> "%TEMP%\verify_seed.sql"
echo UNION ALL SELECT 'Stock Inbound (Total)', COUNT(*) FROM stock_inbound >> "%TEMP%\verify_seed.sql"
echo UNION ALL SELECT 'Stock Inbound Items', COUNT(*) FROM stock_inbound_item >> "%TEMP%\verify_seed.sql"
echo ORDER BY 1; >> "%TEMP%\verify_seed.sql"
echo EXIT; >> "%TEMP%\verify_seed.sql"

sqlplus -S %DB_USER%/%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_SERVICE% @"%TEMP%\verify_seed.sql"
del "%TEMP%\verify_seed.sql" >nul 2>nul

echo.
echo ============================================================================
echo SEED DATA INITIALIZATION COMPLETE
echo ============================================================================
echo.
echo Sample data loaded:
echo   - 3 suppliers
echo   - 3 warehouses
echo   - 600 item products
echo   - 7 stock inbound transactions (5 confirmed, 2 draft)
echo   - 13 stock inbound items
echo.
echo Next steps:
echo   1. Query data: SELECT * FROM supplier;
echo   2. Query data: SELECT * FROM item_product WHERE ROWNUM ^<= 20;
echo   3. Query data: SELECT * FROM stock_inbound;
echo.
echo To connect to database:
echo   sqlplus %DB_USER%/%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_SERVICE%
echo.

pause
exit /b 0
