package com.parking.service.impl;

import com.parking.model.entity.ReservationEntity;
import com.parking.model.entity.ParkingSpaceEntity;
import com.parking.model.dto.ReservationDTO;
import com.parking.model.dto.ParkingSpaceDTO;
import com.parking.model.dto.ReservationCreateRequestDTO;
import com.parking.model.dto.ReservationQueryDTO;
import com.parking.dao.ReservationMapper;
import com.parking.dao.ParkingSpaceMapper;
import com.parking.service.ReservationService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import java.text.SimpleDateFormat;
import java.util.UUID;

/**
 * 预约服务实现类
 */
@Service
public class ReservationServiceImpl extends ServiceImpl<ReservationMapper, ReservationEntity> implements ReservationService {
    
    @Autowired
    private ReservationMapper reservationMapper;
    
    @Autowired
    private ParkingSpaceMapper parkingSpaceMapper;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public ReservationDTO createReservation(ReservationCreateRequestDTO requestDTO, Long userId) {
        // 检查车位是否可预约
        Integer overlappingCount = reservationMapper.checkOverlappingReservation(
                requestDTO.getParkingSpaceId(), requestDTO.getStartTime(), requestDTO.getEndTime());
        if (overlappingCount != null && overlappingCount > 0) {
            throw new RuntimeException("该时间段车位已被预约");
        }
        
        // 锁定车位
        if (parkingSpaceMapper.lockSpace(requestDTO.getParkingSpaceId()) <= 0) {
            throw new RuntimeException("车位锁定失败，请重试");
        }
        
        // 创建预约实体
        ReservationEntity entity = new ReservationEntity();
        BeanUtils.copyProperties(requestDTO, entity);
        entity.setUserId(userId);
        entity.setStatus(ReservationEntity.ReservationStatus.PENDING.getCode());
        entity.setReservationNo(generateReservationNo());
        entity.setCreatedAt(new Date());
        entity.setUpdatedAt(new Date());
        
        // 保存预约
        if (!this.save(entity)) {
            throw new RuntimeException("预约创建失败");
        }
        
        return convertToDTO(entity);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean cancelReservation(Long id, Long userId) {
        ReservationEntity entity = this.getById(id);
        if (entity == null) {
            return false;
        }
        
        // 验证是否为用户本人的预约
        if (!entity.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此预约");
        }
        
        // 只能取消待使用状态的预约
        if (entity.getStatus() != ReservationEntity.ReservationStatus.PENDING.getCode()) {
            throw new RuntimeException("只能取消待使用状态的预约");
        }
        
        // 更新预约状态为已取消
        entity.setStatus(ReservationEntity.ReservationStatus.CANCELLED.getCode());
        entity.setUpdatedAt(new Date());
        
        if (!this.updateById(entity)) {
            return false;
        }
        
        // 释放车位
        parkingSpaceMapper.updateState(entity.getParkingSpaceId(), 0, 1);
        
        return true;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean useReservation(Long id) {
        ReservationEntity entity = this.getById(id);
        if (entity == null) {
            return false;
        }
        
        // 检查预约是否有效
        if (entity.getStatus() != ReservationEntity.ReservationStatus.PENDING.getCode()) {
            throw new RuntimeException("预约状态无效");
        }
        
        if (new Date().after(entity.getEndTime())) {
            throw new RuntimeException("预约已超时");
        }
        
        // 更新预约状态
        entity.setStatus(ReservationEntity.ReservationStatus.USED.getCode());
        entity.setActualEntryTime(new Date());
        entity.setUpdatedAt(new Date());
        
        return this.updateById(entity);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean completeReservation(Long id) {
        ReservationEntity entity = this.getById(id);
        if (entity == null) {
            return false;
        }
        
        // 检查预约是否已使用
        if (entity.getStatus() != ReservationEntity.ReservationStatus.USED.getCode()) {
            throw new RuntimeException("预约尚未使用");
        }
        
        // 更新预约状态
        entity.setActualExitTime(new Date());
        entity.setUpdatedAt(new Date());
        
        boolean result = this.updateById(entity);
        
        // 释放车位
        parkingSpaceMapper.updateState(entity.getParkingSpaceId(), 0, 2);
        
        return result;
    }
    
    @Override
    public ReservationDTO getReservationById(Long id) {
        ReservationEntity entity = this.getById(id);
        if (entity == null) {
            return null;
        }
        
        ReservationDTO dto = convertToDTO(entity);
        
        // 加载关联数据
        ParkingSpaceEntity parkingSpace = parkingSpaceMapper.selectById(entity.getParkingSpaceId());
        if (parkingSpace != null) {
            ParkingSpaceDTO parkingSpaceDTO = new ParkingSpaceDTO();
            BeanUtils.copyProperties(parkingSpace, parkingSpaceDTO);
            dto.setParkingSpace(parkingSpaceDTO);
        }
        
        return dto;
    }
    
    @Override
    public List<ReservationDTO> getUserReservations(Long userId, Integer pageNum, Integer pageSize) {
        List<ReservationEntity> entities = reservationMapper.selectByUserId(userId, pageNum, pageSize);
        return entities.stream().map(this::convertToDTO).collect(Collectors.toList());
    }
    
    @Override
    public List<ReservationDTO> queryReservations(ReservationQueryDTO queryDTO) {
        List<ReservationEntity> entities = reservationMapper.selectByCondition(queryDTO);
        return entities.stream().map(this::convertToDTO).collect(Collectors.toList());
    }
    
    @Override
    public boolean checkSpaceAvailability(Long parkingSpaceId, Date startTime, Date endTime, Long excludeId) {
        Integer overlappingCount;
        if (excludeId != null) {
            overlappingCount = reservationMapper.checkOverlappingReservationExclude(
                    parkingSpaceId, startTime, endTime, excludeId);
        } else {
            overlappingCount = reservationMapper.checkOverlappingReservation(
                    parkingSpaceId, startTime, endTime);
        }
        return overlappingCount == null || overlappingCount <= 0;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateTimeoutReservations() {
        int count = reservationMapper.updateTimeoutReservations(new Date());
        return count;
    }
    

    
    /**
     * 生成预约编号
     * @return 预约编号
     */
    private String generateReservationNo() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String timestamp = sdf.format(new Date());
        String random = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        return "RES" + timestamp + random;
    }
    
    /**
     * 将实体类转换为DTO
     * @param entity 实体类
     * @return DTO对象
     */
    private ReservationDTO convertToDTO(ReservationEntity entity) {
        if (entity == null) {
            return null;
        }
        
        ReservationDTO dto = new ReservationDTO();
        BeanUtils.copyProperties(entity, dto);
        
        // 设置状态描述
        for (ReservationEntity.ReservationStatus status : ReservationEntity.ReservationStatus.values()) {
            if (status.getCode() == entity.getStatus()) {
                dto.setStatusDesc(status.getDesc());
                break;
            }
        }
        
        return dto;
    }
}