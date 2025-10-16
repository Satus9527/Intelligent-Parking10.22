package com.parking.service.impl;

import com.parking.model.entity.ParkingSpaceEntity;
import com.parking.model.dto.ParkingSpaceDTO;
import com.parking.model.dto.ParkingSpaceQueryDTO;
import com.parking.dao.ParkingSpaceMapper;
import com.parking.service.ParkingSpaceService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 车位服务实现类
 */
@Service
public class ParkingSpaceServiceImpl extends ServiceImpl<ParkingSpaceMapper, ParkingSpaceEntity> implements ParkingSpaceService {
    
    @Autowired
    private ParkingSpaceMapper parkingSpaceMapper;
    
    @Override
    public ParkingSpaceDTO getParkingSpaceById(Long id) {
        ParkingSpaceEntity entity = parkingSpaceMapper.selectById(id);
        return convertToDTO(entity);
    }
    
    @Override
    public List<ParkingSpaceDTO> getAvailableSpaces(Long parkingId) {
        List<ParkingSpaceEntity> entities = parkingSpaceMapper.selectAvailableSpaces(parkingId);
        return entities.stream().map(this::convertToDTO).collect(Collectors.toList());
    }
    
    @Override
    public List<ParkingSpaceDTO> searchSpaces(ParkingSpaceQueryDTO queryDTO) {
        // 直接传递查询DTO
        List<ParkingSpaceEntity> entities = parkingSpaceMapper.selectAvailableSpacesByCondition(queryDTO);
        return entities.stream().map(this::convertToDTO).collect(Collectors.toList());
    }
    
    @Override
    public boolean lockSpace(Long spaceId) {
        return parkingSpaceMapper.lockSpace(spaceId) > 0;
    }
    
    @Override
    public boolean releaseSpace(Long spaceId) {
        // 将状态从RESERVED改为AVAILABLE
        return updateState(spaceId, 0, 1);
    }
    
    @Override
    public boolean updateState(Long id, Integer newState, Integer oldState) {
        return parkingSpaceMapper.updateState(id, newState, oldState) > 0;
    }
    
    @Override
    public boolean updateStateWithVersion(Long id, Integer newState, Integer oldState, Integer version) {
        return parkingSpaceMapper.updateStateWithVersion(id, newState, oldState, version) > 0;
    }
    
    @Override
    public ParkingSpaceDTO createParkingSpace(ParkingSpaceDTO parkingSpaceDTO) {
        ParkingSpaceEntity entity = new ParkingSpaceEntity();
        BeanUtils.copyProperties(parkingSpaceDTO, entity);
        // 设置默认状态
        entity.setState(0);  // AVAILABLE
        entity.setStatus("AVAILABLE");
        entity.setIsAvailable(1);  // 1表示可用
        this.save(entity);
        return convertToDTO(entity);
    }
    
    @Override
    public ParkingSpaceDTO updateParkingSpace(ParkingSpaceDTO parkingSpaceDTO) {
        ParkingSpaceEntity entity = new ParkingSpaceEntity();
        BeanUtils.copyProperties(parkingSpaceDTO, entity);
        this.updateById(entity);
        return convertToDTO(entity);
    }
    
    @Override
    public boolean deleteParkingSpace(Long id) {
        return this.removeById(id);
    }
    
    /**
     * 将实体类转换为DTO
     * @param entity 实体类
     * @return DTO对象
     */
    private ParkingSpaceDTO convertToDTO(ParkingSpaceEntity entity) {
        if (entity == null) {
            return null;
        }
        ParkingSpaceDTO dto = new ParkingSpaceDTO();
        BeanUtils.copyProperties(entity, dto);
        return dto;
    }
}