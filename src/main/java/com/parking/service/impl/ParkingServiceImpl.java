 package com.parking.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.Version;
import lombok.Data;
import java.math.BigDecimal;
import java.util.Date; // ✅ 关键：必须是 java.util.Date

/**
 * 车位实体类
 */
@Data
@TableName("parking_space")
public class ParkingSpaceEntity {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("space_number")
    private String spaceNumber;
    
    @TableField("parking_id")
    private Long parkingId;
    
    private String status;
    private String type; 
    private boolean isDisabled;
    
    private String name;
    private String location;
    private String floor;
    private Integer category;
    private Integer state;
    private BigDecimal hourlyRate;
    private BigDecimal dailyRate;
    private String description;
    private String imageUrl;
    private Integer isAvailable;
    
    @Version
    private Integer version;
    
    // ✅ 关键：类型必须是 Date，不能是 LocalDateTime
    private Date createdAt; 
    private Date updatedAt; 
    
    public static final class SpaceStatus {
        public static final Integer FREE = 0;
        public static final Integer LOCKED = 1;
        public static final Integer OCCUPIED = 2;
    }
    
    public static final class SpaceType {
        public static final Integer NORMAL = 0;
        public static final Integer VIP = 1;
        public static final Integer DISABLED = 2;
    }
}