# 开发环境配置指南（Git/CI/CD）

## 一、Git版本控制配置

### 1.1 仓库初始化与设置
```bash
# 1. 创建本地仓库
mkdir parking-project && cd parking-project
git init

# 2. 配置用户信息（必须与TREA环境统一）
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

# 3. 设置远程仓库
git remote add origin https://github.com/your-org/parking-project.git

# 4. 配置.gitignore文件
cat > .gitignore << EOF
# Java
*.class
*.jar
*.war
target/

# IDE
.idea/
.vscode/
*.swp
*.swo

# 环境配置
.env
.env.local
application-*.yml
!application-template.yml

# 日志
logs/
EOF
```

### 1.2 分支管理策略
#### 1.2.1 分支模型定义
| 分支类型 | 命名规范 | 生命周期 | 创建来源 | 合并目标 |
|----------|----------|----------|----------|----------|
| 主分支 | `main` | 永久 | - | `develop`/`hotfix/*` |
| 开发分支 | `develop` | 永久 | `main` | `feature/*`/`release/*` |
| 功能分支 | `feature/PARK-{id}-{name}` | 临时 | `develop` | `develop` |
| 发布分支 | `release/v{version}` | 临时 | `develop` | `main`/`develop` |
| 热修复分支 | `hotfix/PARK-{id}-{name}` | 临时 | `main` | `main`/`develop` |

#### 1.2.2 分支保护规则
```yaml
# 示例：GitLab分支保护配置
branch_protection:
  main:
    push_access_level: none
    merge_access_level: maintainer
    required_approvals: 2
    dismiss_stale_approvals: true
  develop:
    push_access_level: developer
    merge_access_level: developer
    required_approvals: 1
```

### 1.3 提交规范
#### 1.3.1 提交信息格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

#### 1.3.2 类型定义与示例
| 类型 | 说明 | 示例 |
|------|------|------|
| feat | 新功能 | `feat(auth): implement wechat login API` |
| fix | 缺陷修复 | `fix(parking): resolve space status sync issue` |
| docs | 文档更新 | `docs: update API documentation` |
| style | 代码格式 | `style: adjust code indentation` |
| refactor | 代码重构 | `refactor: optimize parking space query` |
| test | 测试相关 | `test: add unit tests for reservation service` |
| chore | 构建/依赖 | `chore: upgrade spring boot to 2.7.5` |

#### 1.3.3 提交验证配置
```bash
# 安装提交验证工具
npm install -g commitlint @commitlint/cli @commitlint/config-conventional
npm install -g husky

# 配置commitlint
echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js

# 设置husky钩子
husky install
husky add .husky/commit-msg 'npx --no -- commitlint --edit $1'
```

## 二、CI/CD流水线配置

### 2.1 持续集成环境搭建
#### 2.1.1 Jenkins配置（TREA环境推荐）
```groovy
// Jenkinsfile (存放在项目根目录)
pipeline {
  agent any
  
  environment {
    // 环境变量配置（必须通过TREA安全管理注入）
    DB_HOST = credentials('db-host')
    DB_USER = credentials('db-user')
    DB_PASS = credentials('db-pass')
  }
  
  stages {
    stage('Build') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
      post {
        success {
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
      }
    }
    
    stage('Unit Test') {
      steps {
        sh 'mvn test'
      }
      post {
        always {
          junit '**/target/surefire-reports/TEST-*.xml'
        }
      }
    }
    
    stage('Code Quality') {
      steps {
        sh 'mvn checkstyle:check'
        sh 'mvn sonar:sonar'
      }
    }
    
    stage('Security Scan') {
      steps {
        sh 'mvn dependency-check:check'
      }
    }
  }
  
  post {
    failure {
      slackSend channel: '#parking-dev-alerts', message: "CI Failed: Job '${env.JOB_NAME}' (${env.BUILD_NUMBER})"
    }
  }
}
```

### 2.2 持续部署流程设计
#### 2.2.1 环境划分与部署策略
| 环境 | 用途 | 部署触发方式 | 部署策略 | 访问地址 |
|------|------|--------------|----------|----------|
| 开发环境 | 功能测试 | develop分支更新 | 自动部署 | dev-parking.example.com |
| 测试环境 | 集成测试 | release分支创建 | 自动部署 | test-parking.example.com |
| 预发布环境 | 验收测试 | 手动触发 | 蓝绿部署 | staging-parking.example.com |
| 生产环境 | 线上运行 | main分支tag | 灰度发布 | parking.example.com |

#### 2.2.2 部署配置文件示例（Docker+K8s）
```yaml
# docker-compose.yml (开发环境)
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - DB_HOST=${DB_HOST}
      - DB_USER=${DB_USER}
      - DB_PASS=${DB_PASS}
    depends_on:
      - mysql
      - redis

  mysql:
    image: mysql:8.0.28
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASS}
      - MYSQL_DATABASE=parking_db
    volumes:
      - mysql-data:/var/lib/mysql

  redis:
    image: redis:6.2.6
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

volumes:
  mysql-data:
  redis-data:
```

### 2.3 自动化测试集成
#### 2.3.1 测试环境配置
```xml
<!-- pom.xml 测试配置 -->
<build>
  <plugins>
    <plugin>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-maven-plugin</artifactId>
      <configuration>
        <excludes>
          <exclude>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
          </exclude>
        </excludes>
      </configuration>
    </plugin>
    <plugin>
      <groupId>org.jacoco</groupId>
      <artifactId>jacoco-maven-plugin</artifactId>
      <version>0.8.7</version>
      <executions>
        <execution>
          <goals>
            <goal>prepare-agent</goal>
          </goals>
        </execution>
        <execution>
          <id>report</id>
          <phase>test</phase>
          <goals>
            <goal>report</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

#### 2.3.2 测试覆盖率要求
```yaml
# sonar-project.properties
sonar.projectKey=parking-project
sonar.projectName=智能停车场项目
sonar.projectVersion=1.0

# 代码覆盖率阈值设置
sonar.java.coveragePlugin=jacoco
sonar.jacoco.reportPaths=target/jacoco.exec
sonar.coverage.minimum.global=80%
sonar.coverage.minimum.byFile=70%
sonar.coverage.exclusions=**/config/**,**/exception/**,**/util/**
```

## 三、环境变量与密钥管理

### 3.1 环境变量分类与优先级
| 环境变量类型 | 存储位置 | 优先级 | 适用环境 | 加密要求 |
|--------------|----------|--------|----------|----------|
| 系统级变量 | /etc/environment | 1 | 所有环境 | 否 |
| 用户级变量 | ~/.bashrc | 2 | 开发环境 | 否 |
| 项目级变量 | .env | 3 | 本地开发 | 部分 |
| 部署级变量 | CI/CD平台 | 4 | 测试/生产 | 是 |
| 运行时变量 | 容器平台 | 5 | 生产环境 | 是 |

### 3.2 密钥管理规范
```bash
# 1. 使用TREA环境密钥管理工具
trea-secrets init --env dev

# 2. 添加敏感配置
trea-secrets add DB_PASSWORD "your_secure_password"
trea-secrets add WECHAT_APP_SECRET "wx_app_secret"

# 3. 生成加密环境文件
trea-secrets export --format env > .env.enc

# 4. 在CI/CD中解密（Jenkins示例）
stage('Decrypt Secrets') {
  steps {
    sh 'trea-secrets decrypt --file .env.enc --output .env'
  }
}
```

## 四、构建与部署命令参考

### 4.1 构建命令汇总
| 构建目标 | 命令 | 说明 |
|----------|------|------|
| 开发构建 | `mvn clean package -DskipTests` | 快速构建，跳过测试 |
| 测试构建 | `mvn clean package` | 包含单元测试 |
| 代码检查构建 | `mvn clean verify` | 包含代码质量检查 |
| 生产构建 | `mvn clean package -Pprod` | 使用生产环境配置 |
| 前端构建 | `npm run build:prod` | 小程序生产构建 |

### 4.2 部署流程命令（生产环境）
```bash
# 1. 拉取最新代码
git checkout main
git pull origin main

# 2. 构建Docker镜像
docker build -t parking-app:${VERSION} .
docker tag parking-app:${VERSION} ${REGISTRY_URL}/parking-app:${VERSION}

# 3. 推送镜像
docker push ${REGISTRY_URL}/parking-app:${VERSION}

# 4. 部署到K8s
kubectl apply -f k8s/deployment.yaml
kubectl set image deployment/parking-app parking-app=${REGISTRY_URL}/parking-app:${VERSION}

# 5. 验证部署
kubectl rollout status deployment/parking-app
kubectl get pods | grep parking-app
```

## 五、CI/CD流水线监控与维护

### 5.1 流水线状态监控
```yaml
# Grafana监控面板配置示例（关键指标）
dashboard:
  name: CI/CD Pipeline Monitoring
  metrics:
    - name: build_success_rate
      query: sum(rate(ci_builds{status="success"}[1h])) / sum(rate(ci_builds[1h]))
      threshold: 95%
    - name: test_coverage
      query: avg(sonar_coverage_percentage)
      threshold: 80%
    - name: deployment_time
      query: histogram_quantile(0.95, sum(rate(deployment_duration_seconds_bucket[1h])) by (le))
      threshold: 300s
```

### 5.2 常见问题排查指南
| 问题类型 | 排查步骤 | 解决方案 |
|----------|----------|----------|
| 构建失败 | 1. 查看构建日志<br>2. 检查依赖版本<br>3. 验证代码格式 | 修复编译错误/更新依赖/调整代码格式 |
| 测试失败 | 1. 运行单测定位问题<br>2. 检查测试数据<br>3. 验证环境配置 | 修复业务逻辑/调整测试数据/修正环境配置 |
| 部署超时 | 1. 检查资源使用情况<br>2. 分析网络延迟<br>3. 查看健康检查配置 | 增加资源配额/优化网络/调整健康检查参数 |
| 密钥错误 | 1. 验证密钥有效期<br>2. 检查权限配置<br>3. 确认解密流程 | 更新密钥/调整权限/修复解密命令 |

## 六、配置验证与检查清单

### 6.1 Git配置检查项
- [ ] 已配置正确的用户信息
- [ ] .gitignore文件包含所有敏感文件
- [ ] 分支保护规则已启用
- [ ] 提交信息验证钩子已配置
- [ ] 已设置上游仓库并测试推拉功能

### 6.2 CI/CD配置检查项
- [ ] Jenkinsfile包含所有必要阶段（构建/测试/部署）
- [ ] 测试覆盖率达到80%以上
- [ ] 环境变量已通过加密方式管理
- [ ] 部署流程包含健康检查步骤
- [ ] 构建产物已正确归档

### 6.3 安全合规检查项
- [ ] 敏感配置未提交到代码仓库
- [ ] 镜像仓库已配置访问权限
- [ ] CI/CD服务账号权限最小化
- [ ] 所有外部依赖已通过安全扫描
- [ ] 部署流程包含漏洞扫描步骤