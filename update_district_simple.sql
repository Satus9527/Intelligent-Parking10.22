-- 简化版：直接更新district字段（假设字段已存在）
-- 如果district字段不存在，请先执行：ALTER TABLE parking_lot ADD COLUMN district VARCHAR(50) NULL AFTER address;

SET NAMES utf8mb4;
USE parking_db;

-- 根据address字段更新district字段（使用CONVERT转换字符集，避免排序规则冲突）
UPDATE parking_lot SET district = CONVERT('天河区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('天河区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id IN (1, 2, 3, 4);

UPDATE parking_lot SET district = CONVERT('越秀区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('越秀区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id IN (6, 8);

UPDATE parking_lot SET district = CONVERT('海珠区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('海珠区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id IN (5, 9);

UPDATE parking_lot SET district = CONVERT('白云区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('白云区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id = 7;

UPDATE parking_lot SET district = CONVERT('番禺区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('番禺区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id IN (11, 16);

UPDATE parking_lot SET district = CONVERT('荔湾区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('荔湾区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id IN (12, 13);

UPDATE parking_lot SET district = CONVERT('黄埔区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('黄埔区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id IN (14, 15);

UPDATE parking_lot SET district = CONVERT('花都区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('花都区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id = 17;

UPDATE parking_lot SET district = CONVERT('南沙区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('南沙区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id = 18;

UPDATE parking_lot SET district = CONVERT('增城区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('增城区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id = 19;

UPDATE parking_lot SET district = CONVERT('从化区' USING utf8mb4) COLLATE utf8mb4_unicode_ci 
WHERE address LIKE CONCAT('%', CONVERT('从化区' USING utf8mb4) COLLATE utf8mb4_unicode_ci, '%') OR id = 20;

-- 查看更新结果
SELECT id, name, address, district FROM parking_lot ORDER BY id;

