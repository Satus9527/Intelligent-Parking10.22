@echo off
chcp 65001 >nul
echo ========================================
echo 核对数据库一致性
echo ========================================
echo.
echo 正在执行数据库检查脚本...
echo.

mysql -uroot -p123 parking_db < check_database_consistency.sql

echo.
echo 如果看到错误，请检查：
echo 1. MySQL服务是否启动
echo 2. 数据库用户名密码是否正确
echo 3. parking_db 数据库是否存在
echo.
pause

