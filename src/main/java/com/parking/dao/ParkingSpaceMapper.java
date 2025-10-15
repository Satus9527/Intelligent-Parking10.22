package com.parking.dao;

import com.parking.model.entity.ParkingSpaceEntity;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface ParkingSpaceMapper {
    /**
     * 根据ID查询车位信息
     */
    ParkingSpaceEntity selectById(Long id);
    
    /**
     * 查询可用车位列表
     */
    List<ParkingSpaceEntity> selectAvailableSpaces(Long parkingId);
    
    /**
     * 锁定车位（悲观锁）
     */
    int lockSpace(Long spaceId);
    
    /**
     * 更新车位状态
     */
    int updateStatus(Long spaceId, String status);
}