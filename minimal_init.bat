@echo off

mysql -uparking_admin -ppassword parking_db < minimal_init.sql

if errorlevel 1 (
    echo Init failed. Please check MySQL connection and permissions.
) else (
    echo Database initialized successfully!
)

pause