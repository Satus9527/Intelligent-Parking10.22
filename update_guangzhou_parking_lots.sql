-- 更新广州地区停车场数据
-- 执行方式：mysql -uroot -p123 parking_db < update_guangzhou_parking_lots.sql

SET NAMES utf8mb4;
USE parking_db;

-- 清空现有停车场和车位数据（注意：这也会删除关联的预约记录）
-- 如果不想删除预约记录，请注释掉下面的DELETE语句
DELETE FROM parking_space;
DELETE FROM parking_lot;

-- 更新现有停车场数据为广州地区停车场
-- 如果ID已存在则更新，不存在则插入新记录

-- 1. 太古汇停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (1, '太古汇停车场', '广州市天河区天河路383号', 500, 350, 12.00, 'open', '07:00-23:00', 113.331394, 23.137466)
ON DUPLICATE KEY UPDATE 
    name = '太古汇停车场',
    address = '广州市天河区天河路383号',
    total_spaces = 500,
    available_spaces = 350,
    hourly_rate = 12.00,
    status = 'open',
    operating_hours = '07:00-23:00',
    longitude = 113.331394,
    latitude = 23.137466,
    updated_at = NOW();

-- 2. 正佳广场停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (2, '正佳广场停车场', '广州市天河区天河路228号', 800, 600, 10.00, 'open', '07:00-23:00', 113.330194, 23.136566)
ON DUPLICATE KEY UPDATE 
    name = '正佳广场停车场',
    address = '广州市天河区天河路228号',
    total_spaces = 800,
    available_spaces = 600,
    hourly_rate = 10.00,
    status = 'open',
    operating_hours = '07:00-23:00',
    longitude = 113.330194,
    latitude = 23.136566,
    updated_at = NOW();

-- 3. 天河城停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (3, '天河城停车场', '广州市天河区天河路208号', 600, 450, 11.00, 'open', '07:00-23:00', 113.329894, 23.135866)
ON DUPLICATE KEY UPDATE 
    name = '天河城停车场',
    address = '广州市天河区天河路208号',
    total_spaces = 600,
    available_spaces = 450,
    hourly_rate = 11.00,
    status = 'open',
    operating_hours = '07:00-23:00',
    longitude = 113.329894,
    latitude = 23.135866,
    updated_at = NOW();

-- 4. 万菱汇停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (4, '万菱汇停车场', '广州市天河区天河路230号', 400, 300, 10.00, 'open', '07:00-23:00', 113.330394, 23.136266)
ON DUPLICATE KEY UPDATE 
    name = '万菱汇停车场',
    address = '广州市天河区天河路230号',
    total_spaces = 400,
    available_spaces = 300,
    hourly_rate = 10.00,
    status = 'open',
    operating_hours = '07:00-23:00',
    longitude = 113.330394,
    latitude = 23.136266,
    updated_at = NOW();

-- 5. 广州塔停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (5, '广州塔停车场', '广州市海珠区阅江西路222号', 300, 200, 8.00, 'open', '09:00-22:00', 113.324944, 23.106594)
ON DUPLICATE KEY UPDATE 
    name = '广州塔停车场',
    address = '广州市海珠区阅江西路222号',
    total_spaces = 300,
    available_spaces = 200,
    hourly_rate = 8.00,
    status = 'open',
    operating_hours = '09:00-22:00',
    longitude = 113.324944,
    latitude = 23.106594,
    updated_at = NOW();

-- 6. 北京路停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (6, '北京路停车场', '广州市越秀区北京路283号', 250, 180, 8.00, 'open', '08:00-22:00', 113.267194, 23.124266)
ON DUPLICATE KEY UPDATE 
    name = '北京路停车场',
    address = '广州市越秀区北京路283号',
    total_spaces = 250,
    available_spaces = 180,
    hourly_rate = 8.00,
    status = 'open',
    operating_hours = '08:00-22:00',
    longitude = 113.267194,
    latitude = 23.124266,
    updated_at = NOW();

-- 7. 白云山风景区停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (7, '白云山风景区停车场', '广州市白云区广园西中路801号', 450, 80, 20.00, 'open', '06:00-22:00', 113.273194, 23.178466)
ON DUPLICATE KEY UPDATE 
    name = '白云山风景区停车场',
    address = '广州市白云区广园西中路801号',
    total_spaces = 450,
    available_spaces = 80,
    hourly_rate = 20.00,
    status = 'open',
    operating_hours = '06:00-22:00',
    longitude = 113.273194,
    latitude = 23.178466,
    updated_at = NOW();

-- 更新车位数据
-- 使用 INSERT ... ON DUPLICATE KEY UPDATE 来更新现有车位或插入新车位
-- 基于唯一键约束 (parking_id, space_number)

-- 为每个停车场插入车位数据

-- 太古汇停车场车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES 
(1, 'A1-01', 'A1区01号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 12.00, 1),
(1, 'A1-02', 'A1区02号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 12.00, 1),
(1, 'A1-03', 'A1区03号', 'A区1楼', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 12.00, 1),
(1, 'A1-04', 'A1区04号', 'A区1楼', 'L1', 'AVAILABLE', 'LARGE', 0, 0, 15.00, 1),
(1, 'A2-01', 'A2区01号', 'A区2楼', 'L2', 'AVAILABLE', 'MEDIUM', 0, 0, 12.00, 1),
(1, 'A2-02', 'A2区02号', 'A区2楼', 'L2', 'AVAILABLE', 'MEDIUM', 0, 0, 12.00, 1),
(1, 'B1-01', 'B1区01号', 'B区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 1, 0, 15.00, 1),
(1, 'B1-02', 'B1区02号', 'B区1楼', 'L1', 'AVAILABLE', 'LARGE', 1, 0, 18.00, 1),
(1, 'C1-01', 'C1区01号', 'C区1楼', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 10.00, 1),
(1, 'C1-02', 'C1区02号', 'C区1楼', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 10.00, 1)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    location = VALUES(location),
    floor = VALUES(floor),
    status = VALUES(status),
    updated_at = NOW();

-- 正佳广场停车场车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES 
(2, 'A1-01', 'A1区01号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 10.00, 1),
(2, 'A1-02', 'A1区02号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 10.00, 1),
(2, 'A1-03', 'A1区03号', 'A区1楼', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 10.00, 1),
(2, 'A2-01', 'A2区01号', 'A区2楼', 'L2', 'AVAILABLE', 'MEDIUM', 0, 0, 10.00, 1),
(2, 'A2-02', 'A2区02号', 'A区2楼', 'L2', 'AVAILABLE', 'LARGE', 0, 0, 12.00, 1),
(2, 'B1-01', 'B1区01号', 'B区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 10.00, 1),
(2, 'B1-02', 'B1区02号', 'B区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 1, 0, 12.00, 1),
(2, 'C1-01', 'C1区01号', 'C区1楼', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 8.00, 1),
(2, 'C1-02', 'C1区02号', 'C区1楼', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 8.00, 1),
(2, 'D1-01', 'D1区01号', 'D区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 2, 0, 10.00, 1)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    location = VALUES(location),
    floor = VALUES(floor),
    status = VALUES(status),
    updated_at = NOW();

-- 天河城停车场车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES 
(3, 'A1-01', 'A1区01号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 11.00, 1),
(3, 'A1-02', 'A1区02号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 11.00, 1),
(3, 'A2-01', 'A2区01号', 'A区2楼', 'L2', 'AVAILABLE', 'SMALL', 0, 0, 11.00, 1),
(3, 'B1-01', 'B1区01号', 'B区1楼', 'L1', 'AVAILABLE', 'LARGE', 0, 0, 13.00, 1),
(3, 'B1-02', 'B1区02号', 'B区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 1, 0, 13.00, 1),
(3, 'C1-01', 'C1区01号', 'C区1楼', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 9.00, 1)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    location = VALUES(location),
    floor = VALUES(floor),
    status = VALUES(status),
    updated_at = NOW();

-- 万菱汇停车场车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES 
(4, 'A1-01', 'A1区01号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 10.00, 1),
(4, 'A1-02', 'A1区02号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 10.00, 1),
(4, 'A2-01', 'A2区01号', 'A区2楼', 'L2', 'AVAILABLE', 'SMALL', 0, 0, 10.00, 1),
(4, 'B1-01', 'B1区01号', 'B区1楼', 'L1', 'AVAILABLE', 'LARGE', 0, 0, 12.00, 1),
(4, 'C1-01', 'C1区01号', 'C区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 1, 0, 12.00, 1)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    location = VALUES(location),
    floor = VALUES(floor),
    status = VALUES(status),
    updated_at = NOW();

-- 广州塔停车场车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES 
(5, 'A1-01', 'A1区01号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 8.00, 1),
(5, 'A1-02', 'A1区02号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 8.00, 1),
(5, 'A2-01', 'A2区01号', 'A区2楼', 'L2', 'AVAILABLE', 'SMALL', 0, 0, 8.00, 1),
(5, 'B1-01', 'B1区01号', 'B区1楼', 'L1', 'AVAILABLE', 'LARGE', 0, 0, 10.00, 1),
(5, 'C1-01', 'C1区01号', 'C区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 8.00, 1)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    location = VALUES(location),
    floor = VALUES(floor),
    status = VALUES(status),
    updated_at = NOW();

-- 北京路停车场车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES 
(6, 'A1-01', 'A1区01号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 8.00, 1),
(6, 'A1-02', 'A1区02号', 'A区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 8.00, 1),
(6, 'A2-01', 'A2区01号', 'A区2楼', 'L2', 'AVAILABLE', 'SMALL', 0, 0, 8.00, 1),
(6, 'B1-01', 'B1区01号', 'B区1楼', 'L1', 'AVAILABLE', 'LARGE', 0, 0, 10.00, 1),
(6, 'C1-01', 'C1区01号', 'C区1楼', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 8.00, 1)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    location = VALUES(location),
    floor = VALUES(floor),
    status = VALUES(status),
    updated_at = NOW();

-- 白云山风景区停车场车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES 
(7, 'A1-01', '1楼A1区01号', '1楼A1区', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 20.00, 1),
(7, 'A1-02', '1楼A1区02号', '1楼A1区', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 20.00, 1),
(7, 'A1-03', '1楼A1区03号', '1楼A1区', 'L1', 'AVAILABLE', 'LARGE', 0, 0, 25.00, 1),
(7, 'A2-01', '1楼A2区01号', '1楼A2区', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 18.00, 1),
(7, 'A2-02', '1楼A2区02号', '1楼A2区', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 20.00, 1),
(7, 'B1-01', '1楼B1区01号', '1楼B1区', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 20.00, 1),
(7, 'B1-02', '1楼B1区02号', '1楼B1区', 'L1', 'AVAILABLE', 'LARGE', 1, 0, 25.00, 1),
(7, 'C1-01', '1楼C1区01号', '1楼C1区', 'L1', 'AVAILABLE', 'SMALL', 0, 0, 18.00, 1),
(7, 'C1-02', '1楼C1区02号', '1楼C1区', 'L1', 'AVAILABLE', 'MEDIUM', 2, 0, 20.00, 1),
(7, 'D1-01', '1楼D1区01号', '1楼D1区', 'L1', 'AVAILABLE', 'MEDIUM', 0, 0, 20.00, 1)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    location = VALUES(location),
    floor = VALUES(floor),
    status = VALUES(status),
    updated_at = NOW();

-- 更新每个停车场的可用车位数
UPDATE parking_lot pl
SET available_spaces = (
    SELECT COUNT(*) 
    FROM parking_space ps 
    WHERE ps.parking_id = pl.id 
    AND ps.status = 'AVAILABLE' 
    AND ps.state = 0
    AND ps.is_available = 1
)
WHERE pl.id IN (1, 2, 3, 4, 5, 6, 7);

-- 显示更新结果
SELECT '广州地区停车场数据更新完成！' AS message;
SELECT id, name, address, total_spaces, available_spaces, hourly_rate 
FROM parking_lot 
ORDER BY id;

