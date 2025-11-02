-- 创建数据库
CREATE DATABASE IF NOT EXISTS parking_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户
CREATE USER IF NOT EXISTS 'parking_admin'@'localhost' IDENTIFIED BY 'password';

-- 授予权限
GRANT ALL PRIVILEGES ON parking_db.* TO 'parking_admin'@'localhost';

-- 刷新权限
FLUSH PRIVILEGES;

-- 显示创建结果
SELECT 'Database and user created successfully!' AS message;
SELECT User, Host FROM mysql.user WHERE User='parking_admin';


