-- 清空所有预约记录
-- 注意：此操作会删除所有预约数据，请谨慎使用

-- 使用数据库（根据实际情况修改）
USE parking_db;

-- 显示删除前的记录数
SELECT '删除前的预约记录数:' AS info, COUNT(*) AS count FROM reservation;

-- 禁用外键检查（确保删除操作能执行）
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 删除所有预约记录
DELETE FROM reservation;

-- 重新启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- 2. 重置自增ID（如果需要从ID=1重新开始）
ALTER TABLE reservation AUTO_INCREMENT = 1;

-- 3. 释放所有被预约占用的车位（将状态重置为可用）
-- 注意：这里假设车位状态 0=可用，1=锁定，2=占用
UPDATE parking_space 
SET state = 0, status = 'AVAILABLE' 
WHERE state IN (1, 2) OR status IN ('RESERVED', 'OCCUPIED');

-- 4. 显示清空结果
SELECT '========================================' AS separator;
SELECT '预约记录已清空！' AS message;
SELECT '========================================' AS separator;
SELECT '剩余预约记录数:' AS info, COUNT(*) AS count FROM reservation;
SELECT '可用车位数:' AS info, COUNT(*) AS count FROM parking_space WHERE state = 0;

