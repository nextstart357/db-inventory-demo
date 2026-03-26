@echo off
REM ============================================================================
REM MINI INVENTORY DATABASE SCHEMA INITIALIZATION (ORACLE)
REM ============================================================================
REM Version: 1.0
REM Created: 2025-12-10
REM Description: Drop and create mini inventory schema and tables ONLY
REM              (Does NOT load seed data - use mini-inventory-seed-init.bat)
REM Platform: Windows / Oracle Database
REM Prerequisites: Oracle client (sqlplus) must be installed and in PATH
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
SET SCHEMA_FILE=%SCRIPT_DIR%mini-inventory.sql

REM ----------------------------------------------------------------------------
REM Display Configuration
REM ----------------------------------------------------------------------------
echo.
echo ============================================================================
echo MINI INVENTORY SCHEMA INITIALIZATION - ORACLE (Schema Only)
echo ============================================================================
echo.
echo Database Configuration:
echo   Host     : %DB_HOST%
echo   Port     : %DB_PORT%
echo   Service  : %DB_SERVICE%
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
echo Please ensure mini-inventory.sql exists in the same directory.
pause
exit /b 1

:SCHEMA_FILE_OK

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
echo [STEP 1/2] Testing database connection...
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
REM Step 2: Execute Schema (Drop and Create Tables)
REM ----------------------------------------------------------------------------
echo [STEP 2/2] Executing schema script (drop and create tables)...
echo.
sqlplus -S %DB_USER%/%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_SERVICE% @"%SCHEMA_FILE%"
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
echo Verifying tables exist...
echo.

echo SET LINESIZE 100 > "%TEMP%\verify_tables.sql"
echo SET PAGESIZE 50 >> "%TEMP%\verify_tables.sql"
echo COLUMN table_name FORMAT A30 >> "%TEMP%\verify_tables.sql"
echo SELECT table_name FROM user_tables WHERE table_name IN ('SUPPLIER', 'WAREHOUSE', 'ITEM_PRODUCT', 'STOCK_INBOUND', 'STOCK_INBOUND_ITEM') ORDER BY table_name; >> "%TEMP%\verify_tables.sql"
echo EXIT; >> "%TEMP%\verify_tables.sql"
sqlplus -S %DB_USER%/%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_SERVICE% @"%TEMP%\verify_tables.sql"
del "%TEMP%\verify_tables.sql" >nul 2>nul

echo.
echo ============================================================================
echo SCHEMA INITIALIZATION COMPLETE
echo ============================================================================
echo.
echo Tables created:
echo   - SUPPLIER
echo   - WAREHOUSE
echo   - ITEM_PRODUCT
echo   - STOCK_INBOUND
echo   - STOCK_INBOUND_ITEM
echo.
echo Next steps:
echo   1. To load seed data, run: ..\seeds\mini-inventory-seed-init.bat
echo   2. Or manually insert data into the tables
echo.
echo To connect to database:
echo   sqlplus %DB_USER%/%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_SERVICE%
echo.

pause
exit /b 0
