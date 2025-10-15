package com.parking.service;

import com.parking.model.dto.ReserveDTO;
import com.parking.model.dto.ResultDTO;

public interface ParkingService {
    /**
     * 预约停车位
     * @param reserveDTO 预约信息
     * @return 预约结果
     */
    ResultDTO reserve(ReserveDTO reserveDTO);
    
    /**
     * 获取停车位详情
     * @param spaceId 车位ID
     * @return 车位详情
     */
    ResultDTO getParkingSpace(Long spaceId);
    
    /**
     * 获取附近停车场列表
     * @param longitude 经度
     * @param latitude 纬度
     * @param radius 搜索半径（米）
     * @return 停车场列表
     */
    ResultDTO getNearbyParkings(double longitude, double latitude, int radius);
}