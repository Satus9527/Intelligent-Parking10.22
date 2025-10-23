<template>
  <div class="loading-overlay" v-if="visible">
    <div class="loading-container">
      <div class="loading-spinner"></div>
      <div class="loading-text" v-if="text">{{ text }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Loading',
  props: {
    visible: {
      type: Boolean,
      default: true
    },
    text: {
      type: String,
      default: '加载中...'
    },
    fullscreen: {
      type: Boolean,
      default: true
    }
  }
}
</script>

<style scoped>
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.loading-container {
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  min-width: 120px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  margin: 0 auto 10px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid var(--primary-color, #007bff);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.loading-text {
  font-size: 14px;
  color: #666;
  margin-top: 10px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 非全屏模式 */
.loading-overlay:not(.fullscreen) {
  position: absolute;
  background-color: rgba(255, 255, 255, 0.8);
}

/* 小型加载动画 */
.loading-container.small {
  padding: 10px;
  min-width: auto;
  background-color: transparent;
  box-shadow: none;
}

.loading-container.small .loading-spinner {
  width: 20px;
  height: 20px;
  margin: 0;
}

.loading-container.small .loading-text {
  display: none;
}
</style>