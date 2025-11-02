@echo off
chcp 65001 >nul
echo ========================================
echo 检查后端服务状态
echo ========================================
echo.

echo [1] 检查端口8081是否被占用...
netstat -ano | findstr ":8081" | findstr "LISTENING"
if %errorlevel% equ 0 (
    echo [√] 端口8081正在监听，服务可能正在运行
) else (
    echo [×] 端口8081未被占用，服务未运行
)

echo.
echo [2] 检查Java进程...
tasklist /FI "IMAGENAME eq java.exe" 2>nul | findstr "java.exe"
if %errorlevel% equ 0 (
    echo [√] 找到Java进程，服务可能正在运行
) else (
    echo [×] 未找到Java进程，服务未运行
)

echo.
echo ========================================
echo 检查完成
echo ========================================
echo.
echo 如果服务未运行，请执行 start.bat 启动服务
echo.
pause

