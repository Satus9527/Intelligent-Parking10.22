@echo off
chcp 65001 >nul
echo ========================================
echo Database Verification Tool
echo ========================================
echo.

REM 设置MySQL路径
set MYSQL_PATH=E:\MySQL\bin

echo Checking MySQL connection...
if not exist "%MYSQL_PATH%\mysql.exe" (
    echo [ERROR] MySQL not found at: %MYSQL_PATH%
    pause
    exit /b 1
)

echo.
echo ========================================
echo Database Status Verification
echo ========================================
echo.

REM 验证数据库和表
echo [1] Checking database...
"%MYSQL_PATH%\mysql.exe" -uroot -p123 --default-character-set=utf8mb4 -e "SHOW DATABASES LIKE 'parking_db';" 2>nul

echo.
echo [2] Checking tables...
"%MYSQL_PATH%\mysql.exe" -uroot -p123 --default-character-set=utf8mb4 parking_db -e "SHOW TABLES;" 2>nul

echo.
echo [3] Table Record Counts:
echo.

REM 使用英文输出，避免乱码
"%MYSQL_PATH%\mysql.exe" -uroot -p123 --default-character-set=utf8mb4 parking_db -e "
SELECT 'Parking Lots:' AS info, COUNT(*) AS count FROM parking_lot
UNION ALL
SELECT 'Parking Spaces:' AS info, COUNT(*) AS count FROM parking_space
UNION ALL
SELECT 'Users:' AS info, COUNT(*) AS count FROM user
UNION ALL
SELECT 'Reservations:' AS info, COUNT(*) AS count FROM reservation;
" 2>nul

echo.
echo [4] Parking Lot Details:
echo.
"%MYSQL_PATH%\mysql.exe" -uroot -p123 --default-character-set=utf8mb4 parking_db -e "
SELECT id, name, address, total_spaces, available_spaces, hourly_rate 
FROM parking_lot;
" 2>nul

echo.
echo [5] Parking Space Summary:
echo.
"%MYSQL_PATH%\mysql.exe" -uroot -p123 --default-character-set=utf8mb4 parking_db -e "
SELECT 
    pl.name AS parking_name,
    COUNT(ps.id) AS total_spaces,
    SUM(CASE WHEN ps.status = 'AVAILABLE' AND ps.is_available = 1 THEN 1 ELSE 0 END) AS available_spaces
FROM parking_lot pl
LEFT JOIN parking_space ps ON pl.id = ps.parking_id
GROUP BY pl.id, pl.name;
" 2>nul

echo.
echo ========================================
echo Verification Complete!
echo ========================================
echo.
pause

