<template>
  <transition name="dialog-fade">
    <div class="dialog-overlay" v-if="visible" @click="handleOverlayClick">
      <transition name="dialog-slide">
        <div class="dialog-container" :class="['dialog-' + size]" @click.stop>
          <!-- 标题 -->
          <div class="dialog-header" v-if="title || showClose">
            <div class="dialog-title" v-if="title">{{ title }}</div>
            <button class="dialog-close" v-if="showClose" @click="handleClose">×</button>
          </div>
          
          <!-- 内容 -->
          <div class="dialog-body">
            <slot></slot>
          </div>
          
          <!-- 底部按钮 -->
          <div class="dialog-footer" v-if="showFooter">
            <button 
              class="dialog-btn dialog-btn-cancel" 
              v-if="showCancelBtn" 
              @click="handleCancel"
              :disabled="loading"
            >
              {{ cancelText }}
            </button>
            <button 
              class="dialog-btn dialog-btn-primary" 
              v-if="showConfirmBtn" 
              @click="handleConfirm"
              :disabled="loading"
            >
              <span v-if="loading" class="dialog-loading"></span>
              {{ confirmText }}
            </button>
          </div>
        </div>
      </transition>
    </div>
  </transition>
</template>

<script>
import { ref, computed } from 'vue'

export default {
  name: 'Dialog',
  props: {
    // 显示状态
    modelValue: {
      type: Boolean,
      default: false
    },
    // 对话框标题
    title: {
      type: String,
      default: ''
    },
    // 对话框大小
    size: {
      type: String,
      default: 'medium',
      validator: (value) => ['small', 'medium', 'large', 'full'].includes(value)
    },
    // 是否显示关闭按钮
    showClose: {
      type: Boolean,
      default: true
    },
    // 是否显示底部
    showFooter: {
      type: Boolean,
      default: true
    },
    // 是否显示取消按钮
    showCancelBtn: {
      type: Boolean,
      default: true
    },
    // 是否显示确认按钮
    showConfirmBtn: {
      type: Boolean,
      default: true
    },
    // 取消按钮文本
    cancelText: {
      type: String,
      default: '取消'
    },
    // 确认按钮文本
    confirmText: {
      type: String,
      default: '确定'
    },
    // 是否点击遮罩关闭
    closeOnClickOverlay: {
      type: Boolean,
      default: true
    },
    // 是否按ESC键关闭
    closeOnPressEscape: {
      type: Boolean,
      default: true
    },
    // 加载状态
    loading: {
      type: Boolean,
      default: false
    }
  },
  emits: ['update:modelValue', 'close', 'cancel', 'confirm'],
  setup(props, { emit }) {
    const visible = computed({
      get: () => props.modelValue,
      set: (value) => emit('update:modelValue', value)
    })
    
    // 处理关闭
    const handleClose = () => {
      visible.value = false
      emit('close')
    }
    
    // 处理取消
    const handleCancel = () => {
      visible.value = false
      emit('cancel')
    }
    
    // 处理确认
    const handleConfirm = () => {
      emit('confirm')
    }
    
    // 处理遮罩点击
    const handleOverlayClick = () => {
      if (props.closeOnClickOverlay) {
        handleClose()
      }
    }
    
    // 处理键盘事件
    const handleKeydown = (event) => {
      if (props.closeOnPressEscape && event.key === 'Escape' && visible.value) {
        handleClose()
      }
    }
    
    return {
      visible,
      handleClose,
      handleCancel,
      handleConfirm,
      handleOverlayClick
    }
  },
  mounted() {
    if (this.closeOnPressEscape) {
      document.addEventListener('keydown', this.handleKeydown)
    }
  },
  beforeUnmount() {
    document.removeEventListener('keydown', this.handleKeydown)
  }
}
</script>

<style scoped>
.dialog-overlay {
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

.dialog-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  width: 500px;
  max-width: 90%;
  max-height: 80vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* 大小变体 */
.dialog-small {
  width: 300px;
}

.dialog-large {
  width: 800px;
}

.dialog-full {
  width: 100%;
  height: 100%;
  max-width: 100%;
  max-height: 100%;
  border-radius: 0;
}

/* 头部 */
.dialog-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid #e9ecef;
}

.dialog-title {
  font-size: 16px;
  font-weight: 500;
  color: #333;
}

.dialog-close {
  background: none;
  border: none;
  font-size: 24px;
  color: #999;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: all 0.3s;
}

.dialog-close:hover {
  background-color: #f5f5f5;
  color: #666;
}

/* 内容 */
.dialog-body {
  padding: 20px;
  overflow-y: auto;
  flex: 1;
}

/* 底部 */
.dialog-footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #e9ecef;
  background-color: #fafafa;
}

/* 按钮 */
.dialog-btn {
  padding: 8px 16px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
  border: 1px solid #d9d9d9;
  background-color: #fff;
  color: #333;
}

.dialog-btn:hover {
  border-color: var(--primary-color, #007bff);
  color: var(--primary-color, #007bff);
}

.dialog-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.dialog-btn-primary {
  background-color: var(--primary-color, #007bff);
  border-color: var(--primary-color, #007bff);
  color: #fff;
}

.dialog-btn-primary:hover {
  background-color: #0056b3;
  border-color: #0056b3;
  color: #fff;
}

/* 加载动画 */
.dialog-loading {
  display: inline-block;
  width: 14px;
  height: 14px;
  border: 2px solid transparent;
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-right: 6px;
  vertical-align: middle;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 动画 */
.dialog-fade-enter-active,
.dialog-fade-leave-active {
  transition: opacity 0.3s ease;
}

.dialog-fade-enter-from,
.dialog-fade-leave-to {
  opacity: 0;
}

.dialog-slide-enter-active,
.dialog-slide-leave-active {
  transition: transform 0.3s ease;
}

.dialog-slide-enter-from {
  transform: scale(0.9);
}

.dialog-slide-leave-to {
  transform: scale(0.9);
}

/* 移动端适配 */
@media (max-width: 575px) {
  .dialog-container {
    width: 100%;
    max-width: 100%;
    height: 100%;
    max-height: 100%;
    border-radius: 0;
  }
  
  .dialog-header {
    padding: 12px 16px;
  }
  
  .dialog-body {
    padding: 16px;
  }
  
  .dialog-footer {
    padding: 12px 16px;
  }
  
  .dialog-title {
    font-size: 15px;
  }
  
  .dialog-btn {
    padding: 6px 12px;
    font-size: 13px;
  }
}
</style>