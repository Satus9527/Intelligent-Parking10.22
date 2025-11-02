@echo off
chcp 65001 > nul
echo =================================================
echo 修复数据库用户权限
echo =================================================
echo.

REM 设置数据库连接信息（使用root用户）
set ROOT_USER=root
set ROOT_PASS=
set DB_NAME=parking_db
set DB_USER=parking_admin
set DB_PASS=password

echo 请提供MySQL root用户密码（如果root没有密码，直接按回车）:
set /p ROOT_PASS="Root密码: "

echo.
echo 正在创建数据库和用户...

REM 创建SQL脚本文件
set SQL_FILE=%TEMP%\fix_db_user.sql
(
    echo -- 创建数据库（如果不存在）
    echo CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo.
    echo -- 创建用户（如果不存在）
    echo CREATE USER IF NOT EXISTS '%DB_USER%'@'localhost' IDENTIFIED BY '%DB_PASS%';
    echo.
    echo -- 授予所有权限
    echo GRANT ALL PRIVILEGES ON %DB_NAME%.* TO '%DB_USER%'@'localhost';
    echo.
    echo -- 刷新权限
    echo FLUSH PRIVILEGES;
    echo.
    echo -- 显示用户信息
    echo SELECT '用户创建成功' AS message;
    echo SELECT User, Host FROM mysql.user WHERE User='%DB_USER%';
) > "%SQL_FILE%"

REM 执行SQL脚本
if "%ROOT_PASS%"=="" (
    mysql -u%ROOT_USER% < "%SQL_FILE%"
) else (
    mysql -u%ROOT_USER% -p%ROOT_PASS% < "%SQL_FILE%"
)

if %errorlevel% equ 0 (
    echo.
    echo =================================================
    echo 数据库用户修复成功！
    echo =================================================
    echo 用户名: %DB_USER%
    echo 密码: %DB_PASS%
    echo 数据库: %DB_NAME%
    echo.
    echo 现在可以重新启动后端服务了。
) else (
    echo.
    echo =================================================
    echo 错误: 数据库用户修复失败！
    echo =================================================
    echo 请检查以下事项：
    echo 1. MySQL服务是否正在运行
    echo 2. root用户密码是否正确
    echo 3. 您是否有足够的权限
)

REM 清理临时文件
del "%SQL_FILE%" 2>nul

echo.
pause


