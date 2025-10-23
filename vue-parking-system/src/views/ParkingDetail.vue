<template>
  <div class="parking-detail">
    <!-- 返回按钮 -->
    <div class="header">
      <div class="back-button" @click="goBack">
        <div class="back-icon"></div>
      </div>
    </div>
    
    <!-- 停车场信息 -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>加载中...</p>
    </div>
    
    <div v-else-if="error" class="error-container">
      <div class="error-icon"></div>
      <p>{{ error }}</p>
      <button class="retry-button" @click="loadParkingDetail">重试</button>
    </div>
    
    <div v-else-if="parkingDetail" class="parking-content">
      <!-- 停车场图片 -->
      <div class="parking-images">
        <div class="image-container">
          <img :src="parkingDetail.imageUrl || '/images/parking-placeholder.jpg'" :alt="parkingDetail.name">
        </div>
      </div>
      
      <!-- 基本信息 -->
      <div class="info-section">
        <h1 class="parking-name">{{ parkingDetail.name }}</h1>
        <div class="parking-tags">
          <span v-if="parkingDetail.hasReservation" class="tag-reservation">可预约</span>
          <span v-if="parkingDetail.hasCharge" class="tag-charge">充电桩</span>
          <span v-if="parkingDetail.isMember" class="tag-member">会员优惠</span>
        </div>
        
        <div class="basic-info">
          <div class="info-item">
            <div class="info-label">地址</div>
            <div class="info-value">{{ parkingDetail.address }}</div>
            <div class="info-action" @click="navigateToMap">
              <div class="location-icon"></div>
              <span>查看地图</span>
            </div>
          </div>
          
          <div class="info-item">
            <div class="info-label">营业时间</div>
            <div class="info-value">{{ parkingDetail.businessHours }}</div>
            <div class="info-status" :class="parkingDetail.status === 'open' ? 'open' : 'closed'">
              {{ parkingDetail.status === 'open' ? '营业中' : '已关闭' }}
            </div>
          </div>
          
          <div class="info-item">
            <div class="info-label">收费标准</div>
            <div class="info-value">首小时¥{{ parkingDetail.priceFirstHour }}，之后每小时¥{{ parkingDetail.pricePerHour }}</div>
          </div>
        </div>
      </div>
      
      <!-- 车位信息 -->
      <div class="spaces-section">
        <div class="section-header">
          <h2>车位信息</h2>
          <span class="total-spaces">总车位：{{ parkingDetail.totalSpaces }}</span>
        </div>
        
        <div class="floor-tabs">
          <div 
            v-for="floor in parkingDetail.floors" 
            :key="floor.id" 
            class="floor-tab"
            :class="{ active: selectedFloor === floor.id }"
            @click="selectFloor(floor.id)"
          >
            {{ floor.name }}
          </div>
        </div>
        
        <div class="spaces-grid">
          <div 
            v-for="space in currentFloorSpaces" 
            :key="space.id" 
            class="space-item"
            :class="getStatusClass(space.status)"
            @click="selectSpace(space)"
          >
            <div class="space-number">{{ space.number }}</div>
            <div class="space-status">{{ getStatusText(space.status) }}</div>
          </div>
        </div>
      </div>
      
      <!-- 停车场设施 -->
      <div class="facilities-section">
        <h2>停车场设施</h2>
        <div class="facilities-list">
          <div class="facility-item" v-for="facility in parkingDetail.facilities" :key="facility.name">
            <div class="facility-icon"></div>
            <span>{{ facility.name }}</span>
          </div>
        </div>
      </div>
      
      <!-- 用户评价 -->
      <div class="reviews-section">
        <div class="section-header">
          <h2>用户评价</h2>
          <div class="rating">
            <span class="score">{{ parkingDetail.rating || 5.0 }}</span>
            <div class="stars">
              <div class="star" v-for="i in 5" :key="i" :class="{ filled: i <= Math.floor(parkingDetail.rating || 5) }"></div>
            </div>
            <span class="review-count">({{ parkingDetail.reviewCount || 0 }}条评价)</span>
          </div>
        </div>
        
        <div class="review-list">
          <div class="review-item" v-for="review in parkingDetail.reviews" :key="review.id">
            <div class="review-header">
              <div class="user-avatar"></div>
              <div class="user-info">
                <div class="username">{{ review.username }}</div>
                <div class="review-stars">
                  <div class="star" v-for="i in 5" :key="i" :class="{ filled: i <= review.rating }"></div>
                </div>
              </div>
              <div class="review-time">{{ formatDate(review.createTime) }}</div>
            </div>
            <div class="review-content">{{ review.content }}</div>
          </div>
          
          <div class="view-more" @click="navigateToAllReviews">查看全部评价</div>
        </div>
      </div>
    </div>
    
    <!-- 底部操作栏 -->
    <div class="bottom-action" v-if="parkingDetail && parkingDetail.status === 'open'">
      <div class="selected-space" v-if="selectedSpace">
        <span>已选择：{{ selectedSpace.floorName }} - {{ selectedSpace.number }}</span>
        <div class="cancel-selection" @click="cancelSpaceSelection">取消</div>
      </div>
      <button 
        class="reserve-button" 
        :disabled="!selectedSpace || !parkingDetail.hasReservation"
        @click="handleReservation"
      >
        {{ parkingDetail.hasReservation ? '立即预约' : '暂不可预约' }}
      </button>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showLoading, hideLoading, showErrorToast, showSuccessToast } from '../utils'
import { fetchParkingDetail, fetchParkingSpaces } from '../api/parking'

export default {
  name: 'ParkingDetail',
  setup() {
    const router = useRouter()
    const route = useRoute()
    const parkingId = computed(() => route.params.id)
    
    const loading = ref(false)
    const error = ref('')
    const parkingDetail = ref(null)
    const selectedFloor = ref('')
    const selectedSpace = ref(null)
    const allSpaces = ref([])
    
    // 获取当前楼层的车位
    const currentFloorSpaces = computed(() => {
      return allSpaces.value.filter(space => space.floorId === selectedFloor.value)
    })
    
    // 格式化日期
    const formatDate = (dateString) => {
      if (!dateString) return ''
      const date = new Date(dateString)
      return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
    }
    
    // 获取车位状态类名
    const getStatusClass = (status) => {
      switch (status) {
        case 'available':
          return 'available'
        case 'occupied':
          return 'occupied'
        case 'reserved':
          return 'reserved'
        case 'maintenance':
          return 'maintenance'
        default:
          return 'unknown'
      }
    }
    
    // 获取车位状态文本
    const getStatusText = (status) => {
      switch (status) {
        case 'available':
          return '空闲'
        case 'occupied':
          return '占用'
        case 'reserved':
          return '已预约'
        case 'maintenance':
          return '维护中'
        default:
          return '未知'
      }
    }
    
    // 加载停车场详情
    const loadParkingDetail = async () => {
      try {
        loading.value = true
        error.value = ''
        
        const response = await fetchParkingDetail(parkingId.value)
        
        if (response.code === 200) {
          parkingDetail.value = response.data
          
          // 默认选择第一个楼层
          if (parkingDetail.value.floors && parkingDetail.value.floors.length > 0) {
            selectedFloor.value = parkingDetail.value.floors[0].id
          }
          
          // 加载车位信息
          await loadSpaces()
        } else {
          error.value = response.message || '获取停车场详情失败'
        }
      } catch (err) {
        error.value = '网络错误，请稍后重试'
        console.error('获取停车场详情失败:', err)
      } finally {
        loading.value = false
      }
    }
    
    // 加载车位信息
    const loadSpaces = async () => {
      try {
        const response = await fetchParkingSpaces(parkingId.value)
        
        if (response.code === 200) {
          allSpaces.value = response.data
        } else {
          showErrorToast(response.message || '获取车位信息失败')
        }
      } catch (err) {
        console.error('获取车位信息失败:', err)
      }
    }
    
    // 选择楼层
    const selectFloor = (floorId) => {
      selectedFloor.value = floorId
      selectedSpace.value = null // 重置已选择的车位
    }
    
    // 选择车位
    const selectSpace = (space) => {
      if (space.status === 'available') {
        selectedSpace.value = space
      }
    }
    
    // 取消车位选择
    const cancelSpaceSelection = () => {
      selectedSpace.value = null
    }
    
    // 返回上一页
    const goBack = () => {
      router.back()
    }
    
    // 导航到地图
    const navigateToMap = () => {
      // 实现地图导航功能
      showSuccessToast('导航功能开发中')
    }
    
    // 导航到所有评价
    const navigateToAllReviews = () => {
      // 实现查看所有评价功能
      showSuccessToast('查看所有评价功能开发中')
    }
    
    // 处理预约
    const handleReservation = () => {
      if (!selectedSpace.value) {
        showErrorToast('请先选择车位')
        return
      }
      
      if (!parkingDetail.value.hasReservation) {
        showErrorToast('该停车场暂不支持预约')
        return
      }
      
      // 导航到预约确认页面
      router.push({
        path: '/reservation-confirm',
        query: {
          parkingId: parkingId.value,
          parkingName: parkingDetail.value.name,
          spaceId: selectedSpace.value.id,
          spaceNumber: selectedSpace.value.number,
          floorName: selectedSpace.value.floorName
        }
      })
    }
    
    onMounted(() => {
      loadParkingDetail()
    })
    
    return {
      loading,
      error,
      parkingDetail,
      selectedFloor,
      selectedSpace,
      currentFloorSpaces,
      formatDate,
      getStatusClass,
      getStatusText,
      selectFloor,
      selectSpace,
      cancelSpaceSelection,
      goBack,
      navigateToMap,
      navigateToAllReviews,
      handleReservation,
      loadParkingDetail
    }
  }
}
</script>

<style scoped>
.parking-detail {
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
  padding: 20px 15px 10px;
  background-color: rgba(255, 255, 255, 0.9);
}

.back-button {
  width: 30px;
  height: 30px;
  background-color: rgba(0, 0, 0, 0.5);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.back-icon {
  width: 12px;
  height: 12px;
  border-left: 2px solid #fff;
  border-top: 2px solid #fff;
  transform: rotate(-45deg);
  margin-left: 4px;
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

/* 停车场内容样式 */
.parking-content {
  padding-top: 60px;
  padding-bottom: 80px;
}

/* 停车场图片 */
.parking-images {
  height: 200px;
  background-color: #fff;
}

.image-container {
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* 基本信息部分 */
.info-section {
  background-color: #fff;
  padding: 15px;
  margin-bottom: 10px;
}

.parking-name {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin: 0 0 10px 0;
}

.parking-tags {
  display: flex;
  gap: 8px;
  margin-bottom: 15px;
}

.tag-reservation,
.tag-charge,
.tag-member {
  padding: 3px 8px;
  font-size: 12px;
  border-radius: 12px;
}

.tag-reservation {
  background-color: #e6f7ff;
  color: #1890ff;
}

.tag-charge {
  background-color: #f6ffed;
  color: #52c41a;
}

.tag-member {
  background-color: #fff7e6;
  color: #fa8c16;
}

.basic-info {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.info-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.info-label {
  font-size: 14px;
  color: #666;
  min-width: 80px;
}

.info-value {
  flex: 1;
  font-size: 14px;
  color: #333;
  margin: 0 10px;
}

.info-action {
  display: flex;
  align-items: center;
  font-size: 14px;
  color: #1890ff;
}

.location-icon {
  width: 16px;
  height: 16px;
  background-color: #1890ff;
  border-radius: 50%;
  margin-right: 5px;
}

.info-status {
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 12px;
}

.info-status.open {
  background-color: #f6ffed;
  color: #52c41a;
}

.info-status.closed {
  background-color: #f5f5f5;
  color: #999;
}

/* 车位信息部分 */
.spaces-section {
  background-color: #fff;
  padding: 15px;
  margin-bottom: 10px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.section-header h2 {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.total-spaces {
  font-size: 14px;
  color: #666;
}

.floor-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
  overflow-x: auto;
  padding-bottom: 5px;
}

.floor-tab {
  padding: 6px 16px;
  background-color: #f5f5f5;
  border-radius: 16px;
  font-size: 14px;
  color: #666;
  white-space: nowrap;
}

.floor-tab.active {
  background-color: #1890ff;
  color: #fff;
}

.spaces-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
}

.space-item {
  padding: 10px 5px;
  background-color: #f5f5f5;
  border-radius: 4px;
  text-align: center;
  font-size: 12px;
}

.space-item.available {
  background-color: #f6ffed;
  color: #52c41a;
}

.space-item.occupied {
  background-color: #fff2f0;
  color: #ff4d4f;
}

.space-item.reserved {
  background-color: #fff7e6;
  color: #fa8c16;
}

.space-item.maintenance {
  background-color: #f5f5f5;
  color: #999;
}

.space-number {
  font-size: 14px;
  font-weight: bold;
  margin-bottom: 2px;
}

.space-status {
  font-size: 10px;
}

/* 设施部分 */
.facilities-section {
  background-color: #fff;
  padding: 15px;
  margin-bottom: 10px;
}

.facilities-section h2 {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0 0 15px 0;
}

.facilities-list {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.facility-item {
  display: flex;
  align-items: center;
  font-size: 14px;
  color: #666;
}

.facility-icon {
  width: 20px;
  height: 20px;
  background-color: #e6f7ff;
  border-radius: 4px;
  margin-right: 8px;
}

/* 评价部分 */
.reviews-section {
  background-color: #fff;
  padding: 15px;
  margin-bottom: 10px;
}

.rating {
  display: flex;
  align-items: center;
  gap: 8px;
}

.score {
  font-size: 18px;
  font-weight: bold;
  color: #fa8c16;
}

.stars {
  display: flex;
  gap: 2px;
}

.star {
  width: 16px;
  height: 16px;
  background-color: #f5f5f5;
  border-radius: 50%;
}

.star.filled {
  background-color: #fa8c16;
}

.review-count {
  font-size: 14px;
  color: #999;
}

.review-list {
  margin-top: 15px;
}

.review-item {
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.review-item:last-child {
  border-bottom: none;
}

.review-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.user-avatar {
  width: 32px;
  height: 32px;
  background-color: #f5f5f5;
  border-radius: 50%;
  margin-right: 10px;
}

.user-info {
  flex: 1;
}

.username {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.review-stars {
  display: flex;
  gap: 2px;
}

.review-stars .star {
  width: 14px;
  height: 14px;
}

.review-time {
  font-size: 12px;
  color: #999;
}

.review-content {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
}

.view-more {
  text-align: center;
  padding: 10px 0;
  font-size: 14px;
  color: #1890ff;
}

/* 底部操作栏 */
.bottom-action {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: #fff;
  padding: 10px 15px;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.selected-space {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
}

.selected-space span {
  font-size: 14px;
  color: #333;
}

.cancel-selection {
  font-size: 14px;
  color: #999;
  padding: 4px 10px;
  background-color: #f5f5f5;
  border-radius: 4px;
}

.reserve-button {
  padding: 10px 30px;
  background-color: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  font-weight: bold;
}

.reserve-button:disabled {
  background-color: #d9d9d9;
  color: #fff;
}
</style>