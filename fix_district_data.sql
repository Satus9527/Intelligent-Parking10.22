/* fix_district_data.sql */
SET NAMES utf8mb4;
USE parking_db;

-- 1. 再次确保字段定义正确
ALTER TABLE parking_lot MODIFY COLUMN district VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL;

-- 2. 执行更新 (这些是标准 UTF-8 字符)
UPDATE parking_lot SET district = '天河区' WHERE id IN (1, 2, 3, 4, 10);
UPDATE parking_lot SET district = '越秀区' WHERE id IN (6, 8, 9);
UPDATE parking_lot SET district = '海珠区' WHERE id = 5;
UPDATE parking_lot SET district = '白云区' WHERE id = 7;
UPDATE parking_lot SET district = '番禺区' WHERE id IN (11, 16);
UPDATE parking_lot SET district = '荔湾区' WHERE id IN (12, 13);
UPDATE parking_lot SET district = '黄埔区' WHERE id IN (14, 15);
UPDATE parking_lot SET district = '花都区' WHERE id = 17;
UPDATE parking_lot SET district = '南沙区' WHERE id = 18;
UPDATE parking_lot SET district = '增城区' WHERE id = 19;
UPDATE parking_lot SET district = '从化区' WHERE id = 20;

-- 3. 验证结果
SELECT id, name, district FROM parking_lot ORDER BY id;