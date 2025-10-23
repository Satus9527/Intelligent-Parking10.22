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
import com.parking.service.PaymentService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import java.util.stream.Collectors;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.UUID;

/**
 * 预约服务实现类
 */
@Service
public class ReservationServiceImpl extends ServiceImpl<ReservationMapper, ReservationEntity> implements ReservationService {
    
    @Autowired
    private PaymentService paymentService;
    
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
    @Transactional(rollbackFor = Exception.class)
    public boolean applyRefund(Long id, Long userId) {
        // 查询预约信息
        ReservationEntity entity = this.getById(id);
        if (entity == null) {
            return false;
        }
        
        // 验证是否为用户本人的预约
        if (!entity.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此预约");
        }
        
        // 检查是否已经申请过退款
        if (entity.getRefundStatus() != null && entity.getRefundStatus() != ReservationEntity.RefundStatus.NO_REFUND.getCode()) {
            throw new RuntimeException("该预约已经申请过退款");
        }
        
        // 检查预约状态是否允许退款
        if (entity.getStatus() != ReservationEntity.ReservationStatus.CANCELLED.getCode() && 
            entity.getStatus() != ReservationEntity.ReservationStatus.USED.getCode()) {
            throw new RuntimeException("只有已取消或已完成的预约可以申请退款");
        }
        
        // 更新退款状态为退款中
        entity.setRefundStatus(ReservationEntity.RefundStatus.REFUNDING.getCode());
        entity.setUpdatedAt(new Date());
        
        if (!this.updateById(entity)) {
            return false;
        }
        
        try {
            // 调用支付服务进行退款 - 暂时跳过实际退款逻辑
            boolean refundResult = true; // paymentService.refund方法暂时模拟成功
            
            if (refundResult) {
                // 更新退款状态为退款成功
                entity.setRefundStatus(ReservationEntity.RefundStatus.REFUND_SUCCESS.getCode());
            } else {
                // 更新退款状态为退款失败
                entity.setRefundStatus(ReservationEntity.RefundStatus.REFUND_FAILED.getCode());
            }
            
            entity.setUpdatedAt(new Date());
            this.updateById(entity);
            
            return refundResult;
        } catch (Exception e) {
            // 更新退款状态为退款失败
            entity.setRefundStatus(ReservationEntity.RefundStatus.REFUND_FAILED.getCode());
            entity.setUpdatedAt(new Date());
            this.updateById(entity);
            
            throw new RuntimeException("申请退款失败: " + e.getMessage(), e);
        }
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
        // 构建查询条件
        QueryWrapper<ReservationEntity> wrapper = new QueryWrapper<>();
        
        if (queryDTO.getUserId() != null) {
            wrapper.eq("user_id", queryDTO.getUserId());
        }
        if (queryDTO.getParkingSpaceId() != null) {
            wrapper.eq("parking_space_id", queryDTO.getParkingSpaceId());
        }
        if (queryDTO.getStatus() != null) {
            wrapper.eq("status", queryDTO.getStatus());
        }
        if (queryDTO.getStartTimeFrom() != null) {
            wrapper.ge("start_time", queryDTO.getStartTimeFrom());
        }
        if (queryDTO.getStartTimeTo() != null) {
            wrapper.le("start_time", queryDTO.getStartTimeTo());
        }
        if (queryDTO.getEndTimeFrom() != null) {
            wrapper.ge("end_time", queryDTO.getEndTimeFrom());
        }
        if (queryDTO.getEndTimeTo() != null) {
            wrapper.le("end_time", queryDTO.getEndTimeTo());
        }
        
        // 执行查询
        List<ReservationEntity> entities = reservationMapper.selectList(wrapper);
        
        // 转换为DTO
        return entities.stream().map(this::convertToDTO).collect(Collectors.toList());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updatePaymentStatus(Long reservationId, int paymentStatus) {
        try {
            ReservationEntity entity = reservationMapper.selectById(reservationId);
            if (entity == null) {
                return false;
            }
            
            entity.setRefundStatus(paymentStatus);
            entity.setUpdatedAt(new Date());
            
            return reservationMapper.updateById(entity) > 0;
        } catch (Exception e) {
            throw new RuntimeException("更新支付状态失败", e);
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateRefundStatus(Long reservationId, int refundStatus) {
        try {
            ReservationEntity entity = reservationMapper.selectById(reservationId);
            if (entity == null) {
                return false;
            }
            
            // 这里假设实体类中有refund_status字段
            // 如果没有，需要先添加该字段
            entity.setRefundStatus(refundStatus);
            entity.setUpdatedAt(new Date());
            
            return reservationMapper.updateById(entity) > 0;
        } catch (Exception e) {
            throw new RuntimeException("更新退款状态失败", e);
        }
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
     * 实体转DTO
     * @param entity 实体对象
     * @return DTO对象
     */
    @Override
    public ReservationDTO convertToDTO(ReservationEntity entity) {
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
        
        // 设置退款状态描述
        if (entity.getRefundStatus() != null) {
            for (ReservationEntity.RefundStatus refundStatus : ReservationEntity.RefundStatus.values()) {
                if (refundStatus.getCode() == entity.getRefundStatus()) {
                    dto.setRefundStatusDesc(refundStatus.getDesc());
                    break;
                }
            }
        }
        
        return dto;
    }
}