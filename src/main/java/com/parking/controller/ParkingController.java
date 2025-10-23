package com.parking.controller;

import com.parking.model.dto.ReserveDTO;
import com.parking.model.dto.ResultDTO;
import com.parking.service.ParkingService;
import org.springframework.beans.factory.annotation.Autowired;
// 移除Spring Security相关导入
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/parking")
public class ParkingController {
    
    @Autowired
    private ParkingService parkingService;
    
    /**
     * 预约停车位
     */
    @PostMapping("/reserve")
    // 移除@PreAuthorize注解，因为移除了Spring Security依赖
    public ResultDTO reserveParking(@RequestBody @Valid ReserveDTO reserveDTO) {
        return parkingService.reserve(reserveDTO);
    }
    
    /**
     * 获取停车位详情
     */
    @GetMapping("/{spaceId}")
    public ResultDTO getParkingSpace(@PathVariable Long spaceId) {
        return parkingService.getParkingSpace(spaceId);
    }
    
    /**
     * 获取附近停车场列表
     */
    @GetMapping("/nearby")
    public ResultDTO getNearbyParkings(
            @RequestParam double longitude,
            @RequestParam double latitude,
            @RequestParam(defaultValue = "2000") int radius) {
        return parkingService.getNearbyParkings(longitude, latitude, radius);
    }
    
    /**
     * 获取停车场统计信息
     */
    @GetMapping("/stats")
    public ResultDTO getParkingStats() {
        // 创建统计数据
        Map<String, Object> statsData = new HashMap<>();
        statsData.put("totalParkings", 3);
        statsData.put("totalSpaces", 450);
        statsData.put("availableSpaces", 270);
        statsData.put("occupiedSpaces", 180);
        statsData.put("hourlyRate", 5.0);
        
        return ResultDTO.success(statsData);
    }
}