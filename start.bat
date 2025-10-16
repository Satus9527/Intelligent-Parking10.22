@echo off
set APP_ENV=dev
set DB_URL=jdbc:mysql://localhost:3306/parking_db?useUnicode=true^&characterEncoding=utf8^&serverTimezone=Asia/Shanghai^&useSSL=false
set DB_USERNAME=root
set DB_PASSWORD=root
set REDIS_HOST=localhost
set REDIS_PORT=6379
set REDIS_TIMEOUT=3000
set jwt.secret=test_jwt_secret_key
set jwt.expiration=3600
set AMAP_API_KEY=test_api_key
set wechat.appid=test_wechat_appid
set wechat.mch_id=test_wechat_mch_id
set wechat.secret=test_wechat_secret_key
java -jar target/parking-system-1.0.0.jar