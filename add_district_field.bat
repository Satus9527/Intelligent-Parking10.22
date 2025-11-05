@echo off
chcp 65001 >nul
echo ========================================
echo 添加行政区字段并更新数据
echo ========================================
echo.

REM 检查MySQL是否可用
where mysql >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 mysql 命令，请确保 MySQL 已安装并添加到 PATH
    pause
    exit /b 1
)

echo 正在执行SQL脚本...
echo.

REM 读取数据库配置（如果有.env文件，可以从那里读取）
REM 如果没有，请手动修改下面的配置
REM 注意：根据 start.bat 中的配置，密码可能是 123，请根据实际情况修改
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=123
set DB_NAME=parking_db

echo 数据库配置:
echo   主机: %DB_HOST%
echo   端口: %DB_PORT%
echo   用户: %DB_USER%
echo   数据库: %DB_NAME%
echo.

REM 执行SQL脚本
REM 注意：如果密码包含特殊字符，可能需要使用 -p 参数并在提示时输入密码
echo 正在执行SQL脚本，请稍候...
mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASSWORD% %DB_NAME% < add_district_field.sql 2>nul
if %errorlevel% neq 0 (
    echo.
    echo 使用密码参数失败，尝试交互式输入密码...
    mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p %DB_NAME% < add_district_field.sql
)

if %errorlevel% equ 0 (
    echo.
    echo [成功] 行政区字段已添加并更新完成！
    echo.
) else (
    echo.
    echo [错误] SQL脚本执行失败，请检查数据库连接和配置
    echo.
    pause
    exit /b 1
)

pause

