# 智能停车场预约系统 - 后端工程

## 项目介绍
这是一个基于Spring Boot开发的智能停车场预约微信小程序后端系统，提供车位预约、查询附近停车场等功能。

## 技术栈
- **后端框架**: Spring Boot 2.7.5
- **ORM框架**: MyBatis
- **缓存**: Redis
- **数据库**: MySQL 8.0+
- **构建工具**: Maven
- **地图服务**: 高德地图API

## 项目结构
```
src/
├── main/
│   ├── java/com/parking/
│   │   ├── controller/    # 控制器层
│   │   ├── service/       # 服务层
│   │   │   └── impl/      # 服务实现
│   │   ├── dao/           # 数据访问层
│   │   ├── model/         # 数据模型
│   │   │   ├── entity/    # 实体类
│   │   │   ├── dto/       # 数据传输对象
│   │   │   └── vo/        # 视图对象
│   │   ├── config/        # 配置类
│   │   ├── util/          # 工具类
│   │   └── exception/     # 异常处理
│   └── resources/         # 资源文件
│       ├── mapper/        # MyBatis映射文件
│       ├── application.yml        # 主配置文件
│       └── application-dev.yml    # 开发环境配置
└── test/                  # 测试代码
```

## 环境配置
1. 确保安装以下组件：
   - JDK 11.0.12+
   - MySQL 8.0.28+
   - Redis 6.2.6+
   - Maven 3.6.0+

2. 配置环境变量：
   - 复制 `.env.example` 到 `.env`
   - 根据实际环境修改 `.env` 中的配置项

3. 数据库初始化：
   - 创建名为 `parking_db` 的数据库
   - 导入初始化SQL脚本（后续提供）

## 启动步骤
1. 确保MySQL和Redis服务已启动
2. 执行以下命令构建并启动项目：
   ```bash
   mvn clean install
   mvn spring-boot:run
   ```
3. 项目启动后，访问 `http://localhost:8080/api/v1/parking/` 查看API接口

## API接口说明
### 停车场接口
- **预约停车位**: POST /api/v1/parking/reserve
- **获取停车位详情**: GET /api/v1/parking/space/{id}
- **获取附近停车场**: GET /api/v1/parking/nearby?latitude={}&longitude={}&radius={}

## 开发规范
请严格遵守TREA开发环境规则文档中的编码规范、命名规则和版本控制策略。

## 注意事项
- 生产环境中，确保将 `APP_ENV` 设置为 `production`
- 生产环境中，确保将 `APP_DEBUG` 设置为 `false`
- 所有敏感信息（如数据库密码、API密钥）必须通过环境变量注入
- 定期运行安全检查命令：`mvn org.owasp:dependency-check-maven:check`