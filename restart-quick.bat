@echo off
chcp 65001 >nul
echo ========================================
echo 快速重启后端服务
echo ========================================
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

REM 检查是否需要重新编译（检查JAR文件修改时间）
echo [2] 检查是否需要重新编译...
for %%F in (target\parking-system-1.0.0.jar) do set JAR_TIME=%%~tF
for %%F in (src\main\resources\mapper\ReservationMapper.xml) do set XML_TIME=%%~tF

REM 启动服务
echo [3] 正在启动服务...
call start.bat

echo.
echo ========================================
echo 服务重启完成！
echo ========================================
echo.
echo 服务地址: http://localhost:8081
echo.
echo [注意] 如果仍有错误，请运行 restart-service.bat 重新编译
echo.
pause

