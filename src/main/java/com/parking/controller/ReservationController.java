package com.parking.controller;

import com.parking.model.dto.ReservationDTO;
import com.parking.model.dto.ReservationCreateRequestDTO;
import com.parking.model.dto.ReservationQueryDTO;
import com.parking.service.ReservationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;
import java.util.List;

/**
 * 预约管理控制器
 */
@RestController
@RequestMapping("/api/reservations")
public class ReservationController {
    
    @Autowired
    private ReservationService reservationService;
    
    /**
     * 创建预约
     * @param requestDTO 预约请求信息
     * @return 创建的预约信息
     */
    @PostMapping
    public ResponseEntity<ReservationDTO> createReservation(@Valid @RequestBody ReservationCreateRequestDTO requestDTO) {
        // 从请求上下文获取用户ID（实际应从认证信息中获取）
        Long userId = 1L; // 临时硬编码，实际应从JWT或Session中获取
        ReservationDTO reservationDTO = reservationService.createReservation(requestDTO, userId);
        return ResponseEntity.ok(reservationDTO);
    }
    
    /**
     * 取消预约
     * @param id 预约ID
     * @return 操作结果
     */
    @PostMapping("/{id}/cancel")
    public ResponseEntity<Boolean> cancelReservation(@PathVariable Long id) {
        // 从请求上下文获取用户ID
        Long userId = 1L; // 临时硬编码
        boolean result = reservationService.cancelReservation(id, userId);
        return ResponseEntity.ok(result);
    }
    
    /**
     * 使用预约（入场）
     * @param id 预约ID
     * @return 操作结果
     */
    @PostMapping("/{id}/use")
    public ResponseEntity<Boolean> useReservation(@PathVariable Long id) {
        boolean result = reservationService.useReservation(id);
        return ResponseEntity.ok(result);
    }
    
    /**
     * 完成预约（出场）
     * @param id 预约ID
     * @return 操作结果
     */
    @PostMapping("/{id}/complete")
    public ResponseEntity<Boolean> completeReservation(@PathVariable Long id) {
        boolean result = reservationService.completeReservation(id);
        return ResponseEntity.ok(result);
    }
    
    /**
     * 申请退款
     * @param id 预约ID
     * @return 操作结果
     */
    @PostMapping("/{id}/refund")
    public ResponseEntity<Boolean> applyRefund(@PathVariable Long id) {
        // 从请求上下文获取用户ID
        Long userId = 1L; // 临时硬编码，实际应从JWT或Session中获取
        boolean result = reservationService.applyRefund(id, userId);
        return ResponseEntity.ok(result);
    }
    
    /**
     * 获取预约详情
     * @param id 预约ID
     * @return 预约详情
     */
    @GetMapping("/{id}")
    public ResponseEntity<ReservationDTO> getReservationById(@PathVariable Long id) {
        ReservationDTO reservationDTO = reservationService.getReservationById(id);
        if (reservationDTO != null) {
            return ResponseEntity.ok(reservationDTO);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * 获取用户的预约列表
     * @param pageNum 页码
     * @param pageSize 每页大小
     * @return 预约列表
     */
    @GetMapping("/user")
    public ResponseEntity<List<ReservationDTO>> getUserReservations(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        // 从请求上下文获取用户ID
        Long userId = 1L; // 临时硬编码
        List<ReservationDTO> reservationDTOs = reservationService.getUserReservations(userId, pageNum, pageSize);
        return ResponseEntity.ok(reservationDTOs);
    }
    
    /**
     * 根据条件查询预约列表
     * @param queryDTO 查询条件
     * @return 预约列表
     */
    @GetMapping("/search")
    public ResponseEntity<List<ReservationDTO>> queryReservations(ReservationQueryDTO queryDTO) {
        List<ReservationDTO> reservationDTOs = reservationService.queryReservations(queryDTO);
        return ResponseEntity.ok(reservationDTOs);
    }
    
    /**
     * 检查车位是否可预约
     * @param parkingSpaceId 车位ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 是否可预约
     */
    @GetMapping("/check-availability")
    public ResponseEntity<Boolean> checkSpaceAvailability(
            @RequestParam Long parkingSpaceId,
            @RequestParam String startTime,
            @RequestParam String endTime) {
        try {
            // 解析时间字符串
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            java.util.Date startDate = sdf.parse(startTime);
            java.util.Date endDate = sdf.parse(endTime);
            
            boolean available = reservationService.checkSpaceAvailability(parkingSpaceId, startDate, endDate, null);
            return ResponseEntity.ok(available);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}