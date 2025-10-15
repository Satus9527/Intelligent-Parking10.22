package com.parking.model.dto;

import lombok.Data;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Future;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

@Data
public class ReserveDTO {
    @NotNull(message = "车位ID不能为空")
    private Long spaceId;
    
    @Future(message = "预约时间必须为未来时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime reserveTime;
    
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式错误")
    private String phone;
}