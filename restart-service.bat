[渲染层错误] Image加载失败: http://127.0.0.1:25965/images/parking.png 改为用默认marker(env: Windows,mp,1.06.2504060; lib: 3.10.3)@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 重启后端服务
echo ========================================
echo.

REM 停止现有服务
echo [1] 正在停止现有服务...

REM 方法1：停止监听8081端口的进程
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8081" ^| findstr "LISTENING"') do (
    echo 正在停止进程 %%a（监听8081端口）...
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel! equ 0 (
        echo [√] 已停止进程 %%a
    )
)

REM 方法2：停止所有使用JAR文件的Java进程
echo 检查是否有Java进程正在使用JAR文件...
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq java.exe" /FO CSV ^| findstr /V "INFO"') do (
    set "PID=%%a"
    set "PID=!PID:"=!"
    for /f "usebackq tokens=*" %%b in (`wmic process where "ProcessId=!PID!" get CommandLine /format:value ^| findstr "parking-system"`) do (
        echo 正在停止进程 !PID!（使用JAR文件）...
        taskkill /F /PID !PID! >nul 2>&1
        if !errorlevel! equ 0 (
            echo [√] 已停止进程 !PID!
        )
    )
)

REM 等待进程完全退出，确保文件解锁
echo 等待进程完全退出...
timeout /t 5 /nobreak >nul

REM 再次检查并强制终止所有相关Java进程（如果还有）
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq java.exe" /FO LIST ^| findstr "PID"') do (
    set "PID=%%a"
    set "PID=!PID:    PID: =!"
    for /f "tokens=*" %%b in (`wmic process where "ProcessId=!PID!" get CommandLine /format:value 2^>nul ^| findstr "parking-system"`) do (
        echo 强制停止残留进程 !PID!...
        taskkill /F /PID !PID! >nul 2>&1
    )
)

echo [√] 服务已停止
echo.

REM 检查并删除锁定的JAR文件（如果仍有问题）
echo 检查JAR文件锁定状态...
if exist "target\parking-system-1.0.0.jar" (
    echo 尝试重命名旧JAR文件...
    move /Y "target\parking-system-1.0.0.jar" "target\parking-system-1.0.0.jar.old" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [√] 旧JAR文件已重命名
    ) else (
        echo [警告] 无法重命名JAR文件，可能仍被锁定
        echo 请手动关闭所有Java进程后重试
    )
)

REM 重新编译打包
echo.
echo [2] 正在重新编译项目...

REM 尝试使用PATH中的mvn，如果找不到则使用完整路径
where mvn >nul 2>&1
if %errorlevel% equ 0 (
    call mvn clean package -DskipTests
) else (
    echo 在PATH中未找到mvn，尝试使用完整路径...
    if exist "E:\apache-maven-3.8.8\bin\mvn.cmd" (
        call "E:\apache-maven-3.8.8\bin\mvn.cmd" clean package -DskipTests
    ) else (
        echo [错误] 找不到Maven，请检查安装路径！
        echo 预期路径: E:\apache-maven-3.8.8\bin\mvn.cmd
        pause
        exit /b 1
    )
)

if %errorlevel% neq 0 (
    echo [错误] 编译失败！
    pause
    exit /b 1
)

echo [√] 编译成功！
echo.

REM 启动服务
echo [3] 正在启动服务...
start.bat

echo.
echo ========================================
echo 服务重启完成！
echo ========================================
echo.
echo 服务地址: http://localhost:8081
echo 按任意键关闭此窗口...
pause >nul

