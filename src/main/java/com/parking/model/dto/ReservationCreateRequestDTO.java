package com.parking.model.dto;

import lombok.Data;
import javax.validation.constraints.NotNull;
import java.util.Date;

/**
 * 预约创建请求DTO
 */
@Data
public class ReservationCreateRequestDTO {
    
    /**
     * 车位ID（兼容前端参数名）
     */
    private Long spaceId;
    
    /**
     * 车位ID
     */
    @NotNull(message = "车位ID不能为空")
    private Long parkingSpaceId;
    
    /**
     * 停车场ID
     */
    @NotNull(message = "停车场ID不能为空")
    private Long parkingId;
    
    /**
     * 预约开始时间
     */
    @NotNull(message = "预约开始时间不能为空")
    private Date startTime;
    
    /**
     * 预约结束时间
     */
    @NotNull(message = "预约结束时间不能为空")
    private Date endTime;
    
    /**
     * 车牌号
     */
    @NotNull(message = "车牌号不能为空")
    private String plateNumber;
    
    /**
     * 联系电话
     */
    @NotNull(message = "联系电话不能为空")
    private String contactPhone;
    
    /**
     * 车辆信息
     */
    private String vehicleInfo;
    
    /**
     * 备注信息
     */
    private String remark;
    
    /**
     * 设置车位ID（兼容前端参数名）
     */
    public void setSpaceId(Long spaceId) {
        this.spaceId = spaceId;
        if (spaceId != null) {
            this.parkingSpaceId = spaceId;
        }
    }
}