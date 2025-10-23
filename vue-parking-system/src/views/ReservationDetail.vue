<template>
  <div class="reservation-detail-page">
    <!-- 页面头部 -->
    <div class="header">
      <div class="back-button" @click="goBack">
        <div class="back-icon"></div>
      </div>
      <h1 class="page-title">预约详情</h1>
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
      <button class="retry-button" @click="loadReservationDetail">重试</button>
    </div>

    <!-- 预约详情内容 -->
    <div v-else-if="reservation" class="reservation-content">
      <!-- 状态卡片 -->
      <div class="status-card" :class="getStatusClass(reservation.status)">
        <div class="status-icon">{{ getStatusIcon(reservation.status) }}</div>
        <div class="status-info">
          <h2 class="status-title">{{ getStatusText(reservation.status) }}</h2>
          <p class="status-desc">{{ getStatusDescription(reservation.status) }}</p>
        </div>
      </div>

      <!-- 预约编号 -->
      <div class="detail-card">
        <div class="detail-header">
          <h3 class="detail-title">预约信息</h3>
        </div>
        <div class="detail-item">
          <span class="detail-label">预约编号：</span>
          <span class="detail-value">{{ reservation.reservationNo }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">预约时间：</span>
          <span class="detail-value">{{ formatDateTime(reservation.createdAt) }}</span>
        </div>
        <div v-if="reservation.remark" class="detail-item">
          <span class="detail-label">备注：</span>
          <span class="detail-value">{{ reservation.remark }}</span>
        </div>
      </div>

      <!-- 停车信息 -->
      <div class="detail-card">
        <div class="detail-header">
          <h3 class="detail-title">停车信息</h3>
        </div>
        <div class="detail-item">
          <span class="detail-label">停车场：</span>
          <span class="detail-value">{{ reservation.parkingName }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">车位位置：</span>
          <span class="detail-value">{{ reservation.floorName }}-{{ reservation.spaceNumber }}</span>
        </div>
      </div>

      <!-- 预约时间 -->
      <div class="detail-card">
        <div class="detail-header">
          <h3 class="detail-title">预约时间</h3>
        </div>
        <div class="detail-item">
          <span class="detail-label">开始时间：</span>
          <span class="detail-value">{{ formatDateTime(reservation.startTime) }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">结束时间：</span>
          <span class="detail-value">{{ formatDateTime(reservation.endTime) }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">预约时长：</span>
          <span class="detail-value">{{ calculateDuration(reservation.startTime, reservation.endTime) }}</span>
        </div>
      </div>

      <!-- 实际停车时间 -->
      <div v-if="reservation.actualEntryTime" class="detail-card">
        <div class="detail-header">
          <h3 class="detail-title">实际停车记录</h3>
        </div>
        <div class="detail-item">
          <span class="detail-label">入场时间：</span>
          <span class="detail-value">{{ formatDateTime(reservation.actualEntryTime) }}</span>
        </div>
        <div v-if="reservation.actualExitTime" class="detail-item">
          <span class="detail-label">出场时间：</span>
          <span class="detail-value">{{ formatDateTime(reservation.actualExitTime) }}</span>
        </div>
        <div v-if="reservation.actualEntryTime && reservation.actualExitTime" class="detail-item">
          <span class="detail-label">实际时长：</span>
          <span class="detail-value">{{ calculateDuration(reservation.actualEntryTime, reservation.actualExitTime) }}</span>
        </div>
      </div>

      <!-- 车辆信息 -->
      <div class="detail-card">
        <div class="detail-header">
          <h3 class="detail-title">车辆信息</h3>
        </div>
        <div class="detail-item">
          <span class="detail-label">车牌号：</span>
          <span class="detail-value">{{ reservation.plateNumber }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">车辆类型：</span>
          <span class="detail-value">{{ reservation.vehicleInfo }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">联系电话：</span>
          <span class="detail-value">{{ reservation.contactPhone }}</span>
        </div>
      </div>

      <!-- 退款信息 -->
      <div v-if="reservation.refundStatus" class="detail-card">
        <div class="detail-header">
          <h3 class="detail-title">退款信息</h3>
        </div>
        <div class="detail-item">
          <span class="detail-label">退款状态：</span>
          <span class="detail-value refund-status" :class="getRefundStatusClass(reservation.refundStatus)">
            {{ getRefundStatusText(reservation.refundStatus) }}
          </span>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <button 
          v-if="reservation.status === 'PENDING'" 
          class="action-button primary cancel-button" 
          @click="confirmCancel"
        >
          取消预约
        </button>
        <button 
          v-if="reservation.status === 'CANCELLED' && !reservation.refundStatus" 
          class="action-button primary refund-button" 
          @click="applyRefund"
        >
          申请退款
        </button>
        <button 
          v-if="reservation.status === 'USED'" 
          class="action-button primary review-button" 
          @click="goToReview"
        >
          评价停车体验
        </button>
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

    <!-- 退款确认弹窗 -->
    <div v-if="showRefundConfirm" class="modal-overlay" @click="closeRefundConfirm">
      <div class="modal-content" @click.stop>
        <h3 class="modal-title">申请退款</h3>
        <p class="modal-message">确定要申请退款吗？退款将在1-3个工作日内退回原支付账户。</p>
        <div class="modal-actions">
          <button class="modal-button cancel" @click="closeRefundConfirm">取消</button>
          <button class="modal-button confirm" @click="submitRefund">确认</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showSuccessToast, showErrorToast } from '../utils'

export default {
  name: 'ReservationDetail',
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const loading = ref(false)
    const error = ref('')
    const reservation = ref(null)
    const showCancelConfirm = ref(false)
    const showRefundConfirm = ref(false)
    
    // 加载预约详情
    const loadReservationDetail = async () => {
      const reservationId = route.query.id
      
      if (!reservationId) {
        error.value = '未找到预约信息'
        return
      }
      
      try {
        loading.value = true
        error.value = ''
        
        // 在实际项目中，这里应该调用后端API
        // const response = await getReservationDetail(reservationId)
        
        // 模拟API调用和数据
        setTimeout(() => {
          reservation.value = generateMockReservation(reservationId)
          loading.value = false
        }, 1000)
      } catch (err) {
        loading.value = false
        error.value = '加载预约详情失败，请稍后重试'
        console.error('加载预约详情失败:', err)
      }
    }
    
    // 生成模拟预约数据
    const generateMockReservation = (id) => {
      const now = new Date()
      const tomorrow = new Date(now)
      tomorrow.setDate(tomorrow.getDate() + 1)
      
      // 模拟根据不同ID返回不同状态的预约
      const mockReservations = {
        '1': {
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
        '2': {
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
        '3': {
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
        }
      }
      
      return mockReservations[id] || mockReservations['1']
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
    
    // 获取状态图标
    const getStatusIcon = (status) => {
      const iconMap = {
        'PENDING': '⏰',
        'USED': '✅',
        'CANCELLED': '❌',
        'TIMEOUT': '⏱️'
      }
      return iconMap[status] || '❓'
    }
    
    // 获取状态文本
    const getStatusText = (status) => {
      const statusMap = {
        'PENDING': '待使用',
        'USED': '已使用',
        'CANCELLED': '已取消',
        'TIMEOUT': '已超时'
      }
      return statusMap[status] || '未知状态'
    }
    
    // 获取状态描述
    const getStatusDescription = (status) => {
      const descMap = {
        'PENDING': '请在预约时间内到达停车场',
        'USED': '感谢您的使用',
        'CANCELLED': '预约已取消',
        'TIMEOUT': '预约已超时'
      }
      return descMap[status] || ''
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
    
    // 计算时长
    const calculateDuration = (startDate, endDate) => {
      if (!startDate || !endDate) return ''
      
      const start = new Date(startDate)
      const end = new Date(endDate)
      const durationMs = end - start
      
      const hours = Math.floor(durationMs / (1000 * 60 * 60))
      const minutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60))
      
      if (hours > 0) {
        return `${hours}小时${minutes > 0 ? minutes + '分钟' : ''}`
      } else {
        return `${minutes}分钟`
      }
    }
    
    // 获取退款状态样式
    const getRefundStatusClass = (status) => {
      const statusMap = {
        'REFUNDING': 'refunding',
        'REFUNDED': 'refunded',
        'FAILED': 'failed'
      }
      return statusMap[status] || ''
    }
    
    // 获取退款状态文本
    const getRefundStatusText = (status) => {
      const statusMap = {
        'REFUNDING': '退款处理中',
        'REFUNDED': '退款成功',
        'FAILED': '退款失败'
      }
      return statusMap[status] || '未知状态'
    }
    
    // 打开取消确认弹窗
    const confirmCancel = () => {
      showCancelConfirm.value = true
    }
    
    // 关闭取消确认弹窗
    const closeCancelConfirm = () => {
      showCancelConfirm.value = false
    }
    
    // 取消预约
    const cancelReservation = async () => {
      if (!reservation.value) return
      
      try {
        loading.value = true
        
        // 在实际项目中，这里应该调用后端API
        // const response = await cancelReservationById(reservation.value.id)
        
        // 模拟API调用
        setTimeout(() => {
          reservation.value.status = 'CANCELLED'
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
    
    // 打开退款确认弹窗
    const applyRefund = () => {
      showRefundConfirm.value = true
    }
    
    // 关闭退款确认弹窗
    const closeRefundConfirm = () => {
      showRefundConfirm.value = false
    }
    
    // 提交退款申请
    const submitRefund = async () => {
      if (!reservation.value) return
      
      try {
        loading.value = true
        
        // 在实际项目中，这里应该调用后端API
        // const response = await submitRefundApplication(reservation.value.id)
        
        // 模拟API调用
        setTimeout(() => {
          reservation.value.refundStatus = 'REFUNDING'
          showSuccessToast('退款申请已提交')
          closeRefundConfirm()
          loading.value = false
        }, 1000)
      } catch (err) {
        loading.value = false
        showErrorToast('提交退款申请失败，请稍后重试')
        console.error('提交退款申请失败:', err)
      }
    }
    
    // 去评价
    const goToReview = () => {
      // 在实际项目中，这里应该跳转到评价页面
      showSuccessToast('评价功能即将上线')
    }
    
    // 返回上一页
    const goBack = () => {
      router.back()
    }
    
    // 生命周期钩子
    onMounted(() => {
      loadReservationDetail()
    })
    
    return {
      loading,
      error,
      reservation,
      showCancelConfirm,
      showRefundConfirm,
      loadReservationDetail,
      getStatusClass,
      getStatusIcon,
      getStatusText,
      getStatusDescription,
      formatDateTime,
      calculateDuration,
      getRefundStatusClass,
      getRefundStatusText,
      confirmCancel,
      closeCancelConfirm,
      cancelReservation,
      applyRefund,
      closeRefundConfirm,
      submitRefund,
      goToReview,
      goBack
    }
  }
}
</script>

<style scoped>
.reservation-detail-page {
  min-height: 100vh;
  background-color: #f5f5f5;
  position: relative;
  padding-bottom: 80px;
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

/* 预约内容 */
.reservation-content {
  padding: 70px 15px 0;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

/* 状态卡片 */
.status-card {
  display: flex;
  align-items: center;
  padding: 20px;
  border-radius: 12px;
  color: #fff;
}

.status-card.pending {
  background: linear-gradient(135deg, #1890ff, #52c41a);
}

.status-card.used {
  background: linear-gradient(135deg, #52c41a, #73d13d);
}

.status-card.cancelled {
  background: linear-gradient(135deg, #999, #d9d9d9);
}

.status-card.timeout {
  background: linear-gradient(135deg, #fa8c16, #ffa940);
}

.status-icon {
  font-size: 48px;
  margin-right: 20px;
}

.status-info {
  flex: 1;
}

.status-title {
  font-size: 20px;
  font-weight: bold;
  margin: 0 0 5px 0;
}

.status-desc {
  font-size: 14px;
  margin: 0;
  opacity: 0.9;
}

/* 详情卡片 */
.detail-card {
  background-color: #fff;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.detail-header {
  margin-bottom: 12px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.detail-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.detail-item {
  display: flex;
  margin-bottom: 10px;
  font-size: 14px;
  line-height: 1.5;
}

.detail-item:last-child {
  margin-bottom: 0;
}

.detail-label {
  color: #666;
  min-width: 80px;
}

.detail-value {
  color: #333;
  flex: 1;
  word-break: break-all;
}

.refund-status.refunding {
  color: #1890ff;
}

.refund-status.refunded {
  color: #52c41a;
}

.refund-status.failed {
  color: #ff4d4f;
}

/* 操作按钮 */
.action-buttons {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: #fff;
  padding: 15px;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  gap: 10px;
}

.action-button {
  flex: 1;
  padding: 12px;
  border-radius: 4px;
  font-size: 15px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.action-button.primary {
  background-color: #1890ff;
  color: #fff;
}

.action-button.cancel-button {
  background-color: #ff4d4f;
}

.action-button.refund-button {
  background-color: #fa8c16;
}

.action-button.review-button {
  background-color: #52c41a;
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
  line-height: 1.5;
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

.modal-button.confirm.refund {
  background-color: #fa8c16;
}
</style>