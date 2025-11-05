-- 丰富停车场和车位数据脚本 (第二批)
-- 目标：将停车场总数增加到20个
-- 2025-11-03
-- 接着现有的ID=11之后添加

SET NAMES utf8mb4;
USE parking_db;

-- ============================================
-- 1. 新增停车场 (parking_lot) - ID 12 至 20
-- ============================================

-- 12. 荔湾区 - 百万葵园停车场 (数据源: LW001)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (12, '百万葵园停车场(荔湾)', '广州市荔湾区万顷沙镇百万葵园周边', 400, 367, 3.00, 'open', '08:00-22:00', 113.5678, 22.6899)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();

-- 13. 荔湾区 - 正佳广场(荔湾店) (数据源: LW002)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (13, '正佳广场停车场(荔湾店)', '广州市荔湾区天河路228号地下', 130, 69, 15.00, 'open', '00:00-24:00', 113.2322, 23.1171)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();

-- 14. 黄埔区 - 海鸥岛停车场 (数据源: HP001)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (14, '海鸥岛停车场(黄埔)', '广州市黄埔区石楼镇海鸥岛周边', 96, 10, 5.00, 'open', '07:00-21:00', 113.5262, 22.9554)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();

-- 15. 黄埔区 - 莲花山停车场 (数据源: HP002)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (15, '莲花山停车场(黄埔)', '广州市黄埔区石楼镇莲花山周边', 79, 35, 5.00, 'open', '06:00-22:00', 113.4866, 22.9751)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();

-- 16. 番禺区 - 客村停车场 (数据源: PY001)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (16, '客村停车场', '广州市番禺区艺苑路客村附近', 73, 35, 6.00, 'open', '00:00-24:00', 113.3325, 23.0991)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();

-- 17. 花都区 - 祈福新村停车场 (数据源: HD004)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (17, '祈福新村停车场(花都)', '广州市花都区祈福大道祈福新村附近', 77, 21, 8.00, 'open', '00:00-24:00', 113.2088, 23.3661)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();

-- 18. 南沙区 - 天汇广场停车场 (数据源: NS001)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (18, '天汇广场停车场(南沙)', '广州市南沙区体育西路天汇广场地下', 23, 23, 16.00, 'open', '08:00-23:00', 113.5683, 22.7821)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();

-- 19. 增城区 - 广百百货停车场 (数据源: ZC003)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (19, '广百百货停车场(增城)', '广州市增城区北京路广百百货地下', 63, 21, 16.00, 'open', '09:00-22:00', 113.8266, 23.2951)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();

-- 20. 从化区 - 丽江花园停车场 (数据源: CH004)
INSERT INTO parking_lot (id, name, address, total_spaces, available_spaces, hourly_rate, status, operating_hours, longitude, latitude)
VALUES (20, '丽江花园停车场(从化)', '广州市从化区新园路丽江花园附近', 165, 5, 7.00, 'open', '00:00-24:00', 113.5855, 23.5439)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), address = VALUES(address), total_spaces = VALUES(total_spaces), available_spaces = VALUES(available_spaces), hourly_rate = VALUES(hourly_rate), longitude = VALUES(longitude), latitude = VALUES(latitude), updated_at = NOW();


-- ============================================
-- 2. 新增对应的车位 (parking_space) - ID 12 至 20
-- ============================================

-- 荔湾区 - 百万葵园停车场车位 (ID=12)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(12, 'LW1-01', 'A区01号', 'A区', 'G', 'AVAILABLE', 'SMALL', 0, 0, 3.00, 1),
(12, 'LW1-02', 'A区02号', 'A区', 'G', 'AVAILABLE', 'SMALL', 0, 0, 3.00, 1),
(12, 'LW1-03', 'A区03号', 'A区', 'G', 'AVAILABLE', 'LARGE', 0, 0, 5.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- 荔湾区 - 正佳广场(荔湾店)车位 (ID=13)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(13, 'LW2-A1', 'A区01', '负1层A区', 'B1', 'AVAILABLE', 'MEDIUM', 0, 0, 15.00, 1),
(13, 'LW2-A2', 'A区02', '负1层A区', 'B1', 'AVAILABLE', 'MEDIUM', 0, 0, 15.00, 1),
(13, 'LW2-B1', 'B区01', '负2层B区', 'B2', 'AVAILABLE', 'SMALL', 0, 0, 15.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- 黄埔区 - 海鸥岛停车场车位 (ID=14)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(14, 'HP1-01', '地面01', '入口区', 'G', 'AVAILABLE', 'LARGE', 0, 0, 5.00, 1),
(14, 'HP1-02', '地面02', '入口区', 'G', 'AVAILABLE', 'LARGE', 0, 0, 5.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- 黄埔区 - 莲花山停车场车位 (ID=15)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(15, 'HP2-01', 'A区01', 'A区', 'G', 'AVAILABLE', 'MEDIUM', 0, 0, 5.00, 1),
(15, 'HP2-02', 'A区02', 'A区', 'G', 'AVAILABLE', 'MEDIUM', 0, 0, 5.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- 番禺区 - 客村停车场车位 (ID=16)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(16, 'PY1-01', 'B1-01', '负1层', 'B1', 'AVAILABLE', 'SMALL', 0, 0, 6.00, 1),
(16, 'PY1-02', 'B1-02', '负1层', 'B1', 'AVAILABLE', 'SMALL', 0, 0, 6.00, 1),
(16, 'PY1-03', 'B1-03', '负1层', 'B1', 'AVAILABLE', 'MEDIUM', 0, 0, 6.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- 花都区 - 祈福新村停车场车位 (ID=17)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(17, 'HD4-01', 'A区01', 'A区', 'G', 'AVAILABLE', 'MEDIUM', 0, 0, 8.00, 1),
(17, 'HD4-02', 'A区02', 'A区', 'G', 'AVAILABLE', 'MEDIUM', 0, 0, 8.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- 南沙区 - 天汇广场停车场车位 (ID=18)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(18, 'NS1-A1', 'A区01', '负1层', 'B1', 'AVAILABLE', 'SMALL', 1, 0, 16.00, 1),
(18, 'NS1-A2', 'A区02', '负1层', 'B1', 'AVAILABLE', 'SMALL', 1, 0, 16.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- 增城区 - 广百百货停车场车位 (ID=19)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(19, 'ZC3-A1', 'A区01', '负1层', 'B1', 'AVAILABLE', 'MEDIUM', 0, 0, 16.00, 1),
(19, 'ZC3-A2', 'A区02', '负1层', 'B1', 'AVAILABLE', 'MEDIUM', 0, 0, 16.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- 从化区 - 丽江花园停车场车位 (ID=20)
INSERT INTO parking_space (parking_id, space_number, name, location, floor, status, type, category, state, hourly_rate, is_available)
VALUES
(20, 'CH4-01', 'A区01', 'A区', 'G', 'AVAILABLE', 'MEDIUM', 0, 0, 7.00, 1),
(20, 'CH4-02', 'A区02', 'A区', 'G', 'AVAILABLE', 'MEDIUM', 0, 0, 7.00, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name), location = VALUES(location), floor = VALUES(floor), status = VALUES(status), updated_at = NOW();

-- ============================================
-- 3. 更新新增停车场的可用车位数
-- ============================================
UPDATE parking_lot pl
SET available_spaces = (
    SELECT COUNT(*)
    FROM parking_space ps
    WHERE ps.parking_id = pl.id
    AND ps.status = 'AVAILABLE'
    AND ps.state = 0
    AND ps.is_available = 1
)
WHERE pl.id BETWEEN 12 AND 20;

-- ============================================
-- 4. 显示导入结果
-- ============================================
SELECT '新增9个停车场数据导入完成！' AS message;
SELECT '当前停车场总数:' AS info, COUNT(*) AS total_count FROM parking_lot;
SELECT id, name, address, total_spaces, available_spaces
FROM parking_lot
WHERE id >= 12;