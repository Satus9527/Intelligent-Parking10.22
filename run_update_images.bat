@echo off
chcp 65001 >nul
echo 正在更新停车场图片数据...
D:\MySQL\bin\mysql.exe -uroot -p123456 --default-character-set=utf8mb4 parking_db < update_images.sql
pause