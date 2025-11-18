@echo off
chcp 65001 >nul
echo ========================================
echo 简单后端服务检查
echo ========================================
echo.

echo 正在测试后端服务连接...
echo 地址: http://172.20.10.5:8081/api/v1/parking/simple-test
echo.

curl -v --max-time 5 http://172.20.10.5:8081/api/v1/parking/simple-test 2>&1

echo.
echo.
echo ========================================
echo 如果看到 HTTP/1.1 200 OK，说明服务正常
echo 如果连接失败，请检查:
echo 1. 后端服务是否已启动
echo 2. 端口 8081 是否被占用
echo 3. 防火墙设置
echo ========================================
pause

