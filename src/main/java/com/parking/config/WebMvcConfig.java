package com.parking.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC配置类
 * 注册拦截器和其他Web MVC相关配置
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Autowired
    private SimpleUserIdInterceptor simpleUserIdInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 注册用户ID拦截器，拦截所有请求
        // 这将为所有控制器方法提供@RequestAttribute("userId")
        registry.addInterceptor(simpleUserIdInterceptor)
                .addPathPatterns("/**"); // 拦截所有路径
    }
}