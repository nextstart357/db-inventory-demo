@echo off
REM ============================================================================
REM MINI INVENTORY DATABASE SCHEMA INITIALIZATION - MySQL 8.0+
REM ============================================================================
REM Version: 2.0
REM Created: 2025-02-12
REM Updated: 2026-03-26
REM Description: Check/create database and initialize schema tables + triggers
REM              Single entry point - handles database creation and schema setup
REM Platform: Windows
REM Prerequisites: MySQL client (mysql) must be installed and in PATH
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
SET SCHEMA_FILE=%SCRIPT_DIR%mini-inventory.sql

REM ----------------------------------------------------------------------------
REM Display Configuration
REM ----------------------------------------------------------------------------
echo.
echo ============================================================================
echo MINI INVENTORY SCHEMA INITIALIZATION - MySQL 8.0+ (Database + Schema)
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
REM Step 1: Test MySQL Server Connection
REM ----------------------------------------------------------------------------
echo [STEP 1/3] Testing MySQL server connection...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% -e "SELECT VERSION();" >nul 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO SERVER_CONNECTION_FAILED
echo [OK] MySQL server connection successful.
echo.
GOTO SERVER_CONNECTION_OK

:SERVER_CONNECTION_FAILED
echo [ERROR] Cannot connect to MySQL server.
echo Please verify:
echo   - MySQL server is running
echo   - Credentials are correct (user: %DB_USER%)
echo   - Host %DB_HOST%:%DB_PORT% is reachable
echo.
echo To start MySQL service:
echo   net start MySQL80
pause
exit /b 1

:SERVER_CONNECTION_OK

REM ----------------------------------------------------------------------------
REM Step 2: Check & Manage Database
REM ----------------------------------------------------------------------------
echo [STEP 2/3] Checking database '%DB_NAME%'...

mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% --skip-column-names -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '%DB_NAME%'" 2>nul | findstr /C:"%DB_NAME%" >nul 2>nul
IF %ERRORLEVEL% EQU 0 GOTO DB_EXISTS
GOTO DB_NOT_EXISTS

:DB_EXISTS
echo [INFO] Database '%DB_NAME%' already exists.
echo.
set /p ANSWER="Drop the database? All data will be lost. (Y/N): "
IF /I "!ANSWER!" == "Y" GOTO DROP_DATABASE
echo.
echo [INFO] Skip drop database. Proceeding to schema...
echo.
GOTO RUN_SCHEMA

:DROP_DATABASE
echo.
echo [INFO] Dropping database '%DB_NAME%'...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% -e "DROP DATABASE %DB_NAME%;"
IF %ERRORLEVEL% NEQ 0 GOTO DROP_FAILED
echo [OK] Database '%DB_NAME%' dropped successfully.
echo.
GOTO CREATE_DATABASE

:DROP_FAILED
echo [ERROR] Failed to drop database '%DB_NAME%'.
echo Please check permissions for user '%DB_USER%'.
pause
exit /b 1

:DB_NOT_EXISTS
echo [INFO] Database '%DB_NAME%' does not exist.
echo.

:CREATE_DATABASE
echo [INFO] Creating database '%DB_NAME%'...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% -e "CREATE DATABASE %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
IF %ERRORLEVEL% NEQ 0 GOTO CREATE_FAILED
echo [OK] Database '%DB_NAME%' created successfully.
echo.
GOTO RUN_SCHEMA

:CREATE_FAILED
echo [ERROR] Failed to create database '%DB_NAME%'.
echo Please check permissions for user '%DB_USER%'.
pause
exit /b 1

:RUN_SCHEMA

REM ----------------------------------------------------------------------------
REM Step 3: Execute Schema (Drop and Create Tables + Triggers)
REM ----------------------------------------------------------------------------
echo [STEP 3/3] Executing schema script (drop/create tables and triggers)...
echo.
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% < "%SCHEMA_FILE%"
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
echo Verifying tables exist in database '%DB_NAME%'...
echo.

mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% -e "SELECT TABLE_SCHEMA AS 'Database', TABLE_NAME AS 'Table', ENGINE, TABLE_ROWS AS 'Rows' FROM information_schema.TABLES WHERE TABLE_SCHEMA = '%DB_NAME%' ORDER BY TABLE_NAME;"

echo.
echo Verifying triggers exist...
echo.

mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% -e "SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE AS 'Table', EVENT_MANIPULATION AS 'Event' FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = '%DB_NAME%' ORDER BY EVENT_OBJECT_TABLE;"

echo.
echo ============================================================================
echo SCHEMA INITIALIZATION COMPLETE
echo ============================================================================
echo.
echo Tables created in database '%DB_NAME%':
echo   - category
echo   - customer
echo   - supplier
echo   - warehouse
echo   - item_product
echo   - stock_inbound
echo   - stock_inbound_item
echo   - stock_outbound
echo   - stock_outbound_item
echo   - stock_beginning_balance
echo.
echo Triggers created (10 total):
echo   - trg_supplier_before_insert
echo   - trg_customer_before_insert
echo   - trg_warehouse_before_insert
echo   - trg_category_before_insert
echo   - trg_item_product_before_insert
echo   - trg_stock_inbound_before_insert
echo   - trg_stock_inbound_item_before_insert
echo   - trg_stock_outbound_before_insert
echo   - trg_stock_outbound_item_before_insert
echo   - trg_stock_beginning_balance_before_insert
echo.
echo Next steps:
echo   1. To load seed data, run: ..\..\seeds\mysql\seed-init.bat
echo   2. Or manually insert data into the tables
echo.
echo To connect to database:
echo   mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p %DB_NAME%
echo.

pause
exit /b 0
