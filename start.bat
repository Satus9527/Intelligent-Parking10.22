@echo off
chcp 65001 >nul
set APP_ENV=dev
set spring.datasource.url=jdbc:mysql://localhost:3306/parking_db?useUnicode=true^&characterEncoding=utf8^&serverTimezone=Asia/Shanghai^&useSSL=false^&allowPublicKeyRetrieval=true
set spring.datasource.username=root
set spring.datasource.password=123
set spring.redis.host=localhost
set spring.redis.port=6379
set spring.redis.timeout=3000
set jwt.secret=test_jwt_secret_key
set jwt.expiration=3600
set AMAP_API_KEY=test_api_key
set wechat.appid=test_wechat_appid
set wechat.mch_id=test_wechat_mch_id
set wechat.secret=test_wechat_secret_key
java -jar target/parking-system-1.0.0.jar