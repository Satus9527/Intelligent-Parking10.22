# TREA开发环境规则文档

## 文档元信息
- **文档版本**: 1.0.0
- **适用项目**: 智能停车场预约微信小程序
- **创建日期**: 2025-10-15
- **AI解析标记**: `TREA_ENV_RULES_V1`

## 1. TREA环境基础配置

### 1.1 核心组件与版本要求
| 组件名称 | 版本要求 | 必须/应/建议 | 检查项 |
|---------|---------|------------|-------|
| 操作系统 | Ubuntu 20.04 LTS / Windows 10+ | 必须 | `lsb_release -a` 验证版本 |
| Node.js | 16.14.0 LTS | 必须 | `node -v` 返回 v16.14.0+ |
| npm | 8.3.1+ | 必须 | `npm -v` 返回 8.3.1+ |
| Java JDK | 11.0.12+ | 必须 | `java -version` 返回 11.0.12+ |
| MySQL | 8.0.28+ | 必须 | `mysql --version` 返回 8.0.28+ |
| Redis | 6.2.6+ | 必须 | `redis-server --version` 返回 6.2.6+ |
| Git | 2.34.1+ | 必须 | `git --version` 返回 2.34.1+ |
| Docker | 20.10.12+ | 应 | `docker --version` 返回 20.10.12+ |
| VS Code | 1.63.0+ | 建议 | `code --version` 返回 1.63.0+ |

### 1.2 环境变量配置规范
#### 1.2.1 配置文件位置
- **必须**在项目根目录创建 `.env` 文件（开发环境）
- **必须**在服务器 `/etc/environment` 配置系统级变量
- **必须**将 `.env` 添加到 `.gitignore` 文件

#### 1.2.2 必要参数示例
```bash
# 应用基础配置
APP_NAME="智能停车场系统"
APP_ENV="development"  # 必须为: development/test/production
APP_PORT=8080
APP_DEBUG="true"       # 生产环境必须设为"false"

# 数据库配置（必须使用加密连接）
DB_HOST="localhost"
DB_PORT=3306
DB_DATABASE="parking_db"
DB_USERNAME="db_user"
DB_PASSWORD="${ENCRYPTED_PASSWORD}"  # 必须使用环境变量注入加密密码

# 第三方服务配置（必须脱敏存储）
AMAP_API_KEY="********************************"  # 高德地图API密钥
WECHAT_APPID="wx****************"
WECHAT_MCH_ID="1********9"
LOG_LEVEL="info"  # 必须为: debug/info/warn/error/fatal
```

### 1.3 依赖管理策略
#### 1.3.1 安装规范
- **必须**使用锁定文件固定依赖版本：
  - Node.js项目：`package-lock.json`（禁止使用yarn）
  - Java项目：`pom.xml`（明确指定版本号）
- **必须**执行依赖安全检查：
  ```bash
  # Node.js项目
  npm audit --production
  
  # Java项目
  mvn org.owasp:dependency-check-maven:check
  ```

#### 1.3.2 更新流程
1. **必须**创建单独的更新分支：`feature/update-dependencies`
2. **必须**逐个更新依赖并验证功能：
   ```bash
   npm update <package> --save-exact  # 精确版本更新
   ```
3. **必须**在提交信息中注明更新内容：  
   `chore(deps): 更新axios至1.2.1版本`

#### 1.3.3 冲突解决
- **必须**优先使用主版本兼容的更新（如1.2.x → 1.3.x）
- **必须**记录冲突解决过程到 `DEPENDENCY_CONFLICT.md`
- **应**使用 `npm ls <package>` 或 `mvn dependency:tree` 分析依赖树

## 2. 项目结构定义

### 2.1 标准目录树结构
```
parking-system/
├── .env.example          # 环境变量示例（必须提交到仓库）
├── .env                  # 环境变量配置（必须忽略提交）
├── .gitignore            # Git忽略规则（必须包含.env/.log）
├── package.json          # 项目元信息（必须包含lint脚本）
├── README.md             # 项目说明文档（必须包含启动步骤）
├── docs/                 # 文档目录（必须包含架构图/接口文档）
│   ├── architecture/     # 架构设计文档
│   ├── api/              # API接口文档
│   └── ai-guidelines.md  # AI交互指南（必须包含解析规则）
├── src/                  # 源代码目录（必须包含所有业务代码）
│   ├── api/              # 接口层（必须按资源划分模块）
│   │   ├── parking/      # 停车场相关接口
│   │   └── reservation/  # 预约相关接口
│   ├── service/          # 服务层（必须包含业务逻辑）
│   ├── model/            # 数据模型层（必须包含验证规则）
│   ├── utils/            # 工具函数（必须无状态）
│   └── config/           # 配置文件（必须区分环境配置）
├── test/                 # 测试目录（必须与src结构对应）
│   ├── unit/             # 单元测试
│   └── integration/      # 集成测试
├── scripts/              # 脚本目录（必须包含构建/部署脚本）
│   ├── build.sh          # 构建脚本（必须可独立执行）
│   └── deploy.sh         # 部署脚本（必须包含回滚逻辑）
└── logs/                 # 日志目录（必须包含.gitignore）
    └── app.log           # 应用日志（必须按日切割）
```

### 2.2 文件命名规范
#### 2.2.1 通用命名规则
| 文件类型 | 命名规则 | 示例 | 必须/应/建议 |
|---------|---------|------|------------|
| 源代码文件 | kebab-case.js | `parking-list.js` | 必须 |
| 组件文件 | PascalCase.js | `ParkingCard.js` | 必须 |
| 测试文件 | [源文件名].test.js | `parking-service.test.js` | 必须 |
| 配置文件 | snake_case.json | `app_config.json` | 必须 |
| 文档文件 | kebab-case.md | `api-guidelines.md` | 必须 |
| 脚本文件 | kebab-case.sh | `deploy-production.sh` | 必须 |

#### 2.2.2 特殊文件命名
- **必须**使用 `README.md` 作为目录说明文档
- **必须**使用 `CHANGELOG.md` 记录版本变更
- **必须**使用 `CONTRIBUTING.md` 定义贡献规则
- **应**使用 `SECURITY.md` 记录安全策略

### 2.3 代码组织原则
#### 2.3.1 模块化要求
- **必须**遵循单一职责原则：一个模块只负责一个功能
- **必须**通过 `index.js` 暴露模块公共接口：
  ```javascript
  // src/utils/date/index.js
  export { formatDate } from './format-date';
  export { parseDate } from './parse-date';
  // 禁止导出未在index.js声明的内部函数
  ```
- **必须**限制模块依赖深度不超过3层

#### 2.3.2 组件化要求
- **必须**将UI组件拆分为：页面组件（pages）/ 通用组件（components）
- **必须**为每个组件编写独立的单元测试
- **应**通过props控制组件行为，禁止组件内部硬编码业务逻辑

## 3. 开发规范与约束

### 3.1 编码风格指南
#### 3.1.1 缩进与格式
- **必须**使用2个空格缩进（禁止使用Tab）
- **必须**使用UTF-8编码且无BOM头
- **必须**在文件末尾保留一个空行
- **必须**控制每行代码长度不超过80个字符
- **应**使用ESLint强制风格检查：
  ```json
  // .eslintrc.json 关键配置
  {
    "rules": {
      "indent": ["error", 2],
      "linebreak-style": ["error", "unix"],
      "quotes": ["error", "single"],
      "semi": ["error", "always"]
    }
  }
  ```

#### 3.1.2 命名规则
| 标识符类型 | 命名规则 | 示例 | 必须/应/建议 |
|---------|---------|------|------------|
| 变量/函数 | camelCase | `userInfo`, `calculateFee()` | 必须 |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` | 必须 |
| 类/组件 | PascalCase | `class UserService`, `component ParkingCard` | 必须 |
| 接口 | I+PascalCase | `interface IReservation` | 必须 |
| 枚举 | PascalCase+Enum | `enum ReservationStatusEnum` | 必须 |
| 私有成员 | _+camelCase | `_privateMethod()` | 应 |

#### 3.1.3 注释要求
- **必须**为以下内容提供注释：
  - 函数/方法（JSDoc格式）
  - 复杂业务逻辑（单行注释）
  - 常量定义（说明用途而非值）
- **禁止**注释显而易见的代码
- **示例**：
  ```javascript
  /**
   * 计算停车费用
   * @param {Object} params - 参数对象
   * @param {number} params.hours - 停车小时数（精确到0.5小时）
   * @param {string} params.vehicleType - 车辆类型（小型/中型/大型）
   * @returns {number} 计算后的费用（元）
   * @throws {Error} 当hours为负数时抛出异常
   */
  function calculateParkingFee(params) {
    // 夜间时段（22:00-8:00）加收50%费用
    if (isNightTime(params.entryTime)) {
      return baseFee * 1.5;
    }
    return baseFee;
  }
  ```

### 3.2 版本控制策略
#### 3.2.1 分支管理
- **必须**遵循GitFlow工作流：
  - `main`: 生产环境分支（禁止直接提交）
  - `develop`: 开发分支（仅接受合并请求）
  - `feature/*`: 功能分支（从develop创建，完成后合并回develop）
  - `release/*`: 发布分支（从develop创建，完成后合并到main和develop）
  - `hotfix/*`: 紧急修复分支（从main创建，完成后合并到main和develop）

#### 3.2.2 提交信息格式
- **必须**使用以下格式：  
  `<类型>[可选作用域]: <描述>`
- **类型**必须为以下之一：
  - `feat`: 新功能
  - `fix`: 缺陷修复
  - `docs`: 文档更新
  - `style`: 代码格式调整（不影响逻辑）
  - `refactor`: 代码重构
  - `test`: 测试相关
  - `chore`: 构建/依赖管理
- **必须**使用英文撰写提交信息
- **示例**：
  ```
  feat(reservation): 添加预约超时自动取消功能
  fix(payment): 修复微信支付回调重复处理问题
  docs(api): 更新预约接口文档
  ```

### 3.3 安全编码规范
#### 3.3.1 输入验证
- **必须**对所有用户输入进行验证：
  ```javascript
  // 禁止直接使用用户输入
  const userId = req.query.userId;
  
  // 必须验证并转换
  const userId = parseInt(req.query.userId, 10);
  if (isNaN(userId) || userId <= 0) {
    throw new Error('无效的用户ID');
  }
  ```
- **必须**使用参数化查询防止SQL注入：
  ```javascript
  // 错误示例
  db.query(`SELECT * FROM users WHERE id = ${userId}`);
  
  // 正确示例
  db.query('SELECT * FROM users WHERE id = ?', [userId]);
  ```

#### 3.3.2 XSS防护
- **必须**对输出到HTML的内容进行转义：
  ```javascript
  // 使用模板引擎自动转义
  res.render('user', { username: userInput });
  
  // 手动转义（当必须直接操作DOM时）
  const safeHtml = escapeHtml(userInput);
  ```
- **必须**设置适当的Content-Security-Policy：
  ```http
  Content-Security-Policy: default-src 'self'; script-src 'self' https://apis.map.qq.com
  ```

#### 3.3.3 敏感数据保护
- **必须**加密存储敏感数据：
  - 密码：使用bcrypt（成本因子≥12）
  - 个人信息：使用AES-256加密
- **必须**在日志中脱敏敏感信息：
  ```javascript
  // 错误示例
  logger.info(`用户${username}登录成功，IP:${ip}`);
  
  // 正确示例
  logger.info(`用户${maskUsername(username)}登录成功，IP:${maskIp(ip)}`);
  ```

## 4. AI交互优化设计

### 4.1 文档结构化标准
#### 4.1.1 标题层级规范
- **必须**使用Markdown标准标题层级：
  - `#` 一级标题（文档主章节）
  - `##` 二级标题（章节子模块）
  - `###` 三级标题（具体规则项）
  - `####` 四级标题（示例/细则）
- **必须**确保标题层级连续（禁止跳过层级，如#直接到###）
- **必须**为每个章节提供唯一ID：  
  `## 2.1 标准目录树结构 {#dir-structure}`

#### 4.1.2 列表格式规范
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

#### 4.1.3 代码块标识
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

### 4.2 关键信息标记方法
#### 4.2.1 AI提取标记
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

#### 4.2.2 表格数据标记
- **必须**为关键表格添加ID：
  ```markdown
  | 参数 | 类型 | 说明 |
  |------|------|------|
  | id   | int  | 用户ID |
  <!-- TABLE-ID: user_params -->
  ```
- **必须**使用表头行明确列定义（禁止无表头表格）

### 4.3 歧义消除规则
#### 4.3.1 术语定义表
<!-- AI-MARKER: GLOSSARY -->
| 术语 | 定义 | 英文对应 |
|-----|------|---------|
| 预约锁定 | 系统为用户临时保留车位的状态（默认10分钟） | Reservation Lock |
| 无感支付 | 用户离场时自动完成扣费的支付方式 |无感支付 |
| 地锁状态 | 车位地锁的物理状态（升锁/降锁/故障） | Lock Status |
| ETA | 预计到达时间（用户到达停车场的时间估算） | Estimated Time of Arrival |
| 车位周转率 | 单位时间内车位的重复使用次数 | Parking Space Turnover Rate |

#### 4.3.2 缩写对照表
| 缩写 | 全称 | 使用场景 |
|-----|------|---------|
| AI | 人工智能 | 通用术语 |
| API | 应用程序编程接口 | 技术文档 |
| DB | 数据库 | 技术文档 |
| ENV | 环境 | 配置文件 |
| HTTP | 超文本传输协议 | 网络相关 |
| JSON | JavaScript对象表示法 | 数据格式 |
| SDK | 软件开发工具包 | 第三方集成 |

## 5. 项目构建与部署流程

### 5.1 构建命令与参数说明
#### 5.1.1 基础构建命令
<!-- AI-MARKER: COMMAND -->
```bash
# 开发环境构建（包含热重载）
npm run dev

# 生产环境构建（压缩/混淆代码）
npm run build -- --mode production

# 构建并生成依赖分析报告
npm run build -- --report

# 构建Docker镜像
npm run build:image -- --tag parking-system:1.0.0
```

#### 5.1.2 关键参数说明
| 参数 | 允许值 | 作用 | 必须/应/建议 |
|-----|------|------|------------|
| --mode | development/test/production | 指定构建环境 | 必须 |
| --report | 无值参数 | 生成构建报告 | 应 |
| --analyze | 无值参数 | 启动依赖分析工具 | 建议 |
| --tag | 字符串（符合语义化版本） | 指定Docker镜像标签 | 必须 |
| --skip-tests | 无值参数 | 跳过构建前测试 | 禁止在生产构建使用 |

### 5.2 测试自动化配置
#### 5.2.1 单元测试要求
- **必须**达到80%以上的代码覆盖率：
  ```bash
  # 执行单元测试并生成覆盖率报告
  npm run test:unit -- --coverage
  ```
- **必须**将测试结果输出到 `tests/unit/results` 目录
- **必须**编写测试用例覆盖以下场景：
  - 正常业务流程
  - 边界条件（如最大/最小值）
  - 错误处理（如参数错误/异常抛出）

#### 5.2.2 集成测试配置
- **必须**使用独立的测试数据库：
  ```javascript
  // jest.config.js
  module.exports = {
    testEnvironment: 'node',
    globalSetup: './tests/integration/setup.js',  // 测试前初始化
    globalTeardown: './tests/integration/teardown.js'  // 测试后清理
  };
  ```
- **必须**模拟第三方服务依赖：
  ```javascript
  // 使用nock模拟API请求
  nock('https://restapi.amap.com')
    .get('/v3/geocode/geo')
    .reply(200, mockAmapResponse);
  ```

### 5.3 部署流程与环境适配指南
#### 5.3.1 环境划分
| 环境名称 | 用途 | 部署触发条件 | 访问控制 |
|---------|------|------------|---------|
| 开发环境 | 日常开发测试 | develop分支更新 | 仅内部开发团队访问 |
| 测试环境 | 功能验证 | release/*分支创建 | 内部+测试团队访问 |
| 预发布环境 | 生产环境模拟 | 手动触发 | 仅授权人员访问 |
| 生产环境 | 最终用户使用 | main分支更新+审批 | 公开访问 |

#### 5.3.2 部署流程（生产环境）
1. **必须**执行预检查：
   ```bash
   # 部署前验证
   ./scripts/deploy-check.sh --env production
   ```
2. **必须**创建部署版本记录：
   ```bash
   # 生成版本元数据
   echo "{\"version\":\"$VERSION\",\"deployTime\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > VERSION.json
   ```
3. **必须**执行蓝绿部署：
   ```bash
   # 部署到备用环境
   docker-compose -f docker-compose.prod.yml up -d --no-deps --build parking-service-new
   
   # 健康检查
   ./scripts/health-check.sh --service parking-service-new --timeout 300
   
   # 切换流量
   ./scripts/switch-traffic.sh --target new
   ```
4. **必须**验证部署结果：
   ```bash
   # 执行冒烟测试
   ./scripts/smoke-test.sh --env production
   ```

## 6. 异常处理与日志规范

### 6.1 错误码体系定义
<!-- AI-MARKER: ERROR_CODE -->
#### 6.1.1 错误码格式
- **必须**使用5位数字错误码：`ABCCC`
  - A: 错误类型（1=系统错误，2=业务错误，3=外部错误）
  - B: 模块编号（0-9）
  - CCC: 具体错误编号（001-999）

#### 6.1.2 系统错误码（1xxxx）
| 错误码 | 错误信息 | HTTP状态码 | 处理建议 |
|-------|---------|-----------|---------|
| 10001 | 数据库连接失败 | 500 | 检查数据库服务状态和连接参数 |
| 10002 | 缓存服务不可用 | 503 | 检查Redis服务或切换备用缓存 |
| 10003 | 配置文件加载失败 | 500 | 验证配置文件格式和权限 |
| 10004 | 内存溢出 | 500 | 检查内存使用情况和代码内存泄漏 |

#### 6.1.3 业务错误码（2xxxx）
| 错误码 | 错误信息 | HTTP状态码 | 处理建议 |
|-------|---------|-----------|---------|
| 20001 | 车位不存在 | 404 | 检查停车场ID和车位编号是否正确 |
| 20002 | 车位已被预约 | 409 | 建议用户选择其他车位或稍后重试 |
| 20003 | 预约已超时 | 400 | 需重新创建预约 |
| 20004 | 余额不足 | 402 | 提示用户充值或选择其他支付方式 |

#### 6.1.4 外部错误码（3xxxx）
| 错误码 | 错误信息 | HTTP状态码 | 处理建议 |
|-------|---------|-----------|---------|
| 30001 | 地图API调用失败 | 502 | 检查API密钥和网络连接 |
| 30002 | 支付服务超时 | 504 | 调用支付查询接口确认状态 |
| 30003 | 语音识别服务不可用 | 503 | 切换到手动输入模式 |

### 6.2 日志记录格式与级别划分
#### 6.2.1 日志格式规范
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

#### 6.2.2 日志级别划分
| 级别 | 使用场景 | 输出要求 | 必须/应/建议 |
|-----|---------|---------|------------|
| FATAL | 系统不可用错误 | 必须记录到文件+发送告警 | 必须 |
| ERROR | 功能失败错误 | 必须记录到文件+错误跟踪系统 | 必须 |
| WARN | 非致命异常情况 | 必须记录到文件 | 必须 |
| INFO | 重要业务操作 | 生产环境：选择性记录；开发环境：详细记录 | 必须 |
| DEBUG | 调试信息 | 仅开发/测试环境记录 | 必须 |
| TRACE | 详细跟踪信息 | 仅问题排查时临时启用 | 建议 |

### 6.3 常见问题排查指引
#### 6.3.1 排查流程
1. **必须**收集基础信息：
   - 发生时间（精确到秒）
   - 错误现象（截图/日志片段）
   - 环境信息（环境/版本/用户ID）
   - 复现步骤（尽可能详细）

2. **必须**按优先级排查：
   ```markdown
   1. 检查网络连接（ping/traceroute）
   2. 检查服务状态（systemctl status/容器状态）
   3. 检查日志文件（按错误码/时间戳过滤）
   4. 检查依赖服务（数据库/缓存/第三方API）
   5. 检查资源使用（CPU/内存/磁盘/网络）
   ```

#### 6.3.2 典型问题解决方案
| 问题现象 | 可能原因 | 解决方案 | 参考文档 |
|---------|---------|---------|---------|
| 预约提交超时 | 数据库连接池耗尽 | 1. 临时增加连接池大小<br>2. 优化慢查询<br>3. 实施请求限流 | [性能优化指南](#performance-optimization) |
| 地图加载失败 | API密钥过期 | 1. 在.env文件更新AMAP_API_KEY<br>2. 执行`npm run config:reload` | [环境变量配置](#env-var-config) |
| 支付回调失败 | 签名验证错误 | 1. 检查微信支付证书是否过期<br>2. 验证mch_key是否正确 | [第三方服务配置](#third-party-config) |

## 7. 扩展与维护规则

### 7.1 功能扩展接口设计标准
#### 7.1.1 接口定义规范
- **必须**使用RESTful风格设计API接口：
  ```
  # 资源命名规范
  GET    /api/v1/parking-spaces        # 获取车位列表
  POST   /api/v1/parking-spaces        # 创建车位
  GET    /api/v1/parking-spaces/{id}   # 获取单个车位
  PUT    /api/v1/parking-spaces/{id}   # 更新车位
  DELETE /api/v1/parking-spaces/{id}   # 删除车位
  ```

#### 7.1.2 版本控制策略
- **必须**在URL中包含主版本号：`/api/v1/...`
- **必须**保证主版本号兼容性：v1接口在v1生命周期内保持兼容
- **应**通过查询参数提供可选功能：`?include_inactive=true`

#### 7.1.3 扩展点设计
- **必须**通过钩子函数提供扩展点：
  ```javascript
  // 预约流程扩展钩子
  function processReservation(params) {
    // 前置扩展点
    const modifiedParams = hooks.execute('beforeReservation', params);
    
    // 核心逻辑
    const result = reservationService.create(modifiedParams);
    
    // 后置扩展点
    hooks.execute('afterReservation', result);
    
    return result;
  }
  ```

### 7.2 配置文件修改流程
#### 7.2.1 修改权限控制
- **必须**遵循最小权限原则：
  - 开发人员：仅可修改开发环境配置
  - 运维人员：可修改所有环境配置（需审批）
  - 自动化流程：仅可修改指定配置项

#### 7.2.2 修改流程
1. **必须**创建配置修改申请单，包含：
   - 修改原因和依据
   - 影响范围评估
   - 回滚方案
   - 生效时间

2. **必须**在测试环境验证修改：
   ```bash
   # 复制配置到测试环境
   ./scripts/copy-config.sh --source development --target test --file app.json
   
   # 执行验证测试
   ./scripts/verify-config.sh --env test
   ```

3. **必须**记录配置变更历史：
   ```bash
   # 提交配置变更记录
   git add config/
   git commit -m "chore(config): 更新预约超时时间为15分钟"
   ```

### 7.3 文档更新与版本同步机制
#### 7.3.1 文档版本控制
- **必须**为每个文档添加版本元数据：
  ```markdown
  ---
  title: TREA开发环境规则文档
  version: 1.0.0
  lastUpdated: 2025-10-15
  updatedBy: system-admin
  ---
  ```

#### 7.3.2 更新触发条件
- **必须**在以下情况更新文档：
  - 功能变更（新增/修改/删除功能）
  - 架构调整（模块/接口/依赖变更）
  - 规则修改（开发规范/流程变更）
  - 用户反馈（文档歧义/错误/缺失）

#### 7.3.3 同步机制
- **必须**在代码提交时检查文档同步：
  ```bash
  # 在pre-commit钩子中执行
  if git diff --name-only HEAD~1 HEAD | grep -E 'src/api/|src/service/'; then
    # 提醒更新API文档
    echo "⚠️ 检测到API相关代码变更，请更新docs/api.md"
  fi
  ```

## AI解析校验清单

### 核心要素校验项
| 校验项 | 要求 | 状态 |
|-------|------|------|
| 标题层级 | 使用#/##/###层级，无跳跃 | ✅ 必须满足 |
| 代码块 | 包含语言标识，关键代码有高亮 | ✅ 必须满足 |
| AI标记 | 关键章节包含`<!-- AI-MARKER: 类型 -->` | ✅ 必须满足 |
| 术语表 | 包含所有专业术语定义 | ✅ 必须满足 |
| 示例代码 | 每个规则项有对应的示例 | ✅ 必须满足 |
| 指令性语言 | 使用"必须"/"应"/"建议"明确约束级别 | ✅ 必须满足 |
| 表格格式 | 所有表格有表头，关键表格有ID | ✅ 必须满足 |
| 错误码体系 | 5位数字编码，包含错误处理建议 | ✅ 必须满足 |
| 流程步骤 | 使用有序列表描述操作序列 | ✅ 必须满足 |
| 版本信息 | 文档包含版本和更新时间 | ✅ 必须满足 |

### AI解析测试用例
1. **提取环境变量配置**：  
   提示："列出TREA环境中必须配置的数据库连接参数"  
   预期结果：返回DB_HOST、DB_PORT、DB_DATABASE等参数及示例值

2. **识别代码规范**：  
   提示："TREA环境中JavaScript函数命名应遵循什么规则？"  
   预期结果：返回"必须使用camelCase命名风格，如calculateParkingFee()"

3. **解析错误码**：  
   提示："错误码20002表示什么问题？如何处理？"  
   预期结果：返回"车位已被预约，建议用户选择其他车位或稍后重试"

4. **提取部署步骤**：  
   提示："生产环境部署的第一步是什么？"  
   预期结果：返回"执行预检查：./scripts/deploy-check.sh --env production"

5. **识别扩展点**：  
   提示："如何扩展预约流程？"  
   预期结果：返回"通过beforeReservation和afterReservation钩子函数扩展"