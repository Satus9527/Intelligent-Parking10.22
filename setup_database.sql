-- 智能停车场系统数据库初始化脚本
-- 请使用以下命令执行：mysql -u[用户名] -p[密码] parking_db < setup_database.sql

-- 设置默认字符集
SET NAMES utf8mb4;
SET CHARACTER_SET_CLIENT = utf8mb4;
SET CHARACTER_SET_RESULTS = utf8mb4;

-- 创建停车场信息表
CREATE TABLE IF NOT EXISTS parking_lot (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '停车场名称',
    address VARCHAR(200) NOT NULL COMMENT '停车场地址',
    total_spaces INT NOT NULL DEFAULT 0 COMMENT '总车位数',
    available_spaces INT NOT NULL DEFAULT 0 COMMENT '可用车位数',
    hourly_rate DECIMAL(10,2) NOT NULL DEFAULT 5.00 COMMENT '每小时收费',
    status VARCHAR(20) NOT NULL DEFAULT 'open' COMMENT '状态：open/closed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建停车位信息表
CREATE TABLE IF NOT EXISTS parking_space (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lot_id INT NOT NULL COMMENT '所属停车场ID',
    space_number VARCHAR(20) NOT NULL COMMENT '车位编号',
    space_type VARCHAR(20) NOT NULL DEFAULT 'normal' COMMENT '车位类型：normal/handicapped/charging',
    status VARCHAR(20) NOT NULL DEFAULT 'available' COMMENT '状态：available/occupied/reserved',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lot_id) REFERENCES parking_lot(id)
);

-- 创建预约记录表
CREATE TABLE IF NOT EXISTS reservation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(50) NOT NULL COMMENT '用户ID',
    space_id INT NOT NULL COMMENT '停车位ID',
    start_time DATETIME NOT NULL COMMENT '预约开始时间',
    end_time DATETIME NOT NULL COMMENT '预约结束时间',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态：pending/confirmed/cancelled/expired/completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (space_id) REFERENCES parking_space(id)
);

-- 插入测试数据
INSERT INTO parking_lot (name, address, total_spaces, available_spaces, hourly_rate) VALUES
('中央停车场', '市中心主干道1号', 50, 45, 5.00),
('科技园停车场', '高新技术开发区创业路88号', 100, 80, 6.00),
('商业广场停车场', '商业街123号', 80, 60, 8.00);

-- 为每个停车场插入一些停车位
INSERT INTO parking_space (lot_id, space_number, space_type) VALUES
(1, 'A1-01', 'normal'),
(1, 'A1-02', 'normal'),
(1, 'A1-03', 'handicapped'),
(1, 'A1-04', 'charging'),
(2, 'B1-01', 'normal'),
(2, 'B1-02', 'normal'),
(3, 'C1-01', 'normal'),
(3, 'C1-02', 'charging');

-- 更新可用车位数
UPDATE parking_lot pl
SET available_spaces = (SELECT COUNT(*) FROM parking_space ps WHERE ps.lot_id = pl.id AND ps.status = 'available');

-- 查询初始化结果
SELECT '数据库初始化完成' AS message;
SELECT '停车场信息:' AS info;
SELECT id, name, address, total_spaces, available_spaces FROM parking_lot;
SELECT '停车位信息:' AS info;
SELECT COUNT(*) AS total_spaces FROM parking_space;