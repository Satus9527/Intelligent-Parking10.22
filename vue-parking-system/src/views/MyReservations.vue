<template>
  <div class="my-reservations-page">
    <!-- 页面头部 -->
    <div class="header">
      <div class="back-button" @click="goBack">
        <div class="back-icon"></div>
      </div>
      <h1 class="page-title">我的预约</h1>
      <div class="empty-placeholder"></div>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>加载中...</p>
    </div>

    <!-- 错误状态 -->
    <div v-else-if="error" class="error-container">
      <p class="error-message">{{ error }}</p>
      <button class="retry-button" @click="loadReservations">重试</button>
    </div>

    <!-- 空状态 -->
    <div v-else-if="reservations.length === 0" class="empty-container">
      <div class="empty-icon"></div>
      <p class="empty-message">暂无预约记录</p>
      <button class="go-home-button" @click="goToHome">去预约</button>
    </div>

    <!-- 预约列表 -->
    <div v-else class="reservation-list">
      <div 
        v-for="reservation in reservations" 
        :key="reservation.id" 
        class="reservation-card"
      >
        <!-- 预约头部信息 -->
        <div class="reservation-header">
          <div class="reservation-info">
            <h3 class="parking-name">{{ reservation.parkingName }}</h3>
            <div class="space-info">
              <span>{{ reservation.floorName }}-{{ reservation.spaceNumber }}</span>
              <span class="reservation-no">预约号：{{ reservation.reservationNo }}</span>
            </div>
          </div>
          <span 
            class="status-badge" 
            :class="getStatusClass(reservation.status)"
          >
            {{ getStatusText(reservation.status) }}
          </span>
        </div>

        <!-- 预约时间 -->
        <div class="time-info">
          <div class="time-item">
            <span class="time-label">预约时间：</span>
            <span class="time-value">{{ formatDateTimeRange(reservation.startTime, reservation.endTime) }}</span>
          </div>
          <div class="time-item" v-if="reservation.actualEntryTime">
            <span class="time-label">实际入场：</span>
            <span class="time-value">{{ formatDateTime(reservation.actualEntryTime) }}</span>
          </div>
          <div class="time-item" v-if="reservation.actualExitTime">
            <span class="time-label">实际出场：</span>
            <span class="time-value">{{ formatDateTime(reservation.actualExitTime) }}</span>
          </div>
        </div>

        <!-- 车辆信息 -->
        <div class="vehicle-info">
          <span class="vehicle-label">车牌号：</span>
          <span class="vehicle-value">{{ reservation.plateNumber }}</span>
        </div>

        <!-- 操作按钮 -->
        <div class="action-buttons">
          <button 
            class="action-button detail-button" 
            @click="viewReservationDetail(reservation)"
          >
            查看详情
          </button>
          <button 
            v-if="reservation.status === 'PENDING'" 
            class="action-button cancel-button" 
            @click="confirmCancel(reservation)"
          >
            取消预约
          </button>
          <button 
            v-if="reservation.status === 'CANCELLED' && !reservation.refundStatus" 
            class="action-button refund-button" 
            @click="applyRefund(reservation)"
          >
            申请退款
          </button>
          <span v-if="reservation.status === 'USED'" class="action-text">已完成</span>
          <span v-if="reservation.status === 'TIMEOUT'" class="action-text">已超时</span>
        </div>
      </div>
    </div>

    <!-- 取消确认弹窗 -->
    <div v-if="showCancelConfirm" class="modal-overlay" @click="closeCancelConfirm">
      <div class="modal-content" @click.stop>
        <h3 class="modal-title">确认取消</h3>
        <p class="modal-message">确定要取消该预约吗？</p>
        <div class="modal-actions">
          <button class="modal-button cancel" @click="closeCancelConfirm">取消</button>
          <button class="modal-button confirm" @click="cancelReservation">确认</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showSuccessToast, showErrorToast } from '../utils'

export default {
  name: 'MyReservations',
  setup() {
    const router = useRouter()
    
    const loading = ref(false)
    const error = ref('')
    const reservations = ref([])
    const showCancelConfirm = ref(false)
    const selectedReservation = ref(null)
    
    // 查看预约详情
    const viewReservationDetail = (reservation) => {
      router.push({
        path: '/reservation-detail',
        query: { id: reservation.id }
      })
    }
    
    // 加载预约列表
    const loadReservations = async () => {
      try {
        loading.value = true
        error.value = ''
        
        // 在实际项目中，这里应该调用后端API
        // const response = await getUserReservations()
        
        // 模拟API调用和数据
        setTimeout(() => {
          reservations.value = generateMockReservations()
          loading.value = false
        }, 1000)
      } catch (err) {
        loading.value = false
        error.value = '加载预约列表失败，请稍后重试'
        console.error('加载预约列表失败:', err)
      }
    }
    
    // 生成模拟预约数据
    const generateMockReservations = () => {
      const now = new Date()
      const tomorrow = new Date(now)
      tomorrow.setDate(tomorrow.getDate() + 1)
      
      return [
        {
          id: 1,
          reservationNo: 'RES20241220083001',
          parkingId: 1,
          parkingName: '中央商场停车场',
          parkingSpaceId: 101,
          floorName: 'B1',
          spaceNumber: 'A区12号',
          status: 'PENDING',
          refundStatus: null,
          startTime: new Date(now.getTime() + 2 * 60 * 60 * 1000), // 2小时后
          endTime: new Date(now.getTime() + 4 * 60 * 60 * 1000),   // 4小时后
          actualEntryTime: null,
          actualExitTime: null,
          plateNumber: '京A12345',
          contactPhone: '13800138000',
          vehicleInfo: '小型轿车',
          remark: '',
          createdAt: new Date()
        },
        {
          id: 2,
          reservationNo: 'RES20241219142533',
          parkingId: 2,
          parkingName: '科技园停车场',
          parkingSpaceId: 205,
          floorName: 'B2',
          spaceNumber: 'C区08号',
          status: 'USED',
          refundStatus: null,
          startTime: new Date(now.getTime() - 48 * 60 * 60 * 1000), // 2天前
          endTime: new Date(now.getTime() - 45 * 60 * 60 * 1000),   // 45小时前
          actualEntryTime: new Date(now.getTime() - 48 * 60 * 60 * 1000),
          actualExitTime: new Date(now.getTime() - 45 * 60 * 60 * 1000),
          plateNumber: '京B54321',
          contactPhone: '13800138000',
          vehicleInfo: '小型SUV',
          remark: '',
          createdAt: new Date(now.getTime() - 49 * 60 * 60 * 1000)
        },
        {
          id: 3,
          reservationNo: 'RES20241218091576',
          parkingId: 3,
          parkingName: '环球影城停车场',
          parkingSpaceId: 312,
          floorName: 'B1',
          spaceNumber: 'E区25号',
          status: 'CANCELLED',
          refundStatus: null,
          startTime: new Date(now.getTime() - 72 * 60 * 60 * 1000), // 3天前
          endTime: new Date(now.getTime() - 69 * 60 * 60 * 1000),   // 69小时前
          actualEntryTime: null,
          actualExitTime: null,
          plateNumber: '京A12345',
          contactPhone: '13800138000',
          vehicleInfo: '小型轿车',
          remark: '临时有事取消',
          createdAt: new Date(now.getTime() - 73 * 60 * 60 * 1000)
        },
        {
          id: 4,
          reservationNo: 'RES20241217164522',
          parkingId: 4,
          parkingName: '王府井停车场',
          parkingSpaceId: 420,
          floorName: 'B3',
          spaceNumber: 'F区05号',
          status: 'TIMEOUT',
          refundStatus: null,
          startTime: new Date(now.getTime() - 96 * 60 * 60 * 1000), // 4天前
          endTime: new Date(now.getTime() - 94 * 60 * 60 * 1000),   // 94小时前
          actualEntryTime: null,
          actualExitTime: null,
          plateNumber: '京A12345',
          contactPhone: '13800138000',
          vehicleInfo: '小型轿车',
          remark: '',
          createdAt: new Date(now.getTime() - 97 * 60 * 60 * 1000)
        }
      ]
    }
    
    // 获取状态样式类
    const getStatusClass = (status) => {
      const statusMap = {
        'PENDING': 'pending',
        'USED': 'used',
        'CANCELLED': 'cancelled',
        'TIMEOUT': 'timeout'
      }
      return statusMap[status] || 'pending'
    }
    
    // 获取状态文本
    const getStatusText = (status) => {
      const statusMap = {
        'PENDING': '待使用',
        'USED': '已使用',
        'CANCELLED': '已取消',
        'TIMEOUT': '已超时'
      }
      return statusMap[status] || '未知'
    }
    
    // 格式化日期时间
    const formatDateTime = (date) => {
      if (!date) return ''
      const d = new Date(date)
      const year = d.getFullYear()
      const month = (d.getMonth() + 1).toString().padStart(2, '0')
      const day = d.getDate().toString().padStart(2, '0')
      const hours = d.getHours().toString().padStart(2, '0')
      const minutes = d.getMinutes().toString().padStart(2, '0')
      return `${year}-${month}-${day} ${hours}:${minutes}`
    }
    
    // 格式化日期时间范围
    const formatDateTimeRange = (startDate, endDate) => {
      return `${formatDateTime(startDate)} - ${formatDateTime(endDate)}`
    }
    
    // 查看预约详情
    const viewReservationDetail = (reservation) => {
      router.push({
        path: '/reservation-detail',
        query: { id: reservation.id }
      })
    }
    
    // 打开取消确认弹窗
    const confirmCancel = (reservation) => {
      selectedReservation.value = reservation
      showCancelConfirm.value = true
    }
    
    // 关闭取消确认弹窗
    const closeCancelConfirm = () => {
      showCancelConfirm.value = false
      selectedReservation.value = null
    }
    
    // 取消预约
    const cancelReservation = async () => {
      if (!selectedReservation.value) return
      
      try {
        loading.value = true
        
        // 在实际项目中，这里应该调用后端API
        // const response = await cancelReservationById(selectedReservation.value.id)
        
        // 模拟API调用
        setTimeout(() => {
          // 更新本地数据
          const index = reservations.value.findIndex(r => r.id === selectedReservation.value.id)
          if (index !== -1) {
            reservations.value[index].status = 'CANCELLED'
          }
          
          showSuccessToast('预约已取消')
          closeCancelConfirm()
          loading.value = false
        }, 1000)
      } catch (err) {
        loading.value = false
        showErrorToast('取消预约失败，请稍后重试')
        console.error('取消预约失败:', err)
      }
    }
    
    // 申请退款
    const applyRefund = async (reservation) => {
      try {
        loading.value = true
        
        // 在实际项目中，这里应该调用后端API
        // const response = await applyRefundById(reservation.id)
        
        // 模拟API调用
        setTimeout(() => {
          // 更新本地数据
          const index = reservations.value.findIndex(r => r.id === reservation.id)
          if (index !== -1) {
            reservations.value[index].refundStatus = 'REFUNDING'
          }
          
          showSuccessToast('退款申请已提交')
          loading.value = false
        }, 1000)
      } catch (err) {
        loading.value = false
        showErrorToast('申请退款失败，请稍后重试')
        console.error('申请退款失败:', err)
      }
    }
    
    // 返回上一页
    const goBack = () => {
      router.push('/')
    }
    
    // 返回首页
    const goToHome = () => {
      router.push('/')
    }
    
    // 生命周期钩子
    onMounted(() => {
      loadReservations()
    })
    
    return {
      loading,
      error,
      reservations,
      showCancelConfirm,
      selectedReservation,
      loadReservations,
      getStatusClass,
      getStatusText,
      formatDateTime,
      formatDateTimeRange,
      viewReservationDetail,
      confirmCancel,
      closeCancelConfirm,
      cancelReservation,
      applyRefund,
      goBack,
      goToHome
    }
  }
}
</script>

<style scoped>
.my-reservations-page {
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

.back-button, .empty-placeholder {
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

.page-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

/* 加载状态 */
.loading-container {
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

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 错误状态 */
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 100px 20px;
  color: #ff4d4f;
}

.error-message {
  margin-bottom: 20px;
  text-align: center;
}

.retry-button {
  padding: 8px 20px;
  background-color: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

/* 空状态 */
.empty-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 100px 20px;
  color: #999;
}

.empty-icon {
  width: 80px;
  height: 80px;
  background-color: #f5f5f5;
  border-radius: 50%;
  margin-bottom: 20px;
  position: relative;
}

.empty-icon::after {
  content: '📝';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 40px;
}

.empty-message {
  margin-bottom: 20px;
}

.go-home-button {
  padding: 8px 20px;
  background-color: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

/* 预约列表 */
.reservation-list {
  padding: 70px 15px 20px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.reservation-card {
  background-color: #fff;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

/* 预约头部 */
.reservation-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.parking-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0 0 5px 0;
}

.space-info {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  color: #666;
}

.reservation-no {
  font-size: 12px;
  color: #999;
}

.status-badge {
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
}

.status-badge.pending {
  background-color: #e6f7ff;
  color: #1890ff;
}

.status-badge.used {
  background-color: #f6ffed;
  color: #52c41a;
}

.status-badge.cancelled {
  background-color: #f5f5f5;
  color: #999;
}

.status-badge.timeout {
  background-color: #fff2e8;
  color: #fa8c16;
}

/* 时间信息 */
.time-info {
  margin-bottom: 12px;
}

.time-item {
  display: flex;
  margin-bottom: 6px;
  font-size: 13px;
}

.time-item:last-child {
  margin-bottom: 0;
}

.time-label {
  color: #666;
  min-width: 80px;
}

.time-value {
  color: #333;
  flex: 1;
}

/* 车辆信息 */
.vehicle-info {
  display: flex;
  margin-bottom: 12px;
  font-size: 13px;
}

.vehicle-label {
  color: #666;
  min-width: 80px;
}

.vehicle-value {
  color: #333;
  flex: 1;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
}

.action-button {
  padding: 6px 16px;
  border-radius: 4px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.detail-button {
  background-color: #f5f5f5;
  color: #666;
  border: 1px solid #d9d9d9;
}

.detail-button:hover {
  background-color: #e6f7ff;
  color: #1890ff;
  border-color: #1890ff;
}

.cancel-button {
  background-color: #fff2e8;
  color: #fa8c16;
  border: 1px solid #ffd591;
}

.cancel-button:hover {
  background-color: #fff1f0;
  color: #ff4d4f;
  border-color: #ffccc7;
}

.refund-button {
  background-color: #f6ffed;
  color: #52c41a;
  border: 1px solid #b7eb8f;
}

.refund-button:hover {
  background-color: #e6f7ff;
  color: #1890ff;
  border-color: #91d5ff;
}

.action-text {
  font-size: 13px;
  color: #999;
}

/* 模态框 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  width: 80%;
  max-width: 300px;
}

.modal-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0 0 10px 0;
  text-align: center;
}

.modal-message {
  font-size: 14px;
  color: #666;
  margin: 0 0 20px 0;
  text-align: center;
}

.modal-actions {
  display: flex;
  gap: 10px;
}

.modal-button {
  flex: 1;
  padding: 8px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.modal-button.cancel {
  background-color: #f5f5f5;
  color: #666;
  border: 1px solid #d9d9d9;
}

.modal-button.confirm {
  background-color: #ff4d4f;
  color: #fff;
}
</style>