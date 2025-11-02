-- 修复数据库字段不一致问题
-- 确保 parking_space 表使用统一的字段名

SET NAMES utf8mb4;
USE parking_db;

-- ========================================
-- 1. 检查当前 parking_space 表的字段
-- ========================================
SELECT '=== 检查 parking_space 表字段 ===' AS info;
SELECT 
    COLUMN_NAME AS 字段名,
    COLUMN_TYPE AS 类型,
    COLUMN_COMMENT AS 说明
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'parking_db'
  AND TABLE_NAME = 'parking_space'
  AND (COLUMN_NAME LIKE '%parking%' OR COLUMN_NAME LIKE '%lot%')
ORDER BY ORDINAL_POSITION;

-- ========================================
-- 2. 统一字段名：如果存在多个字段，统一为 parking_id
-- ========================================

-- 方案1：如果表中有 parking_lot_id 但没有 parking_id，则添加 parking_id 并复制数据
ALTER TABLE parking_space 
ADD COLUMN IF NOT EXISTS parking_id BIGINT COMMENT '停车场ID（统一字段）';

-- 如果存在 parking_lot_id，将其数据复制到 parking_id
UPDATE parking_space 
SET parking_id = parking_lot_id 
WHERE parking_lot_id IS NOT NULL AND parking_id IS NULL;

-- 如果存在 lot_id，将其数据复制到 parking_id
UPDATE parking_space 
SET parking_id = lot_id 
WHERE lot_id IS NOT NULL AND parking_id IS NULL;

-- 方案2：如果表中有 parking_id 但没有 parking_lot_id，则添加 parking_lot_id 作为备用
-- ALTER TABLE parking_space 
-- ADD COLUMN IF NOT EXISTS parking_lot_id BIGINT COMMENT '停车场ID（备用字段）';
-- UPDATE parking_space 
-- SET parking_lot_id = parking_id 
-- WHERE parking_id IS NOT NULL AND parking_lot_id IS NULL;

-- ========================================
-- 3. 确保 parking_id 字段有索引
-- ========================================
CREATE INDEX IF NOT EXISTS idx_parking_id ON parking_space(parking_id);

-- ========================================
-- 4. 验证数据一致性
-- ========================================
SELECT '=== 验证车位与停车场的关联 ===' AS info;
SELECT 
    ps.id AS space_id,
    ps.space_number,
    COALESCE(ps.parking_id, ps.parking_lot_id, ps.lot_id) AS parking_id,
    pl.id AS lot_id_in_lot_table,
    pl.name AS parking_name,
    CASE 
        WHEN pl.id = COALESCE(ps.parking_id, ps.parking_lot_id, ps.lot_id) THEN '✓ 关联正确'
        ELSE '✗ 关联错误'
    END AS association_status
FROM parking_space ps
LEFT JOIN parking_lot pl ON pl.id = COALESCE(ps.parking_id, ps.parking_lot_id, ps.lot_id)
LIMIT 20;

-- ========================================
-- 5. 统计各停车场的车位数量
-- ========================================
SELECT '=== 停车场车位统计 ===' AS info;
SELECT 
    pl.id AS parking_id,
    pl.name AS parking_name,
    COUNT(ps.id) AS space_count,
    SUM(CASE 
        WHEN ps.status = 'AVAILABLE' OR ps.state = 0 OR (ps.status IS NULL AND ps.state IS NULL) 
        THEN 1 ELSE 0 
    END) AS available_count
FROM parking_lot pl
LEFT JOIN parking_space ps ON ps.parking_id = pl.id OR ps.parking_lot_id = pl.id OR ps.lot_id = pl.id
GROUP BY pl.id, pl.name
ORDER BY pl.id;

-- ========================================
-- 6. 查找孤立的车位（关联了不存在的停车场）
-- ========================================
SELECT '=== 查找孤立车位 ===' AS info;
SELECT 
    ps.id,
    ps.space_number,
    COALESCE(ps.parking_id, ps.parking_lot_id, ps.lot_id) AS parking_id,
    '车位关联了不存在的停车场' AS issue
FROM parking_space ps
WHERE NOT EXISTS (
    SELECT 1 FROM parking_lot pl 
    WHERE pl.id = COALESCE(ps.parking_id, ps.parking_lot_id, ps.lot_id)
);

SELECT '修复完成！' AS status;

