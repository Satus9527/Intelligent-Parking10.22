// pages/user/profile.js
const app = getApp();
const { getParkingImage } = require('../../utils/parkingImageUtils');

Page({
  data: {
    userInfo: null,
    favoriteParkings: [] // 收藏的停车场列表
  },

  onShow() {
    this.loadUserInfo();
    this.loadFavoriteParkings();
  },

  loadUserInfo() {
    if (app.globalData.userInfo) {
      this.setData({
        userInfo: app.globalData.userInfo
      });
    } else {
      // 尝试从缓存获取
      const userInfo = wx.getStorageSync('userInfo');
      if (userInfo) {
        this.setData({ userInfo });
      }
    }
  },

  // 登录处理
  handleLogin() {
    wx.navigateTo({
      url: '/pages/login/login',
    });
  },

  // 跳转到我的预约
  goToMyReservations() {
    if (!this.data.userInfo) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    // 如果是tab页用 switchTab，否则用 navigateTo
    wx.switchTab({
      url: '/pages/reservation/index',
      fail: () => {
        wx.navigateTo({ url: '/pages/user/reservations' });
      }
    });
  },

  // 加载收藏的停车场
  loadFavoriteParkings() {
    try {
      // 从本地存储获取收藏的停车场
      const favorites = wx.getStorageSync('favoriteParkings') || [];
      // 为每个收藏的停车场添加图片（使用后端托管的完整 URL）
      const app = getApp();
      const favoritesWithImages = favorites.slice(0, 6).map(item => {
        const relativeImagePath = getParkingImage(item.id, item.name); // 如：/parking.png
        const fullImageUrl = relativeImagePath 
          ? `${app.globalData.imageBaseUrl}${relativeImagePath}` 
          : (item.imageUrl || `${app.globalData.imageBaseUrl}/parking.png`);
        return {
          ...item,
          imageUrl: fullImageUrl
        };
      });
      this.setData({
        favoriteParkings: favoritesWithImages
      });
    } catch (e) {
      console.error('加载收藏停车场失败:', e);
      this.setData({
        favoriteParkings: []
      });
    }
  },

  // 收藏停车场
  goToFavorites() {
    wx.navigateTo({
      url: '/pages/user/favorites'
    });
  },

  // 跳转到停车场详情
  goToParkingDetail(e) {
    const parkingId = e.currentTarget.dataset.id;
    wx.navigateTo({
      url: `/pages/parking/detail?id=${parkingId}`
    });
  },

  // 我的车牌
  goToMyLicensePlate() {
    wx.navigateTo({
      url: '/pages/user/vehicles'
    });
  },
  
  // 客服中心 -> 在线客服（跳转到在线客服页面）
  contactSupport() { 
    wx.navigateTo({
      url: '/pages/user/online-service'
    });
  },
  
  // 关于瞬泊
  aboutUs() { 
    wx.navigateTo({
      url: '/pages/user/about'
    });
  },

  // 退出登录
  handleLogout() {
    wx.showModal({
      title: '提示',
      content: '确定要退出登录吗？',
      success: (res) => {
        if (res.confirm) {
          wx.removeStorageSync('token');
          wx.removeStorageSync('userInfo');
          app.globalData.token = null;
          app.globalData.userInfo = null;
          this.setData({ userInfo: null });
          wx.showToast({ title: '已退出', icon: 'none' });
        }
      }
    });
  },

  // 跳转到编辑资料（占位）
  goToProfileEdit() {
    wx.navigateTo({
      url: '/pages/user/profile-edit'
    });
  }
});
