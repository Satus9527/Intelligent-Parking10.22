# AI交互指南

## 文档元信息
- **文档版本**: 1.0.0
- **适用项目**: 智能停车场预约微信小程序
- **创建日期**: 2025-10-15
- **AI解析标记**: `TREA_AI_GUIDELINES_V1`

<!-- AI-MARKER: RULE -->
## 1. 文档结构化标准

### 1.1 标题层级规范
<!-- AI-MARKER: RULE -->
- **必须**使用Markdown标准标题层级：
  - `#` 一级标题（文档主章节）
  - `##` 二级标题（章节子模块）
  - `###` 三级标题（具体规则项）
  - `####` 四级标题（示例/细则）
- **必须**确保标题层级连续（禁止跳过层级，如#直接到###）
- **必须**为每个章节提供唯一ID：  
  `## 2.1 标准目录树结构 {#dir-structure}`

### 1.2 列表格式规范
<!-- AI-MARKER: RULE -->
- **必须**使用无序列表（`- `）表示并列项
- **必须**使用有序列表（`1. `）表示步骤序列
- **必须**使用任务列表（`- [ ]`）表示待办事项
- **示例**：
  ```markdown
  # 正确列表格式
  - 无序列表项1
    - 子列表项（缩进2个空格）
  - 无序列表项2
  
  1. 步骤一
  2. 步骤二
  
  - [x] 已完成项
  - [ ] 待完成项
  ```

### 1.3 代码块标识
<!-- AI-MARKER: RULE -->
- **必须**为代码块指定语言类型：
  ```javascript
  // 正确：指定语言类型
  function hello() {
    console.log('world');
  }
  ```
- **必须**为关键代码块添加描述性标题：
  ```javascript
  // 数据库连接配置示例（生产环境）
  const dbConfig = {
    host: process.env.DB_HOST,
    ssl: { rejectUnauthorized: true }
  };
  ```
- **必须**使用`// highlight-line`标记关键行：
  ```javascript
  function queryData() {
    const connection = getConnection();
    // highlight-line
    const result = connection.query('SELECT * FROM safe_table');
    return result;
  }
  ```

## 2. 关键信息标记方法

### 2.1 AI提取标记
<!-- AI-MARKER: RULE -->
- **必须**使用`<!-- AI-MARKER: 类型 -->`标记关键信息：
  ```markdown
  <!-- AI-MARKER: ENV_VAR -->
  ## 1.2 环境变量配置规范
  ...
  ```
- **必须**为以下内容添加专用标记：
  - `ENV_VAR`: 环境变量定义
  - `COMMAND`: 命令行指令
  - `RULE`: 核心规则条款
  - `EXAMPLE`: 示例代码/配置
  - `WARNING`: 警告信息

### 2.2 表格数据标记
<!-- AI-MARKER: RULE -->
- **必须**为关键表格添加ID：
  ```markdown
  | 参数 | 类型 | 说明 |
  |------|------|------|
  | id   | int  | 用户ID |
  <!-- TABLE-ID: user_params -->
  ```
- **必须**使用表头行明确列定义（禁止无表头表格）

## 3. 歧义消除规则

### 3.1 术语定义表
<!-- AI-MARKER: GLOSSARY -->
| 术语 | 定义 | 英文对应 |
|-----|------|---------|
| 预约锁定 | 系统为用户临时保留车位的状态（默认10分钟） | Reservation Lock |
| 无感支付 | 用户离场时自动完成扣费的支付方式 |无感支付 |
| 地锁状态 | 车位地锁的物理状态（升锁/降锁/故障） | Lock Status |
| ETA | 预计到达时间（用户到达停车场的时间估算） | Estimated Time of Arrival |
| 车位周转率 | 单位时间内车位的重复使用次数 | Parking Space Turnover Rate |

### 3.2 缩写对照表
<!-- AI-MARKER: GLOSSARY -->
| 缩写 | 全称 | 使用场景 |
|-----|------|---------|
| AI | 人工智能 | 通用术语 |
| API | 应用程序编程接口 | 技术文档 |
| DB | 数据库 | 技术文档 |
| ENV | 环境 | 配置文件 |
| HTTP | 超文本传输协议 | 网络相关 |
| JSON | JavaScript对象表示法 | 数据格式 |
| SDK | 软件开发工具包 | 第三方集成 |

## 4. 代码示例规范

### 4.1 示例代码要求
<!-- AI-MARKER: RULE -->
- **必须**提供完整可运行的代码示例
- **必须**包含必要的注释说明
- **必须**遵循项目编码规范
- **示例**：
  ```java
  /**
   * 预约车位服务
   * @param parkingId 停车场ID
   * @param spaceId 车位ID
   * @param userId 用户ID
   * @return 预约结果
   */
  public ReservationResult reserveSpace(String parkingId, String spaceId, String userId) {
      // 验证参数
      validateReservationParams(parkingId, spaceId, userId);
      
      // 检查车位可用性
      boolean available = checkSpaceAvailability(parkingId, spaceId);
      if (!available) {
          return ReservationResult.failed("车位已被预约");
      }
      
      // 创建预约记录
      return createReservation(parkingId, spaceId, userId);
  }
  ```

### 4.2 测试用例示例
<!-- AI-MARKER: RULE -->
- **必须**包含正常流程测试
- **必须**包含异常情况测试
- **必须**包含边界条件测试
- **示例**：
  ```java
  @Test
  public void testReserveSpace_Success() {
      // 准备测试数据
      String parkingId = "p123";
      String spaceId = "s456";
      String userId = "u789";
      
      // 执行测试
      ReservationResult result = reservationService.reserveSpace(parkingId, spaceId, userId);
      
      // 验证结果
      assertTrue(result.isSuccess());
      assertNotNull(result.getReservationId());
  }
  ```

## 5. 错误处理与日志规范

### 5.1 错误码体系定义
<!-- AI-MARKER: ERROR_CODE -->
#### 5.1.1 错误码格式
- **必须**使用5位数字错误码：`ABCCC`
  - A: 错误类型（1=系统错误，2=业务错误，3=外部错误）
  - B: 模块编号（0-9）
  - CCC: 具体错误编号（001-999）

#### 5.1.2 系统错误码（1xxxx）
| 错误码 | 错误信息 | HTTP状态码 | 处理建议 |
|-------|---------|-----------|---------|
| 10001 | 数据库连接失败 | 500 | 检查数据库服务状态和连接参数 |
| 10002 | 缓存服务不可用 | 503 | 检查Redis服务或切换备用缓存 |
| 10003 | 配置文件加载失败 | 500 | 验证配置文件格式和权限 |
| 10004 | 内存溢出 | 500 | 检查内存使用情况和代码内存泄漏 |

#### 5.1.3 业务错误码（2xxxx）
| 错误码 | 错误信息 | HTTP状态码 | 处理建议 |
|-------|---------|-----------|---------|
| 20001 | 车位不存在 | 404 | 检查停车场ID和车位编号是否正确 |
| 20002 | 车位已被预约 | 409 | 建议用户选择其他车位或稍后重试 |
| 20003 | 预约已超时 | 400 | 需重新创建预约 |
| 20004 | 余额不足 | 402 | 提示用户充值或选择其他支付方式 |

#### 5.1.4 外部错误码（3xxxx）
| 错误码 | 错误信息 | HTTP状态码 | 处理建议 |
|-------|---------|-----------|---------|
| 30001 | 地图API调用失败 | 502 | 检查API密钥和网络连接 |
| 30002 | 支付服务超时 | 504 | 调用支付查询接口确认状态 |
| 30003 | 语音识别服务不可用 | 503 | 切换到手动输入模式 |

### 5.2 日志记录格式与级别划分
<!-- AI-MARKER: RULE -->
#### 5.2.1 日志格式规范
- **必须**使用JSON格式记录日志：
  ```json
  {
    "timestamp": "2025-10-15T20:30:45.123Z",
    "level": "ERROR",
    "service": "parking-service",
    "traceId": "abc-123-xyz-789",
    "userId": "u_12345",
    "module": "reservation",
    "errorCode": "20002",
    "message": "车位已被预约",
    "details": {
      "parkingId": "p_789",
      "spaceId": "s_456",
      "attemptedAt": "2025-10-15T20:30:44.987Z"
    }
  }
  ```

#### 5.2.2 日志级别划分
| 级别 | 使用场景 | 输出要求 | 必须/应/建议 |
|-----|---------|---------|------------|
| FATAL | 系统不可用错误 | 必须记录到文件+发送告警 | 必须 |
| ERROR | 功能失败错误 | 必须记录到文件+错误跟踪系统 | 必须 |
| WARN | 非致命异常 | 必须记录到文件 | 必须 |
| INFO | 重要业务事件 | 开发环境记录到控制台，生产环境记录到文件 | 必须 |
| DEBUG | 调试信息 | 仅开发环境记录 | 应 |
| TRACE | 详细跟踪信息 | 仅本地开发记录 | 建议 |

## 6. AI交互最佳实践

### 6.1 提示词设计原则
<!-- AI-MARKER: RULE -->
- **必须**提供明确的任务描述
- **必须**包含必要的上下文信息
- **必须**指定期望的输出格式
- **必须**明确约束条件和边界

### 6.2 常见交互模式
<!-- AI-MARKER: EXAMPLE -->
```markdown
# 需求描述示例

## 功能需求
设计并实现车位预约功能，要求如下：
- 用户可以浏览停车场列表
- 用户可以查看停车场内的可用车位
- 用户可以预约特定车位（保留10分钟）
- 用户可以取消自己的预约

## 技术要求
- 使用Spring Boot框架
- 使用Redis缓存热点数据
- 实现分布式锁防止并发预约
- 提供RESTful API接口

## 验收标准
- 并发100用户同时预约同一车位，只有1人成功
- 预约超过10分钟未支付自动取消
- API响应时间不超过200ms
```

### 6.3 代码审查提示词示例
<!-- AI-MARKER: EXAMPLE -->
```markdown
# 代码审查请求

## 审查范围
文件: src/service/ReservationService.java
重点关注: reserveSpace方法中的并发控制逻辑

## 审查要点
1. 分布式锁的实现是否正确
2. 是否存在死锁风险
3. 异常处理是否完善
4. 事务边界是否合理
5. 是否有性能优化空间

## 相关上下文
- 该方法处理车位预约请求
- 高并发场景下需要确保数据一致性
- 已使用Redis实现分布式锁
```