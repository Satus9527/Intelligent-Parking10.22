@echo off

set DB_USER=root
set DB_PASS=root
set DB_NAME=parking_db

echo Database initialization started...
echo.

mysql -u%DB_USER% -p%DB_PASS% %DB_NAME% < init_fixed.sql

if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: Database initialized successfully!
) else (
    echo.
    echo ERROR: Database initialization failed!
    echo Check if MySQL is running and user has permissions.
)

echo.
pause