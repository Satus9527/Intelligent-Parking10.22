// pages/reservation/detail.js
const app = getApp()

Page({
  data: {
    reservationDetail: null,
    loading: true,
    error: false,
    errorMsg: '',
    reservationId: null,
    // 倒计时相关
    countdown: 0, // 倒计时秒数
    countdownText: '10:00', // 倒计时显示文本
    countdownTimer: null, // 倒计时定时器
    isImmediateReservation: false, // 是否是立即预约
    hasShownTwoMinuteWarning: false // 是否已显示2分钟警告
  },

  onLoad(options) {
    if (options.id) {
      this.setData({
        reservationId: options.id
      });
      this.getReservationDetail(options.id);
    } else {
      this.setData({
        loading: false,
        error: true,
        errorMsg: '预约ID无效'
      });
    }
  },

  // 获取预约详情
  getReservationDetail(id) {
    const app = getApp();
    
    this.setData({
      loading: true,
      error: false,
      errorMsg: ''
    });
    
    wx.showLoading({ title: '加载预约详情中' });
    
    // 调用后端API获取预约详情
    // 【修改点1】修正路径，加上 /v1
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/v1/reservations/${id}`,
      method: 'GET',
      success: (res) => {
        wx.hideLoading();
        
        if (res.statusCode === 200 && res.data) {
          // 格式化数据以适配前端展示需求
          const reservationData = res.data;
          
          // 从本地存储读取解锁状态和解锁时间
          let isUnlocked = false;
          let unlockTime = null;
          try {
            const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
            isUnlocked = unlockedReservations[reservationData.id] === true;
            
            // 读取解锁时间
            const unlockTimes = wx.getStorageSync('unlockTimes') || {};
            unlockTime = unlockTimes[reservationData.id];
          } catch (e) {
            console.error('读取解锁状态失败:', e);
          }
          
          // 根据原始状态和解锁状态确定显示状态
          let displayStatus = this.getStatusText(reservationData.status);
          if (reservationData.status === 0 && isUnlocked) {
            // 如果后端状态是待使用（0）且已解锁，显示为"使用中"
            displayStatus = '使用中';
          } else if (reservationData.status === 1) {
            // 已使用状态：如果有结束时间则显示"已完成"，否则显示"使用中"
            if (reservationData.actualExitTime) {
              displayStatus = '已完成';
            } else {
              displayStatus = '使用中';
            }
          }
          
          // 如果已解锁，使用解锁时间作为开始时间（优先使用解锁时间）
          let actualStartTimeDisplay = null;
          if (isUnlocked && unlockTime) {
            // 优先使用解锁时间
            actualStartTimeDisplay = this.formatDateTime(unlockTime);
          } else if (reservationData.actualEntryTime) {
            // 如果没有解锁时间，使用后端返回的实际进入时间
            actualStartTimeDisplay = this.formatDateTime(reservationData.actualEntryTime);
          }
          
          // 计算停车费用（如果已结束）
          let calculatedAmount = '0.00';
          if (reservationData.actualExitTime) {
            // 如果已有结束时间，计算费用
            let startTime = null;
            // 优先使用解锁时间，否则使用实际进入时间
            if (isUnlocked && unlockTime) {
              startTime = new Date(unlockTime);
            } else if (reservationData.actualEntryTime) {
              startTime = new Date(reservationData.actualEntryTime);
            }
            
            if (startTime) {
              const endTime = new Date(reservationData.actualExitTime);
              calculatedAmount = this.calculateParkingFee(startTime, endTime, reservationData.parkingLotHourlyRate || 0);
            }
          }
          
          const formattedDetail = {
            id: reservationData.id,
            reservationNo: reservationData.reservationNo || `RES${reservationData.id}`,
            parkingName: reservationData.parkingLotName || reservationData.parkingName || '未知停车场',
            parkingAddress: reservationData.parkingLotAddress || reservationData.parkingAddress || '',
            spaceNumber: reservationData.parkingSpace ? 
              `${reservationData.parkingSpace.floorName || ''}-${reservationData.parkingSpace.spaceNumber || ''}` : 
              '未知车位',
            status: displayStatus,
            paymentStatus: reservationData.paymentStatus === 1 ? '已支付' : '未支付',
            reserveTime: this.formatDateTimeRange(reservationData.startTime, reservationData.endTime),
            createTime: this.formatDateTime(reservationData.createdAt),
            amount: calculatedAmount !== '0.00' ? calculatedAmount : (reservationData.amount ? parseFloat(reservationData.amount).toFixed(2) : '0.00'),
            vehicleNumber: reservationData.plateNumber || '',
            contactPhone: reservationData.contactPhone || '',
            remark: reservationData.remark || '',
            actualStartTime: actualStartTimeDisplay,
            actualEndTime: reservationData.actualExitTime ? this.formatDateTime(reservationData.actualExitTime) : null,
            parkingLotHourlyRate: reservationData.parkingLotHourlyRate || 0, // 保存每小时费率，用于计算费用
            unlockTime: unlockTime // 保存解锁时间，用于计算费用
          };
          
          // 判断是否是立即预约
          // 方法1：检查开始时间是否接近创建时间（立即预约的开始时间应该和创建时间很接近）
          const startTime = new Date(reservationData.startTime);
          const createTime = new Date(reservationData.createdAt);
          const timeDiffFromCreate = Math.abs((startTime - createTime) / 1000); // 秒数差
          const isImmediateByTime = timeDiffFromCreate <= 300; // 5分钟内认为是立即预约
          
          // 方法2：从本地存储检查（如果是从停车场详情页跳转过来的立即预约）
          let isImmediateByStorage = false;
          try {
            const immediateReservations = wx.getStorageSync('immediateReservations') || {};
            isImmediateByStorage = immediateReservations[reservationData.id] === true;
          } catch (e) {
            console.error('读取立即预约标记失败:', e);
          }
          
          // 方法3：检查开始时间是否在当前时间的10分钟内（立即预约的开始时间应该接近当前时间）
          const now = new Date();
          const timeDiffFromNow = (startTime - now) / 1000; // 秒数差
          const isImmediateByNow = timeDiffFromNow >= -60 && timeDiffFromNow <= 600; // 开始时间在当前时间前后1分钟到10分钟之间
          
          const shouldShowCountdown = (isImmediateByTime || isImmediateByStorage || isImmediateByNow) && reservationData.status === 0;
          
          console.log('倒计时判断:', {
            reservationId: reservationData.id,
            status: reservationData.status,
            startTime: reservationData.startTime,
            createTime: reservationData.createdAt,
            timeDiffFromCreate,
            isImmediateByTime,
            isImmediateByStorage,
            timeDiffFromNow,
            isImmediateByNow,
            shouldShowCountdown
          });
          
          this.setData({
            loading: false,
            reservationDetail: formattedDetail,
            isImmediateReservation: shouldShowCountdown
          });
          
          // 如果是立即预约且状态为待使用且未解锁，启动倒计时
          if (shouldShowCountdown && !isUnlocked) {
            // 使用创建时间作为倒计时起点（立即预约从创建时间起10分钟）
            this.startCountdown(reservationData.id, reservationData.createdAt || reservationData.startTime);
          } else if (isUnlocked) {
            // 如果已解锁，不显示倒计时
            this.setData({
              isImmediateReservation: false
            });
          }
        } else {
          this.setData({
            loading: false,
            error: true,
            errorMsg: '获取预约详情失败'
          });
        }
      },
      fail: (error) => {
        wx.hideLoading();
        console.error('获取预约详情失败:', error);
        this.setData({
          loading: false,
          error: true,
          errorMsg: '网络错误，请稍后重试'
        });
      }
    });
  },

  // 取消预约
  cancelReservation() {
    wx.showModal({
      title: '取消预约',
      content: '确定要取消该预约吗？',
      success: (res) => {
        if (res.confirm) {
          wx.showLoading({ title: '处理中...' });
          
          // 调用后端API取消预约
          // 【修改点2】修正路径，加上 /v1
          wx.request({
            url: `${getApp().globalData.apiBaseUrl}/api/v1/reservations/${this.data.reservationId}/cancel`,
            method: 'POST',
            success: (result) => {
              wx.hideLoading();
              
              if (result.statusCode === 200 && result.data) {
                wx.showToast({
                  title: '预约已取消',
                  icon: 'success'
                });
                
                // 清除解锁状态和解锁时间
                try {
                  const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
                  delete unlockedReservations[this.data.reservationId];
                  wx.setStorageSync('unlockedReservations', unlockedReservations);
                  
                  const unlockTimes = wx.getStorageSync('unlockTimes') || {};
                  delete unlockTimes[this.data.reservationId];
                  wx.setStorageSync('unlockTimes', unlockTimes);
                } catch (e) {
                  console.error('清除解锁状态失败:', e);
                }
                
                // 更新预约状态
                this.setData({
                  'reservationDetail.status': '已取消'
                });
                
                // 返回上一页
                setTimeout(() => {
                  wx.navigateBack();
                }, 1500);
              } else {
                wx.showToast({
                  title: '取消预约失败',
                  icon: 'none'
                });
              }
            },
            fail: (error) => {
              wx.hideLoading();
              console.error('取消预约失败:', error);
              wx.showToast({
                title: '网络错误，请稍后重试',
                icon: 'none'
              });
            }
          });
        }
      }
    });
  },

  // 支付订单
  payOrder() {
    wx.showToast({
      title: '支付功能暂未开放',
      icon: 'none'
    });
  },

  // 结束订单
  completeReservation() {
    const that = this;
    const reservationId = this.data.reservationId;
    
    wx.showModal({
      title: '结束订单',
      content: '确定要结束当前停车订单吗？',
      success: (res) => {
        if (res.confirm) {
          wx.showLoading({ title: '处理中...' });
          
          // 调用后端API完成预约
          wx.request({
            url: `${app.globalData.apiBaseUrl}/api/v1/reservations/${reservationId}/complete`,
            method: 'POST',
            header: { 
              'Authorization': `Bearer ${app.globalData.token}`,
              'content-type': 'application/json'
            },
            success: (result) => {
              wx.hideLoading();
              
              if (result.statusCode === 200 && result.data) {
                wx.showToast({
                  title: '订单已结束',
                  icon: 'success',
                  duration: 2000
                });
                
                // 刷新详情，确保获取最新的结束时间和状态
                // 费用计算会在getReservationDetail中自动完成
                setTimeout(() => {
                  that.getReservationDetail(reservationId);
                }, 1500);
              } else {
                wx.showToast({
                  title: result.data?.message || '结束订单失败',
                  icon: 'none'
                });
              }
            },
            fail: (error) => {
              wx.hideLoading();
              console.error('结束订单失败:', error);
              wx.showToast({
                title: '网络错误，请稍后重试',
                icon: 'none'
              });
            }
          });
        }
      }
    });
  },

  /**
   * 计算停车费用
   * @param {Date} startTime 开始时间
   * @param {Date} endTime 结束时间
   * @param {Number} hourlyRate 每小时费率
   * @returns {String} 费用字符串（保留两位小数）
   */
  calculateParkingFee(startTime, endTime, hourlyRate) {
    if (!startTime || !endTime || !hourlyRate || hourlyRate <= 0) {
      return '0.00';
    }
    
    // 计算时间差（毫秒）
    const timeDiff = endTime.getTime() - startTime.getTime();
    
    // 转换为小时（向上取整，未满一小时按一小时算）
    const hours = Math.ceil(timeDiff / (1000 * 60 * 60));
    
    // 计算费用
    const amount = hours * hourlyRate;
    
    // 返回保留两位小数的字符串
    return amount.toFixed(2);
  },

  // 返回上一页
  goBack() {
    wx.navigateBack();
  },

  // 重试
  retry() {
    if (this.data.reservationId) {
      this.getReservationDetail(this.data.reservationId);
    }
  },
  
  /**
   * 页面显示时重新加载数据
   */
  onShow() {
    if (this.data.reservationId) {
      // 如果已经有倒计时在运行，先停止（重新加载时会重新判断是否需要启动）
      if (this.data.countdownTimer) {
        this.stopCountdown();
      }
      // 重新加载详情，确保状态同步（包括解锁状态）
      this.getReservationDetail(this.data.reservationId);
    }
  },
  
  /**
   * 格式化时间范围
   */
  formatDateTimeRange(startTime, endTime) {
    if (!startTime || !endTime) return '';
    
    const start = this.formatDate(new Date(startTime));
    const startHour = this.formatTime(new Date(startTime));
    const endHour = this.formatTime(new Date(endTime));
    
    return `${start} ${startHour}-${endHour}`;
  },
  
  /**
   * 格式化日期
   */
  formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  },
  
  /**
   * 格式化时间
   */
  formatTime(date) {
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
  },
  
  /**
   * 格式化完整日期时间
   */
  formatDateTime(dateTime) {
    const date = new Date(dateTime);
    return `${this.formatDate(date)} ${this.formatTime(date)}`;
  },
  
  /**
   * 获取状态文本
   */
  getStatusText(status) {
    // 支持字符串和数字类型的状态值
    const statusStr = String(status);
    const statusMap = {
      '0': '待使用',
      '1': '已使用',
      '2': '已取消',
      '3': '已超时',
      'PENDING': '待使用',
      'IN_USE': '已使用',
      'CANCELLED': '已取消',
      'TIMEOUT': '已超时'
    };
    return statusMap[statusStr] || '未知状态';
  },

  /**
   * 开始倒计时
   */
  startCountdown(reservationId, baseTime) {
    // 清除之前的倒计时
    if (this.data.countdownTimer) {
      clearInterval(this.data.countdownTimer);
    }
    
    // 检查是否已解锁，如果已解锁则不启动倒计时
    let isUnlocked = false;
    try {
      const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
      isUnlocked = unlockedReservations[reservationId] === true;
    } catch (e) {
      console.error('读取解锁状态失败:', e);
    }
    
    if (isUnlocked) {
      console.log('预约已解锁，不启动倒计时');
      this.setData({
        isImmediateReservation: false
      });
      return;
    }
    
    const base = new Date(baseTime);
    const now = new Date();
    // 从基准时间（创建时间或开始时间）起10分钟
    let countdown = Math.max(0, Math.floor((base.getTime() + 10 * 60 * 1000 - now.getTime()) / 1000));
    
    console.log('启动倒计时:', {
      reservationId,
      baseTime,
      now: now.toISOString(),
      countdown
    });
    
    // 如果已经超过10分钟，不显示倒计时
    if (countdown <= 0) {
      console.log('倒计时已过期，不显示');
      this.setData({
        isImmediateReservation: false
      });
      return;
    }
    
    // 立即设置倒计时数据，确保能显示
    this.setData({
      countdown: countdown,
      countdownText: this.formatCountdown(countdown),
      isImmediateReservation: true
    });
    
    // 每秒更新倒计时
    const timer = setInterval(() => {
      // 每次检查是否已解锁，如果已解锁则停止倒计时
      let isUnlockedNow = false;
      try {
        const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
        isUnlockedNow = unlockedReservations[reservationId] === true;
      } catch (e) {
        console.error('读取解锁状态失败:', e);
      }
      
      if (isUnlockedNow) {
        // 已解锁，停止倒计时
        clearInterval(timer);
        this.setData({
          countdownTimer: null,
          isImmediateReservation: false,
          countdown: 0
        });
        console.log('预约已解锁，停止倒计时');
        return;
      }
      
      countdown--;
      const countdownText = this.formatCountdown(countdown);
      
      this.setData({
        countdown: countdown,
        countdownText: countdownText
      });
      
      // 倒计时剩余2分钟（120秒）时，显示警告弹窗
      if (countdown === 120 && !this.data.hasShownTwoMinuteWarning) {
        this.showTwoMinuteWarning();
        this.setData({
          hasShownTwoMinuteWarning: true
        });
      }
      
      // 倒计时结束，检查是否已解锁
      if (countdown <= 0) {
        clearInterval(timer);
        
        // 检查是否已解锁
        let isUnlockedAfterTimeout = false;
        try {
          const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
          isUnlockedAfterTimeout = unlockedReservations[reservationId] === true;
        } catch (e) {
          console.error('读取解锁状态失败:', e);
        }
        
        if (isUnlockedAfterTimeout) {
          // 已解锁，更新状态为"使用中"，不自动取消
          this.setData({
            'reservationDetail.status': '使用中',
            isImmediateReservation: false,
            countdown: 0
          });
          // 重新加载详情以更新显示
          this.getReservationDetail(reservationId);
        } else {
          // 未解锁，自动取消预约
          this.autoCancelReservation(reservationId);
        }
      }
    }, 1000);
    
    this.setData({
      countdownTimer: timer
    });
  },

  /**
   * 格式化倒计时显示
   */
  formatCountdown(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  },

  /**
   * 停止倒计时
   */
  stopCountdown() {
    if (this.data.countdownTimer) {
      clearInterval(this.data.countdownTimer);
      this.setData({
        countdownTimer: null,
        countdown: 0,
        countdownText: '10:00',
        hasShownTwoMinuteWarning: false
      });
    }
  },

  /**
   * 显示2分钟警告弹窗
   */
  showTwoMinuteWarning() {
    wx.showModal({
      title: '⏰ 时间提醒',
      content: '距离预约自动取消还有2分钟，请尽快到达停车场！',
      showCancel: true,
      confirmText: '知道了',
      cancelText: '取消预约',
      success: (res) => {
        if (res.cancel) {
          // 用户选择取消预约
          this.cancelReservation();
        }
      }
    });
  },

  /**
   * 自动取消预约（超时）
   */
  autoCancelReservation(reservationId) {
    const app = getApp();
    wx.showModal({
      title: '预约超时',
      content: '预约已超时，将自动取消',
      showCancel: false,
      success: () => {
        wx.request({
          url: `${app.globalData.apiBaseUrl}/api/v1/reservations/${reservationId}/cancel`,
          method: 'POST',
          header: { 'Authorization': `Bearer ${app.globalData.token}` },
          success: (res) => {
            if (res.statusCode === 200) {
              wx.showToast({
                title: '预约已自动取消',
                icon: 'none'
              });
              // 清除倒计时和本地存储
              this.stopCountdown();
              try {
                // 清除立即预约标记
                const immediateReservations = wx.getStorageSync('immediateReservations') || {};
                delete immediateReservations[reservationId];
                wx.setStorageSync('immediateReservations', immediateReservations);
                // 清除解锁状态和解锁时间
                const unlockedReservations = wx.getStorageSync('unlockedReservations') || {};
                delete unlockedReservations[reservationId];
                wx.setStorageSync('unlockedReservations', unlockedReservations);
                
                const unlockTimes = wx.getStorageSync('unlockTimes') || {};
                delete unlockTimes[reservationId];
                wx.setStorageSync('unlockTimes', unlockTimes);
              } catch (e) {
                console.error('清除状态失败:', e);
              }
              // 刷新页面数据
              this.getReservationDetail(reservationId);
            }
          },
          fail: () => {
            console.error('自动取消预约失败');
          }
        });
      }
    });
  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload() {
    // 清除倒计时
    this.stopCountdown();
  }
});