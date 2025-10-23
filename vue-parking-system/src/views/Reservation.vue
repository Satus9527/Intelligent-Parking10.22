<template>
  <div class="reservation-page">
    <!-- 页面头部 -->
    <div class="header">
      <div class="back-button" @click="goBack">
        <div class="back-icon"></div>
      </div>
      <h1 class="page-title">车位预约</h1>
      <div class="empty-placeholder"></div>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>处理中...</p>
    </div>

    <!-- 内容区域 -->
    <div v-else class="content">
      <!-- 预约信息卡片 -->
      <div class="info-card">
        <h2 class="card-title">预约信息</h2>
        <div class="info-row">
          <span class="info-label">停车场：</span>
          <span class="info-value">{{ parkingName }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">车位信息：</span>
          <span class="info-value">{{ floorName }}-{{ spaceNumber }}</span>
        </div>
      </div>

      <!-- 预约表单 -->
      <div class="form-card">
        <h2 class="card-title">预约详情</h2>
        
        <!-- 预约时间选择 -->
        <div class="form-group">
          <label class="form-label">预约时间</label>
          <div class="time-selector">
            <div class="time-input-group">
              <span class="time-label">开始：</span>
              <input 
                type="datetime-local" 
                v-model="reservationForm.startTime" 
                class="time-input"
                @change="validateTimeRange"
              />
            </div>
            <div class="time-input-group">
              <span class="time-label">结束：</span>
              <input 
                type="datetime-local" 
                v-model="reservationForm.endTime" 
                class="time-input"
                @change="validateTimeRange"
              />
            </div>
          </div>
          <p v-if="timeError" class="error-message">{{ timeError }}</p>
        </div>

        <!-- 车辆信息 -->
        <div class="form-group">
          <label class="form-label">车牌号</label>
          <input 
            type="text" 
            v-model="reservationForm.plateNumber" 
            class="form-input" 
            placeholder="请输入车牌号"
            maxlength="10"
          />
          <p v-if="errors.plateNumber" class="error-message">{{ errors.plateNumber }}</p>
        </div>

        <div class="form-group">
          <label class="form-label">联系电话</label>
          <input 
            type="tel" 
            v-model="reservationForm.contactPhone" 
            class="form-input" 
            placeholder="请输入联系电话"
            maxlength="11"
          />
          <p v-if="errors.contactPhone" class="error-message">{{ errors.contactPhone }}</p>
        </div>

        <div class="form-group">
          <label class="form-label">车辆信息</label>
          <input 
            type="text" 
            v-model="reservationForm.vehicleInfo" 
            class="form-input" 
            placeholder="请输入车型信息（选填）"
          />
        </div>

        <div class="form-group">
          <label class="form-label">备注</label>
          <textarea 
            v-model="reservationForm.remark" 
            class="form-textarea" 
            placeholder="请输入备注信息（选填）"
            rows="3"
          ></textarea>
        </div>
      </div>

      <!-- 费用说明 -->
      <div class="fee-card" v-if="calculatedFee > 0">
        <h2 class="card-title">费用说明</h2>
        <div class="fee-info">
          <span class="fee-label">预估费用：</span>
          <span class="fee-value">¥{{ calculatedFee.toFixed(2) }}</span>
        </div>
        <p class="fee-note">* 费用仅供参考，实际费用以出场时间为准</p>
      </div>
    </div>

    <!-- 底部提交按钮 -->
    <div class="bottom-actions">
      <button 
        class="submit-button" 
        :disabled="!isFormValid || timeError"
        @click="submitReservation"
      >
        确认预约
      </button>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showSuccessToast, showErrorToast } from '../utils'
import { createReservation, checkSpaceAvailability } from '../api/reservation'

export default {
  name: 'Reservation',
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    // 从路由参数获取信息
    const parkingId = ref(route.query.parkingId || '')
    const spaceId = ref(route.query.spaceId || '')
    const parkingName = ref(route.query.parkingName || '未知停车场')
    const spaceNumber = ref(route.query.spaceNumber || '未知车位')
    const floorName = ref(route.query.floorName || '未知楼层')
    
    const loading = ref(false)
    const timeError = ref('')
    
    // 表单数据
    const reservationForm = reactive({
      parkingId: parkingId.value,
      parkingSpaceId: spaceId.value,
      spaceId: spaceId.value, // 兼容后端参数名
      startTime: '',
      endTime: '',
      plateNumber: '',
      contactPhone: '',
      vehicleInfo: '',
      remark: ''
    })
    
    // 表单验证错误
    const errors = reactive({
      plateNumber: '',
      contactPhone: ''
    })
    
    // 计算属性：表单是否有效
    const isFormValid = computed(() => {
      return (
        reservationForm.startTime && 
        reservationForm.endTime && 
        reservationForm.plateNumber && 
        reservationForm.contactPhone &&
        !errors.plateNumber &&
        !errors.contactPhone &&
        !timeError.value
      )
    })
    
    // 计算属性：预估费用（假设每小时10元）
    const calculatedFee = computed(() => {
      if (!reservationForm.startTime || !reservationForm.endTime) {
        return 0
      }
      
      const start = new Date(reservationForm.startTime)
      const end = new Date(reservationForm.endTime)
      const durationHours = (end - start) / (1000 * 60 * 60)
      
      return durationHours > 0 ? durationHours * 10 : 0
    })
    
    // 设置默认预约时间
    const setDefaultTime = () => {
      const now = new Date()
      const startHour = now.getHours()
      const startMinutes = now.getMinutes() < 30 ? 30 : 60
      
      // 设置开始时间为当前时间向上取整到最近的半小时
      const startTime = new Date(now)
      if (startMinutes === 60) {
        startTime.setHours(startHour + 1, 0, 0, 0)
      } else {
        startTime.setMinutes(30, 0, 0)
      }
      
      // 设置结束时间为开始时间后2小时
      const endTime = new Date(startTime)
      endTime.setHours(startTime.getHours() + 2)
      
      // 转换为本地日期时间字符串格式（不含时区）
      reservationForm.startTime = startTime.toISOString().slice(0, 16)
      reservationForm.endTime = endTime.toISOString().slice(0, 16)
    }
    
    // 验证时间范围
    const validateTimeRange = () => {
      timeError.value = ''
      
      if (!reservationForm.startTime || !reservationForm.endTime) {
        return
      }
      
      const start = new Date(reservationForm.startTime)
      const end = new Date(reservationForm.endTime)
      const now = new Date()
      
      // 检查开始时间是否在当前时间之前
      if (start < now) {
        timeError.value = '预约开始时间不能早于当前时间'
        return
      }
      
      // 检查结束时间是否在开始时间之前
      if (end <= start) {
        timeError.value = '预约结束时间必须晚于开始时间'
        return
      }
      
      // 检查预约时长是否超过24小时
      const durationHours = (end - start) / (1000 * 60 * 60)
      if (durationHours > 24) {
        timeError.value = '单次预约时长不能超过24小时'
        return
      }
    }
    
    // 验证表单
    const validateForm = () => {
      // 重置错误信息
      errors.plateNumber = ''
      errors.contactPhone = ''
      
      // 验证车牌号
      if (!reservationForm.plateNumber) {
        errors.plateNumber = '请输入车牌号'
      } else if (!/^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1}$/.test(reservationForm.plateNumber)) {
        errors.plateNumber = '请输入有效的车牌号'
      }
      
      // 验证联系电话
      if (!reservationForm.contactPhone) {
        errors.contactPhone = '请输入联系电话'
      } else if (!/^1[3-9]\d{9}$/.test(reservationForm.contactPhone)) {
        errors.contactPhone = '请输入有效的手机号码'
      }
      
      return !errors.plateNumber && !errors.contactPhone
    }
    
    // 提交预约
    const submitReservation = async () => {
      // 验证表单
      if (!validateForm()) {
        return
      }
      
      // 验证时间
      validateTimeRange()
      if (timeError.value) {
        return
      }
      
      try {
        loading.value = true
        
        // 在实际项目中，这里应该调用后端API
        // const response = await createReservation(reservationForm)
        
        // 模拟API调用成功
        setTimeout(() => {
          loading.value = false
          showSuccessToast('预约成功！')
          
          // 生成模拟的预约编号
          const reservationNo = 'RES' + Date.now()
          
          // 跳转到预约成功页面或预约列表
          router.push({
            path: '/reservation-success',
            query: {
              parkingName: parkingName.value,
              spaceNumber: spaceNumber.value,
              floorName: floorName.value,
              startTime: reservationForm.startTime,
              endTime: reservationForm.endTime,
              reservationNo: reservationNo,
              totalFee: calculatedFee.value
            }
          })
        }, 1500)
      } catch (error) {
        loading.value = false
        showErrorToast(error.message || '预约失败，请稍后重试')
        console.error('预约失败:', error)
      }
    }
    
    // 返回上一页
    const goBack = () => {
      router.back()
    }
    
    // 生命周期钩子
    onMounted(() => {
      setDefaultTime()
    })
    
    return {
      parkingId,
      spaceId,
      parkingName,
      spaceNumber,
      floorName,
      loading,
      reservationForm,
      errors,
      timeError,
      isFormValid,
      calculatedFee,
      validateTimeRange,
      submitReservation,
      goBack
    }
  }
}
</script>

<style scoped>
.reservation-page {
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

/* 内容区域 */
.content {
  padding: 70px 15px 100px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

/* 信息卡片 */
.info-card,
.form-card,
.fee-card {
  background-color: #fff;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.card-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0 0 15px 0;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.info-row {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-label {
  font-size: 14px;
  color: #666;
  min-width: 80px;
}

.info-value {
  font-size: 14px;
  color: #333;
  flex: 1;
}

/* 表单样式 */
.form-group {
  margin-bottom: 20px;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-label {
  display: block;
  font-size: 14px;
  color: #666;
  margin-bottom: 8px;
}

.form-input,
.form-textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
  color: #333;
  transition: border-color 0.3s;
}

.form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: #1890ff;
}

.form-textarea {
  resize: none;
}

.time-selector {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.time-input-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.time-label {
  font-size: 14px;
  color: #666;
  min-width: 40px;
}

.time-input {
  flex: 1;
  padding: 10px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
}

.error-message {
  margin: 5px 0 0;
  font-size: 12px;
  color: #ff4d4f;
}

/* 费用说明 */
.fee-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.fee-label {
  font-size: 14px;
  color: #666;
}

.fee-value {
  font-size: 18px;
  font-weight: bold;
  color: #ff4d4f;
}

.fee-note {
  font-size: 12px;
  color: #999;
  margin: 0;
  text-align: right;
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
}

.submit-button {
  width: 100%;
  padding: 12px;
  background-color: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.3s;
}

.submit-button:hover:not(:disabled) {
  background-color: #40a9ff;
}

.submit-button:disabled {
  background-color: #d9d9d9;
  cursor: not-allowed;
}
</style>