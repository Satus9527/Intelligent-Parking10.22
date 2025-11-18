@echo off
chcp 65001 >nul
echo ========================================
echo 数据库连接诊断工具
echo ========================================
echo.

echo [1/5] 检查 MySQL 服务是否运行...
sc query MySQL80 >nul 2>&1
if %errorlevel% == 0 (
    echo ✓ MySQL 服务正在运行
) else (
    echo ✗ MySQL 服务未运行，请启动 MySQL 服务
    echo   启动命令: net start MySQL80
    pause
    exit /b 1
)
echo.

echo [2/5] 测试数据库连接...
mysql -uroot -p123456 -e "SELECT 1;" parking_db >nul 2>&1
if %errorlevel% == 0 (
    echo ✓ 数据库连接成功
) else (
    echo ✗ 数据库连接失败
    echo   请检查:
    echo   1. MySQL 服务是否运行
    echo   2. 用户名和密码是否正确 (root/123456)
    echo   3. 数据库 parking_db 是否存在
    pause
    exit /b 1
)
echo.

echo [3/5] 检查数据库是否存在...
mysql -uroot -p123456 -e "USE parking_db;" >nul 2>&1
if %errorlevel% == 0 (
    echo ✓ 数据库 parking_db 存在
) else (
    echo ✗ 数据库 parking_db 不存在
    echo   请运行初始化脚本创建数据库
    pause
    exit /b 1
)
echo.

echo [4/5] 检查 parking_lot 表是否存在...
mysql -uroot -p123456 parking_db -e "SHOW TABLES LIKE 'parking_lot';" | findstr "parking_lot" >nul
if %errorlevel% == 0 (
    echo ✓ parking_lot 表存在
) else (
    echo ✗ parking_lot 表不存在
    echo   请运行初始化脚本创建表
    pause
    exit /b 1
)
echo.

echo [5/5] 检查 parking_lot 表中的数据...
mysql -uroot -p123456 parking_db -e "SELECT COUNT(*) AS count FROM parking_lot;" 2>nul
if %errorlevel% == 0 (
    echo ✓ 数据查询成功
) else (
    echo ✗ 数据查询失败
    pause
    exit /b 1
)
echo.

echo ========================================
echo 诊断完成！
echo ========================================
echo.
echo 如果所有检查都通过，但仍有超时问题，请检查:
echo 1. 后端服务是否正常运行 (http://172.20.10.5:8081)
echo 2. 网络连接是否正常
echo 3. 查看后端日志中的错误信息
echo.
pause

