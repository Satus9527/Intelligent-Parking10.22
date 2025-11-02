@echo off
chcp 65001 >nul
echo ========================================
echo 仅重启服务（不重新编译）
echo ========================================
echo.
echo [警告] 如果修改了XML或Java文件，需要重新编译！
echo.

REM 停止现有服务
echo [1] 正在停止现有服务...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8081" ^| findstr "LISTENING"') do (
    echo 正在停止进程 %%a...
    taskkill /F /PID %%a >nul 2>&1
)

timeout /t 3 /nobreak >nul
echo [√] 服务已停止
echo.

REM 启动服务
echo [2] 正在启动服务...
call start.bat

echo.
echo ========================================
echo 服务重启完成！
echo ========================================
echo.
echo 服务地址: http://localhost:8081
echo.

