package com.parking.controller;

import com.parking.model.dto.ReserveDTO;
import com.parking.model.dto.ResultDTO;
import com.parking.service.ParkingService;
import org.springframework.beans.factory.annotation.Autowired;
// 移除Spring Security相关导入
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;

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
}