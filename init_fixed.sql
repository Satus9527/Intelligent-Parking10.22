-- 智能停车场系统数据库初始化脚本（修复版）

-- 设置字符集
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 创建停车记录表
CREATE TABLE IF NOT EXISTS parking_space (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '车位ID',
    parking_lot_id BIGINT NOT NULL COMMENT '停车场ID',
    space_number VARCHAR(20) NOT NULL COMMENT '车位编号',
    longitude DECIMAL(10,7) NOT NULL COMMENT '经度',
    latitude DECIMAL(10,7) NOT NULL COMMENT '纬度',
    status TINYINT DEFAULT 0 COMMENT '车位状态：0-空闲，1-已预约，2-已占用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_parking_lot_id (parking_lot_id),
    INDEX idx_status (status),
    UNIQUE KEY uk_space_number (parking_lot_id, space_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='停车位信息表';

-- 创建预约记录表
CREATE TABLE IF NOT EXISTS reservation (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '预约ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    parking_space_id BIGINT NOT NULL COMMENT '车位ID',
    license_plate VARCHAR(20) NOT NULL COMMENT '车牌号',
    reserve_time DATETIME NOT NULL COMMENT '预约时间',
    start_time DATETIME COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    status TINYINT DEFAULT 0 COMMENT '预约状态：0-待使用，1-已使用，2-已取消，3-已过期',
    payment_status TINYINT DEFAULT 0 COMMENT '支付状态：0-未支付，1-已支付',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_parking_space_id (parking_space_id),
    INDEX idx_status (status),
    FOREIGN KEY (parking_space_id) REFERENCES parking_space(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预约记录表';

-- 创建停车场信息表
CREATE TABLE IF NOT EXISTS parking_lot (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '停车场ID',
    name VARCHAR(100) NOT NULL COMMENT '停车场名称',
    address VARCHAR(255) NOT NULL COMMENT '停车场地址',
    total_spaces INT NOT NULL COMMENT '总车位数',
    available_spaces INT NOT NULL COMMENT '可用车位数',
    longitude DECIMAL(10,7) NOT NULL COMMENT '经度',
    latitude DECIMAL(10,7) NOT NULL COMMENT '纬度',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_location (longitude, latitude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='停车场信息表';

-- 插入测试数据 - 确保使用正确编码
INSERT INTO parking_lot (name, address, total_spaces, available_spaces, longitude, latitude) VALUES
('中央商务区停车场', '北京市朝阳区建国路88号', 200, 150, 116.465766, 39.924113),
('科技园停车场', '北京市海淀区中关村南大街5号', 150, 80, 116.327944, 39.984702),
('居民区停车场', '北京市丰台区马家堡西路28号', 100, 40, 116.337703, 39.868301);

-- 为每个停车场插入测试车位数据
INSERT INTO parking_space (parking_lot_id, space_number, longitude, latitude, status) VALUES
-- 中央商务区停车场车位
(1, 'A-001', 116.465766, 39.924113, 0),
(1, 'A-002', 116.465866, 39.924213, 0),
(1, 'A-003', 116.465966, 39.924313, 1),
(1, 'B-001', 116.465666, 39.924413, 0),
(1, 'B-002', 116.465566, 39.924513, 0),
-- 科技园停车场车位
(2, 'C-001', 116.327944, 39.984702, 0),
(2, 'C-002', 116.328044, 39.984802, 2),
(2, 'D-001', 116.328144, 39.984902, 0),
(2, 'D-002', 116.328244, 39.985002, 0),
-- 居民区停车场车位
(3, 'E-001', 116.337703, 39.868301, 0),
(3, 'E-002', 116.337803, 39.868401, 1),
(3, 'F-001', 116.337903, 39.868501, 0);

-- 更新停车场可用车位数
UPDATE parking_lot pl
SET available_spaces = (
    SELECT COUNT(*)
    FROM parking_space ps
    WHERE ps.parking_lot_id = pl.id AND ps.status = 0
);

-- 确认创建成功
SELECT '数据库初始化完成' AS message;
SELECT COUNT(*) AS total_parking_lots FROM parking_lot;
SELECT COUNT(*) AS total_parking_spaces FROM parking_space;