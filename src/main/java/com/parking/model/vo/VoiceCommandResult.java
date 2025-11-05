package com.parking.model.vo;

import lombok.Data;

/**
 * 语音指令处理结果
 */
@Data
public class VoiceCommandResult {
    
    /**
     * 处理状态：success/fail
     */
    private String status;
    
    /**
     * 响应消息
     */
    private String message;
    
    /**
     * 指令类型
     */
    private String commandType;
    
    /**
     * 相关数据
     */
    private Object data;
    
    /**
     * 后续动作（前端可据此执行跳转等操作）
     * 例如："NAVIGATE_TO_PARKING_LIST", "NAVIGATE_TO_RESERVATION", "SHOW_PARKING_DETAIL"
     */
    private String followUpAction;
    
    /**
     * 预填充数据（用于后续页面）
     * 例如：预约页面需要预填充的停车场ID、地点名称等
     */
    private Object prefillData;
    
    /**
     * 创建成功响应
     */
    public static VoiceCommandResult success(String message, String commandType, Object data) {
        VoiceCommandResult result = new VoiceCommandResult();
        result.setStatus("success");
        result.setMessage(message);
        result.setCommandType(commandType);
        result.setData(data);
        return result;
    }
    
    /**
     * 创建带后续动作的成功响应
     */
    public static VoiceCommandResult successWithFollowUp(String message, String commandType, Object data, 
                                                         String followUpAction, Object prefillData) {
        VoiceCommandResult result = new VoiceCommandResult();
        result.setStatus("success");
        result.setMessage(message);
        result.setCommandType(commandType);
        result.setData(data);
        result.setFollowUpAction(followUpAction);
        result.setPrefillData(prefillData);
        return result;
    }
    
    /**
     * 创建失败响应
     */
    public static VoiceCommandResult fail(String message) {
        VoiceCommandResult result = new VoiceCommandResult();
        result.setStatus("fail");
        result.setMessage(message);
        return result;
    }
}