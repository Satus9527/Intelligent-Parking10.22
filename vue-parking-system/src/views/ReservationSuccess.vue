<template>
  <div class="success-page">
    <!-- 页面头部 -->
    <div class="header">
      <div class="empty-placeholder"></div>
      <h1 class="page-title">预约成功</h1>
      <div class="empty-placeholder"></div>
    </div>

    <!-- 主要内容 -->
    <div class="content">
      <!-- 成功图标 -->
      <div class="success-icon">
        <div class="check-circle">
          <div class="check-mark"></div>
        </div>
        <h2 class="success-title">预约提交成功</h2>
      </div>

      <!-- 预约信息卡片 -->
      <div class="info-card">
        <div class="info-row">
          <span class="info-label">预约编号：</span>
          <span class="info-value">{{ reservationNo }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">停车场：</span>
          <span class="info-value">{{ parkingName }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">车位信息：</span>
          <span class="info-value">{{ floorName }}-{{ spaceNumber }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">开始时间：</span>
          <span class="info-value">{{ formatDateTime(startTime) }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">结束时间：</span>
          <span class="info-value">{{ formatDateTime(endTime) }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">预付费：</span>
          <span class="info-value fee-value">¥{{ totalFee.toFixed(2) }}</span>
        </div>
      </div>

      <!-- 温馨提示 -->
      <div class="tips-card">
        <h3 class="tips-title">温馨提示</h3>
        <ul class="tips-list">
          <li>请在预约时间内到达停车场</li>
          <li>如遇特殊情况，请提前取消预约</li>
          <li>超时未到场，预约将自动取消</li>
          <li>请凭预约编号或车牌号入场</li>
        </ul>
      </div>
    </div>

    <!-- 底部操作按钮 -->
    <div class="bottom-actions">
      <button class="action-button primary-button" @click="viewReservationDetail">
        查看预约详情
      </button>
      <button class="action-button secondary-button" @click="backToHome">
        返回首页
      </button>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'

export default {
  name: 'ReservationSuccess',
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    // 从路由参数获取信息
    const parkingName = ref(route.query.parkingName || '未知停车场')
    const spaceNumber = ref(route.query.spaceNumber || '未知车位')
    const floorName = ref(route.query.floorName || '未知楼层')
    const startTime = ref(route.query.startTime || '')
    const endTime = ref(route.query.endTime || '')
    
    // 生成预约编号（实际项目中应由后端生成）
    const reservationNo = ref(generateReservationNo())
    
    // 计算费用（假设每小时10元）
    const totalFee = computed(() => {
      if (!startTime.value || !endTime.value) {
        return 0
      }
      
      const start = new Date(startTime.value)
      const end = new Date(endTime.value)
      const durationHours = (end - start) / (1000 * 60 * 60)
      
      return durationHours > 0 ? durationHours * 10 : 0
    })
    
    // 生成预约编号
    function generateReservationNo() {
      const date = new Date()
      const year = date.getFullYear().toString().substr(2)
      const month = String(date.getMonth() + 1).padStart(2, '0')
      const day = String(date.getDate()).padStart(2, '0')
      const hour = String(date.getHours()).padStart(2, '0')
      const minute = String(date.getMinutes()).padStart(2, '0')
      const second = String(date.getSeconds()).padStart(2, '0')
      const random = String(Math.floor(Math.random() * 1000)).padStart(3, '0')
      
      return `Y${year}${month}${day}${hour}${minute}${second}${random}`
    }
    
    // 格式化日期时间
    function formatDateTime(dateTimeStr) {
      if (!dateTimeStr) return ''
      
      const date = new Date(dateTimeStr)
      const year = date.getFullYear()
      const month = String(date.getMonth() + 1).padStart(2, '0')
      const day = String(date.getDate()).padStart(2, '0')
      const hour = String(date.getHours()).padStart(2, '0')
      const minute = String(date.getMinutes()).padStart(2, '0')
      
      return `${year}-${month}-${day} ${hour}:${minute}`
    }
    
    // 查看预约详情
    const viewReservationDetail = () => {
      router.push({
        path: '/reservation-detail',
        query: { reservationNo: reservationNo.value }
      })
    }
    
    // 返回首页
    const backToHome = () => {
      router.push('/')
    }
    
    return {
      parkingName,
      spaceNumber,
      floorName,
      startTime,
      endTime,
      reservationNo,
      totalFee,
      formatDateTime,
      viewReservationDetail,
      backToHome
    }
  }
}
</script>

<style scoped>
.success-page {
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

.empty-placeholder {
  width: 30px;
  height: 30px;
}

.page-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

/* 内容区域 */
.content {
  padding: 70px 15px 120px;
  display: flex;
  flex-direction: column;
  gap: 15px;
  align-items: center;
}

/* 成功图标 */
.success-icon {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 20px;
}

.check-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background-color: #52c41a;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 15px;
}

.check-mark {
  width: 20px;
  height: 10px;
  border-left: 3px solid #fff;
  border-bottom: 3px solid #fff;
  transform: rotate(-45deg);
  margin-bottom: 5px;
  margin-left: -5px;
}

.success-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

/* 信息卡片 */
.info-card, .tips-card {
  width: 100%;
  background-color: #fff;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.info-row {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-label {
  font-size: 14px;
  color: #666;
  min-width: 90px;
}

.info-value {
  font-size: 14px;
  color: #333;
  flex: 1;
}

.fee-value {
  color: #ff4d4f;
  font-weight: bold;
  font-size: 16px;
}

/* 提示卡片 */
.tips-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0 0 15px 0;
}

.tips-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.tips-list li {
  font-size: 14px;
  color: #666;
  padding-left: 16px;
  position: relative;
  margin-bottom: 8px;
}

.tips-list li:last-child {
  margin-bottom: 0;
}

.tips-list li:before {
  content: '•';
  position: absolute;
  left: 0;
  color: #1890ff;
}

/* 底部操作按钮 */
.bottom-actions {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: #fff;
  padding: 15px;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.action-button {
  width: 100%;
  padding: 12px;
  border-radius: 4px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.primary-button {
  background-color: #1890ff;
  color: #fff;
}

.primary-button:hover {
  background-color: #40a9ff;
}

.secondary-button {
  background-color: #fff;
  color: #1890ff;
  border: 1px solid #1890ff;
}

.secondary-button:hover {
  background-color: #f0f9ff;
}
</style>