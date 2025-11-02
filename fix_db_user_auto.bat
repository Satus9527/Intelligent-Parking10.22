@echo off
chcp 65001 > nul
echo =================================================
echo 自动修复数据库用户权限
echo =================================================
echo.

set DB_NAME=parking_db
set DB_USER=parking_admin
set DB_PASS=password

echo 正在尝试创建数据库用户（使用root用户）...
echo 注意：如果root有密码，请先手动修改此脚本
echo.

REM 创建SQL脚本文件
set SQL_FILE=%TEMP%\fix_db_user_auto.sql
(
    echo CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo CREATE USER IF NOT EXISTS '%DB_USER%'@'localhost' IDENTIFIED BY '%DB_PASS%';
    echo GRANT ALL PRIVILEGES ON %DB_NAME%.* TO '%DB_USER%'@'localhost';
    echo FLUSH PRIVILEGES;
    echo SELECT '用户创建成功' AS message;
    echo SELECT User, Host FROM mysql.user WHERE User='%DB_USER%';
) > "%SQL_FILE%"

echo 尝试方法1: root用户无密码...
mysql -uroot < "%SQL_FILE%" 2>nul
if %errorlevel% equ 0 (
    echo 成功！数据库用户已创建。
    goto :success
)

echo 尝试方法2: root用户有密码（默认为root）...
mysql -uroot -proot < "%SQL_FILE%" 2>nul
if %errorlevel% equ 0 (
    echo 成功！数据库用户已创建。
    goto :success
)

echo 尝试方法3: root用户有密码（默认为空，但需要交互）...
mysql -uroot -p < "%SQL_FILE%" 2>nul
if %errorlevel% equ 0 (
    echo 成功！数据库用户已创建。
    goto :success
)

echo.
echo =================================================
echo 自动创建失败！
echo =================================================
echo 请手动执行以下SQL命令：
echo.
echo 1. 使用root用户登录MySQL：
echo    mysql -uroot -p
echo.
echo 2. 然后执行以下SQL：
echo    CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
echo    CREATE USER IF NOT EXISTS '%DB_USER%'@'localhost' IDENTIFIED BY '%DB_PASS%';
echo    GRANT ALL PRIVILEGES ON %DB_NAME%.* TO '%DB_USER%'@'localhost';
echo    FLUSH PRIVILEGES;
echo.
goto :end

:success
echo.
echo =================================================
echo 数据库用户创建成功！
echo =================================================
echo 用户名: %DB_USER%
echo 密码: %DB_PASS%
echo 数据库: %DB_NAME%
echo.
echo 现在可以重新启动后端服务了。
echo.

:end
REM 清理临时文件
del "%SQL_FILE%" 2>nul
"github
pause


