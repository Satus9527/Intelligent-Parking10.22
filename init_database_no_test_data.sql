-- 智能停车场系统数据库初始化脚本（无测试数据）
-- 执行方式：mysql -uroot -p < init_database_no_test_data.sql
-- 注意：不要指定数据库名，脚本会自动创建并选择数据库

-- 设置字符集
SET NAMES utf8mb4;
SET CHARACTER_SET_CLIENT = utf8mb4;
SET CHARACTER_SET_RESULTS = utf8mb4;
SET CHARACTER_SET_CONNECTION = utf8mb4;

-- 删除已存在的数据库（如果存在）
DROP DATABASE IF EXISTS parking_db;

-- 创建数据库
CREATE DATABASE parking_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE parking_db;

-- ============================================
-- 1. 创建停车场信息表 (parking_lot)
-- ============================================
CREATE TABLE IF NOT EXISTS parking_lot (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '停车场ID',
    name              VARCHAR(100) NOT NULL COMMENT '停车场名称',
    address           VARCHAR(200) NOT NULL COMMENT '地址',
    total_spaces      INT NOT NULL DEFAULT 0 COMMENT '总车位数',
    available_spaces  INT NOT NULL DEFAULT 0 COMMENT '可用车位数',
    hourly_rate       DECIMAL(10,2) NOT NULL DEFAULT 5.00 COMMENT '每小时收费',
    status            VARCHAR(20) NOT NULL DEFAULT 'open' COMMENT '状态 open/closed',
    operating_hours   VARCHAR(50) DEFAULT '00:00-24:00' COMMENT '营业时间',
    longitude         DOUBLE COMMENT '经度',
    latitude          DOUBLE COMMENT '纬度',
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_status (status),
    INDEX idx_location (longitude, latitude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='停车场信息表';

-- ============================================
-- 2. 创建停车位信息表 (parking_space)
-- ============================================
CREATE TABLE IF NOT EXISTS parking_space (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '车位ID',
    parking_id   BIGINT NOT NULL COMMENT '所属停车场ID',
    space_number VARCHAR(20) NOT NULL COMMENT '车位编号',
    name         VARCHAR(100) COMMENT '车位名称',
    location     VARCHAR(200) COMMENT '车位位置',
    floor        VARCHAR(20) COMMENT '楼层',
    status       VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE' COMMENT '状态 AVAILABLE/OCCUPIED/RESERVED',
    type         VARCHAR(20) DEFAULT 'SMALL' COMMENT '类型 SMALL/MEDIUM/LARGE',
    category     INT DEFAULT 0 COMMENT '类别 0-普通 1-VIP 2-残疾人专用',
    state        INT DEFAULT 0 COMMENT '数字状态 0-空闲 1-锁定 2-占用',
    hourly_rate  DECIMAL(10,2) COMMENT '小时费率',
    daily_rate   DECIMAL(10,2) COMMENT '日费率',
    description  VARCHAR(500) COMMENT '描述',
    image_url    VARCHAR(500) COMMENT '车位图片',
    is_available INT DEFAULT 1 COMMENT '是否可用 0-不可用 1-可用',
    is_disabled  TINYINT DEFAULT 0 COMMENT '是否禁用 0-正常 1-禁用',
    version      INT DEFAULT 0 COMMENT '乐观锁版本号',
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT fk_space_lot FOREIGN KEY (parking_id) REFERENCES parking_lot(id) ON DELETE CASCADE,
    INDEX idx_parking_id (parking_id),
    INDEX idx_status (status),
    INDEX idx_state (state),
    UNIQUE KEY uk_space_number (parking_id, space_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='停车位信息表';

-- ============================================
-- 3. 创建用户表 (user)
-- ============================================
CREATE TABLE IF NOT EXISTS user (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    openid        VARCHAR(100) COMMENT '微信OpenID',
    nickname      VARCHAR(50) COMMENT '昵称',
    avatar_url    VARCHAR(500) COMMENT '头像URL',
    phone         VARCHAR(20) COMMENT '手机号',
    email         VARCHAR(80) COMMENT '邮箱',
    gender        INT COMMENT '性别 0-未知 1-男 2-女',
    license_plate VARCHAR(20) COMMENT '车牌号',
    id_card_number VARCHAR(50) COMMENT '身份证号',
    status        INT DEFAULT 0 COMMENT '状态 0-正常 1-禁用',
    create_time   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_openid (openid),
    INDEX idx_phone (phone),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ============================================
-- 4. 创建预约记录表 (reservation)
-- ============================================
CREATE TABLE IF NOT EXISTS reservation (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '预约ID',
    user_id        BIGINT NOT NULL COMMENT '用户ID',
    parking_space_id BIGINT NOT NULL COMMENT '车位ID',
    parking_id     BIGINT NOT NULL COMMENT '停车场ID',
    reservation_no VARCHAR(50) COMMENT '预约编号',
    status         INT DEFAULT 0 COMMENT '状态 0-待使用 1-已使用 2-已取消 3-已超时',
    refund_status  INT DEFAULT 0 COMMENT '退款状态 0-无退款 1-退款中 2-退款成功 3-退款失败',
    start_time     DATETIME NOT NULL COMMENT '预约开始时间',
    end_time       DATETIME NOT NULL COMMENT '预约结束时间',
    actual_entry_time DATETIME COMMENT '实际入场时间',
    actual_exit_time  DATETIME COMMENT '实际出场时间',
    plate_number   VARCHAR(20) NOT NULL COMMENT '车牌号',
    contact_phone  VARCHAR(20) NOT NULL COMMENT '联系电话',
    vehicle_info   VARCHAR(200) COMMENT '车辆信息',
    remark         VARCHAR(500) COMMENT '备注信息',
    version        INT DEFAULT 0 COMMENT '乐观锁版本号',
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT fk_res_user FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    CONSTRAINT fk_res_space FOREIGN KEY (parking_space_id) REFERENCES parking_space(id) ON DELETE CASCADE,
    CONSTRAINT fk_res_lot FOREIGN KEY (parking_id) REFERENCES parking_lot(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_parking_space_id (parking_space_id),
    INDEX idx_parking_id (parking_id),
    INDEX idx_status (status),
    INDEX idx_start_time (start_time),
    INDEX idx_end_time (end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预约记录表';

-- ============================================
-- 初始化完成提示
-- ============================================
SELECT '数据库结构初始化完成！' AS message;