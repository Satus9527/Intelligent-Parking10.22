// pages/parking/list.js
Page({
  data: {
    parkingList: [], // 用于存储停车场列表数据
    loading: true,   // 加载状态
    error: false,    // 错误状态
    errorMsg: ''     // 错误信息
  },

  onLoad() {
    // 页面加载时获取数据
    this.getNearbyParkings();
  },

  // 获取附近停车场
  getNearbyParkings() {
    // 1. 先获取用户地理位置（附近停车场需要经纬度）
    wx.getLocation({
      type: 'gcj02', // 高德地图坐标系（与后端一致）
      success: (res) => {
        const { latitude, longitude } = res;
        // 2. 调用后端接口
        wx.request({
          url: 'http://localhost:8081/api/v1/parking/nearby', // 后端接口地址
          method: 'GET',
          data: {
            latitude: latitude,
            longitude: longitude,
            radius: 2000 // 搜索半径（米）
          },
          success: (result) => {
            if (result.statusCode === 200) {
              // 成功获取数据，更新到页面
              this.setData({
                parkingList: result.data.data || [], // 假设后端返回格式为 {code:200, data: [...]} 
                loading: false
              });
              wx.stopPullDownRefresh(); // 数据加载完成后停止下拉刷新
            } else {
              this.setError('获取停车场失败');
              wx.stopPullDownRefresh();
            }
          },
          fail: () => {
            this.setError('网络错误，请重试');
            wx.stopPullDownRefresh();
          }
        });
      },
      fail: () => {
        this.setError('请授权地理位置权限');
        wx.stopPullDownRefresh();
      }
    });
  },

  // 处理错误状态
  setError(msg) {
    this.setData({
      loading: false,
      error: true,
      errorMsg: msg
    });
  },

  // 点击"重试"按钮时触发，处理地理位置权限重新授权
  retryGetLocation() {
    // 1. 先检查当前地理位置权限状态
    wx.getSetting({
      success: (res) => {
        // 2. 判断用户是否已拒绝授权（未授权）
        if (!res.authSetting['scope.userLocation']) {
          // 3. 第一次申请时，直接发起授权请求
          if (res.authSetting['scope.userLocation'] === undefined) {
            this.getNearbyParkings(); // 调用之前的获取位置方法（会触发授权弹窗）
          } else {
            // 4. 用户已拒绝过授权，需引导到设置页手动开启
            wx.showModal({
              title: '需要地理位置权限',
              content: '请在设置中开启地理位置权限，以便查询附近停车场',
              confirmText: '去设置',
              cancelText: '取消',
              success: (modalRes) => {
                if (modalRes.confirm) {
                  // 打开小程序设置页
                  wx.openSetting({
                    success: (settingRes) => {
                      // 用户在设置页开启权限后，重新获取位置
                      if (settingRes.authSetting['scope.userLocation']) {
                        this.getNearbyParkings();
                      }
                    }
                  });
                }
              }
            });
          }
        } else {
          // 已授权但仍失败，直接重试
          this.getNearbyParkings();
        }
      }
    });
  },

  // 跳转到停车场详情页
  goToDetail(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({
      url: `/pages/parking/detail?id=${id}`
    });
  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh() {
    // 重新加载数据
    this.setData({
      loading: true,
      error: false
    });
    this.getNearbyParkings();
    // wx.stopPullDownRefresh() 已移至 getNearbyParkings 方法中
  }
})