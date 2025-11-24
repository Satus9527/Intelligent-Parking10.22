/* update_images.sql */
SET NAMES utf8mb4;
USE parking_db;

-- 1. 增加图片链接字段 (如果不存在)
-- 为了防止重复添加报错，这里使用存储过程或者直接忽略错误，简单起见直接运行ALTER，如果已存在会报错但无大碍
-- 也可以手动在数据库工具里执行: ALTER TABLE parking_lot ADD COLUMN image_url VARCHAR(500);
ALTER TABLE parking_lot ADD COLUMN image_url VARCHAR(500) COMMENT '停车场图片URL';

-- 2. 更新每个停车场的图片链接
-- ID 1: 太古汇
UPDATE parking_lot SET image_url = 'https://i.ibb.co/99kmCZWx/taiguhui.jpg' WHERE id = 1;
-- ID 2: 正佳广场
UPDATE parking_lot SET image_url = 'https://i.ibb.co/qYknn7wJ/zhengjia-square.jpg' WHERE id = 2;
-- ID 3: 天河城
UPDATE parking_lot SET image_url = 'https://i.ibb.co/svvTwhG9/tianhemall.jpg' WHERE id = 3;
-- ID 4: 万菱汇
UPDATE parking_lot SET image_url = 'https://i.ibb.co/QvcqXvzb/wanlinghui.jpg' WHERE id = 4;
-- ID 5: 广州塔
UPDATE parking_lot SET image_url = 'https://i.ibb.co/sv4RB2Dh/cantontower.jpg' WHERE id = 5;
-- ID 6: 北京路
UPDATE parking_lot SET image_url = 'https://i.ibb.co/Y4qM7DHK/beijingroad.webp' WHERE id = 6;
-- ID 7: 白云山
UPDATE parking_lot SET image_url = 'https://i.ibb.co/jkJQXMVL/baiyunmoutain.webp' WHERE id = 7;
-- ID 8: 越秀公园
UPDATE parking_lot SET image_url = 'https://i.ibb.co/mVNMbzZw/yuexiupark.jpg' WHERE id = 8;
-- ID 9: 广州动物园
UPDATE parking_lot SET image_url = 'https://i.ibb.co/WWGXgdWg/zoo.jpg' WHERE id = 9;
-- ID 10: 省博物馆
UPDATE parking_lot SET image_url = 'https://i.ibb.co/kVQZS9qN/guangdongmuseum.jpg' WHERE id = 10;
-- ID 11: 长隆
UPDATE parking_lot SET image_url = 'https://i.ibb.co/C3CzYcSM/changlong.webp' WHERE id = 11;
-- ID 12: 百万葵园
UPDATE parking_lot SET image_url = 'https://i.ibb.co/tMKmPbTd/baiwankuiyuan.webp' WHERE id = 12;
-- ID 13: 正佳广场(荔湾) - 复用正佳的图
UPDATE parking_lot SET image_url = 'https://i.ibb.co/qYknn7wJ/zhengjia-square.jpg' WHERE id = 13;
-- ID 14: 海鸥岛
UPDATE parking_lot SET image_url = 'https://i.ibb.co/HDFfJxtd/haiouisland.webp' WHERE id = 14;
-- ID 15: 莲花山
UPDATE parking_lot SET image_url = 'https://i.ibb.co/TDRdY6kh/lianhuamoutain.jpg' WHERE id = 15;
-- ID 16: 客村
UPDATE parking_lot SET image_url = 'https://i.ibb.co/3yjHJcLP/kecun.jpg' WHERE id = 16;
-- ID 17: 祈福新村
UPDATE parking_lot SET image_url = 'https://i.ibb.co/Cpy1LpH4/qifuxincun.webp' WHERE id = 17;
-- ID 18: 天汇广场
UPDATE parking_lot SET image_url = 'https://i.ibb.co/Pz5J3GYB/tianhui.webp' WHERE id = 18;
-- ID 19: 广百百货
UPDATE parking_lot SET image_url = 'https://i.ibb.co/x86YZxmL/guangbaimall.webp' WHERE id = 19;
-- ID 20: 丽江花园
UPDATE parking_lot SET image_url = 'https://i.ibb.co/b5L68cHq/lijiang.webp' WHERE id = 20;

-- 3. 验证
SELECT id, name, image_url FROM parking_lot;