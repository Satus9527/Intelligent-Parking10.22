// utils/parkingImageUtils.js
// 停车场图片工具函数

/**
 * 根据停车场ID或名称获取图片路径
 * @param {Number|String} parkingId - 停车场ID
 * @param {String} parkingName - 停车场名称
 * @returns {String|null} 图片路径（相对路径），如果没有则返回null
 */
function getParkingImage(parkingId, parkingName) {
  const id = Number(parkingId);
  const name = parkingName || '';
  
  // 注意：这里返回的是相对 static/images 目录的路径，前端会用 imageBaseUrl 拼接成完整 URL
  // 例如：imageBaseUrl = http://服务器:8082/images
  // 返回 '/taiguhui.jpg' => http://服务器:8082/images/taiguhui.jpg

  // 太古汇停车场（ID=1 或名称包含"太古汇"）
  if (id === 1 || name.includes('太古汇')) {
    return '/taiguhui.jpg';
  }
  
  // 正佳广场停车场（ID=2 或名称包含"正佳广场"）
  if (id === 2 || name.includes('正佳广场')) {
    return '/zhengjia-square.jpg';
  }
  
  // 天河城停车场（ID=3 或名称包含"天河城"）
  if (id === 3 || name.includes('天河城')) {
    return '/tianhemall.jpg';
  }
  
  // 万菱汇停车场（ID=4 或名称包含"万菱汇"）
  if (id === 4 || name.includes('万菱汇')) {
    return '/wanlinghui.jpg';
  }
  
  // 广州塔停车场（ID=5 或名称包含"广州塔"）
  if (id === 5 || name.includes('广州塔')) {
    return '/cantontower.jpg';
  }
  
  // 北京路停车场（ID=6 或名称包含"北京路"）
  if (id === 6 || name.includes('北京路')) {
    return '/beijingroad.jpg';
  }
  
  // 白云山风景区停车场（ID=7 或名称包含"白云山"）
  if (id === 7 || name.includes('白云山')) {
    return '/baiyunmoutain.jpg';
  }
  
  // 越秀公园停车场（ID=8 或名称包含"越秀公园"）
  if (id === 8 || name.includes('越秀公园')) {
    return '/yuexiupark.jpg';
  }
  
  // 广州动物园停车场（ID=9 或名称包含"广州动物园"）
  if (id === 9 || name.includes('广州动物园')) {
    return '/zoo.jpg';
  }
  
  // 广东省博物馆停车场（ID=10 或名称包含"广东省博物馆"）
  if (id === 10 || name.includes('广东省博物馆')) {
    return '/guangdongmuseum.jpg';
  }
  
  // 长隆欢乐世界停车场（ID=11 或名称包含"长隆"）
  if (id === 11 || name.includes('长隆')) {
    return '/changlong.jpg';
  }
  
  // 百万葵园停车场（ID=12 或名称包含"百万葵园"）
  if (id === 12 || name.includes('百万葵园')) {
    return '/baiwankuiyuan.jpg';
  }
  
  // 海鸥岛停车场（ID=14 或名称包含"海鸥岛"）
  if (id === 14 || name.includes('海鸥岛')) {
    return '/haiouisland.jpg';
  }
  
  // 莲花山停车场（ID=15 或名称包含"莲花山"）
  if (id === 15 || name.includes('莲花山')) {
    return '/lianhuamoutain.jpg';
  }
  
  // 客村停车场（ID=16 或名称包含"客村"）
  if (id === 16 || name.includes('客村')) {
    return '/kecun.jpg';
  }
  
  // 祈福新村停车场（ID=17 或名称包含"祈福新村"）
  if (id === 17 || name.includes('祈福新村')) {
    return '/qifuxincun.jpg';
  }
  
  // 天汇广场停车场（ID=18 或名称包含"天汇广场"）
  if (id === 18 || name.includes('天汇广场')) {
    return '/tianhui.jpg';
  }
  
  // 广百百货停车场（ID=19 或名称包含"广百"）
  if (id === 19 || name.includes('广百')) {
    return '/guangbaimall.jpg';
  }
  
  // 丽江花园停车场（ID=20 或名称包含"丽江花园"）
  if (id === 20 || name.includes('丽江花园')) {
    return '/lijiang.jpg';
  }
  
  // 默认返回一张通用图片（这里用太古汇代替，确保文件存在）
  return '/taiguhui.jpg';
}

module.exports = {
  getParkingImage
};

