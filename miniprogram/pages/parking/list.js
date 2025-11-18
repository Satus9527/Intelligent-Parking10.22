// 不再需要导入模拟数据工具，现在直接从后端API获取真实数据
// import { searchParkings, getAvailableAreas } from '../../utils/dataUtils';

Page({
  data: {
    parkingList: [], // 停车场列表数据
    searchKeyword: '', // 搜索关键词
    sortType: 'distance', // 排序类型: distance/price/rating
    loading: false, // 加载状态
    hasMore: true, // 是否有更多数据
    page: 1, // 当前页码
    pageSize: 10, // 每页数量
    areaList: [], // 区域列表
    selectedArea: '' // 选中的区域
  },

  onLoad() {
    console.log("停车场页面 onLoad 执行");
    // 加载区域列表
    this.loadAreaList();
    // 初始化加载停车场数据
    this.loadParkingData();
  },

  // 加载区域列表（从后端API获取所有可用的行政区）
  loadAreaList() {
    const app = getApp();
    const that = this;
    
    // 先加载所有停车场，然后提取唯一的行政区列表
    // 不显示错误提示，因为失败时会使用默认列表
    app.request({
      url: '/api/v1/parking/nearby',
      method: 'GET',
      data: {
        longitude: 113.3248,
        latitude: 23.1288,
        radius: 50000
      },
      showError: false // 不显示错误提示，使用默认列表
    }).then(res => {
      // 检查响应数据，支持多种格式
      let allParkings = [];
      if (Array.isArray(res)) {
        allParkings = res;
      } else if (res.data && Array.isArray(res.data)) {
        allParkings = res.data;
      } else if (res.success && res.data && Array.isArray(res.data)) {
        allParkings = res.data;
      }
      
      // 提取所有唯一的行政区
      if (allParkings.length > 0) {
        const districts = [...new Set(allParkings
          .map(p => p.district || p.area)
          .filter(d => d && d.trim() !== ''))];
        
        // 定义热门区域优先级（优先级越高，排名越靠前）
        const hotDistricts = ['天河区', '越秀区', '海珠区', '荔湾区', '白云区', '番禺区', '黄埔区'];
        const otherDistricts = ['花都区', '南沙区', '从化区', '增城区'];
        
        // 按热门程度排序：热门区域在前，其他区域在后，最后按字母顺序
        const sortedDistricts = districts.sort((a, b) => {
          const aHotIndex = hotDistricts.indexOf(a);
          const bHotIndex = hotDistricts.indexOf(b);
          const aOtherIndex = otherDistricts.indexOf(a);
          const bOtherIndex = otherDistricts.indexOf(b);
          
          // 如果都是热门区域，按热门程度排序
          if (aHotIndex !== -1 && bHotIndex !== -1) {
            return aHotIndex - bHotIndex;
          }
          // 如果一个是热门区域，热门区域排前面
          if (aHotIndex !== -1) return -1;
          if (bHotIndex !== -1) return 1;
          // 如果都是其他区域，按其他区域优先级排序
          if (aOtherIndex !== -1 && bOtherIndex !== -1) {
            return aOtherIndex - bOtherIndex;
          }
          // 如果一个是其他区域，其他区域排前面
          if (aOtherIndex !== -1) return -1;
          if (bOtherIndex !== -1) return 1;
          // 都不在列表中，按字母顺序排序
          return a.localeCompare(b, 'zh-CN');
        });
        
        console.log('加载到行政区列表（已排序）:', sortedDistricts);
        
        that.setData({ 
          areaList: sortedDistricts.length > 0 ? sortedDistricts : ['天河区', '越秀区', '海珠区', '荔湾区', '白云区', '番禺区', '黄埔区', '花都区', '南沙区', '从化区', '增城区']
        });
      } else {
        // 如果没有数据，使用默认列表
        that.setData({ 
          areaList: ['天河区', '越秀区', '海珠区', '荔湾区', '白云区', '番禺区', '黄埔区', '花都区', '南沙区', '从化区', '增城区']
        });
      }
    }).catch(err => {
      console.error('加载区域列表失败:', err);
      // 如果请求失败（包括超时），使用默认的行政区列表（热门区域在前）
      // 不显示错误提示，因为已经有默认值可以使用
      that.setData({ 
        areaList: ['天河区', '越秀区', '海珠区', '荔湾区', '白云区', '番禺区', '黄埔区', '花都区', '南沙区', '从化区', '增城区']
      });
    });
  },

  // 加载停车场数据（从后端API获取真实数据）
  loadParkingData() {
    const app = getApp();
    const that = this;
    
    this.setData({ loading: true });
    
    // 构建请求参数，如果选择了区域，传递district参数给后端
    const requestData = {
      longitude: 113.3248, // 广州市中心经度
      latitude: 23.1288,   // 广州市中心纬度
      radius: 50000 // 50公里（获取所有停车场）
    };
    
    // 如果选择了区域，传递给后端进行过滤
    if (that.data.selectedArea && that.data.selectedArea !== '') {
      requestData.district = that.data.selectedArea;
      console.log('选择区域筛选:', that.data.selectedArea);
    } else {
      console.log('未选择区域，获取全部停车场');
    }
    
    console.log('请求参数:', requestData);
    
    return app.request({
      url: '/api/v1/parking/nearby',
      method: 'GET',
      data: requestData,
      showError: true // 显示错误提示
    }).then(res => {
      // 检查响应数据是否为数组或包含data数组
      let allParkings = [];
      if (Array.isArray(res)) {
        allParkings = res;
      } else if (res.data && Array.isArray(res.data)) {
        allParkings = res.data;
      } else if (res.success && res.data && Array.isArray(res.data)) {
        allParkings = res.data;
      }
      
      console.log('获取到停车场数据:', allParkings.length, '个停车场', '区域筛选:', that.data.selectedArea || '全部');
      
      // 处理数据，确保格式统一并转换ID为数字
      let processedParkings = allParkings.map(parking => ({
        id: Number(parking.id) || 0, // 关键：确保ID是数字
        name: parking.name || '未命名停车场',
        address: parking.address || '',
        area: parking.district || parking.area || '', // 使用district字段，兼容area
        district: parking.district || '', // 保存district字段
        distance: parking.distance || 0,
        totalSpaces: Number(parking.totalSpaces) || 0,
        availableSpaces: Number(parking.availableSpaces) || 0,
        hourlyRate: Number(parking.hourlyRate) || 0,
        pricePerHour: Number(parking.hourlyRate) || 0,
        price: `${Number(parking.hourlyRate) || 0}元/小时`,
        rating: 4.5, // 如果需要评分，可以从数据库获取
        status: parking.status || 1
      }));
      
      // 前端搜索过滤（如果有关键词）
      if (that.data.searchKeyword) {
        const keyword = that.data.searchKeyword.toLowerCase();
        processedParkings = processedParkings.filter(parking => 
          parking.name.toLowerCase().includes(keyword) ||
          parking.address.toLowerCase().includes(keyword)
        );
      }
      
      // 排序
      switch (that.data.sortType) {
        case 'distance':
          processedParkings.sort((a, b) => a.distance - b.distance);
          break;
        case 'price':
          processedParkings.sort((a, b) => a.hourlyRate - b.hourlyRate);
          break;
        case 'rating':
          processedParkings.sort((a, b) => b.rating - a.rating);
          break;
      }
      
      // 分页
      const page = that.data.page;
      const pageSize = that.data.pageSize;
      const start = (page - 1) * pageSize;
      const end = start + pageSize;
      const paginatedList = processedParkings.slice(start, end);
      
      let newList = [];
      if (page === 1) {
        newList = paginatedList;
      } else {
        newList = [...that.data.parkingList, ...paginatedList];
      }
      
      that.setData({
        parkingList: newList,
        loading: false,
        hasMore: end < processedParkings.length
      });
    }).catch(err => {
      console.error('加载停车场数据失败:', err);
      that.setData({ 
        loading: false,
        parkingList: [] // 清空列表，避免显示旧数据
      });
      // 错误提示已经在 app.request 中显示
      return Promise.reject(err);
    });
  },

  // 搜索输入
  onSearchInput(e) {
    const keyword = e.detail.value;
    this.setData({ 
      searchKeyword: keyword,
      page: 1 // 重置页码
    });
    
    // 延迟搜索，避免频繁请求
    if (this.searchTimer) {
      clearTimeout(this.searchTimer);
    }
    
    this.searchTimer = setTimeout(() => {
      this.loadParkingData();
    }, 300);
  },

  // 设置排序类型
  setSortType(e) {
    const sortType = e.currentTarget.dataset.type;
    this.setData({ 
      sortType,
      page: 1 // 重置页码
    });
    this.loadParkingData();
  },

  // 设置选中区域
  setArea(e) {
    const area = e.currentTarget.dataset.area;
    this.setData({ 
      selectedArea: area === this.data.selectedArea ? '' : area,
      page: 1 // 重置页码
    });
    this.loadParkingData();
  },

  // 跳转到停车场详情页
  navigateToDetail(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({
      url: `/pages/parking/detail?id=${id}`
    });
  },

  // 加载更多数据
  loadMore() {
    if (!this.data.loading && this.data.hasMore) {
      this.setData({ 
        page: this.data.page + 1
      });
      this.loadParkingData();
    }
  },

  onPullDownRefresh() {
    // 下拉刷新，重置页码并重新加载数据
    this.setData({ 
      page: 1
    });
    // loadParkingData 现在返回 Promise，可以在完成后停止下拉刷新
    this.loadParkingData().then(() => {
      wx.stopPullDownRefresh();
    }).catch(() => {
      wx.stopPullDownRefresh();
    });
  },

  onReachBottom() {
    // 触底加载更多
    this.loadMore();
  }
});