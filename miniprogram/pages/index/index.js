// pages/index/index.js
const app = getApp()
const voiceRecognition = require('../../utils/voiceRecognition')
// 不再需要导入模拟数据工具，现在直接从后端API获取真实数据
// import { getRecommendedParkings, getAllParkings } from '../../utils/dataUtils';

Page({
  data: {
    // 地图相关数据
    longitude: 113.3248, // 默认广州市中心经度
    latitude: 23.1288,  // 默认广州市中心纬度
    markers: [],        // 停车场标记
    covers: [],         // 覆盖物
    mapScale: 15,       // 地图缩放级别
    userLocation: null, // 用户位置
    nearbyParkings: [], // 附近停车场
    isLocationLoaded: false, // 位置是否已加载
    
    // 其他页面数据
    recommendedParkings: [],
    announcement: '欢迎使用智能停车场小程序，祝您停车愉快！',
    latestReservation: null, // 最新预约记录
    
    // 搜索相关数据
    searchKeyword: '', // 搜索关键词
    searchResults: [], // 搜索结果
    showSearchResults: false, // 是否显示搜索结果
    isSearchFocused: false, // 搜索框是否聚焦
    searchTimer: null, // 搜索防抖定时器
    
    // 语音相关数据
    showVoiceModal: false, // 是否显示语音识别浮层
    isRecording: false, // 是否正在录音
    recognitionText: '', // 语音识别文本
    voiceResult: null // 语音处理结果
  },

  onLoad: function() {
    // 初始化地图
    this.initMap()
    
    // 加载推荐停车场数据
    this.loadRecommendedParkings()
    
    // 加载最新预约
    this.loadLatestReservation()
    
    // 检查登录状态
    if (!app.globalData.token) {
      this.handleAutoLogin()
    }
  },

  onShow: function() {
    // 页面显示时执行
    if (!this.data.isLocationLoaded) {
      this.getUserLocation()
    }
    // 刷新最新预约（可能在其他页面修改了预约）
    this.loadLatestReservation()
  },
  
  // 初始化地图
  initMap: function() {
    // 创建地图上下文
    this.mapCtx = wx.createMapContext('parkingMap', this)
    
    // 先使用默认位置显示地图
    this.setData({
      longitude: 113.3248,
      latitude: 23.1288
    })
    
    // 获取用户位置
    this.getUserLocation()
  },
  
  // 获取用户当前位置
  getUserLocation: function() {
    const that = this
    
    wx.showLoading({ title: '正在获取位置...' })
    
    // 检查权限
    wx.getSetting({
      success: function(res) {
        // 如果没有位置权限，请求授权
        if (!res.authSetting['scope.userLocation']) {
          wx.authorize({
            scope: 'scope.userLocation',
            success: function() {
              // 授权成功，获取位置
              that.fetchLocation()
            },
            fail: function() {
              wx.hideLoading()
              wx.showModal({
                title: '位置权限请求',
                content: '需要获取您的位置信息，以便显示附近的停车场',
                showCancel: false,
                confirmText: '去设置',
                success: function(modalRes) {
                  if (modalRes.confirm) {
                    wx.openSetting({
                      success: function(settingRes) {
                        if (settingRes.authSetting['scope.userLocation']) {
                          that.fetchLocation()
                        } else {
                          // 使用默认位置
                          that.useDefaultLocation()
                        }
                      }
                    })
                  }
                }
              })
            }
          })
        } else {
          // 已有权限，直接获取位置
          that.fetchLocation()
        }
      }
    })
  },
  
  // 获取位置信息
  fetchLocation: function() {
    const that = this
    
    // 确保在调用前有显示loading
    if (!wx.getLoading) {
      // 如果无法检测loading状态，默认显示loading
      wx.showLoading({ title: '正在获取位置...' })
    }
    
    wx.getLocation({
      type: 'gcj02', // 返回可用于wx.openLocation的经纬度
      altitude: true,
      success: function(res) {
        try {
          that.setData({
            latitude: parseFloat(res.latitude) || 23.1288,
            longitude: parseFloat(res.longitude) || 113.3248,
            userLocation: res,
            isLocationLoaded: true
          })
          
          // 更新地图中心位置
          if (that.mapCtx && typeof that.mapCtx.moveToLocation === 'function') {
            that.mapCtx.moveToLocation()
          }
          
          // 加载附近停车场
          if (typeof that.loadNearbyParkings === 'function') {
            that.loadNearbyParkings()
          }
          
          wx.showToast({
            title: '定位成功',
            icon: 'success',
            duration: 1500
          })
        } catch (err) {
          console.error('处理位置数据失败:', err)
          wx.showToast({
            title: '位置数据处理失败',
            icon: 'none',
            duration: 2000
          })
        } finally {
          wx.hideLoading() // 确保隐藏加载状态
        }
      },
      fail: function(err) {
        console.error('获取位置失败:', err)
        if (typeof that.useDefaultLocation === 'function') {
          that.useDefaultLocation()
        }
        wx.showToast({
          title: '定位失败，使用默认位置',
          icon: 'none',
          duration: 2000
        })
        wx.hideLoading() // 确保隐藏加载状态
      },
      complete: function() {
        // 再次确保隐藏加载状态，作为双重保障
        try {
          wx.hideLoading()
        } catch (hideErr) {
          // 忽略hideLoading可能抛出的错误
        }
      }
    })
  },
  
  // 使用默认位置
  useDefaultLocation: function() {
    // 使用默认位置（广州市中心）
    this.setData({
      longitude: 113.3248,
      latitude: 23.1288,
      isLocationLoaded: true
    })
    // 加载默认位置的停车场
    this.loadNearbyParkings()
  },
  
  // 加载附近停车场并生成地图标记（从后端API获取真实数据）
  loadNearbyParkings: function() {
    const app = getApp();
    const that = this;
    
    wx.showLoading({ title: '加载中...' });
    
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/v1/parking/nearby`,
      method: 'GET',
      data: {
        longitude: this.data.longitude,
        latitude: this.data.latitude,
        radius: 10000 // 10公里
      },
      header: {
        'content-type': 'application/json'
      },
      success: function(res) {
        wx.hideLoading();
        
        if (res.statusCode === 200 && res.data.success) {
          // res.data.data 是停车场列表
          const allParkings = Array.isArray(res.data.data) ? res.data.data : [];
          
          console.log('获取到停车场数据:', allParkings.length, '个停车场');
          
          // 处理数据，确保格式统一
      const parkingsWithDistance = allParkings.map(parking => {
            // 确保ID是数字类型
            const parkingId = Number(parking.id) || 0;
            // 确保经纬度是数字类型
            const parkingLng = Number(parking.longitude) || 0;
            const parkingLat = Number(parking.latitude) || 0;
            
            // 计算距离（如果前端需要显示距离）
            const distance = that.calculateDistance(
              that.data.longitude, 
              that.data.latitude, 
              parkingLng, 
              parkingLat
            );
            
        return {
              id: parkingId,
              name: parking.name || '未命名停车场',
              address: parking.address || '',
              area: parking.area || '',
              distance: distance,
              longitude: parkingLng,
              latitude: parkingLat,
              totalSpaces: Number(parking.totalSpaces) || 0,
              availableSpaces: Number(parking.availableSpaces) || 0,
              hourlyRate: Number(parking.hourlyRate) || 0,
              pricePerHour: Number(parking.hourlyRate) || 0,
              status: parking.status || 1
            };
          }).sort((a, b) => a.distance - b.distance);
      
      // 生成地图标记
      const markers = parkingsWithDistance.map((parking, index) => {
        try {
          // 确保ID是数字类型
              const markerId = Number(parking.id) || 0;
              if (markerId <= 0) {
            console.warn(`Invalid parking ID: ${parking.id}`);
            return null; // 跳过无效ID的标记
          }
          
          // 确保经纬度是数字类型
              const markerLatitude = Number(parking.latitude) || 0;
              const markerLongitude = Number(parking.longitude) || 0;
              if (markerLatitude === 0 || markerLongitude === 0) {
            console.warn(`Invalid coordinates for parking ${parking.name}`);
            return null; // 跳过无效坐标的标记
          }
          
          // 根据可用车位数量设置不同的标记颜色
          const color = parking.availableSpaces > 0 ? '#52c41a' : '#ff4d4f';
          
          // 确保不使用iconPath，完全使用默认标记样式
          return {
            id: markerId,
            latitude: markerLatitude,
            longitude: markerLongitude,
            width: 30,
            height: 30,
            title: parking.name || '',
            callout: {
              content: `${parking.name || '未命名停车场'}\n可用车位: ${parking.availableSpaces || 0}/${parking.totalSpaces || 0}\n距离: ${parking.distance ? parking.distance.toFixed(1) : '未知'}km`,
              display: 'BYCLICK',
              fontSize: 12,
              padding: 8,
              borderRadius: 4,
              bgColor: 'rgba(255, 255, 255, 0.9)',
              color: '#333'
            },
            // 不设置iconPath，使用默认标记样式
            // 不设置backgroundColor，使用系统默认颜色
            // 为了兼容不同版本，保留基本属性
          };
        } catch (err) {
          console.error('Error creating marker for parking:', parking.name, err);
          return null; // 跳过创建失败的标记
        }
      }).filter(marker => marker !== null); // 过滤掉无效的标记
      
          that.setData({
        markers: markers,
        nearbyParkings: parkingsWithDistance.slice(0, 5) // 显示前5个最近的停车场
          });
        } else {
          console.error('获取停车场数据失败:', res);
          wx.showToast({
            title: res.data?.message || '加载停车场数据失败',
            icon: 'none',
            duration: 2000
          });
        }
      },
      fail: function(err) {
        wx.hideLoading();
        console.error('加载停车场数据失败:', err);
      wx.showToast({
          title: '网络请求失败',
        icon: 'none',
        duration: 2000
        });
    }
    });
  },
  
  // 计算两点之间的距离（单位：公里）
  calculateDistance: function(lng1, lat1, lng2, lat2) {
    const R = 6371 // 地球半径（公里）
    const dLat = (lat2 - lat1) * Math.PI / 180
    const dLng = (lng2 - lng1) * Math.PI / 180
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLng/2) * Math.sin(dLng/2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    return R * c
  },
  
  // 重新定位到用户当前位置
  locateMe: function() {
    wx.showLoading({
      title: '定位中...',
      mask: true
    })
    
    try {
      if (this.data.isLocationLoaded && typeof this.fetchLocation === 'function') {
        // fetchLocation内部已经处理了loading状态的隐藏
        this.fetchLocation()
        
        // 动画移动到当前位置
        setTimeout(() => {
          if (this.mapCtx && typeof this.mapCtx.animateTo === 'function') {
            this.mapCtx.animateTo({
              latitude: this.data.latitude,
              longitude: this.data.longitude,
              duration: 1000
            })
          }
        }, 1000)
      } else {
        if (typeof this.getUserLocation === 'function') {
          // getUserLocation内部已经处理了loading状态的隐藏
          this.getUserLocation()
        } else {
          wx.hideLoading()
        }
      }
    } catch (err) {
      console.error('重新定位失败:', err)
      wx.hideLoading()
      wx.showToast({
        title: '定位失败',
        icon: 'none',
        duration: 2000
      })
    }
  },
  
  // 点击停车场标记
  onMarkerTap: function(e) {
    const markerId = e.markerId
    this.navigateToDetail({ currentTarget: { dataset: { id: markerId } } })
  },
  
  // 点击最近停车场列表项
  navigateToDetail: function(e) {
    // 关键修复：确保ID是数字类型
    let parkingId = e.currentTarget.dataset.id;
    
    // 转换为数字类型
    parkingId = Number(parkingId);
    
    // 验证ID是否有效
    if (isNaN(parkingId) || parkingId <= 0) {
      console.error('无效的停车场ID:', e.currentTarget.dataset.id, '转换后:', parkingId);
      wx.showToast({
        title: '无效的停车场ID',
        icon: 'none',
        duration: 2000
      });
      return;
    }
    
    console.log('跳转到停车场详情，ID:', parkingId, '类型:', typeof parkingId);
    
    wx.navigateTo({
      url: `/pages/parking/detail?id=${parkingId}`,
      fail: function(err) {
        console.error('跳转到停车场详情失败:', err)
        wx.showToast({
          title: '页面跳转失败',
          icon: 'none',
          duration: 2000
        })
      }
    })
  },
  
  // 地图加载完成
  onMapLoaded: function() {
    console.log('地图加载完成')
  },
  
  // 地图移动结束
  onRegionChange: function(e) {
    // 只有手动拖动地图时才重新加载数据
    if (e.type === 'end' && e.causedBy === 'drag') {
      this.mapCtx.getCenterLocation({
        success: function(res) {
          // 更新当前位置
          this.setData({
            longitude: res.longitude,
            latitude: res.latitude
          })
          // 重新加载附近停车场
          this.loadNearbyParkings()
        }.bind(this)
      })
    }
  },

  // 加载推荐停车场（从后端API获取真实数据）
  loadRecommendedParkings: function() {
    const app = getApp();
    const that = this;
    
    wx.showLoading({ title: '加载中' })
    
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/v1/parking/nearby`,
      method: 'GET',
      data: {
        longitude: this.data.longitude || 113.3248,
        latitude: this.data.latitude || 23.1288,
        radius: 10000 // 10公里
      },
      header: {
        'content-type': 'application/json'
      },
      success: function(res) {
        wx.hideLoading();
        
        if (res.statusCode === 200 && res.data.success) {
          // res.data.data 是停车场列表
          let allParkings = Array.isArray(res.data.data) ? res.data.data : [];
          
          // 处理数据，确保ID是数字类型
          const recommendedData = allParkings.slice(0, 5).map(parking => {
            const parkingId = Number(parking.id) || 0;
            const parkingLng = Number(parking.longitude) || 0;
            const parkingLat = Number(parking.latitude) || 0;
            
            // 计算距离
            const distance = that.calculateDistance(
              that.data.longitude || 113.3248,
              that.data.latitude || 23.1288,
              parkingLng,
              parkingLat
            );
            
            return {
              id: parkingId, // 关键：确保ID是数字
              name: parking.name || '未命名停车场',
              address: parking.address || '',
              area: parking.area || '',
              distance: distance * 1000, // 转换为米
              longitude: parkingLng,
              latitude: parkingLat,
              totalSpaces: Number(parking.totalSpaces) || 0,
              availableSpaces: Number(parking.availableSpaces) || 0,
              hourlyRate: Number(parking.hourlyRate) || 0,
              pricePerHour: Number(parking.hourlyRate) || 0,
              status: parking.status || 1
            };
          }).sort((a, b) => a.distance - b.distance); // 按距离排序
          
          that.setData({
          recommendedParkings: recommendedData
          });
        } else {
          console.error('获取推荐停车场失败:', res);
          // 如果API失败，设置为空数组，不显示推荐停车场
          that.setData({
            recommendedParkings: []
          });
        }
      },
      fail: function(err) {
        wx.hideLoading();
        console.error('加载推荐停车场失败:', err);
        // 如果网络请求失败，设置为空数组
        that.setData({
          recommendedParkings: []
        });
      }
    });
  },

  // 自动登录
  handleAutoLogin: function() {
    app.login().then(() => {
      console.log('自动登录成功')
    }).catch(error => {
      console.log('自动登录失败', error)
    })
  },

  // 验证页面是否存在的辅助函数
  validatePageExists: function(pagePath) {
    // 获取小程序的页面列表
    const pages = getApp().globalData.pages || getCurrentPages();
    // 如果无法获取全局页面列表，则尝试通过配置的tabBar判断
    const tabBarPages = getApp().globalData.tabBarPages || [
      'pages/index/index',
      'pages/parking/list',
      'pages/reservation/index',
      'pages/user/profile'
    ];
    
    // 检查是否为tabBar页面或已加载的页面
    return tabBarPages.includes(pagePath) || 
           (pages && Array.isArray(pages) && pages.some(page => page.route === pagePath));
  },

  // 页面跳转的统一处理函数
  navigateToPage: function(pagePath, isTabBar = false, queryParams = '') {
    // 构建完整的URL
    const url = queryParams ? `${pagePath}?${queryParams}` : pagePath;
    
    try {
      // 验证页面是否存在（在实际开发中，这里应该有更完善的页面存在性检查）
      // 由于这是模拟环境，我们假设app.json中配置的页面都可以访问
      
      // 使用合适的跳转方法
      if (isTabBar) {
        wx.switchTab({
          url: url,
          fail: function(err) {
            console.error('Tab页面跳转失败:', err);
            wx.showToast({
              title: '页面加载失败',
              icon: 'none',
              duration: 2000
            });
          }
        });
      } else {
        wx.navigateTo({
          url: url,
          fail: function(err) {
            console.error('页面跳转失败:', err);
            wx.showToast({
              title: '页面加载失败',
              icon: 'none',
              duration: 2000
            });
          }
        });
      }
    } catch (error) {
      console.error('页面跳转异常:', error);
      wx.showToast({
        title: '系统繁忙，请稍后再试',
        icon: 'none',
        duration: 2000
      });
    }
  },

  // 跳转到停车场列表
  // 加载最新预约
  loadLatestReservation: function() {
    const app = getApp();
    const that = this;
    
    // 检查是否有token
    if (!app.globalData.token) {
      this.setData({
        latestReservation: null
      });
      return;
    }
    
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/reservations/user`,
      method: 'GET',
      data: {
        pageNum: 1,
        pageSize: 1
      },
      success: function(res) {
        if (res.statusCode === 200 && res.data && res.data.length > 0) {
          const item = res.data[0];
          const parkingName = item.parkingLotName || item.parkingName || '未知停车场';
          
          // 获取车位号
          let spaceNumber = '未知车位';
          if (item.parkingSpace) {
            const floor = item.parkingSpace.floor || '';
            const spaceNum = item.parkingSpace.spaceNumber || '';
            if (floor || spaceNum) {
              spaceNumber = floor && spaceNum ? `${floor}-${spaceNum}` : (floor || spaceNum);
            }
          }
          
          // 格式化日期时间
          let dateTime = '';
          if (item.startTime && item.endTime) {
            const start = new Date(item.startTime);
            const end = new Date(item.endTime);
            const dateStr = `${start.getFullYear()}-${String(start.getMonth() + 1).padStart(2, '0')}-${String(start.getDate()).padStart(2, '0')}`;
            const startTime = `${String(start.getHours()).padStart(2, '0')}:${String(start.getMinutes()).padStart(2, '0')}`;
            const endTime = `${String(end.getHours()).padStart(2, '0')}:${String(end.getMinutes()).padStart(2, '0')}`;
            dateTime = `${dateStr} ${startTime} - ${endTime}`;
          }
          
          // 获取状态
          const statusMap = {
            0: '待使用',
            1: '已使用',
            2: '已取消',
            3: '已超时'
          };
          const status = statusMap[item.status] || '未知状态';
          const statusClassMap = {
            0: 'pending',
            1: 'completed',
            2: 'cancelled',
            3: 'expired'
          };
          const statusClass = statusClassMap[item.status] || 'pending';
          
          // 获取停车场位置信息（从预约详情或停车场信息中获取）
          let longitude = null;
          let latitude = null;
          
          // 尝试从多个可能的字段获取位置信息
          if (item.parkingLot && item.parkingLot.longitude && item.parkingLot.latitude) {
            longitude = item.parkingLot.longitude;
            latitude = item.parkingLot.latitude;
          } else if (item.longitude && item.latitude) {
            longitude = item.longitude;
            latitude = item.latitude;
          }
          
          that.setData({
            latestReservation: {
              id: item.id,
              parkingName: parkingName,
              parkingAddress: item.parkingLotAddress || item.parkingAddress || '',
              spaceNumber: spaceNumber,
              status: status,
              statusClass: statusClass,
              dateTime: dateTime,
              price: item.amount || '0.00',
              parkingId: item.parkingId,
              longitude: longitude,
              latitude: latitude,
              thumbnail: item.thumbnail || item.parkingLot?.thumbnail || null
            }
          });
        } else {
          that.setData({
            latestReservation: null
          });
        }
      },
      fail: function(err) {
        console.error('加载最新预约失败:', err);
        that.setData({
          latestReservation: null
        });
      }
    });
  },
  
  // 跳转到预约列表页
  goToReservationList: function() {
    wx.switchTab({
      url: '/pages/reservation/index',
      fail: function() {
        wx.showToast({
          title: '跳转失败',
          icon: 'none'
        });
      }
    });
  },
  
  // 解锁车位
  unlockSpace: function(e) {
    const reservationId = e.currentTarget.dataset.id;
    wx.showModal({
      title: '解锁车位',
      content: '确定要解锁车位吗？',
      success: (res) => {
        if (res.confirm) {
          // TODO: 调用解锁车位API
          wx.showToast({
            title: '功能开发中',
            icon: 'none'
          });
        }
      }
    });
  },
  
  // 取消预约
  cancelReservation: function(e) {
    const reservationId = e.currentTarget.dataset.id;
    wx.showModal({
      title: '取消预约',
      content: '确定要取消此预约吗？',
      success: (res) => {
        if (res.confirm) {
          const app = getApp();
          wx.request({
            url: `${app.globalData.apiBaseUrl}/api/reservations/${reservationId}/cancel`,
            method: 'POST',
            success: (res) => {
              if (res.statusCode === 200) {
                wx.showToast({
                  title: '取消成功',
                  icon: 'success'
                });
                // 刷新最新预约
                this.loadLatestReservation();
              } else {
                wx.showToast({
                  title: res.data?.message || '取消失败',
                  icon: 'none'
                });
              }
            },
            fail: (err) => {
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
  
  // 导航到停车场
  navigateToParking: function(e) {
    const reservationId = e.currentTarget.dataset.id;
    const reservation = this.data.latestReservation;
    
    if (reservation && reservation.longitude && reservation.latitude) {
      wx.openLocation({
        latitude: parseFloat(reservation.latitude),
        longitude: parseFloat(reservation.longitude),
        name: reservation.parkingName,
        address: reservation.parkingAddress,
        fail: (err) => {
          wx.showToast({
            title: '打开地图失败',
            icon: 'none'
          });
        }
      });
    } else {
      wx.showToast({
        title: '暂无位置信息',
        icon: 'none'
      });
    }
  },
  
  goToParkingList: function() {
    wx.switchTab({
      url: '/pages/parking/list'
    })
  },

  // 初始化数据
  initData: function() {
    // 初始化附近停车场数据
    this.setData({
      nearbyParkings: []
    });
  },

  // 搜索输入事件
  onSearchInput: function(e) {
    const keyword = e.detail.value;
    this.setData({
      searchKeyword: keyword
    });
    
    // 清除之前的定时器
    if (this.data.searchTimer) {
      clearTimeout(this.data.searchTimer);
    }
    
    // 如果关键词为空，隐藏搜索结果
    if (!keyword || keyword.trim() === '') {
      this.setData({
        showSearchResults: false,
        searchResults: []
      });
      return;
    }
    
    // 防抖处理：延迟500ms后执行搜索
    const timer = setTimeout(() => {
      this.performSearch(keyword.trim());
    }, 500);
    
    this.setData({
      searchTimer: timer
    });
  },

  // 搜索确认事件（点击搜索按钮）
  onSearchConfirm: function(e) {
    const keyword = e.detail.value;
    if (!keyword || keyword.trim() === '') {
      return;
    }
    
    // 清除防抖定时器
    if (this.data.searchTimer) {
      clearTimeout(this.data.searchTimer);
    }
    
    this.performSearch(keyword.trim());
  },

  // 执行搜索
  performSearch: function(keyword) {
    const app = getApp();
    const that = this;
    
    if (!keyword || keyword.trim() === '') {
      return;
    }
    
    wx.showLoading({ title: '搜索中...' });
    
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/v1/parking/search`,
      method: 'GET',
      data: {
        keyword: keyword
      },
      header: {
        'content-type': 'application/json'
      },
      success: function(res) {
        wx.hideLoading();
        
        if (res.statusCode === 200 && res.data.success) {
          const results = Array.isArray(res.data.data) ? res.data.data : [];
          
          // 处理搜索结果数据
          const formattedResults = results.map(parking => {
            const parkingId = Number(parking.id) || 0;
            const parkingLng = Number(parking.longitude) || 0;
            const parkingLat = Number(parking.latitude) || 0;
            
            // 计算距离（如果有用户位置）
            let distance = 0;
            if (that.data.longitude && that.data.latitude && parkingLng && parkingLat) {
              distance = that.calculateDistance(
                that.data.longitude,
                that.data.latitude,
                parkingLng,
                parkingLat
              );
            }
            
            return {
              id: parkingId,
              name: parking.name || '未命名停车场',
              address: parking.address || '',
              hourlyRate: Number(parking.hourlyRate) || 0,
              totalSpaces: Number(parking.totalSpaces) || 0,
              availableSpaces: Number(parking.availableSpaces) || 0,
              distance: distance,
              longitude: parkingLng,
              latitude: parkingLat
            };
          });
          
          that.setData({
            searchResults: formattedResults,
            showSearchResults: true
          });
        } else {
          wx.showToast({
            title: res.data?.message || '搜索失败',
            icon: 'none',
            duration: 2000
          });
          that.setData({
            searchResults: [],
            showSearchResults: true
          });
        }
      },
      fail: function(err) {
        wx.hideLoading();
        console.error('搜索失败:', err);
        wx.showToast({
          title: '网络请求失败',
          icon: 'none',
          duration: 2000
        });
        that.setData({
          searchResults: [],
          showSearchResults: false
        });
      }
    });
  },

  // 清除搜索
  clearSearch: function() {
    this.setData({
      searchKeyword: '',
      searchResults: [],
      showSearchResults: false
    });
    
    // 清除防抖定时器
    if (this.data.searchTimer) {
      clearTimeout(this.data.searchTimer);
      this.setData({
        searchTimer: null
      });
    }
  },

  // 关闭搜索结果
  closeSearchResults: function() {
    this.setData({
      showSearchResults: false,
      isSearchFocused: false
    });
  },
  
  // ==================== 语音功能 ====================
  
  // 打开语音识别浮层
  startVoiceRecognition: function() {
    // 初始化语音识别
    voiceRecognition.initVoiceRecognition();
    
    // 设置识别结果回调
    voiceRecognition.setResultCallback((text) => {
      this.setData({
        recognitionText: text
      });
      // 自动调用后端API处理
      this.processVoiceCommand(text);
    });
    
    // 显示语音浮层
    this.setData({
      showVoiceModal: true,
      isRecording: false,
      recognitionText: '',
      voiceResult: null
    });
  },
  
  // 关闭语音识别浮层
  closeVoiceModal: function() {
    // 如果正在录音，先停止
    if (this.data.isRecording) {
      voiceRecognition.stopRecord();
    }
    
    this.setData({
      showVoiceModal: false,
      isRecording: false,
      recognitionText: '',
      voiceResult: null
    });
  },
  
  // 阻止事件冒泡（防止点击内容区域关闭浮层）
  stopPropagation: function() {
    // 空函数，用于阻止事件冒泡
  },
  
  // 开始录音
  onStartRecord: function() {
    if (this.data.isRecording) {
      return;
    }
    
    const success = voiceRecognition.startRecord({
      lang: 'zh_CN'
    });
    
    if (success) {
      this.setData({
        isRecording: true,
        recognitionText: '',
        voiceResult: null
      });
    } else {
      wx.showToast({
        title: '启动录音失败',
        icon: 'none'
      });
    }
  },
  
  // 停止录音
  onStopRecord: function() {
    if (!this.data.isRecording) {
      return;
    }
    
    voiceRecognition.stopRecord();
    this.setData({
      isRecording: false
    });
  },
  
  // 取消录音
  onCancelRecord: function() {
    voiceRecognition.cancelRecord();
    this.setData({
      isRecording: false,
      recognitionText: '',
      voiceResult: null
    });
  },
  
  // 处理语音指令
  processVoiceCommand: function(text) {
    if (!text || text.trim().length === 0) {
      return;
    }

    wx.showLoading({
      title: '处理中...'
    });

    // 调用后端语音处理API
    // 注意：语音处理需要调用大模型，可能需要较长时间，所以直接使用wx.request并设置更长的超时时间
    wx.request({
      url: `${app.globalData.apiBaseUrl}/api/v1/voice/process`,
      method: 'POST',
      data: {
        command: text
      },
      header: {
        'content-type': 'application/json'
      },
      timeout: 60000, // 设置为60秒，因为需要调用讯飞API
      success: (res) => {
        const response = res.data;
      wx.hideLoading();
      
      if (response.status === 'success') {
        this.setData({
          voiceResult: response
        });
        
        wx.showToast({
          title: response.message || '处理成功',
          icon: 'success',
          duration: 2000
        });
        
        // 如果是预约指令，可以自动刷新附近停车场
        if (response.commandType === 'reserve' || response.commandType === 'nearby') {
          // 延迟刷新，让用户看到结果
          setTimeout(() => {
            this.loadNearbyParkings();
            this.loadRecommendedParkings();
          }, 1500);
        }
      } else {
        this.setData({
          voiceResult: {
            status: 'fail',
            message: response.message || '处理失败'
          }
        });
        
        wx.showToast({
          title: response.message || '处理失败',
          icon: 'none'
        });
      }
      },
      fail: (error) => {
      wx.hideLoading();
      console.error('处理语音指令失败:', error);
        
        let errorMsg = '处理失败，请稍后重试';
        if (error.errMsg && error.errMsg.includes('time out')) {
          errorMsg = '处理超时，请稍后重试（语音处理可能需要更长时间）';
        } else if (error.errMsg && error.errMsg.includes('fail')) {
          errorMsg = '网络请求失败，请检查网络连接';
        }
      
      this.setData({
        voiceResult: {
          status: 'fail',
            message: errorMsg
        }
      });
      
      wx.showToast({
          title: errorMsg,
          icon: 'none',
          duration: 3000
      });
      }
    });
  }
})