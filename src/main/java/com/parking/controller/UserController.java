package com.parking.controller;

import com.parking.model.dto.UserDTO;
import com.parking.model.dto.UserLoginRequestDTO;
import com.parking.model.dto.UserLoginResponseDTO;
import com.parking.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/api/v1/user")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public UserLoginResponseDTO login(@RequestBody UserLoginRequestDTO loginRequest) {
        return userService.login(loginRequest);
    }
    
    /**
     * 获取用户信息
     */
    @GetMapping("/info")
    public UserDTO getUserInfo(@RequestAttribute("userId") Long userId) {
        return userService.getUserById(userId);
    }
    
    /**
     * 更新用户信息
     */
    @PutMapping("/info")
    public UserDTO updateUserInfo(@RequestBody UserDTO userDTO, @RequestAttribute("userId") Long currentUserId) {
        // 确保用户只能更新自己的信息
        if (!userDTO.getId().equals(currentUserId)) {
            throw new RuntimeException("无权更新其他用户信息");
        }
        return userService.updateUserInfo(userDTO);
    }
    
}