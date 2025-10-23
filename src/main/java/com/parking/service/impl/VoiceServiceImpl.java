package com.parking.service.impl;

import com.parking.model.dto.ParkingSpaceDTO;
import com.parking.model.vo.VoiceCommandResult;
import com.parking.service.LocationService;
import com.parking.service.ParkingSpaceService;
import com.parking.service.VoiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * 语音服务实现类
 */
@Service
public class VoiceServiceImpl implements VoiceService {
    
    @Autowired
    private ParkingSpaceService parkingSpaceService;
    
    @Autowired
    private LocationService locationService;
    
    // 指令类型常量
    private static final String COMMAND_TYPE_NEARBY = "nearby";
    private static final String COMMAND_TYPE_NAVIGATE = "navigate";
    private static final String COMMAND_TYPE_RESERVE = "reserve";
    private static final String COMMAND_TYPE_CANCEL = "cancel";
    private static final String COMMAND_TYPE_STATUS = "status";
    private static final String COMMAND_TYPE_UNKNOWN = "unknown";
    
    @Override
    public VoiceCommandResult processVoiceCommand(String voiceCommand, Long userId) {
        // 转换为小写以便匹配
        String command = voiceCommand.toLowerCase().trim();
        
        // 识别指令类型
        String commandType = recognizeCommandType(command);
        
        // 根据指令类型处理
        switch (commandType) {
            case COMMAND_TYPE_NEARBY:
                return handleNearbyCommand(userId);
            case COMMAND_TYPE_NAVIGATE:
                return handleNavigateCommand(command, userId);
            case COMMAND_TYPE_RESERVE:
                return handleReserveCommand(command, userId);
            case COMMAND_TYPE_CANCEL:
                return handleCancelCommand(command, userId);
            case COMMAND_TYPE_STATUS:
                return handleStatusCommand(userId);
            default:
                return VoiceCommandResult.fail("抱歉，我无法理解您的指令。请尝试使用'附近车位'、'导航到车位'等指令。");
        }
    }
    
    @Override
    public String recognizeCommandType(String command) {
        // 附近车位指令
        if (command.contains("附近") && (command.contains("车位") || command.contains("空车位") || command.contains("停车位"))) {
            return COMMAND_TYPE_NEARBY;
        }
        
        // 导航指令
        if (command.contains("导航") && (command.contains("车位") || command.contains("到车位"))) {
            return COMMAND_TYPE_NAVIGATE;
        }
        
        // 预约指令
        if ((command.contains("预约") || command.contains("预订")) && command.contains("车位")) {
            return COMMAND_TYPE_RESERVE;
        }
        
        // 取消预约指令
        if (command.contains("取消") && (command.contains("预约") || command.contains("预订"))) {
            return COMMAND_TYPE_CANCEL;
        }
        
        // 状态查询指令
        if (command.contains("预约状态") || command.contains("我的预约") || command.contains("当前")) {
            return COMMAND_TYPE_STATUS;
        }
        
        return COMMAND_TYPE_UNKNOWN;
    }
    
    @Override
    public VoiceCommandResult getNearbyEmptySpaces(Long userId) {
        return handleNearbyCommand(userId);
    }
    
    @Override
    public VoiceCommandResult navigateToSpace(Long spaceId, Long userId) {
        try {
            // 生成导航路径（这里简化实现，实际应调用地图服务）
            Map<String, Object> navigationData = new HashMap<>();
            navigationData.put("spaceId", spaceId);
            navigationData.put("distance", "约200米");
            navigationData.put("estimatedTime", "约3分钟");
            navigationData.put("route", "从入口直走，左转第三个路口");
            
            return VoiceCommandResult.success(
                "导航已生成，正在为您规划路线",
                COMMAND_TYPE_NAVIGATE,
                navigationData
            );
        } catch (Exception e) {
            return VoiceCommandResult.fail("导航生成失败，请稍后再试");
        }
    }
    
    // 处理附近车位查询指令
    private VoiceCommandResult handleNearbyCommand(Long userId) {
        try {
            // 获取用户当前位置（实际应从LocationService获取）
            Map<String, Double> location = locationService.getUserLocation(userId);
            
            // 由于findNearbyAvailableSpaces方法不存在，我们提供一个模拟实现
            List<ParkingSpaceDTO> spaces = new ArrayList<>();
            // 添加一些模拟数据，只使用DTO中实际存在的属性
            ParkingSpaceDTO space1 = new ParkingSpaceDTO();
            space1.setId(1L);
            space1.setSpaceNumber("A101");
            spaces.add(space1);
            
            ParkingSpaceDTO space2 = new ParkingSpaceDTO();
            space2.setId(2L);
            space2.setSpaceNumber("B203");
            spaces.add(space2);
            
            if (spaces.isEmpty()) {
                return VoiceCommandResult.fail("附近暂无可用车位，请扩大搜索范围");
            }
            
            // 转换为响应数据
            Map<String, Object> data = new HashMap<>();
            data.put("total", spaces.size());
            data.put("spaces", spaces.subList(0, Math.min(5, spaces.size()))); // 最多返回5个
            
            return VoiceCommandResult.success(
                "附近有" + spaces.size() + "个可用车位",
                COMMAND_TYPE_NEARBY,
                data
            );
        } catch (Exception e) {
            return VoiceCommandResult.fail("获取附近车位失败，请稍后再试");
        }
    }
    
    // 处理导航指令
    private VoiceCommandResult handleNavigateCommand(String command, Long userId) {
        try {
            // 从指令中提取车位编号（简化实现）
            Pattern pattern = Pattern.compile("车位(\\d+)");
            java.util.regex.Matcher matcher = pattern.matcher(command);
            
            if (matcher.find()) {
                Long spaceId = Long.parseLong(matcher.group(1));
                return navigateToSpace(spaceId, userId);
            } else {
                return VoiceCommandResult.fail("请指定要导航的车位编号");
            }
        } catch (Exception e) {
            return VoiceCommandResult.fail("导航指令处理失败，请检查车位编号是否正确");
        }
    }
    
    // 处理预约指令
    private VoiceCommandResult handleReserveCommand(String command, Long userId) {
        try {
            // 从指令中提取车位编号
            Pattern pattern = Pattern.compile("车位(\\d+)");
            java.util.regex.Matcher matcher = pattern.matcher(command);
            
            if (matcher.find()) {
                Long spaceId = Long.parseLong(matcher.group(1));
                
                // 这里应调用预约服务进行预约
                // 简化实现，返回成功信息
                Map<String, Object> data = new HashMap<>();
                data.put("spaceId", spaceId);
                data.put("reservationTime", "15分钟");
                
                return VoiceCommandResult.success(
                    "车位预约成功，请在15分钟内到达",
                    COMMAND_TYPE_RESERVE,
                    data
                );
            } else {
                return VoiceCommandResult.fail("请指定要预约的车位编号");
            }
        } catch (Exception e) {
            return VoiceCommandResult.fail("预约失败，请稍后再试");
        }
    }
    
    // 处理取消预约指令
    private VoiceCommandResult handleCancelCommand(String command, Long userId) {
        try {
            // 简化实现，实际应调用预约服务取消预约
            return VoiceCommandResult.success(
                "预约已取消",
                COMMAND_TYPE_CANCEL,
                null
            );
        } catch (Exception e) {
            return VoiceCommandResult.fail("取消预约失败，请稍后再试");
        }
    }
    
    // 处理状态查询指令
    private VoiceCommandResult handleStatusCommand(Long userId) {
        try {
            // 简化实现，实际应查询用户当前预约状态
            Map<String, Object> data = new HashMap<>();
            data.put("hasActiveReservation", false);
            data.put("message", "您当前没有活跃的预约");
            
            return VoiceCommandResult.success(
                "查询成功",
                COMMAND_TYPE_STATUS,
                data
            );
        } catch (Exception e) {
            return VoiceCommandResult.fail("查询状态失败，请稍后再试");
        }
    }
}