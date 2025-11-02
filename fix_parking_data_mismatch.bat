@echo off
chcp 65001 >nul
echo ========================================
echo 检查并修复停车场数据不匹配问题
echo ========================================
echo.

REM 设置MySQL路径（根据你的实际安装路径修改）
set MYSQL_PATH=E:\MySQL\bin
set SQL_FILE=%~dp0fix_parking_data_mismatch.sql

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
echo 重要提示：
echo 1. 此操作将检查停车场和车位数据的关联情况
echo 2. 将显示关联错误的预约和车位
echo 3. 不会修改数据，仅用于诊断
echo 4. 请输入MySQL root用户密码
echo ========================================
echo.

REM 切换到SQL文件所在目录
cd /d "%~dp0"

REM 执行SQL文件
"%MYSQL_PATH%\mysql.exe" -uroot -p --default-character-set=utf8mb4 parking_db < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [完成] 数据检查完成！
    echo ========================================
    echo.
    echo 请查看上面的输出，检查：
    echo 1. 停车场列表是否正确
    echo 2. 车位是否关联到正确的停车场
    echo 3. 预约是否关联到正确的停车场
    echo 4. 是否存在关联错误的预约和车位
    echo.
    echo 如果发现关联错误，请运行 update_guangzhou_parking.bat 更新数据
    echo.
) else (
    echo.
    echo ========================================
    echo [失败] 数据检查出错！
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

