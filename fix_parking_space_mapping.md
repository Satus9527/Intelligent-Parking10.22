# 停车场和车位数据不匹配问题诊断

## 问题分析

用户报告：在"白云山停车场"页面预约，但预约详情显示"太古汇停车场"。

### 根本原因

1. **前端使用模拟数据**：
   - 前端使用 `generateMockSpaces()` 生成模拟车位数据
   - 车位ID是字符串格式（如 `'gz_005_space_1_A1_1'`）
   - 前端停车场ID是字符串格式（如 `'gz_005'`）

2. **后端使用数据库ID**：
   - 后端数据库中的停车场ID是数字（1, 2, 3...）
   - 车位ID也是数字

3. **ID转换问题**：
   - 前端在提交预约时，尝试将字符串ID转换为数字
   - 转换可能不准确，导致选择了错误的车位
   - 后端使用车位关联的停车场ID保存预约（这是正确的行为）

4. **数据不同步**：
   - 前端显示的停车场列表（`dataUtils.js`）与后端数据库不一致
   - 前端车位是模拟数据，后端车位来自数据库
   - 两者可能关联到不同的停车场

### 解决方案

#### 方案1：修复前端，从后端API获取真实车位数据（推荐）

修改 `miniprogram/pages/parking/detail.js`，使其从后端API获取车位列表：

```javascript
// 替换 generateMockSpaces 调用
loadAvailableSpaces() {
  const app = getApp();
  wx.request({
    url: `${app.globalData.apiBaseUrl}/api/parking-spaces/available`,
    method: 'GET',
    data: {
      parkingId: this.convertParkingIdToBackend(this.data.parkingId)
    },
    success: (res) => {
      if (res.statusCode === 200 && res.data) {
        this.setData({
          availableSpaces: res.data,
          groupedSpaces: groupSpacesBySection(res.data)
        });
      }
    }
  });
}

// 将前端停车场ID转换为后端ID
convertParkingIdToBackend(frontendId) {
  // 映射关系：'gz_005' -> 6 (白云山), 'gz_007' -> 1 (太古汇) 等
  const mapping = {
    'gz_001': 3, // 天河城
    'gz_003': 6, // 北京路
    'gz_004': 5, // 广州塔
    'gz_005': 6, // 白云山（假设数据库ID是6）
    'gz_006': 2, // 正佳广场
    'gz_007': 1  // 太古汇
  };
  return mapping[frontendId] || 1;
}
```

#### 方案2：统一前后端ID格式

1. 更新数据库，使停车场ID与前端ID一致
2. 或者更新前端，使用数据库的数字ID

#### 方案3：创建前端ID到后端ID的映射表

在后端添加映射API，前端通过前端ID查询后端ID。

### 立即修复步骤

1. **检查数据一致性**：
   ```bash
   diagnose_parking_issue.bat
   ```

2. **确保数据库中的车位正确关联到停车场**

3. **修复前端，使用后端API获取车位**

4. **确保前端停车场ID正确映射到后端ID**

