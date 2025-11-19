-- 简单版本：直接清空预约记录（手动执行用）
-- 在MySQL命令行中执行：source clear_all_reservations_simple.sql

USE parking_db;

-- 显示删除前的记录数
SELECT COUNT(*) AS '删除前的预约记录数' FROM reservation;

-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- 删除所有预约记录
TRUNCATE TABLE reservation;

-- 重新启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- 释放所有被占用的车位
UPDATE parking_space 
SET state = 0, status = 'AVAILABLE' 
WHERE state IN (1, 2) OR status IN ('RESERVED', 'OCCUPIED');

-- 显示结果
SELECT '预约记录已清空！' AS '结果';
SELECT COUNT(*) AS '剩余预约记录数' FROM reservation;

