@echo off
chcp 65001 > nul

:: 设置数据库连接信息（用户可修改）
set DB_USER=root
set DB_PASS=
set DB_NAME=parking_db
set MYSQL_CMD=mysql

:: 显示配置信息
echo ==========================
echo 智能停车场数据库初始化脚本
echo ==========================
echo 当前配置:
echo - 数据库用户: %DB_USER%
echo - 数据库名称: %DB_NAME%
echo - MySQL命令: %MYSQL_CMD%
echo. 
echo 注意: 密码不会显示在屏幕上

:: 检查MySQL是否可用
%MYSQL_CMD% --version > nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 找不到MySQL命令。请确保MySQL已安装并添加到系统PATH中。
    pause
    exit /b 1
)

echo 正在连接到MySQL服务器...

:: 创建数据库（如果不存在）
echo 创建数据库 %DB_NAME%...
%MYSQL_CMD% -u%DB_USER% -p%DB_PASS% -e "CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2> mysql_error.log
if %errorlevel% neq 0 (
    echo 错误: 无法创建数据库。请检查错误日志。
    type mysql_error.log
    pause
    exit /b 1
)

echo 数据库创建成功。

:: 创建简单的测试表
echo 创建测试表...
%MYSQL_CMD% -u%DB_USER% -p%DB_PASS% %DB_NAME% -e "CREATE TABLE IF NOT EXISTS parking_lot (id INT PRIMARY KEY, name VARCHAR(100), address VARCHAR(200)); INSERT INTO parking_lot (id, name, address) VALUES (1, '中央停车场', '市中心主干道1号');" 2> mysql_error.log
if %errorlevel% neq 0 (
    echo 错误: 无法创建测试表。
    type mysql_error.log
    pause
    exit /b 1
)

echo 数据库初始化成功！
echo 您可以修改此脚本中的DB_USER、DB_PASS和DB_NAME变量以匹配您的实际配置。
pause