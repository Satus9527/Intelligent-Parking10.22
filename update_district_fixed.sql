-- 修复版：解决字符集排序规则冲突问题
-- 如果district字段不存在，请先执行：ALTER TABLE parking_lot ADD COLUMN district VARCHAR(50) NULL AFTER address;

SET NAMES utf8mb4;
USE parking_db;

-- 方法1：使用BINARY比较（简单直接）
UPDATE parking_lot SET district = '天河区' WHERE BINARY address LIKE '%天河区%' OR id IN (1, 2, 3, 4);
UPDATE parking_lot SET district = '越秀区' WHERE BINARY address LIKE '%越秀区%' OR id IN (6, 8);
UPDATE parking_lot SET district = '海珠区' WHERE BINARY address LIKE '%海珠区%' OR id IN (5, 9);
UPDATE parking_lot SET district = '白云区' WHERE BINARY address LIKE '%白云区%' OR id = 7;
UPDATE parking_lot SET district = '番禺区' WHERE BINARY address LIKE '%番禺区%' OR id IN (11, 16);
UPDATE parking_lot SET district = '荔湾区' WHERE BINARY address LIKE '%荔湾区%' OR id IN (12, 13);
UPDATE parking_lot SET district = '黄埔区' WHERE BINARY address LIKE '%黄埔区%' OR id IN (14, 15);
UPDATE parking_lot SET district = '花都区' WHERE BINARY address LIKE '%花都区%' OR id = 17;
UPDATE parking_lot SET district = '南沙区' WHERE BINARY address LIKE '%南沙区%' OR id = 18;
UPDATE parking_lot SET district = '增城区' WHERE BINARY address LIKE '%增城区%' OR id = 19;
UPDATE parking_lot SET district = '从化区' WHERE BINARY address LIKE '%从化区%' OR id = 20;

-- 查看更新结果
SELECT id, name, address, district FROM parking_lot ORDER BY id;

