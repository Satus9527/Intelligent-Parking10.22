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
     * 创建失败响应
     */
    public static VoiceCommandResult fail(String message) {
        VoiceCommandResult result = new VoiceCommandResult();
        result.setStatus("fail");
        result.setMessage(message);
        return result;
    }
}