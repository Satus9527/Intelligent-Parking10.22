@echo off
chcp 65001 >nul
echo ========================================
echo 清空所有预约记录
echo ========================================
echo.
echo 警告：此操作将删除所有预约记录！
echo.

:: 设置数据库连接信息（可根据实际情况修改）
set DB_USER=root
set DB_PASS=123456
set DB_NAME=parking_db

:: 先检查数据库连接和记录数
echo 正在检查数据库连接...
mysql -u %DB_USER% -p%DB_PASS% -e "USE %DB_NAME%; SELECT COUNT(*) AS '当前预约记录数' FROM reservation;" 2>nul
if %errorlevel% neq 0 (
    echo.
    echo 数据库连接失败，请检查：
    echo 1. MySQL服务是否运行
    echo 2. 数据库用户名和密码是否正确
    echo 3. 数据库名称是否正确（当前: %DB_NAME%）
    echo.
    echo 如果密码为空，请修改脚本中的 DB_PASS 变量
    pause
    exit /b
)

echo.
set /p confirm="确认要清空所有预约记录吗？(Y/N): "
if /i not "%confirm%"=="Y" (
    echo 操作已取消
    pause
    exit /b
)

echo.
echo 正在执行清空操作...
echo.

:: 获取当前脚本所在目录
set SCRIPT_DIR=%~dp0
set SQL_FILE=%SCRIPT_DIR%clear_all_reservations.sql

:: 检查SQL文件是否存在
if not exist "%SQL_FILE%" (
    echo.
    echo 错误：找不到SQL文件: %SQL_FILE%
    echo 请确保 clear_all_reservations.sql 文件与此批处理文件在同一目录下
    pause
    exit /b
)

:: 如果设置了密码，使用 -p%DB_PASS% 格式（注意-p和密码之间没有空格）
:: 如果没有密码，使用 -p 让系统提示输入
if defined DB_PASS (
    mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < "%SQL_FILE%"
) else (
    mysql -u %DB_USER% -p %DB_NAME% < "%SQL_FILE%"
)

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 预约记录已成功清空！
    echo ========================================
    echo.
    echo 正在验证清空结果...
    mysql -u %DB_USER% -p%DB_PASS% -e "USE %DB_NAME%; SELECT COUNT(*) AS '剩余预约记录数' FROM reservation;" 2>nul
) else (
    echo.
    echo ========================================
    echo 清空操作失败，请检查：
    echo 1. 数据库连接和权限
    echo 2. SQL脚本文件是否存在
    echo 3. 查看上方的错误信息
    echo ========================================
)

echo.
pause

