@echo off

rem 智能停车场系统数据库初始化脚本
setlocal enabledelayedexpansion

echo =================================================
echo 智能停车场系统数据库初始化工具
echo =================================================
echo 

rem 设置数据库连接信息
set DB_USER=parking_admin
set DB_PASS=password
set DB_NAME=parking_db

rem 检查MySQL是否可用
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到MySQL命令行工具，请确保MySQL已安装并添加到系统PATH
    pause
    exit /b 1
)

echo 正在初始化数据库...

rem 执行SQL脚本
mysql -u%DB_USER% -p%DB_PASS% %DB_NAME% < init_fixed.sql

if %errorlevel% neq 0 (
    echo 错误: 数据库初始化失败！
    echo 请检查以下事项：
    echo 1. MySQL服务是否正在运行
    echo 2. 用户parking_admin是否存在且有正确权限
    echo 3. 数据库parking_db是否已创建
    pause
    exit /b 1
)

echo 
echo 数据库初始化成功！
echo =================================================
echo 数据库已成功创建表结构并插入测试数据。
echo 您可以使用以下命令登录MySQL查看：
echo mysql -u%DB_USER% -p%DB_PASS% %DB_NAME%
echo =================================================
pause