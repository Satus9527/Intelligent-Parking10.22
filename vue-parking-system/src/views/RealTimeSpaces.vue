<template>
  <div class="real-time-spaces">
    <!-- 页面头部 -->
    <div class="header">
      <div class="back-button" @click="goBack">
        <div class="back-icon"></div>
      </div>
      <h1 class="page-title">实时车位</h1>
      <div class="refresh-button" @click="refreshData">
        <div class="refresh-icon" :class="{ refreshing }">⟳</div>
      </div>
    </div>
    
    <!-- 停车场信息 -->
    <div v-if="loading && !spacesData.length" class="loading-container">
      <div class="loading-spinner"></div>
      <p>加载中...</p>
    </div>
    
    <div v-else-if="error" class="error-container">
      <div class="error-icon"></div>
      <p>{{ error }}</p>
      <button class="retry-button" @click="loadSpacesData">重试</button>
    </div>
    
    <div v-else class="content">
      <!-- 停车场基本信息 -->
      <div class="parking-info">
        <h2 class="parking-name">{{ parkingInfo.name }}</h2>
        <div class="parking-stats">
          <div class="stat-item">
            <span class="stat-label">总车位</span>
            <span class="stat-value">{{ parkingInfo.totalSpaces || 0 }}</span>
          </div>
          <div class="stat-divider"></div>
          <div class="stat-item">
            <span class="stat-label">空闲车位</span>
            <span class="stat-value available">{{ parkingInfo.availableSpaces || 0 }}</span>
          </div>
          <div class="stat-divider"></div>
          <div class="stat-item">
            <span class="stat-label">占用率</span>
            <span class="stat-value">{{ occupancyRate }}%</span>
          </div>
        </div>
        <div class="update-time">
          <span>数据更新时间：{{ updateTime }}</span>
        </div>
      </div>
      
      <!-- 楼层选择 -->
      <div class="floor-selector">
        <div 
          v-for="floor in floors" 
          :key="floor.id" 
          class="floor-tab"
          :class="{ active: selectedFloor === floor.id }"
          @click="selectFloor(floor.id)"
        >
          {{ floor.name }}
          <span class="floor-spaces" v-if="floorStats[floor.id]">
            {{ floorStats[floor.id].available }}/{{ floorStats[floor.id].total }}
          </span>
        </div>
      </div>
      
      <!-- 车位状态图例 -->
      <div class="legend">
        <div class="legend-item">
          <div class="legend-color available"></div>
          <span>空闲</span>
        </div>
        <div class="legend-item">
          <div class="legend-color occupied"></div>
          <span>占用</span>
        </div>
        <div class="legend-item">
          <div class="legend-color reserved"></div>
          <span>已预约</span>
        </div>
        <div class="legend-item">
          <div class="legend-color maintenance"></div>
          <span>维护中</span>
        </div>
        <div class="legend-item">
          <div class="legend-color disabled"></div>
          <span>禁用</span>
        </div>
      </div>
      
      <!-- 车位地图 -->
      <div class="spaces-map">
        <!-- 车位分区标题 -->
        <div class="area-header" v-if="currentFloorData.length > 0">
          <h3>{{ selectedFloorName }} 车位分布</h3>
        </div>
        
        <!-- 车位网格 -->
        <div v-if="currentFloorData.length > 0" class="spaces-grid">
          <div 
            v-for="space in currentFloorData" 
            :key="space.id" 
            class="space-item"
            :class="getStatusClass(space)"
            :title="getSpaceTooltip(space)"
            @click="selectSpace(space)"
          >
            <span class="space-number">{{ space.number }}</span>
            <div class="space-indicator" v-if="space.type"></div>
          </div>
        </div>
        
        <!-- 空状态 -->
        <div v-else-if="!loading" class="empty-state">
          <div class="empty-icon"></div>
          <p>暂无车位数据</p>
        </div>
      </div>
      
      <!-- 选中车位信息 -->
      <div class="selected-space-info" v-if="selectedSpace">
        <div class="info-header">
          <h3>车位详情</h3>
          <div class="close-button" @click="clearSelection">×</div>
        </div>
        <div class="info-content">
          <div class="info-row">
            <span class="info-label">车位号：</span>
            <span class="info-value">{{ selectedSpace.floorName }}-{{ selectedSpace.number }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">状态：</span>
            <span class="info-value" :class="getStatusClass(selectedSpace)">
              {{ getStatusText(selectedSpace) }}
            </span>
          </div>
          <div class="info-row" v-if="selectedSpace.type">
            <span class="info-label">类型：</span>
            <span class="info-value">{{ getSpaceTypeText(selectedSpace) }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">位置：</span>
            <span class="info-value">{{ getSpaceLocationText(selectedSpace) }}</span>
          </div>
          <button 
            class="reserve-button" 
            v-if="selectedSpace.status === 'available'"
            :disabled="!parkingInfo.hasReservation"
            @click="goToReservation"
          >
            {{ parkingInfo.hasReservation ? '立即预约' : '暂不可预约' }}
          </button>
        </div>
      </div>
    </div>
    
    <!-- 底部操作栏 -->
    <div class="bottom-actions" v-if="!selectedSpace && spacesData.length > 0">
      <button class="navigate-button" @click="navigateToMap">
        <div class="navigate-icon"></div>
        <span>导航前往</span>
      </button>
      <button class="back-to-detail" @click="backToDetail">
        返回停车场详情
      </button>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { fetchParkingSpaces, fetchParkingDetail } from '../api/parking'
import { showErrorToast, showSuccessToast } from '../utils'

export default {
  name: 'RealTimeSpaces',
  setup() {
    const router = useRouter()
    const route = useRoute()
    const parkingId = computed(() => {
      const id = route.params.parkingId
      // 确保返回数字ID
      const numId = Number(id)
      return numId > 0 ? numId : id
    })
    
    const loading = ref(false)
    const refreshing = ref(false)
    const error = ref('')
    const parkingInfo = ref({})
    const spacesData = ref([])
    const selectedFloor = ref('')
    const selectedSpace = ref(null)
    const floors = ref([])
    const floorStats = ref({})
    const updateTime = ref('')
    const autoRefreshTimer = ref(null)
    
    // 计算属性
    const occupancyRate = computed(() => {
      const total = parkingInfo.value.totalSpaces || 0
      const available = parkingInfo.value.availableSpaces || 0
      if (total === 0) return 0
      return Math.round(((total - available) / total) * 100)
    })
    
    const selectedFloorName = computed(() => {
      const floor = floors.value.find(f => f.id === selectedFloor.value)
      return floor ? floor.name : ''
    })
    
    const currentFloorData = computed(() => {
      return spacesData.value.filter(space => space.floorId === selectedFloor.value)
    })
    
    // 获取车位状态类名
    const getStatusClass = (space) => {
      return space.status || 'unknown'
    }
    
    // 获取车位状态文本
    const getStatusText = (space) => {
      const statusMap = {
        available: '空闲',
        occupied: '占用',
        reserved: '已预约',
        maintenance: '维护中',
        disabled: '禁用',
        unknown: '未知'
      }
      return statusMap[space.status] || '未知'
    }
    
    // 获取车位类型文本
    const getSpaceTypeText = (space) => {
      const typeMap = {
        standard: '标准车位',
        large: '大车车位',
        disabled: '无障碍车位',
        ev: '电动车位'
      }
      return typeMap[space.type] || '普通车位'
    }
    
    // 获取车位位置文本
    const getSpaceLocationText = (space) => {
      if (space.area) {
        return `${space.area}区域，靠近${space.nearby || '主通道'}`
      }
      return `靠近${space.nearby || '主通道'}`
    }
    
    // 获取车位提示文本
    const getSpaceTooltip = (space) => {
      return `${space.floorName}-${space.number}\n状态：${getStatusText(space)}${space.type ? '\n类型：' + getSpaceTypeText(space) : ''}`
    }
    
    // 加载停车场信息
    const loadParkingInfo = async () => {
      try {
        const response = await fetchParkingDetail(parkingId.value)
        if (response.code === 200) {
          parkingInfo.value = response.data
          
          // 设置楼层信息
          if (parkingInfo.value.floors && parkingInfo.value.floors.length > 0) {
            floors.value = parkingInfo.value.floors
            selectedFloor.value = parkingInfo.value.floors[0].id
          }
        } else {
          throw new Error(response.message || '获取停车场信息失败')
        }
      } catch (err) {
        error.value = err.message || '获取停车场信息失败'
        console.error('加载停车场信息失败:', err)
      }
    }
    
    // 加载车位数据
    const loadSpacesData = async () => {
      try {
        loading.value = true
        error.value = ''
        
        // 如果没有选择楼层，不进行加载
        if (!selectedFloor.value) {
          loading.value = false
          return
        }
        
        // 关键修复：调用真实的 API 获取车位数据
        const parkingIdNum = Number(parkingId.value)
        if (!parkingIdNum || parkingIdNum <= 0) {
          throw new Error('无效的停车场ID')
        }
        
        // 构造查询参数，调用真实的 searchSpaces API
        const queryParams = {
          parkingId: parkingIdNum,         // 停车场ID（数字）
          floor: selectedFloorName.value,  // 楼层名称
          pageNum: 1,
          pageSize: 999  // 获取该楼层所有车位
        }
        
        console.log('加载车位数据，查询参数:', queryParams)
        
        // 调用真实的 searchSpaces API（通过 fetchParkingSpaces，传递查询对象）
        const response = await fetchParkingSpaces(queryParams)
        
        if (response.code === 200) {
          // response.data 应该是一个列表 List<ParkingSpaceDTO>
          const currentFloorSpaces = Array.isArray(response.data) ? response.data : []
          
          console.log('获取到车位数据:', currentFloorSpaces.length, '个车位')
          
          // 处理数据，确保字段名统一，并确保ID是数字
          const processedSpaces = currentFloorSpaces.map(space => {
            const processed = {
              ...space,
              id: Number(space.id), // 关键：确保 id 是数字，不是字符串
              number: space.spaceNumber || space.number, // 确保使用 spaceNumber
              floorId: selectedFloor.value, // 设置楼层ID
              floorName: selectedFloorName.value, // 设置楼层名称
              status: convertStatus(space.status, space.state), // 确保状态字段正确
              type: space.type || space.category ? getTypeText(space.type || space.category) : undefined
            }
            // 验证ID转换是否成功
            if (!processed.id || processed.id <= 0 || isNaN(processed.id)) {
              console.error('警告：车位ID无效:', space.id, '转换后:', processed.id)
            }
            return processed
          })
          
          console.log('处理后的车位数据（前3个）:', processedSpaces.slice(0, 3).map(s => ({ id: s.id, number: s.number, status: s.status })))
          
          // 更新总数据数组
          spacesData.value = spacesData.value.filter(space => space.floorId !== selectedFloor.value)
          spacesData.value = [...spacesData.value, ...processedSpaces]
          
          // 计算楼层统计信息
          updateFloorStats()
          
          // 更新时间
          updateTime.value = new Date().toLocaleTimeString('zh-CN')
        } else {
          throw new Error(response.message || '获取车位数据失败')
        }
      } catch (err) {
        error.value = err.message || '获取车位数据失败'
        console.error('加载车位数据失败:', err)
      } finally {
        loading.value = false
        refreshing.value = false
      }
    }
    
    // 转换状态：将后端状态转换为前端状态
    const convertStatus = (status, state) => {
      // 如果后端返回字符串状态
      if (status) {
        const statusLower = status.toLowerCase()
        if (statusLower === 'available') return 'available'
        if (statusLower === 'occupied') return 'occupied'
        if (statusLower === 'reserved') return 'reserved'
        if (statusLower === 'maintenance') return 'maintenance'
      }
      // 如果后端返回数字状态
      if (state !== null && state !== undefined) {
        if (state === 0) return 'available'
        if (state === 1) return 'reserved'
        if (state === 2) return 'occupied'
      }
      // 默认状态
      return 'unknown'
    }
    
    // 获取类型文本
    const getTypeText = (type) => {
      if (typeof type === 'number') {
        const typeMap = { 0: 'standard', 1: 'large', 2: 'disabled', 3: 'ev' }
        return typeMap[type] || 'standard'
      }
      return type
    }
    
    
    // 更新楼层统计信息
    const updateFloorStats = () => {
      const stats = {}
      
      // 按楼层分组统计
      spacesData.value.forEach(space => {
        if (!stats[space.floorId]) {
          stats[space.floorId] = {
            total: 0,
            available: 0,
            occupied: 0,
            reserved: 0,
            maintenance: 0,
            disabled: 0
          }
        }
        
        stats[space.floorId].total++
        if (stats[space.floorId][space.status]) {
          stats[space.floorId][space.status]++
        }
      })
      
      floorStats.value = stats
    }
    
    // 刷新数据
    const refreshData = async () => {
      refreshing.value = true
      await loadSpacesData()
    }
    
    // 选择楼层
    const selectFloor = (floorId) => {
      selectedFloor.value = floorId
      selectedSpace.value = null
      
      // 检查是否已经加载过该楼层的数据
      const hasData = spacesData.value.some(space => space.floorId === floorId)
      if (!hasData) {
        loadSpacesData()
      }
    }
    
    // 选择车位
    const selectSpace = (space) => {
      selectedSpace.value = space
    }
    
    // 清除选择
    const clearSelection = () => {
      selectedSpace.value = null
    }
    
    // 返回上一页
    const goBack = () => {
      router.back()
    }
    
    // 前往预约页面
    const goToReservation = () => {
      if (!selectedSpace.value || selectedSpace.value.status !== 'available') {
        showErrorToast('该车位不可预约')
        return
      }
      
      if (!parkingInfo.value.hasReservation) {
        showErrorToast('该停车场暂不支持预约')
        return
      }
      
      // 关键修复：确保 ID 是数字类型
      const spaceIdNum = Number(selectedSpace.value.id)
      const parkingIdNum = Number(parkingId.value)
      
      // 验证车位ID
      if (!spaceIdNum || spaceIdNum <= 0 || isNaN(spaceIdNum)) {
        console.error('无效的车位ID:', {
          原始ID: selectedSpace.value.id,
          类型: typeof selectedSpace.value.id,
          转换后: spaceIdNum,
          是否NaN: isNaN(spaceIdNum)
        })
        showErrorToast('车位ID无效，请重新选择')
        return
      }
      
      // 验证停车场ID
      if (!parkingIdNum || parkingIdNum <= 0 || isNaN(parkingIdNum)) {
        console.error('无效的停车场ID:', {
          原始ID: parkingId.value,
          类型: typeof parkingId.value,
          转换后: parkingIdNum
        })
        showErrorToast('停车场ID无效')
        return
      }
      
      // 这里的 selectedSpace.value.id 现在应该是来自数据库的真实数字ID
      console.log('即将跳转预约，车位信息:', {
        车位ID: spaceIdNum,
        车位ID类型: typeof spaceIdNum,
        停车场ID: parkingIdNum,
        车位编号: selectedSpace.value.number,
        楼层: selectedSpace.value.floorName
      })
      
      router.push({
        path: '/reservation',
        query: {
          parkingId: parkingIdNum, // 确保是数字
          spaceId: spaceIdNum, // 确保是数字，来自数据库的真实ID
          parkingName: parkingInfo.value.name,
          spaceNumber: selectedSpace.value.number, // 确保使用 number
          floorName: selectedSpace.value.floorName
        }
      })
    }
    
    // 返回停车场详情
    const backToDetail = () => {
      router.push(`/parking-detail/${parkingId.value}`)
    }
    
    // 导航到地图
    const navigateToMap = () => {
      showSuccessToast('导航功能开发中')
    }
    
    
    // 设置自动刷新
    const setupAutoRefresh = () => {
      // 每30秒自动刷新一次数据
      autoRefreshTimer.value = setInterval(() => {
        if (selectedFloor.value) {
          loadSpacesData()
        }
      }, 30000)
    }
    
    // 清理自动刷新
    const clearAutoRefresh = () => {
      if (autoRefreshTimer.value) {
        clearInterval(autoRefreshTimer.value)
        autoRefreshTimer.value = null
      }
    }
    
    // 生命周期钩子
    onMounted(async () => {
      await loadParkingInfo()
      
      // 当楼层数据加载完成后，加载车位数据
      if (selectedFloor.value) {
        await loadSpacesData()
      }
      
      // 设置自动刷新
      setupAutoRefresh()
    })
    
    onUnmounted(() => {
      // 清理自动刷新
      clearAutoRefresh()
    })
    
    return {
      loading,
      refreshing,
      error,
      parkingInfo,
      spacesData,
      selectedFloor,
      selectedSpace,
      floors,
      floorStats,
      updateTime,
      occupancyRate,
      selectedFloorName,
      currentFloorData,
      getStatusClass,
      getStatusText,
      getSpaceTypeText,
      getSpaceLocationText,
      getSpaceTooltip,
      refreshData,
      selectFloor,
      selectSpace,
      clearSelection,
      goBack,
      backToDetail,
      navigateToMap,
      loadSpacesData,
      goToReservation
    }
  }
}
</script>

<style scoped>
.real-time-spaces {
  min-height: 100vh;
  background-color: #f5f5f5;
  position: relative;
}

/* 头部样式 */
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background-color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 15px 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.back-button,
.refresh-button {
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.back-icon {
  width: 12px;
  height: 12px;
  border-left: 2px solid #333;
  border-top: 2px solid #333;
  transform: rotate(-45deg);
  margin-left: 4px;
}

.refresh-icon {
  font-size: 18px;
  color: #333;
  transition: transform 0.3s;
}

.refresh-icon.refreshing {
  animation: rotate 1s linear infinite;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.page-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

/* 加载和错误状态 */
.loading-container,
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 100px 20px;
  color: #999;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #1890ff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 15px;
}

.error-icon {
  width: 60px;
  height: 60px;
  background-color: #ffccc7;
  border-radius: 50%;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.error-icon::after {
  content: '!';
  font-size: 30px;
  color: #ff4d4f;
  font-weight: bold;
}

.retry-button {
  margin-top: 15px;
  padding: 8px 20px;
  background-color: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 14px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 内容区样式 */
.content {
  padding-top: 70px;
  padding-bottom: 80px;
}

/* 停车场信息 */
.parking-info {
  background-color: #fff;
  padding: 15px;
  margin-bottom: 10px;
}

.parking-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0 0 15px 0;
}

.parking-stats {
  display: flex;
  align-items: center;
  justify-content: space-around;
  margin-bottom: 10px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-label {
  font-size: 12px;
  color: #666;
  margin-bottom: 5px;
}

.stat-value {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.stat-value.available {
  color: #52c41a;
}

.stat-divider {
  width: 1px;
  height: 30px;
  background-color: #e8e8e8;
}

.update-time {
  font-size: 12px;
  color: #999;
  text-align: center;
}

/* 楼层选择器 */
.floor-selector {
  background-color: #fff;
  padding: 10px 15px;
  margin-bottom: 10px;
  display: flex;
  overflow-x: auto;
  gap: 10px;
}

.floor-tab {
  padding: 8px 16px;
  background-color: #f5f5f5;
  border-radius: 16px;
  font-size: 14px;
  color: #666;
  white-space: nowrap;
  display: flex;
  align-items: center;
  gap: 6px;
}

.floor-tab.active {
  background-color: #1890ff;
  color: #fff;
}

.floor-spaces {
  font-size: 12px;
  opacity: 0.8;
}

/* 图例 */
.legend {
  background-color: #fff;
  padding: 15px;
  margin-bottom: 10px;
  display: flex;
  overflow-x: auto;
  gap: 15px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 5px;
  white-space: nowrap;
  font-size: 12px;
  color: #666;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.legend-color.available {
  background-color: #52c41a;
}

.legend-color.occupied {
  background-color: #ff4d4f;
}

.legend-color.reserved {
  background-color: #fa8c16;
}

.legend-color.maintenance {
  background-color: #999;
}

.legend-color.disabled {
  background-color: #e8e8e8;
}

/* 车位地图 */
.spaces-map {
  background-color: #fff;
  padding: 15px;
  margin-bottom: 10px;
  min-height: 300px;
}

.area-header {
  margin-bottom: 15px;
}

.area-header h3 {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.spaces-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 8px;
}

.space-item {
  aspect-ratio: 1.5;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #fff;
  position: relative;
  transition: all 0.2s;
  cursor: pointer;
}

.space-item.available {
  background-color: #52c41a;
}

.space-item.occupied {
  background-color: #ff4d4f;
}

.space-item.reserved {
  background-color: #fa8c16;
}

.space-item.maintenance {
  background-color: #999;
}

.space-item.disabled {
  background-color: #e8e8e8;
  color: #999;
}

.space-item.unknown {
  background-color: #f0f0f0;
  color: #999;
}

.space-item:active {
  transform: scale(0.95);
}

.space-number {
  font-weight: bold;
}

.space-indicator {
  position: absolute;
  top: 2px;
  right: 2px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.6);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 50px 20px;
  color: #999;
}

.empty-icon {
  width: 60px;
  height: 60px;
  background-color: #f5f5f5;
  border-radius: 50%;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-icon::after {
  content: '🅿';
  font-size: 30px;
  color: #d9d9d9;
}

/* 选中车位信息 */
.selected-space-info {
  background-color: #fff;
  padding: 15px;
  margin-bottom: 10px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  position: fixed;
  bottom: 80px;
  left: 15px;
  right: 15px;
  z-index: 90;
}

.info-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.info-header h3 {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.close-button {
  font-size: 20px;
  color: #999;
  cursor: pointer;
}

.info-content {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 10px;
}

.info-label {
  font-size: 14px;
  color: #666;
  min-width: 60px;
}

.info-value {
  font-size: 14px;
  color: #333;
  flex: 1;
}

.reserve-button {
  margin-top: 10px;
  padding: 10px;
  background-color: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  font-weight: bold;
}

.reserve-button:disabled {
      background-color: #d9d9d9;
    }
    
    .reserve-button:hover:not(:disabled) {
      background-color: #40a9ff;
      transition: background-color 0.3s;
    }

/* 底部操作栏 */
.bottom-actions {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: #fff;
  padding: 15px;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  gap: 15px;
}

.navigate-button,
.back-to-detail {
  flex: 1;
  padding: 12px;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  font-weight: bold;
}

.navigate-button {
  background-color: #1890ff;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.navigate-icon {
  width: 20px;
  height: 20px;
  background-color: #fff;
  border-radius: 50%;
}

.back-to-detail {
  background-color: #f0f0f0;
  color: #333;
}
</style>