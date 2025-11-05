package com.parking.service.impl;

import com.parking.model.dto.ParkingSpaceDTO;
import com.parking.model.dto.ResultDTO;
import com.parking.model.vo.VoiceCommandResult;
import com.parking.service.AmapService;
import com.parking.service.ChatService;
import com.parking.service.LocationService;
import com.parking.service.ParkingService;
import com.parking.service.ParkingSpaceService;
import com.parking.service.ReservationService;
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
 * 集成讯飞星火大模型进行意图识别，使用高德地图进行地理编码
 */
@Service
public class VoiceServiceImpl implements VoiceService {
    
    @Autowired
    private ParkingSpaceService parkingSpaceService;
    
    @Autowired
    private LocationService locationService;
    
    @Autowired
    private ParkingService parkingService;
    
    @Autowired
    private AmapService amapService;
    
    @Autowired
    private ChatService chatService;
    
    @Autowired
    private ReservationService reservationService;
    
    // 指令类型常量
    private static final String COMMAND_TYPE_NEARBY = "nearby";
    private static final String COMMAND_TYPE_NAVIGATE = "navigate";
    private static final String COMMAND_TYPE_RESERVE = "reserve";
    private static final String COMMAND_TYPE_CANCEL = "cancel";
    private static final String COMMAND_TYPE_STATUS = "status";
    private static final String COMMAND_TYPE_UNKNOWN = "unknown";
    
    @Override
    public VoiceCommandResult processVoiceCommand(String voiceCommand, Long userId) {
        try {
            // 步骤1：使用星火大模型进行意图识别（NLU模式）
            String nluResponse = chatService.getNluResponse(voiceCommand);
            
            if (nluResponse == null || nluResponse.trim().isEmpty() || nluResponse.equals("UNKNOWN")) {
                // 如果无法识别意图，尝试聊天模式
                String chatResponse = chatService.getChatResponse(voiceCommand);
                return VoiceCommandResult.success(
                    chatResponse != null ? chatResponse : "抱歉，我无法理解您的指令。请尝试使用'预约北京路附近的停车场'、'附近有什么停车场'等指令。",
                    COMMAND_TYPE_UNKNOWN,
                    null
                );
            }
            
            // 解析NLU响应（格式：意图类型|地点名称）
            String[] parts = nluResponse.split("\\|");
            String intent = parts[0].trim().toUpperCase();
            String locationName = parts.length > 1 ? parts[1].trim() : "";
            
            // 步骤2：根据意图类型处理
            switch (intent) {
                case "RESERVE_NEARBY":
                    return handleReserveNearbyCommand(locationName, userId);
                case "QUERY_NEARBY":
                    return handleNearbyCommand(userId);
                case "NAVIGATE":
                    return handleNavigateCommand(voiceCommand, userId);
                case "RESERVE_SPACE":
                    return handleReserveCommand(voiceCommand, userId);
                case "CANCEL_RESERVATION":
                    return handleCancelCommand(voiceCommand, userId);
                case "QUERY_STATUS":
                    return handleStatusCommand(userId);
                default:
                    // 无法识别，返回聊天回复
                    String chatResponse = chatService.getChatResponse(voiceCommand);
                    return VoiceCommandResult.success(
                        chatResponse != null ? chatResponse : "抱歉，我无法理解您的指令。",
                        COMMAND_TYPE_UNKNOWN,
                        null
                    );
            }
        } catch (Exception e) {
            System.err.println("处理语音指令异常: " + e.getMessage());
            e.printStackTrace();
            return VoiceCommandResult.fail("处理指令时发生错误，请稍后再试");
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
            // 获取用户当前位置
            Map<String, Double> location = locationService.getUserLocation(userId);
            Double longitude = location != null ? location.get("longitude") : null;
            Double latitude = location != null ? location.get("latitude") : null;
            
            // 调用 ParkingService 查询附近停车场
            ResultDTO result = parkingService.getNearbyParkings(longitude, latitude, 5000, null);
            
            if (result == null || !result.isSuccess()) {
                return VoiceCommandResult.fail("查询附近停车场失败，请稍后再试");
            }
            
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> parkings = (List<Map<String, Object>>) result.getData();
            
            if (parkings == null || parkings.isEmpty()) {
                return VoiceCommandResult.fail("附近暂无停车场，请扩大搜索范围");
            }
            
            // 转换为响应数据
            Map<String, Object> data = new HashMap<>();
            data.put("total", parkings.size());
            data.put("parkings", parkings.subList(0, Math.min(5, parkings.size()))); // 最多返回5个
            
            return VoiceCommandResult.success(
                "附近有" + parkings.size() + "个停车场",
                COMMAND_TYPE_NEARBY,
                data
            );
        } catch (Exception e) {
            System.err.println("查询附近停车场异常: " + e.getMessage());
            e.printStackTrace();
            return VoiceCommandResult.fail("获取附近停车场失败，请稍后再试");
        }
    }
    
    // 处理预约附近地点停车场的指令（新增）
    private VoiceCommandResult handleReserveNearbyCommand(String locationName, Long userId) {
        try {
            if (locationName == null || locationName.trim().isEmpty()) {
                return VoiceCommandResult.fail("请指定地点名称，例如：预约北京路附近的停车场");
            }
            
            // 步骤1：使用高德地图进行地理编码
            Map<String, Double> coords = amapService.geocode(locationName);
            if (coords == null) {
                return VoiceCommandResult.fail("无法找到地点\"" + locationName + "\"，请检查地点名称是否正确");
            }
            
            Double longitude = coords.get("longitude");
            Double latitude = coords.get("latitude");
            
            // 步骤2：查询该地点附近的停车场
            ResultDTO result = parkingService.getNearbyParkings(longitude, latitude, 2000, null);
            
            if (result == null || !result.isSuccess()) {
                return VoiceCommandResult.fail("查询附近停车场失败，请稍后再试");
            }
            
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> parkings = (List<Map<String, Object>>) result.getData();
            
            if (parkings == null || parkings.isEmpty()) {
                return VoiceCommandResult.fail(locationName + "附近暂无停车场，请扩大搜索范围");
            }
            
            // 转换为响应数据
            Map<String, Object> data = new HashMap<>();
            data.put("location", locationName);
            data.put("longitude", longitude);
            data.put("latitude", latitude);
            data.put("total", parkings.size());
            data.put("parkings", parkings.subList(0, Math.min(5, parkings.size()))); // 最多返回5个
            
            return VoiceCommandResult.success(
                "已找到" + locationName + "附近" + parkings.size() + "个停车场",
                COMMAND_TYPE_RESERVE,
                data
            );
        } catch (Exception e) {
            System.err.println("预约附近停车场异常: " + e.getMessage());
            e.printStackTrace();
            return VoiceCommandResult.fail("处理预约请求失败，请稍后再试");
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