@echo off
chcp 65001 >nul
echo ========================================
echo 补充缺失的停车场数据 (ID 8-11)
echo ========================================
echo.

REM 设置MySQL路径
set MYSQL_PATH=D:\MySQL\bin
set SQL_FILE=%~dp0add_missing_lots.sql

echo 正在检查MySQL路径...
if not exist "%MYSQL_PATH%\mysql.exe" (
    echo [错误] 找不到MySQL，请检查路径：%MYSQL_PATH%
    pause
    exit /b 1
)

echo [√] MySQL路径正确
echo [√] 准备执行文件：%SQL_FILE%
echo.
echo 请输入MySQL root用户密码...
echo.

REM 执行SQL文件
"%MYSQL_PATH%\mysql.exe" -uroot -p --default-character-set=utf8mb4 parking_db < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [成功] 缺失数据已补全！
    echo ========================================
) else (
    echo.
    echo [失败] 导入出错，请检查密码或SQL文件内容。
)

pause