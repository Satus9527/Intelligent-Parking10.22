<template>
  <transition name="toast-fade">
    <div v-if="visible" class="toast" :class="['toast-' + type]">
      <div class="toast-content">
        <i class="toast-icon" :class="iconClass"></i>
        <span class="toast-message">{{ message }}</span>
      </div>
    </div>
  </transition>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue'

export default {
  name: 'Toast',
  setup() {
    const visible = ref(false)
    const message = ref('')
    const type = ref('info')
    const duration = ref(3000)
    let timer = null
    
    // 计算图标类名
    const iconClass = computed(() => {
      const iconMap = {
        success: 'toast-icon-success',
        error: 'toast-icon-error',
        warning: 'toast-icon-warning',
        info: 'toast-icon-info'
      }
      return iconMap[type.value] || 'toast-icon-info'
    })
    
    // 显示Toast
    const show = (msg, toastType = 'info', toastDuration = 3000) => {
      message.value = msg
      type.value = toastType
      duration.value = toastDuration
      visible.value = true
      
      // 清除之前的定时器
      if (timer) {
        clearTimeout(timer)
      }
      
      // 设置定时器自动隐藏
      timer = setTimeout(() => {
        visible.value = false
      }, duration.value)
    }
    
    // 隐藏Toast
    const hide = () => {
      visible.value = false
      if (timer) {
        clearTimeout(timer)
        timer = null
      }
    }
    
    // 暴露全局方法到window对象
    onMounted(() => {
      window.$toast = {
        show,
        hide,
        success: (msg, dur = 3000) => show(msg, 'success', dur),
        error: (msg, dur = 3000) => show(msg, 'error', dur),
        warning: (msg, dur = 3000) => show(msg, 'warning', dur),
        info: (msg, dur = 3000) => show(msg, 'info', dur)
      }
    })
    
    // 清理定时器
    onUnmounted(() => {
      if (timer) {
        clearTimeout(timer)
      }
    })
    
    return {
      visible,
      message,
      type,
      iconClass
    }
  }
}
</script>

<style scoped>
.toast {
  position: fixed;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 20px;
  border-radius: 8px;
  background-color: rgba(0, 0, 0, 0.7);
  color: #fff;
  z-index: 9999;
  max-width: 80%;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.toast-success {
  background-color: rgba(40, 167, 69, 0.9);
}

.toast-error {
  background-color: rgba(220, 53, 69, 0.9);
}

.toast-warning {
  background-color: rgba(255, 193, 7, 0.9);
  color: #333;
}

.toast-info {
  background-color: rgba(0, 123, 255, 0.9);
}

.toast-content {
  display: flex;
  align-items: center;
  gap: 8px;
}

.toast-icon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.toast-message {
  font-size: 14px;
  line-height: 1.5;
  word-break: break-word;
}

/* 动画 */
.toast-fade-enter-active,
.toast-fade-leave-active {
  transition: all 0.3s ease;
}

.toast-fade-enter-from {
  opacity: 0;
  transform: translate(-50%, -20px);
}

.toast-fade-leave-to {
  opacity: 0;
  transform: translate(-50%, -20px);
}

/* 移动端适配 */
@media (max-width: 575px) {
  .toast {
    top: 10px;
    padding: 10px 16px;
  }
  
  .toast-message {
    font-size: 13px;
  }
}
</style>

<style>
/* 图标样式 */
.toast-icon-success::before {
  content: '✓';
  font-size: 16px;
  font-weight: bold;
}

.toast-icon-error::before {
  content: '✕';
  font-size: 16px;
  font-weight: bold;
}

.toast-icon-warning::before {
  content: '!';
  font-size: 16px;
  font-weight: bold;
}

.toast-icon-info::before {
  content: 'ℹ';
  font-size: 16px;
  font-weight: bold;
}
</style>