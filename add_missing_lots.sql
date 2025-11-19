SET NAMES utf8mb4;
USE parking_db;

-- ============================================
-- 补充缺失的停车场 (ID 8-11)
-- ============================================

-- 8. 越秀公园停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (8, '越秀公园停车场', '广州市越秀区解放北路988号', 300, 150, 8.00, 'open', '06:00-22:00', 113.2657, 23.1435)
ON DUPLICATE KEY UPDATE available_spaces = VALUES(available_spaces);

-- 9. 广州动物园停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (9, '广州动物园停车场', '广州市越秀区先烈中路120号', 200, 80, 10.00, 'open', '08:00-18:00', 113.3036, 23.1483)
ON DUPLICATE KEY UPDATE available_spaces = VALUES(available_spaces);

-- 10. 广东省博物馆停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (10, '广东省博物馆停车场', '广州市天河区珠江东路2号', 400, 320, 6.00, 'open', '09:00-17:00', 113.3263, 23.1181)
ON DUPLICATE KEY UPDATE available_spaces = VALUES(available_spaces);

-- 11. 长隆欢乐世界停车场
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (11, '长隆欢乐世界停车场', '广州市番禺区汉溪大道东299号', 1000, 850, 15.00, 'open', '09:00-23:00', 113.3322, 22.9968)
ON DUPLICATE KEY UPDATE available_spaces = VALUES(available_spaces);

-- ============================================
-- 补充对应的车位数据
-- ============================================

-- 8. 越秀公园车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, hourly_rate, is_available) VALUES
(8, 'YX2-01', 'A区01', '地面A区', 'G', 'AVAILABLE', 'MEDIUM', 8.00, 1),
(8, 'YX2-02', 'A区02', '地面A区', 'G', 'AVAILABLE', 'MEDIUM', 8.00, 1);

-- 9. 广州动物园车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, hourly_rate, is_available) VALUES
(9, 'ZW1-01', '南门01', '南门停车场', 'G', 'AVAILABLE', 'SMALL', 10.00, 1),
(9, 'ZW1-02', '南门02', '南门停车场', 'G', 'AVAILABLE', 'SMALL', 10.00, 1);

-- 10. 省博物馆车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, hourly_rate, is_available) VALUES
(10, 'BW1-01', '负一01', '地下负一层', 'B1', 'AVAILABLE', 'MEDIUM', 6.00, 1),
(10, 'BW1-02', '负一02', '地下负一层', 'B1', 'AVAILABLE', 'MEDIUM', 6.00, 1);

-- 11. 长隆车位
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, hourly_rate, is_available) VALUES
(11, 'CL1-01', '北门01', '北门停车场', 'G', 'AVAILABLE', 'LARGE', 15.00, 1),
(11, 'CL1-02', '北门02', '北门停车场', 'G', 'AVAILABLE', 'LARGE', 15.00, 1);

-- 更新可用车位统计
UPDATE parking_lot pl
SET available_spaces = (
    SELECT COUNT(*) FROM parking_space ps 
    WHERE ps.parking_id = pl.id AND ps.status = 'AVAILABLE'
)
WHERE pl.id BETWEEN 8 AND 11;

SELECT '补充数据完成，当前停车场总数：' as msg, COUNT(*) as total FROM parking_lot;