package com.parking.service.impl;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.parking.service.ChatService;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 讯飞星火大模型服务实现类
 * 使用 WebSocket 连接讯飞星火 API v4.0
 */
@Service
public class ChatServiceImpl implements ChatService {

    @Value("${iflytek.spark.appid}")
    private String appId;

    @Value("${iflytek.spark.api-key}")
    private String apiKey;

    @Value("${iflytek.spark.api-secret}")
    private String apiSecret;

    @Value("${iflytek.spark.chat-url}")
    private String chatUrl;

    private final Gson gson = new Gson();
    private final OkHttpClient client = new OkHttpClient.Builder()
            .readTimeout(60, java.util.concurrent.TimeUnit.SECONDS)
            .build();

    // NLU 指令提示词（返回JSON格式）
    private static final String NLU_PROMPT = "你是一个智能停车场助手。请分析用户的语音指令，判断用户意图。\n" +
            "可能的意图类型：\n" +
            "1. RESERVE_NEARBY - 用户想预约附近某个地点的停车场（如\"预约北京路附近的停车场\"）\n" +
            "2. RESERVE_SPACE - 用户想预约特定车位（如\"预约A101车位\"）\n" +
            "3. FIND_NEARBY - 用户想查找附近停车场（如\"附近有什么停车场\"、\"查找天河区的停车场\"）\n" +
            "4. NAVIGATE - 用户想导航到某个地点（如\"导航到北京路\"）\n" +
            "5. CANCEL_RESERVATION - 用户想取消预约\n" +
            "6. QUERY_STATUS - 用户想查询预约状态\n" +
            "7. UNKNOWN - 无法识别或普通聊天\n\n" +
            "请以JSON格式返回结果，格式如下：\n" +
            "{\n" +
            "  \"intent\": \"意图类型（如RESERVE_NEARBY）\",\n" +
            "  \"entities\": {\n" +
            "    \"destination\": \"地点名称（如北京路，如果适用）\",\n" +
            "    \"parkingLotName\": \"停车场名称（如果适用）\"\n" +
            "  }\n" +
            "}\n" +
            "例如：\n" +
            "用户说\"预约北京路附近的停车场\" -> {\"intent\":\"RESERVE_NEARBY\",\"entities\":{\"destination\":\"北京路\"}}\n" +
            "用户说\"附近有什么停车场\" -> {\"intent\":\"FIND_NEARBY\",\"entities\":{}}\n" +
            "用户说\"你好\" -> {\"intent\":\"UNKNOWN\",\"entities\":{}}";

    // 聊天模式提示词
    private static final String CHAT_PROMPT = "你是一个智能停车场助手，名字叫小智。你友好、专业，可以帮助用户预约停车位、查询附近停车场、导航等功能。请用简洁、友好的方式回复用户。";

    @Override
    public String getNluResponse(String text) {
        try {
            String response = callSparkAPI(text, NLU_PROMPT);
            
            if (response == null || response.trim().isEmpty()) {
                // 返回默认UNKNOWN的JSON
                return "{\"intent\":\"UNKNOWN\",\"entities\":{}}";
            }
            
            // 尝试解析JSON响应
            try {
                JsonObject json = gson.fromJson(response.trim(), JsonObject.class);
                // 验证JSON格式是否正确
                if (json.has("intent")) {
                    return response.trim(); // 返回原始JSON
                }
            } catch (Exception jsonEx) {
                // 如果不是JSON格式，尝试解析为旧格式（向后兼容）
                System.out.println("NLU响应不是JSON格式，尝试解析为旧格式: " + response);
                String[] parts = response.split("\\|");
                String intent = parts[0].trim().toUpperCase();
                String destination = parts.length > 1 ? parts[1].trim() : "";
                
                // 转换为JSON格式
                JsonObject json = new JsonObject();
                json.addProperty("intent", intent);
                JsonObject entities = new JsonObject();
                if (!destination.isEmpty()) {
                    entities.addProperty("destination", destination);
                }
                json.add("entities", entities);
                return gson.toJson(json);
            }
            
            // 如果都失败了，返回默认UNKNOWN
            return "{\"intent\":\"UNKNOWN\",\"entities\":{}}";
            
        } catch (Exception e) {
            System.err.println("NLU处理异常: " + e.getMessage());
            e.printStackTrace();
            return "{\"intent\":\"UNKNOWN\",\"entities\":{}}";
        }
    }

    @Override
    public String getChatResponse(String text) {
        try {
            System.out.println("开始调用讯飞星火API，用户输入: " + text);
            System.out.println("配置信息 - APPID: " + appId + ", API-Key: " + (apiKey != null ? apiKey.substring(0, Math.min(8, apiKey.length())) + "..." : "null"));
            System.out.println("配置信息 - Chat URL: " + chatUrl);
            
            String response = callSparkAPI(text, CHAT_PROMPT);
            
            if (response == null || response.trim().isEmpty()) {
                System.err.println("警告: 讯飞API返回空响应");
                return "抱歉，我现在有点忙，请稍后再试。";
            }
            
            System.out.println("讯飞API调用成功，响应长度: " + response.length());
            return response;
        } catch (Exception e) {
            System.err.println("========== 聊天处理异常 ==========");
            System.err.println("异常类型: " + e.getClass().getName());
            System.err.println("异常消息: " + e.getMessage());
            System.err.println("异常原因: " + (e.getCause() != null ? e.getCause().getMessage() : "无"));
            
            // 输出更详细的错误信息
            if (e.getMessage() != null) {
                String errorMsg = e.getMessage().toLowerCase();
                if (errorMsg.contains("401") || errorMsg.contains("unauthorized") || errorMsg.contains("鉴权")) {
                    System.err.println("错误类型: 鉴权失败 - 请检查 appid、api-key 和 api-secret 是否正确");
                } else if (errorMsg.contains("403") || errorMsg.contains("forbidden")) {
                    System.err.println("错误类型: 权限不足 - 请确认 APPID 是否开通了 v4.0 版本权限");
                } else if (errorMsg.contains("timeout") || errorMsg.contains("超时")) {
                    System.err.println("错误类型: 连接超时 - 请检查网络连接或防火墙设置");
                } else if (errorMsg.contains("connection") || errorMsg.contains("连接")) {
                    System.err.println("错误类型: 连接失败 - 无法连接到讯飞服务器");
                } else if (errorMsg.contains("signature") || errorMsg.contains("签名")) {
                    System.err.println("错误类型: 签名错误 - 请检查系统时间是否准确");
                }
            }
            
            System.err.println("完整堆栈跟踪:");
            e.printStackTrace();
            System.err.println("==================================");
            
            return "抱歉，我现在有点忙，请稍后再试。";
        }
    }

    /**
     * 调用讯飞星火API
     */
    private String callSparkAPI(String userText, String systemPrompt) throws Exception {
        // 验证配置
        if (appId == null || appId.trim().isEmpty()) {
            throw new IllegalArgumentException("讯飞 APPID 未配置");
        }
        if (apiKey == null || apiKey.trim().isEmpty()) {
            throw new IllegalArgumentException("讯飞 API-Key 未配置");
        }
        if (apiSecret == null || apiSecret.trim().isEmpty()) {
            throw new IllegalArgumentException("讯飞 API-Secret 未配置");
        }
        if (chatUrl == null || chatUrl.trim().isEmpty()) {
            throw new IllegalArgumentException("讯飞 Chat URL 未配置");
        }
        
        // 生成鉴权URL
        System.out.println("正在生成鉴权URL...");
        String authUrl = generateAuthUrl();
        System.out.println("鉴权URL生成成功（已隐藏敏感信息）");
        
        // 构建消息数组（用于payload.message.text）
        // 注意：v4.0 API可能不支持system角色，需要将系统提示词合并到用户消息中
        JsonArray textMessages = new JsonArray();
        
        // 构建完整的用户消息（包含系统提示词和用户输入）
        String fullUserMessage = userText;
        if (systemPrompt != null && !systemPrompt.isEmpty()) {
            // 将系统提示词作为上下文加入到用户消息中
            // 格式：系统提示词 + \n\n用户输入
            fullUserMessage = systemPrompt + "\n\n用户说：" + userText;
        }
        
        // 添加用户消息（v4.0 API通常只需要user角色）
        JsonObject userMessage = new JsonObject();
        userMessage.addProperty("role", "user");
        userMessage.addProperty("content", fullUserMessage);
        textMessages.add(userMessage);
        
        System.out.println("构建的消息数量: " + textMessages.size());
        System.out.println("用户消息长度: " + fullUserMessage.length());
        
        // 构建请求体 - 按照讯飞星火 v4.0 API 的正确格式
        // 1. header 字段
        JsonObject header = new JsonObject();
        header.addProperty("app_id", appId);
        header.addProperty("uid", "user_" + System.currentTimeMillis()); // 用户标识，可以使用时间戳
        
        // 2. parameter 字段
        JsonObject parameter = new JsonObject();
        JsonObject chatParam = new JsonObject();
        // v4.0 版本：使用 domain 参数，正确值应该是 "4.0Ultra"
        chatParam.addProperty("domain", "4.0Ultra");
        chatParam.addProperty("temperature", 0.5);
        chatParam.addProperty("max_tokens", 4096);
        parameter.add("chat", chatParam);
        
        // 3. payload 字段
        JsonObject payload = new JsonObject();
        JsonObject messageObj = new JsonObject();
        messageObj.add("text", textMessages); // 消息数组放在 text 字段中
        payload.add("message", messageObj);
        
        // 4. 构建完整的请求体
        JsonObject requestData = new JsonObject();
        requestData.add("header", header);
        requestData.add("parameter", parameter);
        requestData.add("payload", payload);
        
        String requestBody = gson.toJson(requestData);
        System.out.println("========== 请求体详情 ==========");
        System.out.println("请求体JSON（已隐藏敏感信息）: " + requestBody.replace(appId, "***").replace(apiKey, "***"));
        System.out.println("请求体大小: " + requestBody.length() + " 字节");
        System.out.println("==================================");
        
        // 建立WebSocket连接
        Request request = new Request.Builder()
                .url(authUrl)
                .build();
        
        final StringBuilder responseBuilder = new StringBuilder();
        final Object lock = new Object();
        final boolean[] completed = {false};
        final Exception[] connectionError = {null}; // 用于存储连接错误
        
        System.out.println("========== 开始建立WebSocket连接 ==========");
        System.out.println("鉴权URL（前100字符）: " + (authUrl.length() > 100 ? authUrl.substring(0, 100) + "..." : authUrl));
        
        WebSocket webSocket = client.newWebSocket(request, new WebSocketListener() {
            @Override
            public void onOpen(WebSocket webSocket, Response response) {
                System.out.println("========== WebSocket连接已建立 ==========");
                System.out.println("HTTP状态码: " + response.code());
                System.out.println("响应消息: " + response.message());
                
                if (response.code() != 101) {
                    System.err.println("警告: WebSocket连接状态码异常！期望101，实际: " + response.code());
                    System.err.println("这可能导致连接失败");
                    connectionError[0] = new RuntimeException("WebSocket握手失败，状态码: " + response.code());
                } else {
                    System.out.println("WebSocket握手成功（状态码101）");
                }
                
                // 发送消息
                System.out.println("正在发送请求消息...");
                System.out.println("请求体长度: " + requestBody.length());
                try {
                    webSocket.send(requestBody);
                    System.out.println("请求消息已发送");
                } catch (Exception e) {
                    System.err.println("发送请求消息失败: " + e.getMessage());
                    connectionError[0] = new RuntimeException("发送请求消息失败", e);
                    synchronized (lock) {
                        completed[0] = true;
                        lock.notify();
                    }
                }
                System.out.println("======================================");
            }
            
            @Override
            public void onMessage(WebSocket webSocket, String text) {
                System.out.println("========== 收到WebSocket消息 ==========");
                System.out.println("消息长度: " + text.length());
                System.out.println("消息内容（前500字符）: " + (text.length() > 500 ? text.substring(0, 500) + "..." : text));
                System.out.println("======================================");
                try {
                    JsonObject json = gson.fromJson(text, JsonObject.class);
                    
                    // 检查是否有错误
                    if (json.has("header")) {
                        JsonObject header = json.getAsJsonObject("header");
                        if (header.has("code") && header.get("code").getAsInt() != 0) {
                            int code = header.get("code").getAsInt();
                            String message = header.has("message") ? header.get("message").getAsString() : "未知错误";
                            System.err.println("讯飞API返回错误 - 错误码: " + code + ", 错误消息: " + message);
                            
                            // 根据错误码提供更详细的说明
                            switch (code) {
                                case 10013:
                                    System.err.println("错误说明: APPID不存在或未开通服务");
                                    break;
                                case 10014:
                                    System.err.println("错误说明: 签名校验失败，请检查api-key和api-secret");
                                    break;
                                case 10015:
                                    System.err.println("错误说明: 参数校验失败");
                                    break;
                                case 10019:
                                    System.err.println("错误说明: 请求过于频繁，请稍后再试");
                                    break;
                                default:
                                    System.err.println("请查看讯飞星火API文档了解错误码含义");
                            }
                            
                            // 保存错误信息
                            connectionError[0] = new RuntimeException("讯飞API返回错误: " + code + " - " + message);
                            
                            synchronized (lock) {
                                completed[0] = true;
                                lock.notify();
                            }
                            webSocket.close(1000, "错误关闭");
                            return;
                        }
                    }
                    
                    JsonObject payload = json.getAsJsonObject("payload");
                    
                    if (payload != null) {
                        // v4.0 API 响应格式：payload.choices.text 数组
                        JsonObject choices = payload.getAsJsonObject("choices");
                        if (choices != null) {
                            JsonArray textArray = choices.getAsJsonArray("text");
                            if (textArray != null && textArray.size() > 0) {
                                JsonObject textObj = textArray.get(0).getAsJsonObject();
                                if (textObj.has("content")) {
                                    String content = textObj.get("content").getAsString();
                                    responseBuilder.append(content);
                                    System.out.println("已追加内容片段，当前总长度: " + responseBuilder.length());
                                } else {
                                    System.err.println("警告: text对象中未找到content字段");
                                    System.err.println("text对象内容: " + textObj.toString());
                                }
                            } else {
                                System.err.println("警告: text数组为空或不存在");
                                System.err.println("choices对象: " + choices.toString());
                            }
                        } else {
                            System.err.println("警告: payload中未找到choices字段");
                            System.err.println("payload对象: " + payload.toString());
                        }
                        
                        // 检查是否完成 - v4.0 API使用payload.status.status字段
                        JsonObject status = payload.getAsJsonObject("status");
                        if (status != null && status.has("status")) {
                            int statusCode = status.get("status").getAsInt();
                            System.out.println("收到状态码: " + statusCode);
                            if (statusCode == 2) {
                                System.out.println("收到完成信号，准备关闭连接");
                                synchronized (lock) {
                                    completed[0] = true;
                                    lock.notify();
                                }
                                webSocket.close(1000, "正常关闭");
                            }
                        } else {
                            // 也可能在header中检查
                            if (json.has("header")) {
                                JsonObject header = json.getAsJsonObject("header");
                                if (header.has("status")) {
                                    int headerStatus = header.get("status").getAsInt();
                                    System.out.println("header中的状态码: " + headerStatus);
                                    if (headerStatus == 2) {
                                        System.out.println("收到完成信号（来自header），准备关闭连接");
                                        synchronized (lock) {
                                            completed[0] = true;
                                            lock.notify();
                                        }
                                        webSocket.close(1000, "正常关闭");
                                    }
                                }
                            }
                        }
                    } else {
                        System.err.println("警告: 消息中未找到payload字段");
                        System.err.println("完整消息内容: " + text);
                        // 如果多次收到无payload的消息，可能是格式问题
                        // 但不立即失败，等待其他消息
                    }
                } catch (Exception e) {
                    System.err.println("解析WebSocket消息异常: " + e.getMessage());
                    System.err.println("原始消息: " + text);
                    e.printStackTrace();
                    synchronized (lock) {
                        completed[0] = true;
                        lock.notify();
                    }
                }
            }
            
            @Override
            public void onFailure(WebSocket webSocket, Throwable t, Response response) {
                System.err.println("========== WebSocket连接失败 ==========");
                System.err.println("错误消息: " + t.getMessage());
                System.err.println("错误类型: " + t.getClass().getName());
                if (response != null) {
                    System.err.println("HTTP状态码: " + response.code());
                    System.err.println("响应消息: " + response.message());
                    try {
                        if (response.body() != null) {
                            String body = response.body().string();
                            System.err.println("响应体: " + body);
                        }
                    } catch (Exception e) {
                        System.err.println("无法读取响应体: " + e.getMessage());
                    }
                } else {
                    System.err.println("响应对象为null，可能是网络连接问题");
                }
                t.printStackTrace();
                System.err.println("=====================================");
                
                // 保存错误信息，以便后续抛出
                connectionError[0] = new RuntimeException("WebSocket连接失败: " + t.getMessage(), t);
                
                synchronized (lock) {
                    completed[0] = true;
                    lock.notify();
                }
            }
            
            @Override
            public void onClosing(WebSocket webSocket, int code, String reason) {
                webSocket.close(1000, null);
            }
        });
        
        // 等待响应完成（最多50秒，因为大模型生成可能需要较长时间）
        synchronized (lock) {
            if (!completed[0]) {
                try {
                    System.out.println("等待WebSocket响应（最多50秒）...");
                    lock.wait(50000);
                    
                    if (!completed[0]) {
                        System.err.println("========== WebSocket响应超时 ==========");
                        System.err.println("在50秒内未收到完成信号");
                        System.err.println("当前responseBuilder长度: " + responseBuilder.length());
                        webSocket.close(1000, "超时关闭");
                    } else {
                        System.out.println("WebSocket响应完成，等待结束");
                    }
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    System.err.println("等待响应被中断");
                }
            } else {
                System.out.println("WebSocket响应已完成，无需等待");
            }
        }
        
        // 检查是否有连接错误
        if (connectionError[0] != null) {
            System.err.println("检测到连接错误，抛出异常");
            throw connectionError[0];
        }
        
        String result = responseBuilder.length() > 0 ? responseBuilder.toString() : null;
        if (result == null || result.trim().isEmpty()) {
            System.err.println("========== 错误: 未收到任何响应内容 ==========");
            System.err.println("responseBuilder长度: " + responseBuilder.length());
            System.err.println("completed状态: " + completed[0]);
            System.err.println("连接错误: " + (connectionError[0] != null ? connectionError[0].getMessage() : "无"));
            System.err.println("=============================================");
            throw new RuntimeException("讯飞API未返回任何内容。可能原因：1) WebSocket连接失败 2) 未收到响应消息 3) 响应格式错误。请检查网络连接、API配置和后端日志。");
        }
        
        System.out.println("========== 成功获取响应 ==========");
        System.out.println("响应内容长度: " + result.length());
        System.out.println("响应内容预览: " + (result.length() > 100 ? result.substring(0, 100) + "..." : result));
        System.out.println("==================================");
        return result;
    }

    /**
     * 生成鉴权URL（带HMAC-SHA256签名）
     */
    private String generateAuthUrl() throws Exception {
        // >>>>> 添加下面这两行调试日志 <<<<<
        System.out.println("【调试】正在生成鉴权URL，原始配置: " + chatUrl);
        String httpUrl = chatUrl.replace("wss://", "https://").replace("ws://", "http://");
        System.out.println("【调试】替换后的HTTP URL: " + httpUrl);
        // >>>>> 调试日志结束 <<<<<

        URL url = new URL(httpUrl); 
        // ...
        String host = url.getHost();
        String path = url.getPath();
        
        // 检查系统时间（如果时间偏差过大，会导致鉴权失败）
        long currentTime = System.currentTimeMillis();
        System.out.println("当前系统时间: " + new Date(currentTime));
        
        // 生成时间戳
        SimpleDateFormat sdf = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US);
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        String date = sdf.format(new Date());
        System.out.println("GMT时间戳: " + date);
        
        // 构建签名字符串
        String signatureOrigin = String.format("host: %s\ndate: %s\nGET %s HTTP/1.1", host, date, path);
        
        // HMAC-SHA256签名
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec = new SecretKeySpec(apiSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(secretKeySpec);
        String signature = Base64.getEncoder().encodeToString(mac.doFinal(signatureOrigin.getBytes(StandardCharsets.UTF_8)));
        
        // 构建authorization
        String authorizationOrigin = String.format("api_key=\"%s\", algorithm=\"hmac-sha256\", headers=\"host date request-line\", signature=\"%s\"", 
                apiKey, signature);
        String authorization = Base64.getEncoder().encodeToString(authorizationOrigin.getBytes(StandardCharsets.UTF_8));
        
        // 构建最终URL
        String authUrl = String.format("%s?authorization=%s&date=%s&host=%s",
                chatUrl,
                java.net.URLEncoder.encode(authorization, "UTF-8"),
                java.net.URLEncoder.encode(date, "UTF-8"),
                java.net.URLEncoder.encode(host, "UTF-8"));
        
        return authUrl;
    }
}


