-- 修复预约数据不匹配问题
-- 执行方式：mysql -uroot -p123 parking_db < fix_reservation_mismatch.sql

SET NAMES utf8mb4;
USE parking_db;

-- ============================================
-- 1. 检查当前预约与停车场的关联情况
-- ============================================
SELECT '========== 当前预约数据 ==========' AS info;
SELECT 
    r.id AS reservation_id,
    r.parking_id AS reservation_parking_id,
    pl1.name AS reservation_parking_name,
    pl1.address AS reservation_parking_address,
    r.parking_space_id,
    ps.parking_id AS space_parking_id,
    pl2.name AS space_parking_name,
    pl2.address AS space_parking_address,
    r.status AS reservation_status,
    r.created_at,
    CASE 
        WHEN r.parking_id != ps.parking_id THEN '不匹配！需要修复'
        WHEN ps.parking_id IS NULL THEN '车位不存在'
        ELSE '正确'
    END AS status
FROM reservation r
LEFT JOIN parking_lot pl1 ON r.parking_id = pl1.id
LEFT JOIN parking_space ps ON r.parking_space_id = ps.id
LEFT JOIN parking_lot pl2 ON ps.parking_id = pl2.id
ORDER BY r.id DESC;

-- ============================================
-- 2. 修复关联错误的预约（使用车位关联的停车场ID）
-- ============================================
SELECT '========== 开始修复预约数据 ==========' AS info;

-- 更新预约的parking_id，使用车位关联的parking_id（如果车位存在）
UPDATE reservation r
INNER JOIN parking_space ps ON r.parking_space_id = ps.id
SET r.parking_id = ps.parking_id,
    r.updated_at = NOW()
WHERE r.parking_id != ps.parking_id;

SELECT CONCAT('已修复 ', ROW_COUNT(), ' 个预约的停车场关联') AS result;

-- ============================================
-- 3. 检查修复后的结果
-- ============================================
SELECT '========== 修复后的预约数据 ==========' AS info;
SELECT 
    r.id AS reservation_id,
    r.parking_id AS reservation_parking_id,
    pl1.name AS reservation_parking_name,
    pl1.address AS reservation_parking_address,
    r.parking_space_id,
    ps.parking_id AS space_parking_id,
    pl2.name AS space_parking_name,
    CASE 
        WHEN r.parking_id = ps.parking_id THEN '正确'
        ELSE '仍然不匹配'
    END AS status
FROM reservation r
LEFT JOIN parking_lot pl1 ON r.parking_id = pl1.id
LEFT JOIN parking_space ps ON r.parking_space_id = ps.id
LEFT JOIN parking_lot pl2 ON ps.parking_id = pl2.id
ORDER BY r.id DESC
LIMIT 20;

