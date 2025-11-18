@echo off
chcp 65001 >nul
echo ========================================
echo 后端服务连接诊断工具
echo ========================================
echo.

echo [1/3] 检查后端服务是否运行...
curl -s -o nul -w "%%{http_code}" http://172.20.10.5:8081/api/v1/parking/simple-test 2>nul | findstr "200" >nul
if %errorlevel% == 0 (
    echo [OK] 后端服务正在运行
) else (
    echo [ERROR] 后端服务未响应
    echo.
    echo 请检查以下项目:
    echo 1. 后端服务是否已启动
    echo 2. 服务地址是否正确: http://172.20.10.5:8081
    echo 3. 防火墙是否阻止了连接
    echo.
    pause
    exit /b 1
)
echo.

echo [2/3] 测试简单API端点...
curl -s http://172.20.10.5:8081/api/v1/parking/simple-test
if %errorlevel% == 0 (
    echo.
    echo [OK] API 端点响应正常
) else (
    echo [ERROR] API 端点无响应
    pause
    exit /b 1
)
echo.
echo.

echo [3/3] 测试附近停车场API（带超时）...
echo 正在测试 /api/v1/parking/nearby...
curl -s --max-time 10 "http://172.20.10.5:8081/api/v1/parking/nearby?longitude=113.3248&latitude=23.1288&radius=10000"
if %errorlevel% == 0 (
    echo.
    echo [OK] 附近停车场API响应正常
) else (
    echo.
    echo [ERROR] 附近停车场API超时或失败
    echo.
    echo 可能原因:
    echo 1. 数据库连接失败
    echo 2. 数据库查询超时
    echo 3. 网络问题
    echo.
    echo 请查看后端日志获取详细错误信息
    pause
    exit /b 1
)
echo.
echo.

echo ========================================
echo 诊断完成！
echo ========================================
pause

