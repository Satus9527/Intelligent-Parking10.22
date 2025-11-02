@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 停止后端服务
echo ========================================
echo.

REM 停止监听8081端口的进程
echo [1] 停止监听8081端口的进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8081" ^| findstr "LISTENING" 2^>nul') do (
    echo 正在停止进程 %%a...
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel! equ 0 (
        echo [√] 已停止进程 %%a
    )
)

REM 停止所有使用JAR文件的Java进程
echo.
echo [2] 停止所有使用parking-system JAR的Java进程...
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq java.exe" /FO LIST 2^>nul ^| findstr "PID"') do (
    set "PID=%%a"
    set "PID=!PID:    PID: =!"
    set "PID=!PID:PID:=!"
    if not "!PID!"=="" (
        for /f "tokens=*" %%b in ('wmic process where "ProcessId=!PID!" get CommandLine /format:value 2^>nul ^| findstr "parking-system"') do (
            echo 正在停止进程 !PID!...
            taskkill /F /PID !PID! >nul 2>&1
            if !errorlevel! equ 0 (
                echo [√] 已停止进程 !PID!
            )
        )
    )
)

REM 等待进程完全退出
echo.
echo [3] 等待进程完全退出（5秒）...
timeout /t 5 /nobreak >nul

REM 验证是否还有残留进程
echo.
echo [4] 验证进程是否已完全停止...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8081" ^| findstr "LISTENING" 2^>nul') do (
    echo [警告] 发现残留进程 %%a，尝试再次停止...
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo ========================================
echo 服务停止完成！
echo ========================================
echo.
pause

