USE parking_db;

-- 检查并添加 district 字段
SET @dbname = DATABASE();
SET @tablename = 'parking_lot';
SET @columnname = 'district';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' VARCHAR(50) NULL AFTER address')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

UPDATE parking_lot SET district = '天河区' WHERE id IN (1, 2, 3, 4) OR address LIKE CONVERT('%天河区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '海珠区' WHERE id = 5 OR address LIKE CONVERT('%海珠区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '越秀区' WHERE id IN (6, 8, 10) OR address LIKE CONVERT('%越秀区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '白云区' WHERE id = 7 OR address LIKE CONVERT('%白云区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '海珠区' WHERE id = 9 OR address LIKE CONVERT('%海珠区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '番禺区' WHERE id IN (11, 16) OR address LIKE CONVERT('%番禺区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '荔湾区' WHERE id IN (12, 13) OR address LIKE CONVERT('%荔湾区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '黄埔区' WHERE id IN (14, 15) OR address LIKE CONVERT('%黄埔区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '花都区' WHERE id = 17 OR address LIKE CONVERT('%花都区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '南沙区' WHERE id = 18 OR address LIKE CONVERT('%南沙区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '增城区' WHERE id = 19 OR address LIKE CONVERT('%增城区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
UPDATE parking_lot SET district = '从化区' WHERE id = 20 OR address LIKE CONVERT('%从化区%' USING utf8mb4) COLLATE utf8mb4_unicode_ci;

SELECT id, name, address, district FROM parking_lot ORDER BY id LIMIT 10;

