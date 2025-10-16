package com.parking.dao;

import com.parking.model.entity.ReservationEntity;
import com.parking.model.dto.ReservationQueryDTO;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Date;

/**
 * 预约Mapper接口
 */
@Mapper
public interface ReservationMapper extends BaseMapper<ReservationEntity> {
    
    /**
     * 查询用户的预约列表
     * @param userId 用户ID
     * @param pageNum 页码
     * @param pageSize 每页大小
     * @return 预约列表
     */
    List<ReservationEntity> selectByUserId(@Param("userId") Long userId, 
                                          @Param("pageNum") Integer pageNum, 
                                          @Param("pageSize") Integer pageSize);
    
    /**
     * 根据条件查询预约列表
     * @param query 查询条件
     * @return 预约列表
     */
    List<ReservationEntity> selectByCondition(ReservationQueryDTO query);
    
    /**
     * 检查是否有重叠的预约
     * @param parkingSpaceId 车位ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 重叠预约数量
     */
    Integer checkOverlappingReservation(@Param("parkingSpaceId") Long parkingSpaceId,
                                       @Param("startTime") Date startTime,
                                       @Param("endTime") Date endTime);
    
    /**
     * 检查是否有重叠的预约（排除特定预约）
     * @param parkingSpaceId 车位ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param excludeId 排除的预约ID（用于更新场景）
     * @return 重叠预约数量
     */
    Integer checkOverlappingReservationExclude(@Param("parkingSpaceId") Long parkingSpaceId,
                                             @Param("startTime") Date startTime,
                                             @Param("endTime") Date endTime,
                                             @Param("excludeId") Long excludeId);
    
    /**
     * 更新预约状态
     * @param id 预约ID
     * @param status 新状态
     * @param version 版本号
     * @return 更新结果
     */
    int updateStatusWithVersion(@Param("id") Long id,
                               @Param("status") Integer status,
                               @Param("version") Integer version);
    
    /**
     * 更新超时预约
     * @param currentTime 当前时间
     * @return 更新数量
     */
    int updateTimeoutReservations(@Param("currentTime") Date currentTime);
    
    /**
     * 根据预约编号查询预约
     * @param reservationNo 预约编号
     * @return 预约信息
     */
    ReservationEntity selectByReservationNo(@Param("reservationNo") String reservationNo);
}