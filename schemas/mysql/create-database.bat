@echo off
REM ============================================================================
REM CREATE DATABASE BATCH SCRIPT (MySQL)
REM ============================================================================
REM Version: 1.0
REM Created: 2026-02-18
REM Description: Batch script untuk membuat database dan menjalankan schema
REM ============================================================================

setlocal enabledelayedexpansion

REM Configuration
set DB_NAME=dbinv
set DB_USER=root
set SCRIPT_DIR=%~dp0

REM No colors - plain text output

echo.
echo ============================================================================
echo   MINI INVENTORY - DATABASE SETUP (MySQL)
echo ============================================================================
echo.

REM Check if mysql is available
where mysql >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] mysql tidak ditemukan di PATH
    echo Pastikan MySQL sudah terinstall dan mysql.exe ada di PATH
    echo.
    echo Contoh lokasi: C:\Program Files\MySQL\MySQL Server 8.0\bin
    echo.
    pause
    exit /b 1
)

echo [INFO] mysql ditemukan
echo.

REM Step 1: Create database
echo [STEP 1] Membuat database %DB_NAME%...
echo.

mysql -u %DB_USER% -p < "%SCRIPT_DIR%create-database.sql"
if !ERRORLEVEL! equ 0 goto :db_created

echo.
echo [ERROR] Gagal membuat database
echo.
echo Kemungkinan penyebab:
echo   - Password salah
echo   - MySQL service tidak berjalan
echo   - User tidak punya privilege CREATE DATABASE
echo.

set /p CONTINUE="Lanjutkan ke schema? (Y/N): "
if /i "!CONTINUE!" neq "Y" (
    pause
    exit /b 1
)
goto :run_schema

:db_created
echo.
echo [SUCCESS] Database berhasil dibuat
echo.

:run_schema
REM Step 2: Run schema
echo [STEP 2] Menjalankan schema mini-inventory.sql...
echo.

mysql -u %DB_USER% -p %DB_NAME% < "%SCRIPT_DIR%mini-inventory.sql"

if !ERRORLEVEL! neq 0 (
    echo.
    echo [ERROR] Gagal menjalankan schema
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo [SUCCESS] Database setup selesai!
echo ============================================================================
echo.
echo Database: %DB_NAME%
echo Tables created:
echo   - supplier
echo   - customer
echo   - warehouse
echo   - category
echo   - item_product
echo   - stock_inbound
echo   - stock_inbound_item
echo   - stock_outbound
echo   - stock_outbound_item
echo.

pause
