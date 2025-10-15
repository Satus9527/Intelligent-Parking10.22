package com.parking.model.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ParkingSpaceEntity {
    private Long id;
    private String spaceNumber;
    private Long parkingId;
    private String status; // AVAILABLE, OCCUPIED, RESERVED
    private String type; // SMALL, MEDIUM, LARGE
    private boolean isDisabled;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}