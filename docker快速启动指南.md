# Docker快速启动项目详细指南

本指南提供了使用Docker快速搭建智能停车场系统开发环境的完整步骤。

## 第一部分：安装Docker环境

### Step 1: 下载Docker Desktop

1. 访问Docker官方网站下载页面：[Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
2. 点击"Download for Windows"按钮下载安装包
3. 等待下载完成（约500MB-1GB）

### Step 2: 安装Docker Desktop

1. 双击下载的Docker Desktop安装程序
2. 在安装向导中：
   - 勾选"Install required Windows components for WSL 2"
   - 勾选"Add shortcut to desktop"
   - 点击"OK"开始安装
3. 安装过程中可能需要管理员权限，请确认允许
4. 安装完成后，点击"Close and restart"重启系统

### Step 3: 验证Docker安装

1. 重启系统后，Docker Desktop将自动启动
2. 等待Docker Desktop完全启动（右下角托盘图标变绿）
3. 按下`Win + R`键，输入`cmd`并回车打开命令提示符
4. 执行以下命令验证安装：

```bash
docker --version
docker-compose --version
docker run hello-world
```

如果看到以下输出，说明Docker安装成功：
- Docker版本信息
- docker-compose版本信息
- "Hello from Docker!" 消息

## 第二部分：启动项目所需服务

### Step 4: 准备项目文件

确保项目根目录下有以下文件：
- `docker-compose.yml`（已创建）
- `init.sql`（已创建）
- `.env`（已创建）

### Step 5: 启动服务容器

1. 打开命令提示符或PowerShell
2. 使用`cd`命令切换到项目根目录：

```bash
cd d:\Park（Wechat）
```

3. 执行以下命令启动Docker容器：

```bash
docker-compose up -d
```

这个命令会：
- 下载MySQL 8.0.28镜像
- 下载Redis 6.2.6镜像
- 下载phpMyAdmin镜像
- 下载Redis Commander镜像
- 创建并启动所有容器
- 自动初始化数据库（运行init.sql脚本）

### Step 6: 验证服务启动

1. 等待命令执行完成（首次启动需要较长时间下载镜像）
2. 执行以下命令检查容器状态：

```bash
docker-compose ps
```

3. 确保所有服务状态都是"Up"：
   - mysql-server: 运行中
   - redis-server: 运行中
   - phpmyadmin: 运行中
   - redis-commander: 运行中

## 第三部分：安装Maven

### Step 7: 下载Maven

1. 访问Maven官方下载页面：[Apache Maven Download](https://maven.apache.org/download.cgi)
2. 下载最新的二进制压缩包（如apache-maven-3.9.6-bin.zip）
3. 下载完成后，将压缩包解压到合适的目录（如`C:\Program Files\Apache Maven`）

### Step 8: 配置Maven环境变量

1. 右键点击"此电脑" → "属性" → "高级系统设置" → "环境变量"
2. 在"系统变量"中点击"新建"，添加：
   - 变量名：`MAVEN_HOME`
   - 变量值：Maven安装路径（如`C:\Program Files\Apache Maven\apache-maven-3.9.6`）
3. 编辑"Path"系统变量，添加：`%MAVEN_HOME%\bin`
4. 点击"确定"保存所有更改

### Step 9: 验证Maven安装

1. 打开新的命令提示符
2. 执行以下命令：

```bash
mvn --version
```

如果看到Maven版本信息，说明安装成功。

## 第四部分：构建和运行项目

### Step 10: 构建项目

1. 确保Docker容器仍在运行
2. 在项目根目录执行以下命令构建项目：

```bash
mvn clean install
```

这个命令会：
- 清理之前的构建文件
- 下载所有必要的Maven依赖
- 编译项目代码
- 运行单元测试
- 打包生成JAR文件

### Step 11: 启动Spring Boot应用

构建成功后，执行以下命令启动应用：

```bash
mvn spring-boot:run
```

应用将在以下端口启动：
- Spring Boot应用：8080
- 数据库管理工具：8081（phpMyAdmin）
- Redis管理工具：8082（Redis Commander）

### Step 12: 验证应用运行

1. 等待应用启动完成（控制台显示Tomcat started on port(s): 8080）
2. 打开浏览器访问：http://localhost:8080/
3. 访问phpMyAdmin：http://localhost:8081/（用户名：parking_admin，密码：parking_password）
4. 访问Redis Commander：http://localhost:8082/

## 第五部分：测试API接口

使用以下API测试系统功能：

### 测试获取附近停车场

```bash
curl "http://localhost:8080/api/v1/parking/nearby?longitude=116.465766&latitude=39.924113&radius=5000"
```

### 测试获取车位详情

```bash
curl http://localhost:8080/api/v1/parking/1
```

### 测试预约车位

使用Postman或其他API测试工具发送POST请求：
- URL: http://localhost:8080/api/v1/parking/reserve
- 请求体：

```json
{
  "parkingSpaceId": 1,
  "userId": 1001,
  "licensePlate": "京A12345",
  "reserveTime": "2023-10-15T15:30:00"
}
```

## 常见问题处理

### 1. Docker启动失败
- 确保Windows系统版本至少为1903，内部版本号18362
- 确保已启用WSL 2功能
- 检查虚拟化是否已启用（BIOS设置）

### 2. Maven构建失败
- 检查网络连接（Maven需要下载依赖）
- 确认JDK 11已正确安装
- 执行`mvn clean install -U`强制更新依赖

### 3. 数据库连接失败
- 检查.env文件中的数据库连接配置
- 确认MySQL容器状态为"Up"
- 使用phpMyAdmin验证数据库是否已创建

### 4. Redis连接失败
- 确认Redis容器状态为"Up"
- 使用Redis Commander验证Redis服务

## 停止服务

完成开发后，可以执行以下命令停止所有容器：

```bash
docker-compose down
```

要完全清理环境（包括删除数据卷），执行：

```bash
docker-compose down -v
```

## 额外提示

1. **数据持久化**：MySQL和Redis数据都配置了持久化存储，即使容器重启数据也不会丢失
2. **查看日志**：执行`docker-compose logs -f`可以查看所有服务的实时日志
3. **修改配置**：如需修改配置，编辑相关文件后执行`docker-compose restart`重启服务

祝您开发愉快！