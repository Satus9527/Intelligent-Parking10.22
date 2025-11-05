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

    // NLU 指令提示词
    private static final String NLU_PROMPT = "你是一个智能停车场助手。请分析用户的语音指令，判断用户意图。\n" +
            "可能的意图类型：\n" +
            "1. RESERVE_NEARBY - 用户想预约附近某个地点的停车场（如\"预约北京路附近的停车场\"）\n" +
            "2. RESERVE_SPACE - 用户想预约特定车位（如\"预约A101车位\"）\n" +
            "3. QUERY_NEARBY - 用户想查询附近停车场（如\"附近有什么停车场\"）\n" +
            "4. NAVIGATE - 用户想导航到某个地点（如\"导航到北京路\"）\n" +
            "5. CANCEL_RESERVATION - 用户想取消预约\n" +
            "6. QUERY_STATUS - 用户想查询预约状态\n" +
            "7. UNKNOWN - 无法识别或普通聊天\n\n" +
            "请只返回意图类型（如 RESERVE_NEARBY），如果是指令类型1（RESERVE_NEARBY），请额外提取地点名称（如\"北京路\"）。\n" +
            "格式：意图类型|地点名称（如果适用）\n" +
            "例如：\"预约北京路附近的停车场\" -> RESERVE_NEARBY|北京路\n" +
            "\"附近有什么停车场\" -> QUERY_NEARBY|\n" +
            "\"你好\" -> UNKNOWN|";

    // 聊天模式提示词
    private static final String CHAT_PROMPT = "你是一个智能停车场助手，名字叫小智。你友好、专业，可以帮助用户预约停车位、查询附近停车场、导航等功能。请用简洁、友好的方式回复用户。";

    @Override
    public String getNluResponse(String text) {
        try {
            String response = callSparkAPI(text, NLU_PROMPT);
            
            if (response == null || response.trim().isEmpty()) {
                return "UNKNOWN";
            }
            
            // 解析响应，提取意图类型
            String[] parts = response.split("\\|");
            String intent = parts[0].trim().toUpperCase();
            
            // 验证意图类型是否有效
            if (intent.matches("(RESERVE_NEARBY|RESERVE_SPACE|QUERY_NEARBY|NAVIGATE|CANCEL_RESERVATION|QUERY_STATUS|UNKNOWN)")) {
                return response.trim(); // 返回完整响应（包含地点信息）
            } else {
                return "UNKNOWN";
            }
            
        } catch (Exception e) {
            System.err.println("NLU处理异常: " + e.getMessage());
            e.printStackTrace();
            return "UNKNOWN";
        }
    }

    @Override
    public String getChatResponse(String text) {
        try {
            return callSparkAPI(text, CHAT_PROMPT);
        } catch (Exception e) {
            System.err.println("聊天处理异常: " + e.getMessage());
            e.printStackTrace();
            return "抱歉，我现在有点忙，请稍后再试。";
        }
    }

    /**
     * 调用讯飞星火API
     */
    private String callSparkAPI(String userText, String systemPrompt) throws Exception {
        // 生成鉴权URL
        String authUrl = generateAuthUrl();
        
        // 构建消息数组
        JsonArray messages = new JsonArray();
        
        // 添加系统提示词（如果有）
        if (systemPrompt != null && !systemPrompt.isEmpty()) {
            JsonObject systemMessage = new JsonObject();
            systemMessage.addProperty("role", "system");
            systemMessage.addProperty("content", systemPrompt);
            messages.add(systemMessage);
        }
        
        // 添加用户消息
        JsonObject message = new JsonObject();
        message.addProperty("role", "user");
        message.addProperty("content", userText);
        messages.add(message);
        
        // 构建请求参数
        JsonObject parameter = new JsonObject();
        parameter.addProperty("chat", new JsonObject().toString()); // 空对象表示默认参数
        
        JsonObject payload = new JsonObject();
        payload.addProperty("appid", appId);
        payload.add("parameter", parameter);
        payload.add("messages", messages);
        
        String requestBody = gson.toJson(payload);
        
        // 建立WebSocket连接
        Request request = new Request.Builder()
                .url(authUrl)
                .build();
        
        final StringBuilder responseBuilder = new StringBuilder();
        final Object lock = new Object();
        final boolean[] completed = {false};
        
        WebSocket webSocket = client.newWebSocket(request, new WebSocketListener() {
            @Override
            public void onOpen(WebSocket webSocket, Response response) {
                // 发送消息
                webSocket.send(requestBody);
            }
            
            @Override
            public void onMessage(WebSocket webSocket, String text) {
                try {
                    JsonObject json = gson.fromJson(text, JsonObject.class);
                    JsonObject payload = json.getAsJsonObject("payload");
                    
                    if (payload != null) {
                        JsonObject choices = payload.getAsJsonObject("choices");
                        if (choices != null) {
                            JsonArray textArray = choices.getAsJsonArray("text");
                            if (textArray != null && textArray.size() > 0) {
                                JsonObject textObj = textArray.get(0).getAsJsonObject();
                                String content = textObj.get("content").getAsString();
                                responseBuilder.append(content);
                            }
                        }
                        
                        // 检查是否完成
                        JsonObject status = payload.getAsJsonObject("status");
                        if (status != null && status.get("status").getAsInt() == 2) {
                            synchronized (lock) {
                                completed[0] = true;
                                lock.notify();
                            }
                            webSocket.close(1000, "正常关闭");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("解析WebSocket消息异常: " + e.getMessage());
                    synchronized (lock) {
                        completed[0] = true;
                        lock.notify();
                    }
                }
            }
            
            @Override
            public void onFailure(WebSocket webSocket, Throwable t, Response response) {
                System.err.println("WebSocket连接失败: " + t.getMessage());
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
        
        // 等待响应完成（最多30秒）
        synchronized (lock) {
            if (!completed[0]) {
                try {
                    lock.wait(30000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        }
        
        return responseBuilder.length() > 0 ? responseBuilder.toString() : null;
    }

    /**
     * 生成鉴权URL（带HMAC-SHA256签名）
     */
    private String generateAuthUrl() throws Exception {
        // 解析原始URL
        URL url = new URL(chatUrl);
        String host = url.getHost();
        String path = url.getPath();
        
        // 生成时间戳
        SimpleDateFormat sdf = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US);
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        String date = sdf.format(new Date());
        
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

