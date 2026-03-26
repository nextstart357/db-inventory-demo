@echo off
REM ============================================================================
REM MINI INVENTORY DATABASE SCHEMA INITIALIZATION
REM ============================================================================
REM Version: 1.0
REM Created: 2025-12-10
REM Description: Drop and create mini inventory schema and tables ONLY
REM              (Does NOT load seed data - use mini-inventory-seed-init.bat)
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
echo MINI INVENTORY SCHEMA INITIALIZATION (Schema Only)
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
REM Step 1: Test Database Connection
REM ----------------------------------------------------------------------------
echo [STEP 1/2] Testing database connection...
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
REM Step 2: Execute Schema (Drop and Create Tables)
REM ----------------------------------------------------------------------------
echo [STEP 2/2] Executing schema script (drop and create tables)...
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
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('supplier', 'warehouse', 'item_product', 'stock_inbound', 'stock_inbound_item') ORDER BY table_name;"

echo.
echo ============================================================================
echo SCHEMA INITIALIZATION COMPLETE
echo ============================================================================
echo.
echo Tables created in schema 'public':
echo   - supplier
echo   - warehouse
echo   - item_product
echo   - stock_inbound
echo   - stock_inbound_item
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
