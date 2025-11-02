@echo off
chcp 65001 > nul
echo =================================================
echo 快速修复数据库用户
echo =================================================
echo.

set SQL_FILE=create_user.sql

echo 尝试方法1: root用户无密码...
cmd /c "mysql -uroot < %SQL_FILE%" 2>nul
if %errorlevel% equ 0 (
    echo [成功] 数据库用户已创建！
    goto :end
)

echo 尝试方法2: root密码为"root"...
cmd /c "mysql -uroot -proot < %SQL_FILE%" 2>nul
if %errorlevel% equ 0 (
    echo [成功] 数据库用户已创建！
    goto :end
)

echo 尝试方法3: root密码为空字符串...
cmd /c "mysql -uroot -p^<^<%SQL_FILE%" 2>nul
if %errorlevel% equ 0 (
    echo [成功] 数据库用户已创建！
    goto :end
)

echo.
echo =================================================
echo 自动修复失败！
echo =================================================
echo 请手动执行以下步骤：
echo.
echo 1. 打开命令提示符（CMD）
echo 2. 进入项目目录
echo 3. 使用root用户登录MySQL：
echo    mysql -uroot -p
echo    (会提示输入密码)
echo.
echo 4. 然后执行以下SQL命令：
echo.
type create_user.sql
echo.
echo 或者直接在命令行执行：
echo    mysql -uroot -p ^< create_user.sql
echo.

:end
pause


