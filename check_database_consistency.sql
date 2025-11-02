-- 核对数据库一致性脚本
-- 用于检查前端展示的数据库和后端数据库是否一致

SET NAMES utf8mb4;
USE parking_db;

-- ========================================
-- 1. 检查停车场表结构
-- ========================================
SELECT '=== 检查停车场表结构 ===' AS info;

DESCRIBE parking_lot;

-- ========================================
-- 2. 检查车位表结构
-- ========================================
SELECT '=== 检查车位表结构 ===' AS info;

DESCRIBE parking_space;

-- ========================================
-- 3. 查看当前数据库中的停车场数据
-- ========================================
SELECT '=== 数据库中的停车场列表 ===' AS info;
SELECT 
    id,
    name,
    address,
    total_spaces,
    available_spaces,
    hourly_rate,
    status,
    operating_hours,
    longitude,
    latitude,
    created_at,
    updated_at
FROM parking_lot
ORDER BY id;

-- ========================================
-- 4. 查看每个停车场的车位数量
-- ========================================
SELECT '=== 停车场及其车位统计 ===' AS info;
SELECT 
    pl.id AS parking_id,
    pl.name AS parking_name,
    pl.total_spaces AS parking_total_spaces,
    COUNT(ps.id) AS actual_spaces_count,
    SUM(CASE WHEN ps.status = 'AVAILABLE' OR ps.state = 0 THEN 1 ELSE 0 END) AS available_count,
    pl.available_spaces AS parking_available_spaces
FROM parking_lot pl
LEFT JOIN parking_space ps ON ps.parking_id = pl.id OR ps.parking_lot_id = pl.id
GROUP BY pl.id, pl.name, pl.total_spaces, pl.available_spaces
ORDER BY pl.id;

-- ========================================
-- 5. 查看车位表中的字段名
-- ========================================
SELECT '=== 车位表中的停车场ID字段名检查 ===' AS info;
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'parking_db'
  AND TABLE_NAME = 'parking_space'
  AND (COLUMN_NAME LIKE '%parking%' OR COLUMN_NAME LIKE '%lot%')
ORDER BY ORDINAL_POSITION;

-- ========================================
-- 6. 检查车位数据（前10条）
-- ========================================
SELECT '=== 车位数据样例（前10条） ===' AS info;
SELECT 
    ps.id,
    ps.parking_id,
    ps.parking_lot_id,
    ps.space_number,
    ps.name,
    ps.floor,
    ps.location,
    ps.status,
    ps.state,
    ps.type,
    ps.is_available,
    ps.hourly_rate
FROM parking_space ps
ORDER BY ps.id
LIMIT 10;

-- ========================================
-- 7. 检查字段名不一致的问题
-- ========================================
SELECT '=== 检查字段名不一致问题 ===' AS info;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                     WHERE TABLE_SCHEMA = 'parking_db' 
                       AND TABLE_NAME = 'parking_space' 
                       AND COLUMN_NAME = 'parking_id') 
        THEN '使用 parking_id'
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                     WHERE TABLE_SCHEMA = 'parking_db' 
                       AND TABLE_NAME = 'parking_space' 
                       AND COLUMN_NAME = 'parking_lot_id') 
        THEN '使用 parking_lot_id'
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                     WHERE TABLE_SCHEMA = 'parking_db' 
                       AND TABLE_NAME = 'parking_space' 
                       AND COLUMN_NAME = 'lot_id') 
        THEN '使用 lot_id'
        ELSE '未找到停车场ID字段'
    END AS parking_id_field_name;

-- ========================================
-- 8. 检查预约表中的停车场ID字段
-- ========================================
SELECT '=== 检查预约表结构 ===' AS info;
DESCRIBE reservation;

-- ========================================
-- 9. 统计各停车场的车位数量
-- ========================================
SELECT '=== 各停车场车位详细统计 ===' AS info;
SELECT 
    pl.id AS parking_id,
    pl.name AS parking_name,
    COALESCE(COUNT(ps.id), 0) AS total_spaces_in_db,
    COALESCE(SUM(CASE 
        WHEN ps.status = 'AVAILABLE' OR (ps.status IS NULL AND ps.state = 0) OR ps.is_available = 1 
        THEN 1 ELSE 0 
    END), 0) AS available_spaces_in_db,
    pl.total_spaces AS expected_total_spaces,
    pl.available_spaces AS expected_available_spaces,
    CASE 
        WHEN COALESCE(COUNT(ps.id), 0) = pl.total_spaces THEN '✓ 一致'
        ELSE '✗ 不一致'
    END AS total_match,
    CASE 
        WHEN COALESCE(SUM(CASE 
            WHEN ps.status = 'AVAILABLE' OR (ps.status IS NULL AND ps.state = 0) OR ps.is_available = 1 
            THEN 1 ELSE 0 
        END), 0) = pl.available_spaces THEN '✓ 一致'
        ELSE '✗ 不一致'
    END AS available_match
FROM parking_lot pl
LEFT JOIN parking_space ps ON (
    ps.parking_id = pl.id 
    OR ps.parking_lot_id = pl.id 
    OR ps.lot_id = pl.id
)
GROUP BY pl.id, pl.name, pl.total_spaces, pl.available_spaces
ORDER BY pl.id;

-- ========================================
-- 10. 查找可能的数据不一致问题
-- ========================================
SELECT '=== 数据不一致检查 ===' AS info;

-- 检查是否有车位关联了不存在的停车场
SELECT 
    '车位关联了不存在的停车场' AS issue_type,
    ps.id AS space_id,
    ps.space_number,
    COALESCE(ps.parking_id, ps.parking_lot_id, ps.lot_id) AS parking_id_in_space
FROM parking_space ps
WHERE NOT EXISTS (
    SELECT 1 FROM parking_lot pl 
    WHERE pl.id = COALESCE(ps.parking_id, ps.parking_lot_id, ps.lot_id)
);

SELECT '检查完成！' AS status;

