package com.parking.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.parking.dao.ReservationMapper;
import com.parking.dao.ParkingSpaceMapper;
import com.parking.dao.LogMapper;
import com.parking.model.dto.ReservationDTO;
import com.parking.model.entity.ReservationEntity;
import com.parking.model.vo.PageResult;
import com.parking.model.vo.SystemMonitorData;
import com.parking.service.AdminService;
import com.parking.service.ReservationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 管理员服务实现类
 */
@Service
public class AdminServiceImpl implements AdminService {
    
    @Autowired
    private ReservationMapper reservationMapper;
    
    @Autowired
    private ParkingSpaceMapper parkingSpaceMapper;
    
    @Autowired
    private LogMapper logMapper;
    
    @Autowired
    private ReservationService reservationService;
    
    @Override
    public PageResult<ReservationDTO> getAbnormalReservations(int pageNum, int pageSize) {
        // 计算分页偏移量
        int offset = (pageNum - 1) * pageSize;
        
        // 查询异常预约（状态为已取消或已过期的预约）
        QueryWrapper<ReservationEntity> wrapper = new QueryWrapper<>();
        wrapper.in("status", 2, 3) // 2-已取消，3-已过期
               .orderByDesc("updated_at");
        
        List<ReservationEntity> entities = reservationMapper.selectPage(wrapper, offset, pageSize);
        int total = reservationMapper.selectCount(wrapper);
        
        // 转换为DTO
        List<ReservationDTO> dtos = entities.stream()
                .map(entity -> reservationService.convertToDTO(entity))
                .collect(Collectors.toList());
        
        return new PageResult<>(dtos, total, pageNum, pageSize);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean cancelAbnormalReservation(Long reservationId) {
        // 查询预约信息
        ReservationEntity entity = reservationMapper.selectById(reservationId);
        if (entity == null) {
            return false;
        }
        
        // 检查是否为异常预约
        if (entity.getStatus() != 2 && entity.getStatus() != 3) {
            throw new RuntimeException("只能取消异常预约（已取消或已过期）");
        }
        
        // 释放车位
        if (parkingSpaceMapper.unlockSpace(entity.getParkingSpaceId()) <= 0) {
            throw new RuntimeException("车位释放失败");
        }
        
        return true;
    }
    
    @Override
    public SystemMonitorData getSystemMonitorData() {
        SystemMonitorData data = new SystemMonitorData();
        
        // 获取总预约数
        QueryWrapper<ReservationEntity> totalWrapper = new QueryWrapper<>();
        data.setTotalReservations(reservationMapper.selectCount(totalWrapper));
        
        // 获取今日预约数
        QueryWrapper<ReservationEntity> todayWrapper = new QueryWrapper<>();
        todayWrapper.ge("created_at", new Date(System.currentTimeMillis() - 24 * 60 * 60 * 1000));
        data.setTodayReservations(reservationMapper.selectCount(todayWrapper));
        
        // 获取异常预约数
        QueryWrapper<ReservationEntity> abnormalWrapper = new QueryWrapper<>();
        abnormalWrapper.in("status", 2, 3);
        data.setAbnormalReservations(reservationMapper.selectCount(abnormalWrapper));
        
        // 获取系统运行时间（模拟数据）
        data.setSystemUpTime("24小时");
        
        return data;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean forceReleaseReservation(Long reservationId) {
        // 强制释放预约，无论状态如何
        ReservationEntity entity = reservationMapper.selectById(reservationId);
        if (entity == null) {
            return false;
        }
        
        // 更新预约状态为已取消
        entity.setStatus(2);
        entity.setUpdatedAt(new Date());
        reservationMapper.updateById(entity);
        
        // 释放车位
        parkingSpaceMapper.unlockSpace(entity.getParkingSpaceId());
        
        return true;
    }
    
    @Override
    public PageResult<Map<String, Object>> getReservationErrorLogs(int pageNum, int pageSize) {
        // 这里简化实现，实际应从日志表查询
        int offset = (pageNum - 1) * pageSize;
        List<Map<String, Object>> logs = logMapper.selectErrorLogs("reservation", offset, pageSize);
        int total = logMapper.countErrorLogs("reservation");
        
        return new PageResult<>(logs, total, pageNum, pageSize);
    }
}