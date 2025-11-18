import axios from 'axios'
import { showErrorToast } from '../utils'

// 创建axios实例
const service = axios.create({
  baseURL: 'http://172.20.10.5:8081', // 后端API基础URL（真机测试使用局域网IP）
  timeout: 10000, // 请求超时时间
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    // 可以在这里添加token等认证信息
    const token = localStorage.getItem('token')
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }
    return config
  },
  error => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    return response
  },
  error => {
    // 统一错误处理
    let errorMessage = '网络异常，请稍后重试'
    
    if (error.response) {
      // 服务器返回错误状态码
      switch (error.response.status) {
        case 400:
          errorMessage = error.response.data?.message || '请求参数错误'
          break
        case 401:
          errorMessage = '未授权，请重新登录'
          // 可以在这里处理登出逻辑
          localStorage.removeItem('token')
          break
        case 403:
          errorMessage = '没有权限访问该资源'
          break
        case 404:
          errorMessage = '请求的资源不存在'
          break
        case 500:
          errorMessage = '服务器内部错误'
          break
        default:
          errorMessage = error.response.data?.message || `请求失败: ${error.response.status}`
      }
    } else if (error.request) {
      // 请求已发出但没有收到响应
      errorMessage = '服务器无响应，请稍后重试'
    }
    
    // 显示错误提示
    showErrorToast(errorMessage)
    console.error('响应错误:', error)
    
    return Promise.reject(error)
  }
)

export default service