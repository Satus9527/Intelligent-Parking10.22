// pages/index/index.js
const app = getApp()
const voiceRecognition = require('../../utils/voiceRecognition')

Page({
  data: {
    // 地图相关数据
    longitude: 113.3248, 
    latitude: 23.1288,  
    markers: [],        
    mapScale: 15,       
    userLocation: null, 
    nearbyParkings: [], 
    isLocationLoaded: false, 
    
    // 其他页面数据
    recommendedParkings: [],
    announcement: '欢迎使用智能停车场小程序，祝您停车愉快！',
    latestReservation: null,
    
    // 搜索与语音
    searchKeyword: '', 
    searchResults: [], 
    showSearchResults: false, 
    isSearchFocused: false, 
    searchTimer: null, 
    
    showVoiceModal: false, 
    isRecording: false, 
    recognitionText: '',
    
    // 倒计时监听相关
    countdownTimer: null, // 倒计时定时器
    hasShownTwoMinuteWarning: false, // 是否已显示2分钟警告 
    voiceResult: null
  },

  onLoad: function() {
    this.initMap();
    this.loadRecommendedParkings();
    
    if (app.globalData.token) {
      this.loadLatestReservation();
    } else {
      app.tokenReadyCallback = (token) => {
        this.loadLatestReservation();
      }
    }
  },

  onShow: function() {
    if (!this.data.isLocationLoaded) {
      this.getUserLocation()
    }
    if (app.globalData.token) {
      // 重新加载预约数据，确保状态同步
      this.loadLatestReservation()
    }
  },

  onUnload: function() {
    // 清除倒计时定时器
    this.stopCountdown();
  },

  onHide: function() {
    // 页面隐藏时不清除定时器，保持监听
  },
  
  // 初始化地图
  initMap: function() {
    this.mapCtx = wx.createMapContext('parkingMap', this)
    this.setData({ longitude: 113.3248, latitude: 23.1288 })
    this.getUserLocation()
  },
  
  // 获取用户当前位置
  getUserLocation: function() {
    const that = this
    wx.getSetting({
      success: function(res) {
        if (!res.authSetting['scope.userLocation']) {
          wx.authorize({
            scope: 'scope.userLocation',
            success: function() { that.fetchLocation() },
            fail: function() { that.useDefaultLocation() }
          })
        } else {
          that.fetchLocation()
        }
      }
    })
  },
  
  fetchLocation: function() {
    const that = this
    wx.getLocation({
      type: 'gcj02',
      altitude: true,
      success: function(res) {
        that.setData({
          latitude: parseFloat(res.latitude) || 23.1288,
          longitude: parseFloat(res.longitude) || 113.3248,
          userLocation: res,
          isLocationLoaded: true
        })
        if (that.mapCtx) that.mapCtx.moveToLocation()
        that.loadNearbyParkings()
      },
      fail: function(err) {
        console.error('获取位置失败:', err)
        that.useDefaultLocation()
      }
    })
  },
  
  useDefaultLocation: function() {
    this.setData({ longitude: 113.3248, latitude: 23.1288, isLocationLoaded: true })
    this.loadNearbyParkings()
  },
  
  // 加载附近停车场（修复：添加 pricePerHour）
  loadNearbyParkings: function() {
    const that = this;
    app.request({
      url: '/api/v1/parking/nearby',
      method: 'GET',
      data: {
        longitude: this.data.longitude,
        latitude: this.data.latitude,
        radius: 10000
      }
    }).then(res => {
      if (res && (Array.isArray(res) || Array.isArray(res.data))) {
        const allParkings = Array.isArray(res) ? res : res.data;
        
        const parkingsWithDistance = allParkings.map(parking => {
          const distance = that.calculateDistance(
            that.data.longitude, that.data.latitude, 
            Number(parking.longitude), Number(parking.latitude)
          );
          
          return {
            ...parking,
            id: Number(parking.id),
            distance: distance,
            latitude: Number(parking.latitude),
            longitude: Number(parking.longitude),
            // 【修复点1】增加 pricePerHour 字段，确保只包含数字
            pricePerHour: Number(parking.hourlyRate) || 0,
            price: `${Number(parking.hourlyRate)}元/小时`
          };
        }).sort((a, b) => a.distance - b.distance);
    
        const markers = parkingsWithDistance.map(parking => ({
            id: Number(parking.id),
            latitude: Number(parking.latitude),
            longitude: Number(parking.longitude),
            width: 30,
            height: 30,
            callout: {
              content: `${parking.name}\n剩余: ${parking.availableSpaces}`,
              display: 'BYCLICK',
              padding: 8,
              borderRadius: 4,
              bgColor: '#ffffff',
              color: '#333333'
            },
            iconPath: '../../images/parking.png' 
        }));
    
        that.setData({
          markers: markers,
          nearbyParkings: parkingsWithDistance.slice(0, 5)
        });
      }
    }).catch(err => {
      console.error('加载停车场失败:', err);
    });
  },
  
  calculateDistance: function(lng1, lat1, lng2, lat2) {
    const R = 6371 
    const dLat = (lat2 - lat1) * Math.PI / 180
    const dLng = (lng2 - lng1) * Math.PI / 180
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLng/2) * Math.sin(dLng/2)
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  },
  
  locateMe: function() {
    this.fetchLocation();
  },
  
  onMarkerTap: function(e) {
    this.navigateToDetail({ currentTarget: { dataset: { id: e.markerId } } })
  },
  
  navigateToDetail: function(e) {
    const parkingId = Number(e.currentTarget.dataset.id);
    if (parkingId > 0) {
      wx.navigateTo({
        url: `/pages/parking/detail?id=${parkingId}`
      })
    }
  },

  // 加载推荐停车场（修复：添加 pricePerHour）
  loadRecommendedParkings: function() {
    const that = this;
    app.request({
      url: '/api/v1/parking/nearby', 
      data: {
        longitude: this.data.longitude,
        latitude: this.data.latitude,
        radius: 20000 
      }
    }).then(res => {
       const data = Array.isArray(res) ? res : (res.data || []);
       if (data.length > 0) {
         const recommended = data.slice(0, 3).map(p => ({
           ...p,
           id: Number(p.id),
           // 【修复点2】推荐列表也需要增加 pricePerHour
           pricePerHour: Number(p.hourlyRate) || 0,
           distanceStr: '未知距离' 
         }));
         that.setData({ recommendedParkings: recommended });
       }
    }).catch(console.error);
  },

  loadLatestReservation: function() {
    const that = this;
    if (!app.globalData.token) return;
    
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/v1/reservations/user`,
      method: 'GET',
      header: { 'Authorization': `Bearer ${app.globalData.token}` },
      data: { pageNum: 1, pageSize: 1 },
      success: function(res) {
        if (res.statusCode === 200 && res.data) {
           const resultData = res.data.data || res.data;
           const list = Array.isArray(resultData) ? resultData : (resultData.list || []);
           
           if (list.length > 0) {
             const item = list[0];
             
             // 提取车位号
             let spaceNumber = '未知车位';
             if (item.parkingSpace) {
               const floor = item.parkingSpace.floor || '';
               const spaceNum = item.parkingSpace.spaceNumber || item.parkingSpace.number || '';
               if (floor || spaceNum) {
                 spaceNumber = floor && spaceNum ? `${floor}-${spaceNum}` : (floor || spaceNum);
               }
             }
             
             // 提取价格（优先使用总费用，否则使用小时费率）
             let price = '0.00';
             if (item.amount !== undefined && item.amount !== null) {
               price = parseFloat(item.amount).toFixed(2);
             } else if (item.parkingLotHourlyRate !== undefined && item.parkingLotHourlyRate !== null) {
               // 如果有开始和结束时间，计算总费用
               if (item.startTime && item.endTime) {
                 const start = new Date(item.startTime);
                 const end = new Date(item.endTime);
                 const hours = Math.max(1, Math.ceil((end - start) / (1000 * 60 * 60))); // 至少1小时
                 price = (parseFloat(item.parkingLotHourlyRate) * hours).toFixed(2);
               } else {
                 price = parseFloat(item.parkingLotHourlyRate).toFixed(2);
               }
             }
             
             // 从本地存储读取解锁状态和解锁时间
             const reservationId = item.id;
             let isUnlocked = false;
             let unlockTime = null;
             try {
               const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
               isUnlocked = unlockedReservations[reservationId] === true;
               
               // 读取解锁时间
               const unlockTimes = wx.getStorageSync('unlockTimes') || {};
               unlockTime = unlockTimes[reservationId];
             } catch (e) {
               console.error('读取解锁状态失败:', e);
             }
             
             // 根据原始状态和解锁状态确定显示状态
             // 状态值：0-待使用，1-已使用，2-已取消，3-已超时
             let displayStatus = '待使用';
             let statusClass = 'pending';
             
             if (item.status === 0) {
               // 待使用状态
               if (isUnlocked) {
                 displayStatus = '使用中';
                 statusClass = 'in-use';
               } else {
                 displayStatus = '待使用';
                 statusClass = 'pending';
               }
             } else if (item.status === 1) {
               // 已使用状态：如果有结束时间则显示"已完成"，否则显示"使用中"
               if (item.actualExitTime) {
                 displayStatus = '已完成';
                 statusClass = 'completed';
               } else {
                 displayStatus = '使用中';
                 statusClass = 'in-use';
               }
             } else if (item.status === 2) {
               // 已取消状态
               displayStatus = '已取消';
               statusClass = 'cancelled';
             } else if (item.status === 3) {
               // 已超时状态
               displayStatus = '已超时';
               statusClass = 'expired';
             } else {
               // 其他未知状态，默认显示已完成
               displayStatus = '已完成';
               statusClass = 'completed';
             }
             
             that.setData({
               latestReservation: {
                 id: reservationId,
                 parkingId: item.parkingId,
                 parkingName: item.parkingLotName || item.parkingName || '停车场',
                 status: displayStatus,
                 statusClass: statusClass,
                 dateTime: item.startTime ? item.startTime.replace('T', ' ').substring(0, 19) : '',
                 spaceNumber: spaceNumber,
                 price: price,
                 isUnlocked: isUnlocked, // 从本地存储恢复解锁状态
                 startTime: item.startTime, // 保存开始时间
                 createdAt: item.createdAt, // 保存创建时间
                 unlockTime: unlockTime // 保存解锁时间
               }
             });
             
             // 检查是否是立即预约，如果是则启动倒计时监听
             // 只有待使用状态且未解锁时才需要监听倒计时
             if (item.status === 0 && !isUnlocked) {
               that.checkAndStartCountdown(item);
             } else {
               // 如果不是待使用状态或已解锁，清除倒计时
               that.stopCountdown();
             }
           } else {
             // 没有预约，清除倒计时
             that.stopCountdown();
           }
        }
      }
    });
  },

  onSearchInput: function(e) {
    this.setData({ searchKeyword: e.detail.value });
  },
  
  onSearchConfirm: function() {
    const keyword = this.data.searchKeyword;
    if (!keyword) return;
    wx.navigateTo({
      url: `/pages/parking/list?keyword=${keyword}`
    });
  },

  // 跳转方法
  goToParkingList: function() {
    wx.switchTab({ url: '/pages/parking/list' })
  },

  goToReservationList: function() {
    wx.switchTab({ url: '/pages/reservation/index' })
  },

  goToProfile: function() {
    wx.switchTab({ url: '/pages/user/profile' })
  },

  // 解锁车位（调用后端API更新状态）
  unlockSpace: function(e) {
    const reservationId = this.data.latestReservation.id;
    if (!reservationId) return;
    
    const that = this;
    
    // 检查是否已经解锁
    if (this.data.latestReservation.isUnlocked || this.data.latestReservation.status === '使用中') {
      wx.showToast({
        title: '该预约已解锁',
        icon: 'none',
        duration: 2000
      });
      return;
    }
    
    wx.showLoading({ title: '解锁中...' });
    
    // 先获取预约详情，检查当前状态
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/v1/reservations/${reservationId}`,
      method: 'GET',
      header: { 
        'Authorization': `Bearer ${app.globalData.token}`,
        'content-type': 'application/json'
      },
      success: function(detailRes) {
        if (detailRes.statusCode === 200 && detailRes.data) {
          const reservation = detailRes.data;
          
          // 检查预约状态
          if (reservation.status !== 0) {
            wx.hideLoading();
            let errorMsg = '预约状态无效，无法解锁';
            if (reservation.status === 1) {
              errorMsg = '该预约已在使用中';
            } else if (reservation.status === 2) {
              errorMsg = '该预约已取消';
            } else if (reservation.status === 3) {
              errorMsg = '该预约已超时';
            }
            
            wx.showModal({
              title: '提示',
              content: errorMsg + '，请刷新页面查看最新状态',
              showCancel: false,
              success: () => {
                // 刷新预约数据
                that.loadLatestReservation();
              }
            });
            return;
          }
          
          // 状态正常，调用解锁接口
          wx.request({
            url: `${app.globalData.apiBaseUrl}/api/v1/reservations/${reservationId}/use`,
            method: 'POST',
            header: { 
              'Authorization': `Bearer ${app.globalData.token}`,
              'content-type': 'application/json'
            },
            success: function(res) {
              wx.hideLoading();
              
              if (res.statusCode === 200 && res.data) {
                // 保存解锁状态和解锁时间到本地存储
                try {
                  const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
                  unlockedReservations[reservationId] = true;
                  wx.setStorageSync('unlockedReservations', unlockedReservations);
                  
                  // 保存解锁时间
                  const unlockTimes = wx.getStorageSync('unlockTimes') || {};
                  unlockTimes[reservationId] = new Date().toISOString();
                  wx.setStorageSync('unlockTimes', unlockTimes);
                } catch (e) {
                  console.error('保存解锁状态失败:', e);
                }
                
                // 停止倒计时（因为已解锁，不再需要倒计时）
                that.stopCountdown();
                
                // 更新页面状态：解锁后状态变为"使用中"
                that.setData({
                  'latestReservation.isUnlocked': true,
                  'latestReservation.status': '使用中',
                  'latestReservation.statusClass': 'in-use'
                });
                
                wx.showToast({
                  title: '已解锁',
                  icon: 'success',
                  duration: 2000
                });
                
                // 刷新预约数据，确保状态同步
                setTimeout(() => {
                  that.loadLatestReservation();
                }, 1500);
              } else {
                wx.hideLoading();
                let errorMsg = '解锁失败';
                if (res.data && res.data.message) {
                  errorMsg = res.data.message;
                } else if (res.data && typeof res.data === 'string') {
                  errorMsg = res.data;
                }
                
                wx.showModal({
                  title: '解锁失败',
                  content: errorMsg,
                  showCancel: false
                });
              }
            },
            fail: function(error) {
              wx.hideLoading();
              console.error('解锁失败:', error);
              wx.showToast({
                title: '网络错误，请稍后重试',
                icon: 'none',
                duration: 2000
              });
            }
          });
        } else {
          wx.hideLoading();
          wx.showToast({
            title: '获取预约信息失败',
            icon: 'none',
            duration: 2000
          });
        }
      },
      fail: function(error) {
        wx.hideLoading();
        console.error('获取预约详情失败:', error);
        wx.showToast({
          title: '网络错误，请稍后重试',
          icon: 'none',
          duration: 2000
        });
      }
    });
  },

  // 取消预约
  cancelReservation: function(e) {
    const reservationId = e.currentTarget.dataset.id;
    const that = this;
    
    wx.showModal({
      title: '取消预约',
      content: '确定要取消该预约吗？',
      success: (res) => {
        if (res.confirm) {
          wx.showLoading({ title: '处理中...' });
          
          const app = getApp();
          wx.request({
            url: `${app.globalData.apiBaseUrl}/api/v1/reservations/${reservationId}/cancel`,
            method: 'POST',
            header: { 'Authorization': `Bearer ${app.globalData.token}` },
            success: (result) => {
              wx.hideLoading();
              if (result.statusCode === 200) {
                // 清除解锁状态
                try {
                  const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
                  delete unlockedReservations[reservationId];
                  wx.setStorageSync('unlockedReservations', unlockedReservations);
                } catch (e) {
                  console.error('清除解锁状态失败:', e);
                }
                
                wx.showToast({
                  title: '预约已取消',
                  icon: 'success'
                });
                // 刷新预约数据
                that.loadLatestReservation();
              } else {
                wx.showToast({
                  title: result.data?.message || '取消失败',
                  icon: 'none'
                });
              }
            },
            fail: () => {
              wx.hideLoading();
              wx.showToast({
                title: '网络错误',
                icon: 'none'
              });
            }
          });
        }
      }
    });
  },

  // 导航前往
  navigateToParking: function(e) {
    const reservationId = e.currentTarget.dataset.id;
    // 跳转到预约详情页面，详情页面可以显示导航功能
    wx.navigateTo({
      url: `/pages/reservation/detail?id=${reservationId}`
    });
  },

  // 跳转到预约详情
  navigateToReservationDetail: function(e) {
    const reservationId = e.currentTarget.dataset.id;
    if (reservationId) {
      wx.navigateTo({
        url: `/pages/reservation/detail?id=${reservationId}`
      });
    }
  },

  // 阻止事件冒泡（用于按钮区域）
  stopPropagation: function(e) {
    // 空函数，仅用于阻止事件冒泡
  },

  /**
   * 检查并启动倒计时监听
   */
  checkAndStartCountdown: function(reservationItem) {
    // 清除之前的定时器
    this.stopCountdown();
    
    // 检查是否是立即预约
    const startTime = new Date(reservationItem.startTime);
    const createTime = new Date(reservationItem.createdAt);
    const timeDiffFromCreate = Math.abs((startTime - createTime) / 1000); // 秒数差
    const isImmediateByTime = timeDiffFromCreate <= 300; // 5分钟内认为是立即预约
    
    // 从本地存储检查
    let isImmediateByStorage = false;
    try {
      const immediateReservations = wx.getStorageSync('immediateReservations') || {};
      isImmediateByStorage = immediateReservations[reservationItem.id] === true;
    } catch (e) {
      console.error('读取立即预约标记失败:', e);
    }
    
    // 检查开始时间是否在当前时间的10分钟内
    const now = new Date();
    const timeDiffFromNow = (startTime - now) / 1000;
    const isImmediateByNow = timeDiffFromNow >= -60 && timeDiffFromNow <= 600;
    
    const isImmediate = isImmediateByTime || isImmediateByStorage || isImmediateByNow;
    
    if (isImmediate && reservationItem.status === 0) {
      // 启动倒计时监听
      this.startCountdown(reservationItem.id, reservationItem.createdAt || reservationItem.startTime);
    }
  },

  /**
   * 启动倒计时监听
   */
  startCountdown: function(reservationId, baseTime) {
    const that = this;
    const base = new Date(baseTime);
    
    // 每秒检查倒计时
    const timer = setInterval(() => {
      // 每次检查是否已解锁，如果已解锁则停止倒计时
      let isUnlocked = false;
      try {
        const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
        isUnlocked = unlockedReservations[reservationId] === true;
      } catch (e) {
        console.error('读取解锁状态失败:', e);
      }
      
      if (isUnlocked) {
        // 已解锁，停止倒计时
        clearInterval(timer);
        that.setData({
          countdownTimer: null,
          hasShownTwoMinuteWarning: false
        });
        console.log('预约已解锁，停止倒计时');
        return;
      }
      
      const now = new Date();
      // 从基准时间（创建时间或开始时间）起10分钟
      const countdown = Math.max(0, Math.floor((base.getTime() + 10 * 60 * 1000 - now.getTime()) / 1000));
      
      // 如果已经超过10分钟，检查是否已解锁
      if (countdown <= 0) {
        clearInterval(timer);
        
        // 检查是否已解锁，如果已解锁则更新状态为"使用中"
        let isUnlockedAfterTimeout = false;
        try {
          const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
          isUnlockedAfterTimeout = unlockedReservations[reservationId] === true;
        } catch (e) {
          console.error('读取解锁状态失败:', e);
        }
        
        if (isUnlockedAfterTimeout) {
          // 已解锁，更新状态为"使用中"
          that.setData({
            'latestReservation.status': '使用中',
            'latestReservation.statusClass': 'in-use',
            'latestReservation.isUnlocked': true
          });
        }
        
        that.setData({
          countdownTimer: null,
          hasShownTwoMinuteWarning: false
        });
        return;
      }
      
      // 倒计时剩余2分钟（120秒）时，显示警告弹窗
      if (countdown === 120 && !that.data.hasShownTwoMinuteWarning) {
        that.showTwoMinuteWarning(reservationId);
        that.setData({
          hasShownTwoMinuteWarning: true
        });
      }
    }, 1000);
    
    this.setData({
      countdownTimer: timer
    });
  },

  /**
   * 停止倒计时监听
   */
  stopCountdown: function() {
    if (this.data.countdownTimer) {
      clearInterval(this.data.countdownTimer);
      this.setData({
        countdownTimer: null,
        hasShownTwoMinuteWarning: false
      });
    }
  },

  /**
   * 显示2分钟警告弹窗
   */
  showTwoMinuteWarning: function(reservationId) {
    const that = this;
    wx.showModal({
      title: '⏰ 时间提醒',
      content: '距离预约自动取消还有2分钟，请尽快到达停车场！',
      showCancel: true,
      confirmText: '知道了',
      cancelText: '取消预约',
      success: (res) => {
        if (res.cancel) {
          // 用户选择取消预约
          that.cancelReservation({ currentTarget: { dataset: { id: reservationId } } });
        }
      }
    });
  },

  // 语音功能
  startVoiceRecognition: function() {
    wx.authorize({
      scope: 'scope.record',
      success: () => {
        this.setData({ showVoiceModal: true, isRecording: true });
        voiceRecognition.startRecord({
           success: () => console.log('开始录音'),
           fail: () => wx.showToast({title: '录音失败', icon: 'none'})
        });
      },
      fail: () => {
        wx.showModal({ title: '提示', content: '需要麦克风权限进行语音识别' });
      }
    });
  },
  
  closeVoiceModal: function() {
    this.setData({ showVoiceModal: false, isRecording: false });
    voiceRecognition.stopRecord();
  },

  stopRecordAndRecognize: function() {
    this.setData({ isRecording: false });
    voiceRecognition.stopRecord((res) => {
        if (res && res.result) {
            this.setData({ recognitionText: res.result });
            this.processVoiceCommand(res.result);
        }
    });
  },

  processVoiceCommand: function(text) {
    if (!text) return;
    wx.showLoading({ title: '智能分析中...' });
    
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/v1/voice/process`,
      method: 'POST',
      data: { command: text },
      success: (res) => {
        wx.hideLoading();
        if (res.data.success) {
            wx.showToast({ title: '指令已执行', icon: 'success' });
            if (res.data.type === 'SEARCH') {
                this.loadNearbyParkings();
            }
        } else {
            wx.showToast({ title: '无法识别指令', icon: 'none' });
        }
      },
      fail: () => {
        wx.hideLoading();
        wx.showToast({ title: '网络错误', icon: 'none' });
      }
    });
  }
})