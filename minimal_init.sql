SET NAMES utf8;
SET character_set_server = utf8;

-- Create tables
CREATE TABLE parking_lot (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    address VARCHAR(255),
    total_spaces INT,
    available_spaces INT,
    longitude DECIMAL(10,7),
    latitude DECIMAL(10,7)
);

CREATE TABLE parking_space (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parking_lot_id INT,
    space_number VARCHAR(20),
    longitude DECIMAL(10,7),
    latitude DECIMAL(10,7),
    status TINYINT,
    FOREIGN KEY (parking_lot_id) REFERENCES parking_lot(id)
);

CREATE TABLE reservation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    parking_space_id INT,
    license_plate VARCHAR(20),
    reserve_time DATETIME,
    status TINYINT,
    FOREIGN KEY (parking_space_id) REFERENCES parking_space(id)
);

-- Insert simple test data
INSERT INTO parking_lot (name, address, total_spaces, available_spaces, longitude, latitude) VALUES
('Parking 1', 'Address 1', 100, 50, 116.4, 39.9),
('Parking 2', 'Address 2', 80, 40, 116.5, 40.0);

INSERT INTO parking_space (parking_lot_id, space_number, longitude, latitude, status) VALUES
(1, 'A-001', 116.4, 39.9, 0),
(1, 'A-002', 116.41, 39.91, 0);

SELECT 'Database initialized' AS status;