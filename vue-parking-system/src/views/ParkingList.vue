<template>
  <div class="parking-list">
    <!-- 顶部搜索栏 -->
    <div class="search-header">
      <div class="search-input">
        <i class="icon-search"></i>
        <input type="text" placeholder="搜索停车场名称或地址" v-model="searchQuery" @input="handleSearch">
      </div>
    </div>
    
    <!-- 筛选条件 -->
    <div class="filter-section">
      <div class="filter-tabs">
        <div class="filter-tab" :class="{ active: activeFilter === 'all' }" @click="setFilter('all')">全部</div>
        <div class="filter-tab" :class="{ active: activeFilter === 'nearby' }" @click="setFilter('nearby')">附近</div>
        <div class="filter-tab" :class="{ active: activeFilter === 'price' }" @click="setFilter('price')">价格</div>
        <div class="filter-tab" :class="{ active: activeFilter === 'spaces' }" @click="setFilter('spaces')">车位</div>
      </div>
      
      <!-- 筛选面板 -->
      <div class="filter-panel" v-if="showFilterPanel">
        <div v-if="activeFilter === 'nearby'" class="filter-content">
          <div class="filter-item" @click="setDistanceFilter(1)">1公里内</div>
          <div class="filter-item" @click="setDistanceFilter(3)">3公里内</div>
          <div class="filter-item" @click="setDistanceFilter(5)">5公里内</div>
          <div class="filter-item" @click="setDistanceFilter(10)">10公里内</div>
        </div>
        
        <div v-if="activeFilter === 'price'" class="filter-content">
          <div class="filter-item" @click="setPriceFilter('asc')">价格从低到高</div>
          <div class="filter-item" @click="setPriceFilter('desc')">价格从高到低</div>
        </div>
        
        <div v-if="activeFilter === 'spaces'" class="filter-content">
          <div class="filter-item" @click="setSpacesFilter('all')">全部</div>
          <div class="filter-item" @click="setSpacesFilter('available')">有可用车位</div>
          <div class="filter-item" @click="setSpacesFilter('more')">10个以上</div>
        </div>
      </div>
    </div>
    
    <!-- 停车场列表 -->
    <div class="parkings-container">
      <div v-if="loading" class="loading-container">
        <div class="loading-spinner"></div>
        <p>加载中...</p>
      </div>
      
      <div v-else-if="parkings.length === 0" class="empty-container">
        <div class="empty-icon"></div>
        <p>暂无符合条件的停车场</p>
      </div>
      
      <div v-else class="parkings-list">
        <div class="parking-item" v-for="parking in parkings" :key="parking.id" @click="navigateToDetail(parking.id)">
          <div class="parking-image">
            <img :src="parking.imageUrl || '/images/parking-placeholder.jpg'" :alt="parking.name">
          </div>
          <div class="parking-info">
            <div class="parking-header">
              <h4>{{ parking.name }}</h4>
              <div class="parking-tags">
                <span v-if="parking.hasReservation" class="tag-reservation">可预约</span>
                <span v-if="parking.hasCharge" class="tag-charge">充电桩</span>
              </div>
            </div>
            
            <p class="address">{{ parking.address }}</p>
            
            <div class="parking-meta">
              <div class="meta-item">
                <span class="label">价格：</span>
                <span class="value price">¥{{ parking.pricePerHour }}/小时</span>
              </div>
              <div class="meta-item">
                <span class="label">距离：</span>
                <span class="value distance">{{ formatDistance(parking.distance) }}</span>
              </div>
            </div>
            
            <div class="parking-footer">
              <div class="spaces-info">
                <span class="label">剩余车位：</span>
                <span class="value" :class="parking.availableSpaces > 0 ? 'available' : 'unavailable'">
                  {{ parking.availableSpaces }}
                </span>
              </div>
              <div class="status" :class="parking.status === 'open' ? 'open' : 'closed'">
                {{ parking.status === 'open' ? '营业中' : '已关闭' }}
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 上拉加载提示 -->
      <div v-if="!loading && parkings.length > 0 && !noMoreData" class="load-more" @click="loadMore">
        <span>加载更多</span>
      </div>
      
      <div v-if="!loading && noMoreData && parkings.length > 0" class="no-more">
        <span>没有更多数据了</span>
      </div>
    </div>
    
    <!-- 底部导航栏 -->
    <div class="tab-bar">
      <div class="tab-item" @click="navigateToHome">
        <div class="tab-icon home-icon"></div>
        <span>首页</span>
      </div>
      <div class="tab-item active" @click="navigateToParkingList">
        <div class="tab-icon parking-icon-active"></div>
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
import { fetchParkingList } from '../api/parking'

export default {
  name: 'ParkingList',
  setup() {
    const router = useRouter()
    const searchQuery = ref('')
    const parkings = ref([])
    const loading = ref(false)
    const currentPage = ref(1)
    const pageSize = 10
    const noMoreData = ref(false)
    
    // 筛选条件
    const activeFilter = ref('all')
    const showFilterPanel = ref(false)
    const distanceFilter = ref(null)
    const priceFilter = ref(null)
    const spacesFilter = ref('all')
    
    // 格式化距离
    const formatDistance = (distance) => {
      if (distance < 1000) {
        return `${distance}m`
      } else {
        return `${(distance / 1000).toFixed(1)}km`
      }
    }
    
    // 设置筛选器
    const setFilter = (filterType) => {
      if (activeFilter.value === filterType) {
        showFilterPanel.value = !showFilterPanel.value
      } else {
        activeFilter.value = filterType
        showFilterPanel.value = true
      }
    }
    
    // 设置距离筛选
    const setDistanceFilter = (distance) => {
      distanceFilter.value = distance
      showFilterPanel.value = false
      resetAndLoadParkings()
    }
    
    // 设置价格筛选
    const setPriceFilter = (sort) => {
      priceFilter.value = sort
      showFilterPanel.value = false
      resetAndLoadParkings()
    }
    
    // 设置车位筛选
    const setSpacesFilter = (type) => {
      spacesFilter.value = type
      showFilterPanel.value = false
      resetAndLoadParkings()
    }
    
    // 重置并加载停车场列表
    const resetAndLoadParkings = () => {
      currentPage.value = 1
      noMoreData.value = false
      parkings.value = []
      loadParkings()
    }
    
    // 加载停车场列表
    const loadParkings = async () => {
      if (loading.value || noMoreData.value) return
      
      try {
        loading.value = true
        
        const params = {
          page: currentPage.value,
          pageSize,
          keyword: searchQuery.value,
          distance: distanceFilter.value,
          priceSort: priceFilter.value,
          spacesFilter: spacesFilter.value
        }
        
        const response = await fetchParkingList(params)
        
        if (response.code === 200) {
          const newParkings = response.data.list || []
          
          if (currentPage.value === 1) {
            parkings.value = newParkings
          } else {
            parkings.value = [...parkings.value, ...newParkings]
          }
          
          // 检查是否还有更多数据
          noMoreData.value = newParkings.length < pageSize || (response.data.total || 0) <= parkings.value.length
        } else {
          showErrorToast(response.message || '获取停车场列表失败')
        }
      } catch (error) {
        showErrorToast('网络错误，请稍后重试')
        console.error('获取停车场列表失败:', error)
      } finally {
        loading.value = false
      }
    }
    
    // 搜索处理
    const handleSearch = () => {
      resetAndLoadParkings()
    }
    
    // 加载更多
    const loadMore = () => {
      if (!loading.value && !noMoreData.value) {
        currentPage.value++
        loadParkings()
      }
    }
    
    // 导航到停车场详情
    const navigateToDetail = (parkingId) => {
      router.push(`/parking-detail/${parkingId}`)
    }
    
    // 导航到首页
    const navigateToHome = () => {
      router.push('/')
    }
    
    // 导航到车位页面
    const navigateToSpaces = () => {
      router.push('/spaces')
    }
    
    // 导航到个人中心
    const navigateToMy = () => {
      router.push('/my')
    }
    
    // 导航到停车场列表
    const navigateToParkingList = () => {
      // 已经在当前页面
    }
    
    // 处理滚动加载
    const handleScroll = () => {
      const scrollTop = document.documentElement.scrollTop || document.body.scrollTop
      const scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
      const clientHeight = document.documentElement.clientHeight || window.innerHeight
      
      // 当滚动到距离底部100px时加载更多
      if (scrollTop + clientHeight >= scrollHeight - 100 && !loading.value && !noMoreData.value) {
        loadMore()
      }
    }
    
    onMounted(() => {
      loadParkings()
      window.addEventListener('scroll', handleScroll)
    })
    
    // 组件卸载时移除滚动事件监听
    const cleanup = () => {
      window.removeEventListener('scroll', handleScroll)
    }
    
    return {
      searchQuery,
      parkings,
      loading,
      noMoreData,
      activeFilter,
      showFilterPanel,
      formatDistance,
      setFilter,
      setDistanceFilter,
      setPriceFilter,
      setSpacesFilter,
      handleSearch,
      loadMore,
      navigateToDetail,
      navigateToHome,
      navigateToParkingList,
      navigateToSpaces,
      navigateToMy
    }
  }
}
</script>

<style scoped>
.parking-list {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding-bottom: 60px;
}

/* 搜索头部样式 */
.search-header {
  position: sticky;
  top: 0;
  background-color: #fff;
  padding: 10px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
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

/* 筛选栏样式 */
.filter-section {
  background-color: #fff;
  margin-bottom: 10px;
  position: relative;
}

.filter-tabs {
  display: flex;
  border-bottom: 1px solid #e8e8e8;
}

.filter-tab {
  flex: 1;
  text-align: center;
  padding: 12px 0;
  font-size: 14px;
  color: #333;
  position: relative;
}

.filter-tab.active {
  color: #1890ff;
}

.filter-tab.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 20px;
  height: 2px;
  background-color: #1890ff;
}

.filter-panel {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background-color: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 20;
  max-height: 300px;
  overflow-y: auto;
}

.filter-content {
  padding: 10px;
}

.filter-item {
  padding: 12px 15px;
  font-size: 14px;
  color: #333;
  border-bottom: 1px solid #f0f0f0;
}

.filter-item:last-child {
  border-bottom: none;
}

.filter-item:active {
  background-color: #f5f5f5;
}

/* 停车场列表样式 */
.parkings-container {
  padding: 10px;
}

.loading-container,
.empty-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 50px 0;
  color: #999;
}

.loading-spinner {
  width: 30px;
  height: 30px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #1890ff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 10px;
}

.empty-icon {
  width: 60px;
  height: 60px;
  background-color: #f5f5f5;
  border-radius: 50%;
  margin-bottom: 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.parkings-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.parking-item {
  background-color: #fff;
  border-radius: 8px;
  padding: 12px;
  display: flex;
  gap: 12px;
}

.parking-image {
  width: 100px;
  height: 100px;
  border-radius: 4px;
  overflow: hidden;
}

.parking-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.parking-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.parking-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 5px;
}

.parking-header h4 {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.parking-tags {
  display: flex;
  gap: 5px;
  margin-left: 5px;
}

.tag-reservation,
.tag-charge {
  padding: 2px 6px;
  font-size: 10px;
  border-radius: 10px;
}

.tag-reservation {
  background-color: #e6f7ff;
  color: #1890ff;
}

.tag-charge {
  background-color: #f6ffed;
  color: #52c41a;
}

.address {
  font-size: 13px;
  color: #666;
  margin: 0 0 8px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.parking-meta {
  display: flex;
  gap: 20px;
  margin-bottom: 8px;
}

.meta-item {
  font-size: 13px;
}

.meta-item .label {
  color: #999;
}

.meta-item .value.price {
  color: #ff4d4f;
  font-weight: bold;
}

.meta-item .value.distance {
  color: #333;
}

.parking-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.spaces-info {
  font-size: 13px;
}

.spaces-info .label {
  color: #666;
}

.spaces-info .value {
  font-weight: bold;
}

.spaces-info .value.available {
  color: #52c41a;
}

.spaces-info .value.unavailable {
  color: #ff4d4f;
}

.status {
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 12px;
}

.status.open {
  background-color: #f6ffed;
  color: #52c41a;
}

.status.closed {
  background-color: #f5f5f5;
  color: #999;
}

/* 加载更多样式 */
.load-more,
.no-more {
  text-align: center;
  padding: 15px 0;
  font-size: 14px;
  color: #999;
}

.load-more:active {
  background-color: #f5f5f5;
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
</style>