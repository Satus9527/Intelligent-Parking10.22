//app.js
App({
  globalData: {
    userInfo: null,
    token: '',
    apiBaseUrl: 'http://172.20.10.5:8081', // 修改为后端实际API地址（真机测试使用局域网IP）
    mockMode: false, // 关闭模拟模式，使用真实API
    appConfig: {
      debug: true,
      timeout: 10000
    },
    // 高德地图 API Key（微信小程序端）
    amapApiKey: '6f2913cf2e046ca0e89c34f65cc2b810'
  },

  onLaunch: function() {
    // 展示本地存储能力
    const logs = wx.getStorageSync('logs') || []
    logs.unshift(Date.now())
    wx.setStorageSync('logs', logs)

    // 检查登录状态
    this.checkLoginStatus()

    // 获取系统信息
    const systemInfo = wx.getSystemInfoSync()
    this.globalData.systemInfo = systemInfo

    console.log('小程序启动成功')
  },

  onShow: function() {
    // 小程序显示时执行
  },

  onHide: function() {
    // 小程序隐藏时执行
  },

  checkLoginStatus: function() {
    const token = wx.getStorageSync('token')
    const userInfo = wx.getStorageSync('userInfo')
    
    if (token && userInfo) {
      this.globalData.token = token
      this.globalData.userInfo = userInfo
      console.log('用户已登录')
    } else {
      console.log('用户未登录')
    }
  },

  login: function() {
    return new Promise((resolve, reject) => {
      // 模拟模式下直接返回模拟数据
      if (this.globalData.mockMode) {
        setTimeout(() => {
          const mockToken = 'mock_token_' + Date.now()
          const mockUserInfo = {
            id: 1,
            username: '测试用户',
            avatar: '',
            phone: '138****8888'
          }
          this.globalData.token = mockToken
          this.globalData.userInfo = mockUserInfo
          wx.setStorageSync('token', mockToken)
          wx.setStorageSync('userInfo', mockUserInfo)
          console.log('模拟登录成功')
          resolve({ token: mockToken, userInfo: mockUserInfo })
        }, 500)
        return
      }
      
      // 正常模式下调用真实登录接口
      wx.login({
        success: (res) => {
          if (res.code) {
            // 发送 res.code 到后台换取 openId, sessionKey, unionId
            wx.request({
              url: `${this.globalData.apiBaseUrl}/auth/login`,
              method: 'POST',
              data: {
                code: res.code
              },
              success: (response) => {
                const { token, userInfo } = response.data
                if (token) {
                  this.globalData.token = token
                  this.globalData.userInfo = userInfo
                  wx.setStorageSync('token', token)
                  wx.setStorageSync('userInfo', userInfo)
                  resolve({ token, userInfo })
                } else {
                  reject(new Error('登录失败'))
                }
              },
              fail: (err) => {
                reject(err)
              }
            })
          } else {
            reject(new Error('获取登录凭证失败'))
          }
        },
        fail: (err) => {
          reject(err)
        }
      })
    })
  },

  // 封装网络请求
  request: function(options) {
    const { url, method = 'GET', data = {}, header = {} } = options
    
    // 添加认证头
    if (this.globalData.token) {
      header['Authorization'] = `Bearer ${this.globalData.token}`
    }

    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.globalData.apiBaseUrl}${url}`,
        method,
        data,
        header: {
          'content-type': 'application/json',
          ...header
        },
        timeout: this.globalData.appConfig.timeout,
        success: (res) => {
          // 处理业务错误
          if (res.data.code && res.data.code !== 200) {
            wx.showToast({
              title: res.data.message || '请求失败',
              icon: 'none'
            })
            reject(res.data)
          } else {
            resolve(res.data)
          }
        },
        fail: (err) => {
          wx.showToast({
            title: '网络请求失败',
            icon: 'none'
          })
          reject(err)
        }
      })
    })
  }
})