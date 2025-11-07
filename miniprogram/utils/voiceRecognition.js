/**
 * 语音转写工具类
 * 方案1：使用微信同声传译插件（需要在小程序后台添加插件）
 * 方案2：使用微信原生录音API + 后端语音识别（当前实现）
 */
let resultCallback = null;
let recorderManager = null;

/**
 * 初始化语音识别管理器
 */
function initVoiceRecognition() {
  // 尝试使用插件（如果已配置）
  let usePlugin = false;
  try {
    // 检查插件是否在app.json中配置
    const appConfig = getApp().globalData?.appConfig || {};
    
    // 尝试加载插件
    const plugin = requirePlugin("WechatSI");
    if (plugin && typeof plugin.getRecordRecognitionManager === 'function') {
      recorderManager = plugin.getRecordRecognitionManager();
      if (recorderManager) {
        setupPluginCallbacks();
        console.log("✓ 使用微信同声传译插件");
        usePlugin = true;
        return recorderManager;
      }
    }
  } catch (error) {
    // 插件未配置或加载失败，这是正常的
    console.log("ℹ 插件未配置或加载失败，使用原生录音API: ", error.message || error);
  }
  
  // 使用微信原生录音API（降级方案）
  if (!usePlugin) {
    try {
      recorderManager = wx.getRecorderManager();
      if (recorderManager) {
        setupNativeCallbacks();
        console.log("✓ 使用微信原生录音API");
        return recorderManager;
      }
    } catch (error) {
      console.error("✗ 无法初始化录音管理器: ", error);
      wx.showToast({
        title: "录音功能初始化失败",
        icon: "none"
      });
    }
  }
  
  return recorderManager;
}

/**
 * 设置插件回调函数
 */
function setupPluginCallbacks() {
  if (!recorderManager) return;
  
  // 识别结束回调
  recorderManager.onStop = (res) => {
    console.log("插件识别结果: ", res.result);
    if (res.result && resultCallback) {
      resultCallback(res.result);
    } else {
      console.error("未能识别到声音");
      if (typeof wx !== 'undefined' && wx.showToast) {
        wx.showToast({
          title: "未能识别到声音",
          icon: "none"
        });
      }
    }
  };

  // 识别错误回调
  recorderManager.onError = (err) => {
    console.error("插件识别失败: ", err);
    if (typeof wx !== 'undefined' && wx.showToast) {
      wx.showToast({
        title: "语音识别失败: " + (err.msg || err.errMsg || "未知错误"),
        icon: "none"
      });
    }
  };

  // 识别开始回调
  recorderManager.onStart = () => {
    console.log("插件开始语音识别");
  };
}

/**
 * 设置原生录音API回调函数
 */
function setupNativeCallbacks() {
  if (!recorderManager) return;
  
  recorderManager.onStop((res) => {
    console.log("录音结束: ", res);
    const { tempFilePath, duration } = res;
    
    if (tempFilePath) {
      // 自动上传录音文件到后端进行识别
      if (resultCallback) {
        uploadAudioFile(tempFilePath);
      } else {
        // 如果没有设置回调，提示用户
        wx.showModal({
          title: '提示',
          content: '录音完成，正在上传识别中...',
          showCancel: false
        });
        uploadAudioFile(tempFilePath);
      }
    } else {
      wx.showToast({
        title: "录音文件获取失败",
        icon: "none"
      });
    }
  });

  recorderManager.onError((err) => {
    console.error("录音失败: ", err);
    wx.showToast({
      title: "录音失败: " + (err.errMsg || "未知错误"),
      icon: "none"
    });
  });

  recorderManager.onStart(() => {
    console.log("✓ 开始录音（原生API）");
  });
}

/**
 * 上传音频文件到后端进行识别
 */
function uploadAudioFile(filePath) {
  wx.showLoading({
    title: '识别中...'
  });

  // 这里需要实现上传逻辑
  // 示例：上传到后端API
  const app = getApp();
  wx.uploadFile({
    url: `${app.globalData.apiBaseUrl}/api/v1/voice/upload`,
    filePath: filePath,
    name: 'audio',
    formData: {
      'format': 'mp3'
    },
    success: (res) => {
      wx.hideLoading();
      try {
        const data = JSON.parse(res.data);
        if (data.status === 'success' && data.text && resultCallback) {
          resultCallback(data.text);
        } else {
          wx.showToast({
            title: data.message || '识别失败',
            icon: 'none'
          });
        }
      } catch (error) {
        console.error('解析识别结果失败:', error);
        wx.showToast({
          title: '识别失败',
          icon: 'none'
        });
      }
    },
    fail: (err) => {
      wx.hideLoading();
      console.error('上传录音文件失败:', err);
      wx.showToast({
        title: '上传失败，请检查网络',
        icon: 'none'
      });
    }
  });
}

/**
 * 开始录音
 * @param {Object} options 配置选项
 * @param {String} options.lang 语言类型，默认 'zh_CN'
 */
function startRecord(options = {}) {
  try {
    if (!recorderManager) {
      initVoiceRecognition();
    }

    // 检查是否是插件模式
    if (recorderManager && typeof recorderManager.start === 'function' && recorderManager.start.length === 1) {
      // 插件模式
      recorderManager.start({
        lang: options.lang || 'zh_CN'
      });
    } else {
      // 原生API模式
      recorderManager.start({
        duration: 60000, // 最长录音时间60秒
        sampleRate: 16000, // 采样率
        numberOfChannels: 1, // 录音通道数
        encodeBitRate: 96000, // 编码码率
        format: 'mp3', // 音频格式
        frameSize: 50 // 指定帧大小
      });
    }
    return true;
  } catch (error) {
    console.error("开始录音失败: ", error);
    wx.showToast({
      title: "启动录音失败",
      icon: "none"
    });
    return false;
  }
}

/**
 * 停止录音
 */
function stopRecord() {
  try {
    if (recorderManager && typeof recorderManager.stop === 'function') {
      recorderManager.stop();
      return true;
    }
    return false;
  } catch (error) {
    console.error("停止录音失败: ", error);
    return false;
  }
}

/**
 * 取消录音
 */
function cancelRecord() {
  try {
    if (recorderManager) {
      if (typeof recorderManager.cancel === 'function') {
        recorderManager.cancel();
      } else if (typeof recorderManager.stop === 'function') {
        recorderManager.stop();
      }
    }
    return true;
  } catch (error) {
    console.error("取消录音失败: ", error);
    return false;
  }
}

/**
 * 设置识别结果回调
 * @param {Function} callback 回调函数，参数为识别结果文本
 */
function setResultCallback(callback) {
  resultCallback = callback;
}

module.exports = {
  startRecord,
  stopRecord,
  cancelRecord,
  setResultCallback,
  initVoiceRecognition
};

