@echo off
REM 设置UTF-8编码输出
chcp 65001 >nul

echo ========================================
echo Database Import Tool (UTF-8)
echo ========================================
echo.

REM 设置MySQL路径
set MYSQL_PATH=E:\MySQL\bin
set SQL_FILE=%~dp0init_full_database.sql

echo Checking MySQL path...
if not exist "%MYSQL_PATH%\mysql.exe" (
    echo [ERROR] MySQL not found at: %MYSQL_PATH%
    pause
    exit /b 1
)

echo [OK] MySQL found: %MYSQL_PATH%
echo.

echo Checking SQL file...
if not exist "%SQL_FILE%" (
    echo [ERROR] SQL file not found: %SQL_FILE%
    pause
    exit /b 1
)

echo [OK] SQL file found: %SQL_FILE%
echo.

echo ========================================
echo IMPORTANT:
echo 1. This will DROP and recreate parking_db database
echo 2. All existing data will be LOST
echo 3. Enter MySQL root password when prompted
echo ========================================
echo.

REM 切换到SQL文件所在目录
cd /d "%~dp0"

REM 执行SQL文件，使用UTF-8编码
REM 使用 --default-character-set=utf8mb4 确保正确编码
chcp 65001
"%MYSQL_PATH%\mysql.exe" -uroot -p --default-character-set=utf8mb4 < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [SUCCESS] Database import completed!
    echo ========================================
    echo.
    echo Database Name: parking_db
    echo Character Set: utf8mb4
    echo Collation: utf8mb4_unicode_ci
    echo.
    echo Created Tables:
    echo   - parking_lot (Parking Lot Table)
    echo   - parking_space (Parking Space Table)
    echo   - user (User Table)
    echo   - reservation (Reservation Table)
    echo.
    echo Run verify_database.bat to check the database status
    echo.
) else (
    echo.
    echo ========================================
    echo [FAILED] Database import error!
    echo ========================================
    echo.
    echo Possible causes:
    echo 1. MySQL root password is incorrect
    echo 2. MySQL service is not running
    echo 3. SQL file format error
    echo.
)

pause

