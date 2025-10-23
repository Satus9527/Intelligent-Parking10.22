package com.parking.controller;

import com.parking.model.dto.ParkingSpaceDTO;
import com.parking.model.dto.ResultDTO;
import com.parking.service.ParkingSpaceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.*;

/**
 * 实时停车场控制器
 * 处理实时车位分布相关的API请求
 */
@RestController
@RequestMapping("/api/v1/parkings")
public class RealTimeParkingController {
    
    @Autowired
    private ParkingSpaceService parkingSpaceService;
    
    /**
     * 获取停车场实时车位分布
     * @param parkingId 停车场ID
     * @param floor 楼层
     * @return 实时车位分布数据
     */
    @GetMapping("/{parkingId}/real-time-spaces")
    public ResultDTO getRealTimeSpaces(@PathVariable String parkingId, @RequestParam(defaultValue = "1") String floor) {
        // 创建响应数据对象
        Map<String, Object> responseData = new HashMap<>();
        
        // 设置楼层列表，包括地下楼层
        List<String> floors = Arrays.asList("B2", "B1", "1", "2", "3");
        responseData.put("floors", floors);
        
        // 生成模拟的车位数据
        List<Map<String, Object>> spaces = generateMockSpaceData(parkingId, floor);
        responseData.put("spaces", spaces);
        
        // 返回成功结果
        return ResultDTO.success(responseData);
    }
    
    /**
     * 获取停车场详情
     * @param parkingId 停车场ID
     * @return 停车场详情
     */
    @GetMapping("/{parkingId}")
    public ResultDTO getParkingDetail(@PathVariable String parkingId) {
        // 创建停车场详情数据
        Map<String, Object> parkingDetail = new HashMap<>();
        parkingDetail.put("id", parkingId);
        parkingDetail.put("name", "智能停车场 " + parkingId.substring(0, 3).toUpperCase());
        parkingDetail.put("address", "示例地址" + parkingId);
        parkingDetail.put("totalSpaces", 200);
        parkingDetail.put("availableSpaces", 120);
        
        return ResultDTO.success(parkingDetail);
    }
    
    /**
     * 生成模拟的车位数据
     */
    private List<Map<String, Object>> generateMockSpaceData(String parkingId, String floor) {
        List<Map<String, Object>> spaces = new ArrayList<>();
        
        // 使用parkingId作为种子，确保不同停车场有不同的数据
        // 将floor转换为数值用于种子生成
        int floorNum = 0;
        if (floor.startsWith("B")) {
            try {
                floorNum = -Integer.parseInt(floor.substring(1));
            } catch (NumberFormatException e) {
                floorNum = 0;
            }
        } else {
            try {
                floorNum = Integer.parseInt(floor);
            } catch (NumberFormatException e) {
                floorNum = 0;
            }
        }
        long seed = parkingId.hashCode() + floorNum * 100;
        Random random = new Random(seed);
        
        // 设置停车场规模
        int rows = 10; // 10行
        int cols = 12; // 12列
        
        // 为每个格子生成数据（包括车位和通道）
        for (int row = 1; row <= rows; row++) {
            for (int col = 1; col <= cols; col++) {
                // 根据行列位置决定是车位还是通道
                // 每3列设置一个通道，模拟真实停车场布局
                if (col % 3 == 0 && row % 5 != 0) {
                    // 通道位置，跳过（或标记为empty）
                    continue;
                }
                
                // 每隔5行设置一个横向通道
                if (row % 5 == 0 && col % 3 != 0) {
                    continue;
                }
                
                // 创建车位数据
                Map<String, Object> space = new HashMap<>();
                space.put("id", parkingId + "_" + floor + "_" + row + "_" + col);
                space.put("type", "space");
                space.put("row", row);
                space.put("col", col);
                
                // 生成有意义的车位编号
                int sequentialNumber = ((row - 1) * cols + col) - (row / 5) - (col / 3);
                // 如果是地下楼层，格式为B1-XXX，如果是地上楼层，格式为1FXXX
                String numberFormat = floor.startsWith("B") ? floor + "-%03d" : floor + "F%03d";
                space.put("number", String.format(numberFormat, sequentialNumber));
                
                // 设置车位状态，根据概率分布
                int rand = random.nextInt(100);
                if (rand < 60) {
                    space.put("status", "AVAILABLE");
                } else if (rand < 90) {
                    space.put("status", "OCCUPIED");
                } else if (rand < 98) {
                    space.put("status", "RESERVED");
                } else {
                    space.put("status", "FAULT"); // 添加故障状态
                }
                
                // 根据位置设置车位类型
                String spaceType;
                // 特定位置设置为VIP车位
                if ((row == 1 || row == 2) && col % 4 == 0) {
                    spaceType = "VIP";
                }
                // 特定位置设置为残疾人车位
                else if ((row == 3 || row == 4) && col % 5 == 0) {
                    spaceType = "DISABLED";
                }
                // 其他为普通车位
                else {
                    spaceType = "NORMAL";
                }
                space.put("spaceType", spaceType);
                
                spaces.add(space);
            }
        }
        
        return spaces;
    }
}