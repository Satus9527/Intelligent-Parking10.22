-- 诊断停车场和车位关联问题
-- 执行方式：mysql -uroot -p123 parking_db < diagnose_parking_issue.sql

SET NAMES utf8mb4;
USE parking_db;

SELECT '========== 诊断：停车场和车位关联问题 ==========' AS info;
SELECT '';

-- 1. 显示所有停车场及其ID
SELECT '1. 停车场列表（用于对比前端ID）:' AS section;
SELECT 
    id AS parking_id,
    name AS parking_name,
    address,
    total_spaces,
    available_spaces
FROM parking_lot
ORDER BY id;

SELECT '';
SELECT '2. 车位及其关联的停车场:' AS section;
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
LIMIT 30;

SELECT '';
SELECT '3. 最近创建的预约及其关联信息:' AS section;
SELECT 
    r.id AS reservation_id,
    r.parking_id AS reservation_parking_id,
    pl.name AS reservation_parking_name,
    r.parking_space_id,
    ps.parking_id AS space_parking_id,
    pl2.name AS space_parking_name,
    r.status AS reservation_status,
    r.created_at
FROM reservation r
LEFT JOIN parking_lot pl ON r.parking_id = pl.id
LEFT JOIN parking_space ps ON r.parking_space_id = ps.id
LEFT JOIN parking_lot pl2 ON ps.parking_id = pl2.id
ORDER BY r.id DESC
LIMIT 10;

SELECT '';
SELECT '4. 检查不匹配的预约:' AS section;
SELECT 
    r.id AS reservation_id,
    r.parking_id AS reservation_parking_id,
    pl.name AS reservation_parking_name,
    r.parking_space_id,
    ps.parking_id AS space_parking_id,
    pl2.name AS space_parking_name,
    CASE 
        WHEN r.parking_id != ps.parking_id THEN '不匹配'
        ELSE '匹配'
    END AS match_status
FROM reservation r
LEFT JOIN parking_lot pl ON r.parking_id = pl.id
LEFT JOIN parking_space ps ON r.parking_space_id = ps.id
LEFT JOIN parking_lot pl2 ON ps.parking_id = pl2.id
WHERE r.parking_id != ps.parking_id OR ps.parking_id IS NULL
ORDER BY r.id DESC
LIMIT 10;

SELECT '';
SELECT '5. 前端ID映射建议:' AS section;
SELECT 
    id AS backend_id,
    name,
    CASE 
        WHEN name LIKE '%白云山%' THEN 'gz_005'
        WHEN name LIKE '%太古汇%' THEN 'gz_007'
        WHEN name LIKE '%正佳%' THEN 'gz_006'
        WHEN name LIKE '%天河城%' THEN 'gz_001'
        WHEN name LIKE '%广州塔%' THEN 'gz_004'
        WHEN name LIKE '%北京路%' THEN 'gz_003'
        ELSE CONCAT('gz_', LPAD(id, 3, '0'))
    END AS frontend_id_suggestion
FROM parking_lot
ORDER BY id;

