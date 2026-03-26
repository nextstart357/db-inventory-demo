@echo off
REM ============================================================================
REM MINI INVENTORY DATABASE SCHEMA INITIALIZATION
REM ============================================================================
REM Version: 2.0
REM Created: 2025-12-10
REM Updated: 2026-03-26
REM Description: Check/create database and initialize schema tables
REM              Single entry point - handles database creation and schema setup
REM Platform: Windows
REM Prerequisites: PostgreSQL client (psql) must be installed and in PATH
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
SET SCHEMA_FILE=%SCRIPT_DIR%mini-inventory.sql

REM ----------------------------------------------------------------------------
REM Display Configuration
REM ----------------------------------------------------------------------------
echo.
echo ============================================================================
echo MINI INVENTORY SCHEMA INITIALIZATION (Database + Schema)
echo ============================================================================
echo.
echo Database Configuration:
echo   Host     : %DB_HOST%
echo   Port     : %DB_PORT%
echo   Database : %DB_NAME%
echo   User     : %DB_USER%
echo.
echo Files:
echo   Schema   : %SCHEMA_FILE%
echo.
echo ============================================================================
echo.

REM ----------------------------------------------------------------------------
REM Verify Files Exist
REM ----------------------------------------------------------------------------
IF NOT EXIST "%SCHEMA_FILE%" GOTO SCHEMA_FILE_NOT_FOUND
GOTO SCHEMA_FILE_OK

:SCHEMA_FILE_NOT_FOUND
echo [ERROR] Schema file not found: %SCHEMA_FILE%
echo Please ensure mini-inventory.sql exists in the schemas directory.
pause
exit /b 1

:SCHEMA_FILE_OK

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
REM Step 1: Test PostgreSQL Server Connection
REM ----------------------------------------------------------------------------
echo [STEP 1/3] Testing PostgreSQL server connection...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "SELECT version();" >nul 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO SERVER_CONNECTION_FAILED
echo [OK] PostgreSQL server connection successful.
echo.
GOTO SERVER_CONNECTION_OK

:SERVER_CONNECTION_FAILED
echo [ERROR] Cannot connect to PostgreSQL server.
echo Please verify:
echo   - PostgreSQL server is running
echo   - Credentials are correct
echo   - Host %DB_HOST%:%DB_PORT% is reachable
pause
exit /b 1

:SERVER_CONNECTION_OK

REM ----------------------------------------------------------------------------
REM Step 2: Check & Manage Database
REM ----------------------------------------------------------------------------
echo [STEP 2/3] Checking database '%DB_NAME%'...

psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '%DB_NAME%'" 2>nul | findstr /C:"1" >nul 2>nul
IF %ERRORLEVEL% EQU 0 GOTO DB_EXISTS
GOTO DB_NOT_EXISTS

:DB_EXISTS
echo [INFO] Database '%DB_NAME%' sudah ada.
echo.
set /p ANSWER="Apakah ingin di-drop database? Semua data akan hilang. (Y/N): "
IF /I "!ANSWER!" == "Y" GOTO DROP_DATABASE
echo.
echo [INFO] Skip drop database. Melanjutkan ke schema...
echo.
GOTO RUN_SCHEMA

:DROP_DATABASE
echo.
echo [INFO] Terminating existing connections to '%DB_NAME%'...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '%DB_NAME%' AND pid <> pg_backend_pid();" >nul 2>nul
echo [INFO] Dropping database '%DB_NAME%'...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "DROP DATABASE %DB_NAME%;"
IF %ERRORLEVEL% NEQ 0 GOTO DROP_FAILED
echo [OK] Database '%DB_NAME%' berhasil di-drop.
echo.
GOTO CREATE_DATABASE

:DROP_FAILED
echo [ERROR] Failed to drop database '%DB_NAME%'.
echo Please check if there are active connections or permissions issue.
pause
exit /b 1

:DB_NOT_EXISTS
echo [INFO] Database '%DB_NAME%' belum ada.
echo.

:CREATE_DATABASE
echo [INFO] Creating database '%DB_NAME%'...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "CREATE DATABASE %DB_NAME%;"
IF %ERRORLEVEL% NEQ 0 GOTO CREATE_FAILED
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "COMMENT ON DATABASE %DB_NAME% IS 'Mini Inventory Database';"
echo [OK] Database '%DB_NAME%' berhasil dibuat.
echo.
GOTO RUN_SCHEMA

:CREATE_FAILED
echo [ERROR] Failed to create database '%DB_NAME%'.
echo Please check user permissions.
pause
exit /b 1

:RUN_SCHEMA

REM ----------------------------------------------------------------------------
REM Step 3: Execute Schema (Drop and Create Tables)
REM ----------------------------------------------------------------------------
echo [STEP 3/3] Executing schema script (drop and create tables)...
echo.
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "%SCHEMA_FILE%"
IF %ERRORLEVEL% NEQ 0 GOTO SCHEMA_EXECUTION_FAILED
echo.
echo [OK] Schema created successfully.
echo.
GOTO SCHEMA_EXECUTION_OK

:SCHEMA_EXECUTION_FAILED
echo.
echo [ERROR] Schema execution failed.
echo Please check the error messages above.
pause
exit /b 1

:SCHEMA_EXECUTION_OK

REM ----------------------------------------------------------------------------
REM Verification
REM ----------------------------------------------------------------------------
echo ============================================================================
echo VERIFICATION
echo ============================================================================
echo.
echo Verifying tables exist in schema 'public'...
echo.

SET PAGER=
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('supplier', 'customer', 'warehouse', 'category', 'item_product', 'stock_inbound', 'stock_inbound_item', 'stock_outbound', 'stock_outbound_item', 'stock_beginning_balance') ORDER BY table_name;"

echo.
echo ============================================================================
echo SCHEMA INITIALIZATION COMPLETE
echo ============================================================================
echo.
echo Tables created in schema 'public':
echo   - supplier
echo   - customer
echo   - warehouse
echo   - category
echo   - item_product
echo   - stock_inbound
echo   - stock_inbound_item
echo   - stock_outbound
echo   - stock_outbound_item
echo   - stock_beginning_balance
echo.
echo Next steps:
echo   1. To load seed data, run: ..\seeds\mini-inventory-seed-init.bat
echo   2. Or manually insert data into the tables
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
