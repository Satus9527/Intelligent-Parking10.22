-- 修复停车场数据不匹配问题
-- 执行方式：mysql -uroot -p123 parking_db < fix_parking_data_mismatch.sql

SET NAMES utf8mb4;
USE parking_db;

-- ============================================
-- 1. 显示所有停车场及其车位关联情况
-- ============================================
SELECT '========== 停车场列表 ==========' AS info;
SELECT 
    pl.id AS parking_id,
    pl.name AS parking_name,
    pl.address AS parking_address,
    COUNT(ps.id) AS total_spaces,
    SUM(CASE WHEN ps.status = 'AVAILABLE' AND ps.state = 0 THEN 1 ELSE 0 END) AS available_spaces
FROM parking_lot pl
LEFT JOIN parking_space ps ON pl.id = ps.parking_id
GROUP BY pl.id, pl.name, pl.address
ORDER BY pl.id;

-- ============================================
-- 2. 检查车位与停车场的关联
-- ============================================
SELECT '========== 车位关联检查 ==========' AS info;
SELECT 
    ps.id AS space_id,
    ps.space_number,
    ps.parking_id AS space_parking_id,
    pl.id AS lot_id,
    pl.name AS parking_lot_name,
    CASE 
        WHEN ps.parking_id = pl.id THEN '正确'
        WHEN pl.id IS NULL THEN '停车场不存在'
        ELSE '不匹配'
    END AS status
FROM parking_space ps
LEFT JOIN parking_lot pl ON ps.parking_id = pl.id
ORDER BY ps.parking_id, ps.id
LIMIT 50;

-- ============================================
-- 3. 检查预约与停车场的关联
-- ============================================
SELECT '========== 预约关联检查 ==========' AS info;
SELECT 
    r.id AS reservation_id,
    r.parking_id AS reservation_parking_id,
    r.parking_space_id,
    pl.name AS parking_lot_name,
    ps.parking_id AS space_parking_id,
    CASE 
        WHEN r.parking_id = ps.parking_id THEN '正确'
        WHEN ps.parking_id IS NULL THEN '车位不存在'
        ELSE '不匹配'
    END AS status,
    r.status AS reservation_status,
    r.created_at
FROM reservation r
LEFT JOIN parking_lot pl ON r.parking_id = pl.id
LEFT JOIN parking_space ps ON r.parking_space_id = ps.id
ORDER BY r.id DESC
LIMIT 20;

-- ============================================
-- 4. 查找关联错误的预约
-- ============================================
SELECT '========== 关联错误的预约 ==========' AS info;
SELECT 
    r.id AS reservation_id,
    r.parking_id AS reservation_parking_id,
    pl1.name AS reservation_parking_name,
    r.parking_space_id,
    ps.parking_id AS space_parking_id,
    pl2.name AS space_parking_name,
    CASE 
        WHEN r.parking_id != ps.parking_id THEN '不匹配！'
        ELSE '正确'
    END AS issue
FROM reservation r
LEFT JOIN parking_lot pl1 ON r.parking_id = pl1.id
LEFT JOIN parking_space ps ON r.parking_space_id = ps.id
LEFT JOIN parking_lot pl2 ON ps.parking_id = pl2.id
WHERE r.parking_id != ps.parking_id OR ps.parking_id IS NULL
ORDER BY r.id DESC;

-- ============================================
-- 5. 查找关联错误的车位
-- ============================================
SELECT '========== 关联错误的车位 ==========' AS info;
SELECT 
    ps.id AS space_id,
    ps.space_number,
    ps.parking_id AS space_parking_id,
    pl.name AS parking_lot_name,
    CASE 
        WHEN pl.id IS NULL THEN '停车场不存在！'
        ELSE '正确'
    END AS issue
FROM parking_space ps
LEFT JOIN parking_lot pl ON ps.parking_id = pl.id
WHERE pl.id IS NULL
ORDER BY ps.parking_id, ps.id;

