@echo off
chcp 65001 >nul
echo ========================================
echo 诊断停车场和车位关联问题
echo ========================================
echo.

REM 设置MySQL路径（根据你的实际安装路径修改）
set MYSQL_PATH=E:\MySQL\bin
set SQL_FILE=%~dp0diagnose_parking_issue.sql

echo 正在检查MySQL路径...
if not exist "%MYSQL_PATH%\mysql.exe" (
    echo [错误] 找不到MySQL，请检查路径：%MYSQL_PATH%
    echo.
    echo 请修改此脚本中的 MYSQL_PATH 变量为你的MySQL安装路径
    pause
    exit /b 1
)

echo [√] MySQL路径正确：%MYSQL_PATH%
echo.

echo 正在检查SQL文件...
if not exist "%SQL_FILE%" (
    echo [错误] 找不到SQL文件：%SQL_FILE%
    pause
    exit /b 1
)

echo [√] SQL文件存在：%SQL_FILE%
echo.

echo ========================================
echo 正在诊断数据一致性问题...
echo ========================================
echo.

REM 切换到SQL文件所在目录
cd /d "%~dp0"

REM 执行SQL文件
"%MYSQL_PATH%\mysql.exe" -uroot -p123 --default-character-set=utf8mb4 parking_db < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [完成] 诊断完成！
    echo ========================================
    echo.
    echo 请查看上面的输出，重点关注：
    echo 1. 停车场ID和名称的对应关系
    echo 2. 车位关联的停车场是否正确
    echo 3. 预约记录的停车场ID是否与车位关联的停车场ID匹配
    echo 4. 前端ID映射建议
    echo.
) else (
    echo.
    echo ========================================
    echo [失败] 诊断出错！
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. MySQL root密码错误
    echo 2. MySQL服务未启动
    echo 3. parking_db数据库不存在
    echo.
    echo 请检查上述问题后重试
    echo.
)

pause

