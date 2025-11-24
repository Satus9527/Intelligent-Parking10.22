// pages/user/favorites.js
const { getParkingImage } = require('../../utils/parkingImageUtils');

Page({
  data: {
    favorites: []
  },

  onShow() {
    this.loadFavorites();
  },

  loadFavorites() {
    try {
      let favorites = wx.getStorageSync('favoriteParkings') || [];

      // 最近收藏的排在前面
      favorites = favorites.sort((a, b) => {
        const ta = new Date(a.collectedAt || a.createdAt || 0).getTime();
        const tb = new Date(b.collectedAt || b.createdAt || 0).getTime();
        return tb - ta;
      });

      const app = getApp();
      const enriched = favorites.map(item => {
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
        favorites: enriched
      });
    } catch (e) {
      console.error('加载收藏停车场失败:', e);
      this.setData({
        favorites: []
      });
    }
  },

  goToParkingDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({
      url: `/pages/parking/detail?id=${id}`
    });
  },

  removeFavorite(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;

    wx.showModal({
      title: '取消收藏',
      content: '确定要取消收藏这个停车场吗？',
      success: (res) => {
        if (!res.confirm) return;

        try {
          let favorites = wx.getStorageSync('favoriteParkings') || [];
          favorites = favorites.filter(item => Number(item.id) !== Number(id));
          wx.setStorageSync('favoriteParkings', favorites);
        } catch (err) {
          console.error('更新收藏失败:', err);
        }

        wx.showToast({
          title: '已取消收藏',
          icon: 'none'
        });

        this.loadFavorites();
      }
    });
  }
});


