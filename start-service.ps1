# 智能停车场系统 - 后端服务启动脚本
# PowerShell版本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "智能停车场系统 - 启动后端服务" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查JAR文件
$jarPath = "target\parking-system-1.0.0.jar"
if (-not (Test-Path $jarPath)) {
    Write-Host "[错误] 找不到JAR文件: $jarPath" -ForegroundColor Red
    Write-Host "请先编译项目: mvn clean package" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[√] JAR文件已找到: $jarPath" -ForegroundColor Green
Write-Host ""

# 检查端口占用
Write-Host "检查端口8081是否被占用..." -ForegroundColor Yellow
$portCheck = netstat -ano | findstr ":8081"
if ($portCheck) {
    Write-Host "[警告] 端口8081已被占用！" -ForegroundColor Yellow
    Write-Host "占用信息: $portCheck" -ForegroundColor Yellow
    Write-Host "是否要停止占用进程并继续? (Y/N)" -ForegroundColor Yellow
    $answer = Read-Host
    if ($answer -ne "Y" -and $answer -ne "y") {
        exit 0
    }
}

# 设置环境变量
$env:APP_ENV = "dev"
$env:"spring.datasource.url" = "jdbc:mysql://localhost:3306/parking_db?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true"
$env:"spring.datasource.username" = "root"
$env:"spring.datasource.password" = "123"
$env:"spring.redis.host" = "localhost"
$env:"spring.redis.port" = "6379"
$env:"spring.redis.timeout" = "3000"
$env:"jwt.secret" = "test_jwt_secret_key"
$env:"jwt.expiration" = "3600"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "正在启动后端服务..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "服务地址: http://localhost:8081" -ForegroundColor Green
Write-Host "API文档: http://localhost:8081/swagger-ui.html (如果启用)" -ForegroundColor Green
Write-Host ""
Write-Host "按 Ctrl+C 停止服务" -ForegroundColor Yellow
Write-Host ""

# 启动服务
java -jar $jarPath
