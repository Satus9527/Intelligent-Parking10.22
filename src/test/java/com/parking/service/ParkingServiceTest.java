package com.parking.service;

import com.parking.dao.ParkingSpaceMapper;
import com.parking.model.dto.ReserveDTO;
import com.parking.model.dto.ResultDTO;
import com.parking.service.impl.ParkingServiceImpl;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@SpringBootTest
public class ParkingServiceTest {
    
    @InjectMocks
    private ParkingServiceImpl parkingService;
    
    @Mock
    private ParkingSpaceMapper parkingSpaceMapper;
    
    @Mock
    private RedisTemplate<String, Object> redisTemplate;
    
    @Test
    public void testReserve_Success() {
        // 准备测试数据
        ReserveDTO reserveDTO = new ReserveDTO();
        reserveDTO.setSpaceId(1L);
        reserveDTO.setPhone("13800138000");
        
        // 设置未来30分钟的时间
        LocalDateTime reserveTime = LocalDateTime.now().plusMinutes(30);
        reserveDTO.setReserveTime(reserveTime);
        
        // 模拟行为
        when(parkingSpaceMapper.lockSpace(1L)).thenReturn(1);
        doNothing().when(parkingSpaceMapper).updateStatus(1L, "RESERVED");
        doNothing().when(redisTemplate).opsForValue().set(anyString(), any(), anyLong(), any());
        
        // 执行测试
        ResultDTO result = parkingService.reserve(reserveDTO);
        
        // 验证结果
        assertEquals(true, result.isSuccess());
        verify(parkingSpaceMapper, times(1)).lockSpace(1L);
        verify(parkingSpaceMapper, times(1)).updateStatus(1L, "RESERVED");
        verify(redisTemplate, times(1)).opsForValue().set(anyString(), any(), anyLong(), any());
    }
    
    @Test
    public void testReserve_Failure() {
        // 准备测试数据
        ReserveDTO reserveDTO = new ReserveDTO();
        reserveDTO.setSpaceId(1L);
        reserveDTO.setPhone("13800138000");
        
        // 设置未来30分钟的时间
        LocalDateTime reserveTime = LocalDateTime.now().plusMinutes(30);
        reserveDTO.setReserveTime(reserveTime);
        
        // 模拟行为
        when(parkingSpaceMapper.lockSpace(1L)).thenReturn(0);
        
        // 执行测试
        ResultDTO result = parkingService.reserve(reserveDTO);
        
        // 验证结果
        assertEquals(false, result.isSuccess());
        verify(parkingSpaceMapper, times(1)).lockSpace(1L);
        verify(parkingSpaceMapper, never()).updateStatus(anyLong(), anyString());
        verify(redisTemplate, never()).opsForValue().set(anyString(), any(), anyLong(), any());
    }
}