package com.parking.service.impl;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.parking.model.dto.ParkingSpaceDTO;
import com.parking.model.dto.ResultDTO;
import com.parking.model.vo.VoiceCommandResult;
import com.parking.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 语音服务实现类 (已升级为智能调度中心)
 */
@Service
public class VoiceServiceImpl implements VoiceService {

    // 业务服务
    @Autowired
    private ParkingSpaceService parkingSpaceService;
    
    @Autowired
    private ParkingService parkingService;
    
    @Autowired
    private LocationService locationService;
    
    // AI 服务
    @Autowired
    private AmapService amapService;
    
    @Autowired
    private ChatService chatService;

    // JSON 解析器
    private final Gson gson = new Gson();

    // 指令类型常量
    private static final String COMMAND_TYPE_CHAT = "chat";
    private static final String COMMAND_TYPE_RESERVE_NEARBY = "RESERVE_NEARBY";
    private static final String COMMAND_TYPE_FIND_NEARBY = "FIND_NEARBY";
    private static final String COMMAND_TYPE_UNKNOWN = "UNKNOWN";

    @Override
    public VoiceCommandResult processVoiceCommand(String voiceCommand, Long userId) {
        
        // 步骤 1: 调用 NLU 模式 (指令1)，获取JSON回复
        String nluJsonResponse = chatService.getNluResponse(voiceCommand);
        
        String intent = COMMAND_TYPE_UNKNOWN;
        String destination = null;
        String parkingLotName = null;
        
        try {
            // 尝试解析 NLU JSON（如果返回的是JSON格式）
            if (nluJsonResponse != null && nluJsonResponse.trim().startsWith("{")) {
                JsonObject root = gson.fromJson(nluJsonResponse, JsonObject.class);
                intent = root.has("intent") ? root.get("intent").getAsString() : COMMAND_TYPE_UNKNOWN;
                
                if (root.has("entities")) {
                    JsonObject entities = root.getAsJsonObject("entities");
                    
                    if (entities.has("destination") && !entities.get("destination").isJsonNull()) {
                        destination = entities.get("destination").getAsString();
                    }
                    if (entities.has("parkingLotName") && !entities.get("parkingLotName").isJsonNull()) {
                        parkingLotName = entities.get("parkingLotName").getAsString();
                    }
                }
            } else {
                // 如果返回的是字符串格式 "RESERVE_NEARBY|北京路"，解析它
                if (nluJsonResponse != null && !nluJsonResponse.trim().isEmpty()) {
                    String[] parts = nluJsonResponse.split("\\|");
                    intent = parts[0].trim().toUpperCase();
                    if (parts.length > 1 && !parts[1].trim().isEmpty()) {
                        destination = parts[1].trim();
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("NLU 响应解析失败: " + nluJsonResponse);
            e.printStackTrace();
            // 保持 intent 为 UNKNOWN，进入聊天模式
        }

        // 步骤 2: 智能调度
        switch (intent) {
            case COMMAND_TYPE_RESERVE_NEARBY:
                // 执行"一句话预约"
                return handleReserveNearbyCommand(destination, userId);
                
            case "QUERY_NEARBY":
            case COMMAND_TYPE_FIND_NEARBY:
                // 执行"查找附近" (可以是基于地理位置或停车场名称)
                if (parkingLotName != null) {
                    // TODO: 实现按名称搜索并返回信息
                    return VoiceCommandResult.success("正在搜索 " + parkingLotName, COMMAND_TYPE_FIND_NEARBY, null);
                } else {
                    return handleNearbyCommand(userId); // 复用旧的"附近车位"
                }
                
            case COMMAND_TYPE_UNKNOWN:
            default:
                // 步骤 3: 转入聊天模式 (指令2)
                try {
                    String chatResponse = chatService.getChatResponse(voiceCommand);
                    return VoiceCommandResult.success(chatResponse, COMMAND_TYPE_CHAT, null);
                } catch (Exception e) {
                    e.printStackTrace();
                    return VoiceCommandResult.fail("抱歉，我现在有点忙，您可以换个问题吗？");
                }
        }
    }

    /**
     * 处理 "预约附近" 指令
     */
    private VoiceCommandResult handleReserveNearbyCommand(String destination, Long userId) {
        try {
            // 1. 地理编码：将 "北京路" 转为坐标
            if (destination == null || destination.isEmpty()) {
                return VoiceCommandResult.fail("请告诉我您的目的地，例如'北京路'。");
            }

            Map<String, Double> coords = amapService.geocode(destination);
            if (coords == null) {
                return VoiceCommandResult.fail("抱歉，我找不到 '" + destination + "' 的位置。");
            }
            
            // 2. 查找停车场：调用 getNearbyParkings (假设搜索半径5公里)
            ResultDTO nearbyResult = parkingService.getNearbyParkings(coords.get("longitude"), coords.get("latitude"), 5000, null);
            if (!nearbyResult.isSuccess() || !(nearbyResult.getData() instanceof List)) {
                return VoiceCommandResult.fail("在 " + destination + " 附近未找到停车场。");
            }

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> parkingLots = (List<Map<String, Object>>) nearbyResult.getData();
            if (parkingLots.isEmpty()) {
                return VoiceCommandResult.fail("在 " + destination + " 附近未找到停车场。");
            }
            
            // 3. 遍历停车场，查找第一个有空车位的
            for (Map<String, Object> lot : parkingLots) {
                Long parkingId = ((Number) lot.get("id")).longValue();
                String parkingName = (String) lot.get("name");
                
                // 4. 查找空车位
                List<ParkingSpaceDTO> availableSpaces = parkingSpaceService.getAvailableSpaces(parkingId);
                
                if (availableSpaces != null && !availableSpaces.isEmpty()) {
                    // 5. 找到了！选择第一个空车位
                    ParkingSpaceDTO firstSpace = availableSpaces.get(0);
                    
                    // 6. 准备后续动作数据
                    Map<String, Object> prefillData = new HashMap<>();
                    prefillData.put("parkingId", parkingId);
                    prefillData.put("spaceId", firstSpace.getId());
                    prefillData.put("parkingName", parkingName);
                    prefillData.put("spaceNumber", firstSpace.getSpaceNumber());
                    prefillData.put("floorName", firstSpace.getFloor() != null ? firstSpace.getFloor() : "");
                    
                    String message = "已为您在 " + destination + " 附近找到停车场【" + parkingName + "】，并锁定空闲车位【" + 
                                   (firstSpace.getFloor() != null ? firstSpace.getFloor() + "-" : "") + 
                                   firstSpace.getSpaceNumber() + "】。请完善预约信息。";
                    
                    return VoiceCommandResult.successWithFollowUp(
                        message, 
                        COMMAND_TYPE_RESERVE_NEARBY, 
                        "NAV_TO_RESERVATION_FORM", // 告诉前端跳转到预约表单
                        prefillData
                    );
                }
            }
            
            // 循环结束，没有找到任何空车位
            return VoiceCommandResult.fail("抱歉，" + destination + " 附近的所有停车场均已满位。");
            
        } catch (Exception e) {
            e.printStackTrace();
            return VoiceCommandResult.fail("处理预约时发生内部错误：" + e.getMessage());
        }
    }

    /**
     * 处理 "附近车位" 指令
     * (这是旧的实现，复用于 FIND_NEARBY 意图)
     */
    @Override
    public VoiceCommandResult getNearbyEmptySpaces(Long userId) {
        return handleNearbyCommand(userId);
    }
    
    private VoiceCommandResult handleNearbyCommand(Long userId) {
        try {
            Map<String, Double> location = locationService.getUserLocation(userId);
            if (location == null) {
                return VoiceCommandResult.fail("无法获取您的位置信息，请检查位置权限。");
            }
            
            ResultDTO nearbyResult = parkingService.getNearbyParkings(
                location.get("longitude"), 
                location.get("latitude"), 
                5000, 
                null
            );
            
            if (!nearbyResult.isSuccess() || !(nearbyResult.getData() instanceof List)) {
                return VoiceCommandResult.fail("附近暂无可用车位。");
            }

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> parkingLots = (List<Map<String, Object>>) nearbyResult.getData();
            if (parkingLots.isEmpty()) {
                return VoiceCommandResult.fail("附近暂无可用车位。");
            }

            // 只返回第一个
            Map<String, Object> firstLot = parkingLots.get(0);
            String message = "已为您找到附近停车场：" + firstLot.get("name") + "，剩余车位 " + firstLot.get("availableSpaces") + " 个。";
            
            return VoiceCommandResult.success(message, COMMAND_TYPE_FIND_NEARBY, firstLot);
            
        } catch (Exception e) {
            e.printStackTrace();
            return VoiceCommandResult.fail("获取附近车位失败：" + e.getMessage());
        }
    }

    // (旧的 recognizeCommandType 可以删掉，或保留用于兼容旧代码)
    @Override
    public String recognizeCommandType(String command) {
        // 这个方法现在被 processVoiceCommand 内部的 NLU 调用取代了
        // 我们可以保留它，但它不再是主要逻辑
        if (command.contains("附近") && (command.contains("车位") || command.contains("停车位"))) {
            return COMMAND_TYPE_FIND_NEARBY;
        }
        return COMMAND_TYPE_UNKNOWN;
    }

    @Override
    public VoiceCommandResult navigateToSpace(Long spaceId, Long userId) {
        // (此功能保持不变)
        try {
            Map<String, Object> navigationData = new HashMap<>();
            navigationData.put("spaceId", spaceId);
            navigationData.put("distance", "约200米");
            navigationData.put("estimatedTime", "约3分钟");
            
            return VoiceCommandResult.success(
                "导航已生成，正在为您规划路线",
                "navigate",
                navigationData
            );
        } catch (Exception e) {
            return VoiceCommandResult.fail("导航生成失败，请稍后再试");
        }
    }
}
