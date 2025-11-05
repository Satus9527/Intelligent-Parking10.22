package com.parking.service;

/**
 * 讯飞星火大模型服务接口
 * 负责自然语言理解和对话生成
 */
public interface ChatService {
    
    /**
     * NLU模式：理解用户意图并返回结构化结果
     * 用于指令识别（如"预约北京路附近的停车场"）
     * @param text 用户输入的文本
     * @return 意图识别结果（如"RESERVE_NEARBY"或"UNKNOWN"）
     */
    String getNluResponse(String text);
    
    /**
     * 聊天模式：生成对话回复
     * 用于普通聊天场景
     * @param text 用户输入的文本
     * @return AI生成的回复文本
     */
    String getChatResponse(String text);
}

