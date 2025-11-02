@echo off
chcp 65001 >nul
echo ========================================
echo 智能停车场系统 - 数据库导入工具
echo ========================================
echo.

REM 设置MySQL路径（根据你的实际安装路径修改）
set MYSQL_PATH=E:\MySQL\bin
set SQL_FILE=%~dp0init_full_database.sql

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
echo 1. 此操作将删除并重建 parking_db 数据库
echo 2. 所有现有数据将被清空
echo 3. 请输入MySQL root用户密码
echo ========================================
echo.

REM 切换到SQL文件所在目录
cd /d "%~dp0"

REM 设置MySQL客户端字符集为UTF-8
set LANG=zh_CN.UTF-8

REM 执行SQL文件（不指定数据库名，让SQL文件自己创建）
REM 使用 --default-character-set=utf8mb4 参数确保输出正确编码
"%MYSQL_PATH%\mysql.exe" -uroot -p --default-character-set=utf8mb4 < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [成功] 数据库导入完成！
    echo ========================================
    echo.
    echo 数据库名称: parking_db
    echo 字符集: utf8mb4
    echo 排序规则: utf8mb4_unicode_ci
    echo.
    echo 已创建的表：
    echo   - parking_lot (停车场表)
    echo   - parking_space (车位表)
    echo   - user (用户表)
    echo   - reservation (预约表)
    echo.
) else (
    echo.
    echo ========================================
    echo [失败] 数据库导入出错！
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. MySQL root密码错误
    echo 2. MySQL服务未启动
    echo 3. SQL文件格式错误
    echo.
    echo 请检查上述问题后重试
    echo.
)

pause

