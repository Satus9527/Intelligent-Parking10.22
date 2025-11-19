@echo off
chcp 65001 >nul
echo ========================================
echo 更新广州地区停车场数据
echo ========================================
echo.

REM 设置MySQL路径（根据你的实际安装路径修改）
set MYSQL_PATH=D:\MySQL\bin
set SQL_FILE=%~dp0add_more_lots.sql

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
echo 1. 此操作将更新数据库中的停车场数据
echo 2. 将添加/更新以下停车场：
echo    - 太古汇停车场
echo    - 正佳广场停车场
echo    - 天河城停车场
echo    - 万菱汇停车场
echo    - 广州塔停车场
echo    - 北京路停车场
echo 3. 如果停车场ID已存在，将更新为广州地区数据
echo 4. 如果停车场ID不存在，将插入新数据
echo 5. 请输入MySQL root用户密码
echo ========================================
echo.

REM 切换到SQL文件所在目录
cd /d "%~dp0"

REM 执行SQL文件
"%MYSQL_PATH%\mysql.exe" -uroot -p --default-character-set=utf8mb4 parking_db < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [成功] 广州地区停车场数据更新完成！
    echo ========================================
    echo.
    echo 已更新/添加的停车场：
    echo   - 太古汇停车场（天河路383号）
    echo   - 正佳广场停车场（天河路228号）
    echo   - 天河城停车场（天河路208号）
    echo   - 万菱汇停车场（天河路230号）
    echo   - 广州塔停车场（阅江西路222号）
    echo   - 北京路停车场（北京路283号）
    echo.
) else (
    echo.
    echo ========================================
    echo [失败] 数据更新出错！
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. MySQL root密码错误
    echo 2. MySQL服务未启动
    echo 3. parking_db数据库不存在
    echo 4. SQL文件格式错误
    echo.
    echo 请检查上述问题后重试
    echo.
)

pause

