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
    public ResultDTO getNearbyParkings(double longitude, double latitude, int radius) {
        try {
            // 参数验证
            if (radius <= 0 || radius > 10000) {
                return ResultDTO.fail("搜索半径必须在1-10000米之间");
            }
            
            // 实际项目中这里会调用地图API和数据库查询
            // 这里为了简化，返回模拟数据
            String cacheKey = "parking:nearby:" + latitude + ":" + longitude + ":" + radius;
            
            // 尝试从缓存获取数据
            Object cachedData = redisTemplate.opsForValue().get(cacheKey);
            if (cachedData != null) {
                return ResultDTO.success(cachedData);
            }
            
            // 模拟返回附近停车场列表
            // 实际项目中需要调用地图API和数据库查询
            String result = "附近停车场列表（坐标：" + latitude + "," + longitude + "，半径：" + radius + "米）";
            
            // 存入缓存，设置过期时间（5分钟）
            redisTemplate.opsForValue().set(cacheKey, result, 5, java.util.concurrent.TimeUnit.MINUTES);
            
            return ResultDTO.success(result);
        } catch (Exception e) {
            throw new ParkingException("获取附近停车场失败：" + e.getMessage());
        }
    }
}