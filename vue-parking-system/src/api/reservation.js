import request from './request'

/**
 * 创建预约
 * @param {Object} reservationData - 预约数据
 * @returns {Promise} - 返回预约结果
 */
export const createReservation = async (reservationData) => {
  try {
    console.log('发送预约请求，数据:', reservationData)
    const response = await request.post('/api/reservations', reservationData)
    console.log('预约响应:', response)
    return response.data
  } catch (error) {
    console.error('创建预约失败:', error)
    // 提取错误消息
    let errorMessage = '预约失败，请稍后重试'
    if (error.response?.data) {
      const errorData = error.response.data
      if (errorData.message) {
        errorMessage = errorData.message
      } else if (typeof errorData === 'string') {
        errorMessage = errorData
      }
    } else if (error.message) {
      errorMessage = error.message
    }
    
    // 创建带有详细错误信息的错误对象
    const enhancedError = new Error(errorMessage)
    enhancedError.originalError = error
    enhancedError.statusCode = error.response?.status
    enhancedError.data = error.response?.data
    
    throw enhancedError
  }
}

/**
 * 检查车位可用性
 * @param {Object} params - 查询参数
 * @returns {Promise} - 返回检查结果
 */
export const checkSpaceAvailability = async (params) => {
  try {
    const response = await request.get('/api/reservations/check-availability', { params })
    return response.data
  } catch (error) {
    console.error('检查车位可用性失败:', error)
    throw error.response?.data || new Error('检查失败，请稍后重试')
  }
}

/**
 * 获取预约详情
 * @param {number} reservationId - 预约ID
 * @returns {Promise} - 返回预约详情
 */
export const getReservationDetail = async (reservationId) => {
  try {
    const response = await request.get(`/api/reservations/${reservationId}`)
    return response.data
  } catch (error) {
    console.error('获取预约详情失败:', error)
    throw error.response?.data || new Error('获取详情失败，请稍后重试')
  }
}

/**
 * 获取用户预约列表
 * @param {Object} params - 查询参数
 * @returns {Promise} - 返回预约列表
 */
export const getUserReservations = async (params = {}) => {
  try {
    const response = await request.get('/api/reservations/user', { params })
    return response.data
  } catch (error) {
    console.error('获取用户预约列表失败:', error)
    throw error.response?.data || new Error('获取列表失败，请稍后重试')
  }
}

/**
 * 取消预约
 * @param {number} reservationId - 预约ID
 * @returns {Promise} - 返回取消结果
 */
export const cancelReservationById = async (reservationId) => {
  try {
    const response = await request.post(`/api/reservations/${reservationId}/cancel`)
    return response.data
  } catch (error) {
    console.error('取消预约失败:', error)
    throw error.response?.data || new Error('取消失败，请稍后重试')
  }
}