# 设置环境变量
$env:SERVER_PORT = "8081"

# 启动服务
Write-Host "启动停车场系统服务在端口 8081..."
java -jar target/parking-system-1.0.0.jar