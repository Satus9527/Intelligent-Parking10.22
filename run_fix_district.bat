@echo off
chcp 65001 >nul
echo ========================================
echo 正在修复区域(District)数据...
echo ========================================
echo.

REM 请根据您的实际路径修改 MySQL 路径
set MYSQL_EXE=D:\MySQL\bin\mysql.exe

if not exist "%MYSQL_EXE%" (
    echo [错误] 找不到 mysql.exe，请检查脚本中的路径！
    pause
    exit /b
)

REM 执行 SQL，强制指定 utf8mb4 编码
"%MYSQL_EXE%" -uroot -p123456 --default-character-set=utf8mb4 parking_db < fix_district_data.sql

if %errorlevel% equ 0 (
    echo.
    echo [成功] 数据更新完成！
) else (
    echo.
    echo [失败] 更新出错，请检查报错信息。
)

pause