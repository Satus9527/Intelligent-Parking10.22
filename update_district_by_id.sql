-- 根据ID直接更新district字段（最简单的方法，不涉及字符集冲突）
-- 如果district字段不存在，请先执行：ALTER TABLE parking_lot ADD COLUMN district VARCHAR(50) NULL AFTER address;

SET NAMES utf8mb4;
USE parking_db;

-- 根据ID直接更新district字段
UPDATE parking_lot SET district = '天河区' WHERE id IN (1, 2, 3, 4, 10);
UPDATE parking_lot SET district = '越秀区' WHERE id IN (6, 8, 9);
UPDATE parking_lot SET district = '海珠区' WHERE id IN (5);
UPDATE parking_lot SET district = '白云区' WHERE id IN (7);
UPDATE parking_lot SET district = '番禺区' WHERE id IN (11, 16);
UPDATE parking_lot SET district = '荔湾区' WHERE id IN (12, 13);
UPDATE parking_lot SET district = '黄埔区' WHERE id IN (14, 15);
UPDATE parking_lot SET district = '花都区' WHERE id IN (17);
UPDATE parking_lot SET district = '南沙区' WHERE id IN (18);
UPDATE parking_lot SET district = '增城区' WHERE id IN (19);
UPDATE parking_lot SET district = '从化区' WHERE id IN (20);

-- 查看更新结果
SELECT id, name, address, district FROM parking_lot ORDER BY id;

