-- 修复用户数据：确保ID=1的用户存在
USE parking_db;

-- 如果ID=1的用户不存在，则插入
INSERT INTO user (id, openid, nickname, phone, status, create_time, update_time) 
VALUES (1, 'test_openid_001', '测试用户1', '13800138000', 0, NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    nickname = COALESCE(nickname, '测试用户1'),
    phone = COALESCE(phone, '13800138000'),
    status = 0;

-- 验证插入结果
SELECT '用户数据修复完成' AS message;
SELECT id, openid, nickname, phone, status FROM user WHERE id = 1;

