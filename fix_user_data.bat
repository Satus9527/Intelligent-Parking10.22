@echo off
chcp 65001 >nul
echo ========================================
echo 修复用户数据
echo ========================================
echo.

REM 设置MySQL路径
set MYSQL_PATH=E:\MySQL\bin
set SQL_FILE=%~dp0fix_user_data.sql

echo 正在执行SQL脚本修复用户数据...
echo.

"%MYSQL_PATH%\mysql.exe" -uroot -p123 --default-character-set=utf8mb4 parking_db < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [成功] 用户数据修复完成！
    echo ========================================
    echo.
) else (
    echo.
    echo [错误] 用户数据修复失败！
    echo.
)

pause

