package com.parking.service.impl;

import com.parking.dao.ParkingSpaceMapper;
import com.parking.exception.ParkingException;
import com.parking.model.dto.ReserveDTO;
import com.parking.model.dto.ResultDTO;
import com.parking.model.entity.ParkingSpaceEntity;
import com.parking.service.ParkingService;
import com.parking.util.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class ParkingServiceImpl implements ParkingService {
    
    @Autowired
    private ParkingSpaceMapper parkingSpaceMapper;
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    @Override
    @Transactional
    public ResultDTO reserve(ReserveDTO dto) {
        try {
            // 参数验证
            if (dto.getSpaceId() == null || dto.getSpaceId() <= 0) {
                return ResultDTO.fail("无效的车位ID");
            }
            
            // 验证预约时间是否为未来时间
            LocalDateTime reserveTime = dto.getReserveTime();
            if (reserveTime == null || !DateUtils.isFutureTime(reserveTime)) {
                return ResultDTO.fail("预约时间必须为未来时间");
            }
            
            // 悲观锁保证并发安全
            int affected = parkingSpaceMapper.lockSpace(dto.getSpaceId());
            if (affected == 0) {
                return ResultDTO.fail("车位已被占用或不存在");
            }
            
            // 验证成功后，更新车位状态为已预约
            parkingSpaceMapper.updateStatus(dto.getSpaceId(), "RESERVED");
            
            // 存入Redis，设置过期时间（30分钟）
            String key = "parking:reservation:" + dto.getSpaceId();
            redisTemplate.opsForValue().set(key, dto, 30, java.util.concurrent.TimeUnit.MINUTES);
            
            return ResultDTO.success("预约成功");
        } catch (Exception e) {
            throw new ParkingException("预约失败：" + e.getMessage());
        }
    }
    
    @Override
    @Cacheable(value = "parkingSpace", key = "#spaceId")
    public ResultDTO getParkingSpace(Long spaceId) {
        try {
            if (spaceId == null || spaceId <= 0) {
                return ResultDTO.fail("无效的车位ID");
            }
            
            ParkingSpaceEntity entity = parkingSpaceMapper.selectById(spaceId);
            if (entity == null) {
                return ResultDTO.fail("车位不存在");
            }
            
            // 缓存数据
            redisTemplate.opsForValue().set("parking:space:" + spaceId, entity);
            
            return ResultDTO.success(entity);
        } catch (Exception e) {
            throw new ParkingException("获取车位详情失败：" + e.getMessage());
        }
    }
    
    @Override
    public ResultDTO getNearbyParkings(Double longitude, Double latitude, Integer radius) {
        try {
            // 提供默认值
            double defaultLongitude = longitude != null ? longitude : 116.4074;
            double defaultLatitude = latitude != null ? latitude : 39.9042;
            int defaultRadius = radius != null ? radius : 3000;
            
            // 详细参数验证
            if (defaultLongitude < -180 || defaultLongitude > 180) {
                return ResultDTO.fail("经度必须在-180到180之间");
            }
            if (defaultLatitude < -90 || defaultLatitude > 90) {
                return ResultDTO.fail("纬度必须在-90到90之间");
            }
            if (defaultRadius <= 0 || defaultRadius > 10000) {
                return ResultDTO.fail("搜索半径必须在1-10000米之间");
            }
            
            // 构建模拟数据，使用List和Map结构返回更有意义的数据
            java.util.List<java.util.Map<String, Object>> parkings = new java.util.ArrayList<>();
            
            // 添加几个模拟停车场
            java.util.Map<String, Object> parking1 = new java.util.HashMap<>();
            parking1.put("id", "1");
            parking1.put("name", "智能停车场A区");
            parking1.put("address", "示例街道1号");
            parking1.put("distance", 500); // 距离（米）
            parking1.put("totalSpaces", 150);
            parking1.put("availableSpaces", 85);
            parking1.put("hourlyRate", 5.0);
            parking1.put("longitude", defaultLongitude + 0.001);
            parking1.put("latitude", defaultLatitude + 0.001);
            parkings.add(parking1);
            
            java.util.Map<String, Object> parking2 = new java.util.HashMap<>();
            parking2.put("id", "2");
            parking2.put("name", "智能停车场B区");
            parking2.put("address", "示例街道2号");
            parking2.put("distance", 800);
            parking2.put("totalSpaces", 200);
            parking2.put("availableSpaces", 120);
            parking2.put("hourlyRate", 6.0);
            parking2.put("longitude", defaultLongitude - 0.002);
            parking2.put("latitude", defaultLatitude + 0.001);
            parkings.add(parking2);
            
            // 添加一个默认停车场，确保至少返回一个结果
            java.util.Map<String, Object> defaultParking = new java.util.HashMap<>();
            defaultParking.put("id", "3");
            defaultParking.put("name", "智能停车场中心区");
            defaultParking.put("address", "示例市中心");
            defaultParking.put("distance", 1200);
            defaultParking.put("totalSpaces", 300);
            defaultParking.put("availableSpaces", 150);
            defaultParking.put("hourlyRate", 8.0);
            defaultParking.put("longitude", defaultLongitude);
            defaultParking.put("latitude", defaultLatitude);
            parkings.add(defaultParking);
            
            // 返回结构化数据
            return ResultDTO.success(parkings);
        } catch (Exception e) {
            // 捕获异常并记录，返回友好的错误信息
            e.printStackTrace();
            return ResultDTO.fail("获取附近停车场失败，请稍后重试");
        }
    }
}