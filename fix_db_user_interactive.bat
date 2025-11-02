@echo off
chcp 65001 > nul
echo =================================================
echo 修复数据库用户权限（交互式）
echo =================================================
echo.
echo 此脚本将创建数据库用户 parking_admin
echo.
echo 请输入MySQL root用户的密码：
echo （如果没有密码，直接按回车）
echo.
set /p ROOT_PASS="Root密码: "

set SQL_FILE=create_user.sql

if "%ROOT_PASS%"=="" (
    echo.
    echo 正在尝试使用无密码的root用户...
    mysql -uroot < %SQL_FILE%
) else (
    echo.
    echo 正在使用提供的密码连接...
    mysql -uroot -p%ROOT_PASS% < %SQL_FILE%
)

if %errorlevel% equ 0 (
    echo.
    echo =================================================
    echo [成功] 数据库用户已创建！
    echo =================================================
    echo 用户名: parking_admin
    echo 密码: password
    echo 数据库: parking_db
    echo.
    echo 现在可以重新启动后端服务了。
) else (
    echo.
    echo =================================================
    echo [失败] 创建用户失败
    echo =================================================
    echo 可能的原因：
    echo 1. root密码不正确
    echo 2. MySQL服务未运行
    echo 3. 没有足够的权限
    echo.
    echo 请检查后重试，或手动执行 create_user.sql 文件中的SQL命令
)

echo.
pause


