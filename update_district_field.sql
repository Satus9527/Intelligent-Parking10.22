-- 更新停车场district字段
-- 执行方式：mysql -uroot -p123 parking_db < update_district_field.sql

SET NAMES utf8mb4;
USE parking_db;

-- 确保district字段存在
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

-- 根据address字段更新district字段（如果district为空或NULL）
UPDATE parking_lot 
SET district = '天河区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%天河区%' OR id IN (1, 2, 3, 4));

UPDATE parking_lot 
SET district = '越秀区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%越秀区%' OR id IN (6, 8));

UPDATE parking_lot 
SET district = '海珠区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%海珠区%' OR id IN (5, 9));

UPDATE parking_lot 
SET district = '白云区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%白云区%' OR id = 7);

UPDATE parking_lot 
SET district = '番禺区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%番禺区%' OR id IN (11, 16));

UPDATE parking_lot 
SET district = '荔湾区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%荔湾区%' OR id IN (12, 13));

UPDATE parking_lot 
SET district = '黄埔区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%黄埔区%' OR id IN (14, 15));

UPDATE parking_lot 
SET district = '花都区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%花都区%' OR id = 17);

UPDATE parking_lot 
SET district = '南沙区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%南沙区%' OR id = 18);

UPDATE parking_lot 
SET district = '增城区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%增城区%' OR id = 19);

UPDATE parking_lot 
SET district = '从化区' 
WHERE (district IS NULL OR district = '') 
  AND (address LIKE '%从化区%' OR id = 20);

-- 显示更新结果
SELECT 'district字段更新完成！' AS message;
SELECT id, name, address, district 
FROM parking_lot 
WHERE district IS NOT NULL AND district != ''
ORDER BY id;

