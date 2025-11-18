-- 优化数据库查询性能
-- 执行方式：mysql -uroot -p123456 parking_db < 优化数据库查询.sql

USE parking_db;

-- 1. 为 district 字段添加索引（如果还没有）
-- 检查索引是否存在
SELECT COUNT(*) AS index_exists 
FROM information_schema.statistics 
WHERE table_schema = 'parking_db' 
  AND table_name = 'parking_lot' 
  AND index_name = 'idx_district';

-- 如果不存在，创建索引
-- ALTER TABLE parking_lot ADD INDEX idx_district (district);

-- 2. 优化 status 字段的查询
-- 确保 status 字段有索引（通常创建表时已经有了）

-- 3. 检查表结构和索引
SHOW INDEX FROM parking_lot;

-- 4. 分析查询性能
EXPLAIN SELECT 
    id,
    name,
    address,
    district,
    hourly_rate AS hourlyRate,
    total_spaces AS totalSpaces,
    available_spaces AS availableSpaces,
    status,
    operating_hours AS operatingHours,
    longitude,
    latitude
FROM parking_lot
WHERE (status = 'open' OR status = 'OPEN' OR status = 1 OR status IS NULL OR status = '')
ORDER BY id ASC
LIMIT 100;

