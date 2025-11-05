-- 添加行政区字段并更新现有数据
-- 执行此脚本需要先连接到 parking_db 数据库

USE parking_db;

-- 步骤1：添加 district 字段到 parking_lot 表
-- 如果字段已存在，先删除再添加（避免重复添加错误）
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

-- 步骤2：根据 address 字段更新现有数据的 district 字段
UPDATE parking_lot SET district = '天河区' WHERE id IN (1, 2, 3, 4) OR address LIKE '%天河区%';
UPDATE parking_lot SET district = '海珠区' WHERE id = 5 OR address LIKE '%海珠区%';
UPDATE parking_lot SET district = '越秀区' WHERE id IN (6, 8, 10) OR address LIKE '%越秀区%';
UPDATE parking_lot SET district = '白云区' WHERE id = 7 OR address LIKE '%白云区%';
UPDATE parking_lot SET district = '海珠区' WHERE id = 9 OR address LIKE '%海珠区%';
UPDATE parking_lot SET district = '番禺区' WHERE id IN (11, 16) OR address LIKE '%番禺区%';
UPDATE parking_lot SET district = '荔湾区' WHERE id IN (12, 13) OR address LIKE '%荔湾区%';
UPDATE parking_lot SET district = '黄埔区' WHERE id IN (14, 15) OR address LIKE '%黄埔区%';
UPDATE parking_lot SET district = '花都区' WHERE id = 17 OR address LIKE '%花都区%';
UPDATE parking_lot SET district = '南沙区' WHERE id = 18 OR address LIKE '%南沙区%';
UPDATE parking_lot SET district = '增城区' WHERE id = 19 OR address LIKE '%增城区%';
UPDATE parking_lot SET district = '从化区' WHERE id = 20 OR address LIKE '%从化区%';

-- 验证更新结果
SELECT id, name, address, district FROM parking_lot ORDER BY id;

