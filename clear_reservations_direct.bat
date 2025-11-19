@echo off
chcp 65001 >nul
echo ========================================
echo 直接清空预约记录（内嵌SQL）
echo ========================================
echo.
echo 警告：此操作将删除所有预约记录！
echo.

:: 设置数据库连接信息
set DB_USER=root
set DB_PASS=123456
set DB_NAME=parking_db

:: 先检查数据库连接和记录数
echo 正在检查数据库连接...
mysql -u %DB_USER% -p%DB_PASS% -e "USE %DB_NAME%; SELECT COUNT(*) AS '当前预约记录数' FROM reservation;" 2>nul
if %errorlevel% neq 0 (
    echo.
    echo 数据库连接失败，请检查MySQL服务是否运行
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

:: 直接在命令行执行SQL，不依赖外部文件
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% -e "SET FOREIGN_KEY_CHECKS = 0; TRUNCATE TABLE reservation; SET FOREIGN_KEY_CHECKS = 1; UPDATE parking_space SET state = 0, status = 'AVAILABLE' WHERE state IN (1, 2) OR status IN ('RESERVED', 'OCCUPIED'); SELECT '预约记录已清空！' AS '结果'; SELECT COUNT(*) AS '剩余预约记录数' FROM reservation;"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 预约记录已成功清空！
    echo ========================================
) else (
    echo.
    echo ========================================
    echo 清空操作失败，请检查错误信息
    echo ========================================
)

echo.
pause

