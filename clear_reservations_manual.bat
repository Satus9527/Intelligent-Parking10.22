@echo off
chcp 65001 >nul
echo ========================================
echo 手动清空预约记录（交互式）
echo ========================================
echo.
echo 此脚本会提示您输入MySQL密码
echo.

:: 设置数据库连接信息
set DB_USER=root
set DB_NAME=parking_db

echo 正在连接数据库...
echo 请输入MySQL密码（如果密码为空直接回车）:
mysql -u %DB_USER% -p -e "USE %DB_NAME%; SELECT COUNT(*) AS '当前预约记录数' FROM reservation;"

echo.
set /p confirm="确认要清空所有预约记录吗？(Y/N): "
if /i not "%confirm%"=="Y" (
    echo 操作已取消
    pause
    exit /b
)

echo.
echo 正在执行清空操作...
echo 请输入MySQL密码:

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

:: 执行SQL文件
mysql -u %DB_USER% -p %DB_NAME% < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 预约记录已成功清空！
    echo ========================================
    echo.
    echo 正在验证清空结果...
    echo 请输入MySQL密码:
    mysql -u %DB_USER% -p -e "USE %DB_NAME%; SELECT COUNT(*) AS '剩余预约记录数' FROM reservation;"
) else (
    echo.
    echo ========================================
    echo 清空操作失败，请检查错误信息
    echo ========================================
)

echo.
pause

