<template>
  <div class="home">
    <!-- 顶部搜索栏 -->
    <div class="search-bar">
      <div class="search-input">
        <i class="icon-search"></i>
        <input type="text" placeholder="搜索附近停车场" v-model="searchQuery" @focus="navigateToSearch">
      </div>
    </div>
    
    <!-- 轮播图 -->
    <div class="banner">
      <div class="swiper-container">
        <div class="swiper-slide" v-for="(item, index) in banners" :key="index">
          <img :src="item.image" :alt="item.title">
        </div>
      </div>
      <div class="banner-indicators">
        <span v-for="(item, index) in banners" :key="index" :class="{ active: currentBannerIndex === index }"></span>
      </div>
    </div>
    
    <!-- 功能入口 -->
    <div class="function-entry">
      <div class="function-item" @click="navigateToParkingList">
        <div class="icon-parking"></div>
        <span>停车场</span>
      </div>
      <div class="function-item" @click="navigateToRealTimeSpaces">
        <div class="icon-spaces"></div>
        <span>实时车位</span>
      </div>
      <div class="function-item" @click="navigateToReservation">
        <div class="icon-reservation"></div>
        <span>我的预约</span>
      </div>
      <div class="function-item" @click="navigateToMy">
        <div class="icon-my"></div>
        <span>个人中心</span>
      </div>
    </div>
    
    <!-- 推荐停车场 -->
    <div class="recommended-parking">
      <div class="section-header">
        <h3>推荐停车场</h3>
        <span class="more" @click="navigateToParkingList">查看更多 ></span>
      </div>
      
      <div class="parking-list">
        <div class="parking-item" v-for="parking in recommendedParkings" :key="parking.id" @click="navigateToParkingDetail(parking.id)">
          <div class="parking-info">
            <h4>{{ parking.name }}</h4>
            <p class="address">{{ parking.address }}</p>
            <div class="meta-info">
              <span class="price">¥{{ parking.pricePerHour }}/小时</span>
              <span class="distance">{{ parking.distance }}m</span>
            </div>
            <div class="status">
              <span class="available-spaces">剩余车位：{{ parking.availableSpaces }}</span>
              <span class="status-tag" :class="parking.status === 'open' ? 'open' : 'closed'">{{ parking.status === 'open' ? '营业中' : '已关闭' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 底部导航栏 -->
    <div class="tab-bar">
      <div class="tab-item active" @click="navigateToHome">
        <div class="tab-icon home-icon-active"></div>
        <span>首页</span>
      </div>
      <div class="tab-item" @click="navigateToParkingList">
        <div class="tab-icon parking-icon"></div>
        <span>停车场</span>
      </div>
      <div class="tab-item" @click="navigateToSpaces">
        <div class="tab-icon spaces-icon"></div>
        <span>车位</span>
      </div>
      <div class="tab-item" @click="navigateToMy">
        <div class="tab-icon my-icon"></div>
        <span>我的</span>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showLoading, hideLoading, showErrorToast } from '../utils'
import { fetchRecommendedParkings } from '../api/parking'

export default {
  name: 'Home',
  setup() {
    const router = useRouter()
    const searchQuery = ref('')
    const banners = ref([
      { id: 1, image: '/images/banner1.jpg', title: '欢迎使用智能停车系统' },
      { id: 2, image: '/images/banner2.jpg', title: '预约车位享优惠' },
      { id: 3, image: '/images/banner3.jpg', title: '新用户注册送停车券' }
    ])
    const currentBannerIndex = ref(0)
    const recommendedParkings = ref([])
    
    // 获取推荐停车场数据
    const loadRecommendedParkings = async () => {
      try {
        showLoading()
        const response = await fetchRecommendedParkings()
        if (response.code === 200) {
          recommendedParkings.value = response.data
        } else {
          showErrorToast(response.message || '获取推荐停车场失败')
        }
      } catch (error) {
        showErrorToast('网络错误，请稍后重试')
        console.error('获取推荐停车场失败:', error)
      } finally {
        hideLoading()
      }
    }
    
    // 导航到搜索页面
    const navigateToSearch = () => {
      router.push('/search')
    }
    
    // 导航到停车场列表
    const navigateToParkingList = () => {
      router.push('/parking-list')
    }
    
    // 导航到停车场详情
    const navigateToParkingDetail = (parkingId) => {
      router.push(`/parking-detail/${parkingId}`)
    }
    
    // 导航到实时车位页面
    const navigateToRealTimeSpaces = () => {
      router.push('/real-time-spaces')
    }
    
    // 导航到预约页面
    const navigateToReservation = () => {
      router.push('/my-reservations')
    }
    
    // 导航到我的预约页面（快捷入口）
    const goToMyReservations = () => {
      router.push('/my-reservations')
    }
    
    // 导航到个人中心
    const navigateToMy = () => {
      router.push('/my')
    }
    
    // 导航到车位页面
    const navigateToSpaces = () => {
      router.push('/spaces')
    }
    
    // 导航到首页
    const navigateToHome = () => {
      router.push('/')
    }
    
    // 初始化轮播图
    const initBanner = () => {
      // 这里可以添加轮播图的自动播放逻辑
      setInterval(() => {
        currentBannerIndex.value = (currentBannerIndex.value + 1) % banners.value.length
      }, 3000)
    }
    
    onMounted(() => {
      loadRecommendedParkings()
      initBanner()
    })
    
    return {
      searchQuery,
      banners,
      currentBannerIndex,
      recommendedParkings,
      navigateToSearch,
      navigateToParkingList,
      navigateToParkingDetail,
      navigateToRealTimeSpaces,
      navigateToReservation,
      navigateToMy,
      navigateToSpaces,
      navigateToHome,
      goToMyReservations
    }
  }
}
</script>

<style scoped>
.home {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding-bottom: 60px;
}

/* 搜索栏样式 */
.search-bar {
  padding: 10px;
  background-color: #fff;
  position: sticky;
  top: 0;
  z-index: 10;
}

.search-input {
  display: flex;
  align-items: center;
  background-color: #f5f5f5;
  border-radius: 20px;
  padding: 8px 15px;
}

.search-input .icon-search {
  width: 20px;
  height: 20px;
  background-color: #999;
  margin-right: 10px;
  border-radius: 50%;
}

.search-input input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 14px;
  color: #333;
}

.search-input input::placeholder {
  color: #999;
}

/* 轮播图样式 */
.banner {
  position: relative;
  height: 180px;
  background-color: #fff;
}

.swiper-container {
  height: 100%;
}

.swiper-slide img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.banner-indicators {
  position: absolute;
  bottom: 10px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 6px;
}

.banner-indicators span {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.6);
}

.banner-indicators span.active {
  background-color: #fff;
  width: 20px;
  border-radius: 3px;
}

/* 功能入口样式 */
.function-entry {
  display: flex;
  justify-content: space-around;
  padding: 20px 0;
  background-color: #fff;
  margin-bottom: 10px;
}

.function-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.function-item > div {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background-color: #e6f7ff;
  margin-bottom: 8px;
}

.function-item:nth-child(2) > div {
  background-color: #f0f9ff;
}

.function-item:nth-child(3) > div {
  background-color: #fff7e6;
}

.function-item:nth-child(4) > div {
  background-color: #f6ffed;
}

.function-item span {
  font-size: 12px;
  color: #333;
}

/* 推荐停车场样式 */
.recommended-parking {
  background-color: #fff;
  padding: 15px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.section-header h3 {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.section-header .more {
  font-size: 14px;
  color: #999;
}

.parking-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.parking-item {
  padding: 12px;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.parking-info h4 {
  font-size: 15px;
  color: #333;
  margin: 0 0 8px 0;
}

.parking-info .address {
  font-size: 13px;
  color: #666;
  margin: 0 0 10px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.meta-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.meta-info .price {
  font-size: 14px;
  color: #ff4d4f;
  font-weight: bold;
}

.meta-info .distance {
  font-size: 14px;
  color: #999;
}

.status {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.status .available-spaces {
  font-size: 13px;
  color: #666;
}

.status-tag {
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 12px;
}

.status-tag.open {
  background-color: #f6ffed;
  color: #52c41a;
}

.status-tag.closed {
  background-color: #f5f5f5;
  color: #999;
}

/* 底部导航栏样式 */
.tab-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 50px;
  background-color: #fff;
  display: flex;
  justify-content: space-around;
  align-items: center;
  border-top: 1px solid #e8e8e8;
  z-index: 100;
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #999;
}

.tab-item.active {
  color: #1890ff;
}

.tab-icon {
  width: 24px;
  height: 24px;
  margin-bottom: 4px;
  background-color: #999;
}

.tab-item.active .tab-icon {
  background-color: #1890ff;
}

.tab-item span {
  font-size: 12px;
}

/* 快捷入口图标 */
.icon-realtime:before { content: '📍'; }
.icon-reservation:before { content: '📝'; }
.icon-my:before { content: '👤'; }

.reservation-icon {
  background-color: #fff2e8;
  color: #fa8c16;
}
.reservation-icon:before { content: '📝'; }
</style>