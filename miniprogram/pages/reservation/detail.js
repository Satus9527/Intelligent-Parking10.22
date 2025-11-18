// pages/reservation/detail.js
const app = getApp()

Page({
  data: {
    reservationDetail: null,
    loading: true,
    error: false,
    errorMsg: '',
    reservationId: null
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
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/reservations/${id}`,
      method: 'GET',
      success: (res) => {
        wx.hideLoading();
        
        if (res.statusCode === 200 && res.data) {
          // 格式化数据以适配前端展示需求
          const reservationData = res.data;
          const formattedDetail = {
            id: reservationData.id,
            reservationNo: reservationData.reservationNo || `RES${reservationData.id}`,
            parkingName: reservationData.parkingLotName || reservationData.parkingName || '未知停车场',
            parkingAddress: reservationData.parkingLotAddress || reservationData.parkingAddress || '',
            spaceNumber: reservationData.parkingSpace ? 
              `${reservationData.parkingSpace.floorName || ''}-${reservationData.parkingSpace.spaceNumber || ''}` : 
              '未知车位',
            status: this.getStatusText(reservationData.status),
            paymentStatus: reservationData.paymentStatus === 1 ? '已支付' : '未支付',
            reserveTime: this.formatDateTimeRange(reservationData.startTime, reservationData.endTime),
            createTime: this.formatDateTime(reservationData.createdAt),
            amount: '0.00', // 实际应用中应从后端获取
            vehicleNumber: reservationData.plateNumber || '',
            contactPhone: reservationData.contactPhone || '',
            remark: reservationData.remark || '',
            actualStartTime: reservationData.actualEntryTime ? this.formatDateTime(reservationData.actualEntryTime) : null,
            actualEndTime: reservationData.actualExitTime ? this.formatDateTime(reservationData.actualExitTime) : null
          };
          
          this.setData({
            loading: false,
            reservationDetail: formattedDetail
          });
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
            wx.request({
              url: `${getApp().globalData.apiBaseUrl}/api/reservations/${this.data.reservationId}/cancel`,
            method: 'POST',
            success: (result) => {
              wx.hideLoading();
              
              if (result.statusCode === 200 && result.data) {
                wx.showToast({
                  title: '预约已取消',
                  icon: 'success'
                });
                
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
  }
});