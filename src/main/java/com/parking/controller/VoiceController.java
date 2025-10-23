package com.parking.controller;

import com.parking.model.vo.VoiceCommandResult;
import com.parking.service.VoiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

/**
 * 语音交互控制器
 * 处理用户语音指令的API请求
 */
@RestController
@RequestMapping("/api/v1/voice")
public class VoiceController {
    
    @Autowired
    private VoiceService voiceService;
    
    /**
     * 处理语音指令
     * @param command 语音指令文本
     * @param userId 用户ID（从请求头或会话中获取）
     * @return 语音处理结果
     */
    @PostMapping("/process")
    public ResponseEntity<VoiceCommandResult> processVoiceCommand(
            @RequestBody Map<String, String> requestBody,
            @RequestAttribute("userId") Long userId) {
        
        String command = requestBody.get("command");
        if (command == null || command.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(
                VoiceCommandResult.fail("语音指令不能为空")
            );
        }
        
        VoiceCommandResult result = voiceService.processVoiceCommand(command, userId);
        return ResponseEntity.ok(result);
    }
    
    /**
     * 获取附近空车位
     * @param userId 用户ID
     * @return 附近空车位信息
     */
    @GetMapping("/nearby-spaces")
    public ResponseEntity<VoiceCommandResult> getNearbyEmptySpaces(
            @RequestAttribute("userId") Long userId) {
        
        VoiceCommandResult result = voiceService.getNearbyEmptySpaces(userId);
        return ResponseEntity.ok(result);
    }
    
    /**
     * 导航到指定车位
     * @param spaceId 车位ID
     * @param userId 用户ID
     * @return 导航信息
     */
    @GetMapping("/navigate/{spaceId}")
    public ResponseEntity<VoiceCommandResult> navigateToSpace(
            @PathVariable Long spaceId,
            @RequestAttribute("userId") Long userId) {
        
        VoiceCommandResult result = voiceService.navigateToSpace(spaceId, userId);
        return ResponseEntity.ok(result);
    }
    
    /**
     * 识别语音指令类型
     * @param requestBody 包含指令文本的请求体
     * @return 指令类型
     */
    @PostMapping("/recognize")
    public ResponseEntity<Map<String, String>> recognizeCommandType(
            @RequestBody Map<String, String> requestBody) {
        
        String command = requestBody.get("command");
        if (command == null || command.trim().isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "语音指令不能为空");
            return ResponseEntity.badRequest().body(error);
        }
        
        String commandType = voiceService.recognizeCommandType(command);
        Map<String, String> result = new HashMap<>();
        result.put("commandType", commandType);
        
        return ResponseEntity.ok(result);
    }
}