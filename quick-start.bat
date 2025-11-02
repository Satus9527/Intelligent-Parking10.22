@echo off
chcp 65001 >nul
echo ========================================
echo 快速启动后端服务
echo ========================================
echo.

echo 正在启动服务...
echo.

REM 检查JAR文件是否存在
if not exist "target\parking-system-1.0.0.jar" (
    echo [错误] JAR文件不存在！
    echo 请先编译项目: mvn clean package
    pause
    exit /b 1
)

REM 设置环境变量
set APP_ENV=dev
set spring.datasource.url=jdbc:mysql://localhost:3306/parking_db?useUnicode=true^&characterEncoding=utf8^&serverTimezone=Asia/Shanghai^&useSSL=false^&allowPublicKeyRetrieval=true
set spring.datasource.username=root
set spring.datasource.password=123
set spring.redis.host=localhost
set spring.redis.port=6379
set spring.redis.timeout=3000
set jwt.secret=test_jwt_secret_key
set jwt.expiration=3600

REM 启动服务
echo 服务地址: http://localhost:8081
echo.
echo 服务正在启动中...
echo 请等待服务完全启动后再使用...
echo.

java -jar target\parking-system-1.0.0.jar

