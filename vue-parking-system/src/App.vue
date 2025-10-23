<template>
  <div class="app-container">
    <!-- 全局加载指示器 -->
    <Loading v-if="loading" />
    
    <!-- 全局Toast提示 -->
    <Toast />
    
    <!-- 全局对话框 -->
    <Dialog />
    
    <!-- 路由视图容器 -->
    <RouterView />
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Loading from './components/common/Loading.vue'
import Toast from './components/common/Toast.vue'
import Dialog from './components/common/Dialog.vue'
import { useAppStore } from './stores/modules/app'

export default {
  name: 'App',
  components: {
    Loading,
    Toast,
    Dialog
  },
  setup() {
    const router = useRouter()
    const appStore = useAppStore()
    const loading = ref(false)

    // 应用初始化
    onMounted(() => {
      initApp()
    })

    // 初始化应用
    const initApp = async () => {
      loading.value = true
      try {
        // 检查用户登录状态
        await appStore.checkLoginStatus()
        
        // 初始化应用配置
        await appStore.initAppConfig()
      } catch (error) {
        console.error('应用初始化失败:', error)
      } finally {
        loading.value = false
      }
    }

    return {
      loading
    }
  }
}
</script>

<style>
/* 全局样式重置 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  color: #333;
  background-color: #f5f5f5;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#app {
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

.app-container {
  width: 100%;
  height: 100%;
  position: relative;
}

/* 通用样式类 */
.text-center {
  text-align: center;
}

.text-right {
  text-align: right;
}

.mt-10 {
  margin-top: 10px;
}

.mb-10 {
  margin-bottom: 10px;
}
</style>