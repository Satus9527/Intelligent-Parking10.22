-- 检查停车场和车位数据的一致性
-- 执行方式：mysql -uroot -p123 parking_db < check_parking_data.sql

SET NAMES utf8mb4;
USE parking_db;

-- 1. 显示所有停车场信息
SELECT '========== 停车场列表 ==========' AS info;
SELECT id, name, address, total_spaces, available_spaces, hourly_rate 
FROM parking_lot 
ORDER BY id;

-- 2. 显示车位及其关联的停车场
SELECT '========== 车位与停车场关联 ==========' AS info;
SELECT 
    ps.id AS space_id,
    ps.space_number,
    ps.parking_id,
    pl.name AS parking_lot_name,
    pl.address AS parking_lot_address,
    ps.status,
    ps.state
FROM parking_space ps
LEFT JOIN parking_lot pl ON ps.parking_id = pl.id
ORDER BY ps.parking_id, ps.id
LIMIT 50;

-- 3. 检查是否有车位关联到不存在的停车场
SELECT '========== 无效关联检查 ==========' AS info;
SELECT 
    ps.id AS space_id,
    ps.space_number,
    ps.parking_id,
    '车位关联的停车场不存在' AS issue
FROM parking_space ps
LEFT JOIN parking_lot pl ON ps.parking_id = pl.id
WHERE pl.id IS NULL;

-- 4. 检查预约及其关联的停车场
SELECT '========== 预约与停车场关联 ==========' AS info;
SELECT 
    r.id AS reservation_id,
    r.parking_id AS reservation_parking_id,
    pl.name AS parking_lot_name,
    pl.address AS parking_lot_address,
    r.status AS reservation_status,
    r.created_at
FROM reservation r
LEFT JOIN parking_lot pl ON r.parking_id = pl.id
ORDER BY r.id DESC
LIMIT 20;

