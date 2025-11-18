// 停车场相关API
import request from './request'

// 获取推荐停车场列表
export const fetchRecommendedParkings = async () => {
  // 模拟API调用
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        code: 200,
        data: [
          {
            id: 1,
            name: '中央商场停车场',
            address: '市中心商业区',
            distance: 1200,
            availableSpaces: 45,
            totalSpaces: 200,
            pricePerHour: 10
          },
          {
            id: 2,
            name: '科技园停车场',
            address: '科技园区',
            distance: 800,
            availableSpaces: 120,
            totalSpaces: 300,
            pricePerHour: 8
          }
        ],
        message: 'success'
      })
    }, 500)
  })
}

// 获取停车场详情
export const fetchParkingDetail = async (parkingId) => {
  // 模拟API调用
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        code: 200,
        data: {
          id: parkingId,
          name: '示例停车场',
          address: '示例地址',
          description: '这是一个示例停车场',
          availableSpaces: 50,
          totalSpaces: 200,
          pricePerHour: 10,
          operatingHours: '00:00-24:00',
          features: ['24小时开放', '监控覆盖', '充电桩']
        },
        message: 'success'
      })
    }, 300)
  })
}

// 获取实时车位信息
export const fetchRealTimeSpaces = async (parkingId) => {
  // 模拟API调用
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        code: 200,
        data: {
          totalSpaces: 200,
          availableSpaces: Math.floor(Math.random() * 100) + 20,
          occupiedSpaces: Math.floor(Math.random() * 100) + 80,
          updatedAt: new Date().toISOString()
        },
        message: 'success'
      })
    }, 200)
  })
}

// 搜索停车场
export const searchParkings = async (keyword) => {
  // 模拟API调用
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        code: 200,
        data: [
          {
            id: 3,
            name: `搜索结果-${keyword}`,
            address: '搜索地址',
            distance: 1500,
            availableSpaces: 30,
            totalSpaces: 150,
            pricePerHour: 12
          }
        ],
        message: 'success'
      })
    }, 400)
  })
}

// 获取车位列表（根据停车场ID）
export const fetchParkingSpaces = async (parkingIdOrQuery) => {
  try {
    // 如果传入的是对象（查询条件），调用 search 接口
    if (typeof parkingIdOrQuery === 'object' && parkingIdOrQuery !== null) {
      const response = await request.get(`/api/parking-spaces/search`, {
        params: parkingIdOrQuery
      })
      return {
        code: 200,
        data: response.data || [],
        message: 'success'
      }
    }
    
    // 如果传入的是数字（停车场ID），调用 available 接口（向后兼容）
    const parkingId = parkingIdOrQuery
    const response = await request.get(`/api/parking-spaces/available`, {
      params: { parkingId }
    })
    return {
      code: 200,
      data: response.data || [],
      message: 'success'
    }
  } catch (error) {
    console.error('获取车位列表失败:', error)
    // 如果API调用失败，返回空数组而不是抛出错误
    return {
      code: 200,
      data: [],
      message: '获取车位列表失败'
    }
  }
}

// 获取指定楼层的车位列表
export const fetchFloorSpaces = async (parkingId, floor) => {
  try {
    // 先获取所有可用车位
    const allSpaces = await fetchParkingSpaces(parkingId)
    if (allSpaces.code === 200) {
      // 根据楼层过滤车位
      const floorSpaces = (allSpaces.data || []).filter(space => {
        // 匹配楼层：floor可能是楼层ID或楼层名称
        return space.floor === floor || 
               space.floorId === floor || 
               space.floorName === floor ||
               (space.floor && space.floor.toString() === floor.toString())
      })
      return {
        code: 200,
        data: floorSpaces,
        message: 'success'
      }
    }
    return allSpaces
  } catch (error) {
    console.error('获取楼层车位失败:', error)
    return {
      code: 200,
      data: [],
      message: '获取楼层车位失败'
    }
  }
}

// 获取停车场列表
export const fetchParkingList = async (params = {}) => {
  try {
    console.log('获取停车场列表，参数:', params)
    
    // 调用后端API获取停车场列表
    // 如果后端没有对应的API，暂时返回空数组
    // TODO: 实现真实的后端API调用
    const response = await request.get('/api/v1/parking/nearby', {
      params: {
        longitude: params.longitude,
        latitude: params.latitude,
        radius: params.distance || 5000
      }
    })
    
    if (response && response.data) {
      // 转换后端数据格式为前端需要的格式
      const parkingList = Array.isArray(response.data) ? response.data : []
      return {
        code: 200,
        data: {
          list: parkingList.map(item => ({
            id: item.id,
            name: item.name || item.parkingName,
            address: item.address || item.parkingAddress,
            distance: item.distance || 0,
            availableSpaces: item.availableSpaces || item.available_spaces || 0,
            totalSpaces: item.totalSpaces || item.total_spaces || 0,
            pricePerHour: item.hourlyRate || item.hourly_rate || item.pricePerHour || 0,
            hasReservation: item.hasReservation !== false,
            hasCharge: item.hasCharge || false
          })),
          total: parkingList.length,
          page: params.page || 1,
          pageSize: params.pageSize || 10
        },
        message: 'success'
      }
    }
    
    // 如果API调用失败，返回空列表
    return {
      code: 200,
      data: {
        list: [],
        total: 0,
        page: params.page || 1,
        pageSize: params.pageSize || 10
      },
      message: '获取停车场列表失败'
    }
  } catch (error) {
    console.error('获取停车场列表失败:', error)
    // 即使失败也返回空列表，避免页面崩溃
    return {
      code: 200,
      data: {
        list: [],
        total: 0,
        page: params.page || 1,
        pageSize: params.pageSize || 10
      },
      message: '获取停车场列表失败'
    }
  }
}