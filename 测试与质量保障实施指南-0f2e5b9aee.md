# 测试与质量保障实施指南

## 1. 测试策略与范围

### 1.1 测试阶段划分
- **单元测试**：覆盖后端80%以上核心业务逻辑代码，重点验证预约锁定、超时释放等关键算法
- **集成测试**：验证前后端接口交互、第三方服务集成（支付/地图/语音）的端到端流程
- **系统测试**：验证完整业务场景（用户注册→车位预约→支付→使用→评价）
- **性能测试**：模拟1000+并发用户场景下的系统响应时间和资源占用
- **安全测试**：验证权限控制、数据加密、防注入等安全防护措施

### 1.2 测试环境配置
| 环境类型 | 用途 | 配置规格 | 数据库 |
|---------|------|---------|--------|
| 开发环境 | 单元测试/集成测试 | 4核8G | H2内存数据库 |
| 测试环境 | 系统测试/功能验证 | 8核16G | MySQL 8.0主从架构 |
| 压测环境 | 性能测试 | 16核32G | MySQL+Redis集群 |

## 2. 自动化测试框架搭建

### 2.1 后端测试框架
```java
// Spring Boot测试示例（使用JUnit 5 + Mockito）
@SpringBootTest
public class ReservationServiceTest {
    @MockBean
    private RedisTemplate<String, Object> redisTemplate;
    
    @Autowired
    private ReservationService reservationService;
    
    @Test
    public void testLockParkingSpace_Success() {
        // 测试预约锁定成功场景
        when(redisTemplate.opsForValue().setIfAbsent(anyString(), any(), anyLong(), any()))
            .thenReturn(true);
            
        ResultDTO<ReservationDTO> result = reservationService.lockParkingSpace(1L, "USER123", 30);
        assertTrue(result.isSuccess());
        assertEquals(ReservationStatus.LOCKED, result.getData().getStatus());
    }
}
```

### 2.2 前端测试框架
```javascript
// 小程序单元测试示例（使用Jest + miniprogram-simulate）
describe('预约组件测试', () => {
  let component;
  
  beforeEach(() => {
    component = simulate.render(require('../components/reservation/reservation.vue'));
    component.attach(document.createElement('parent'));
  });
  
  test('选择日期后显示可用车位', async () => {
    // 模拟选择日期
    component.instance.selectDate('2025-10-20');
    await component.instance.$nextTick();
    
    // 验证车位列表是否正确渲染
    expect(component.querySelector('.parking-list').children.length).toBeGreaterThan(0);
  });
});
```

### 2.3 接口自动化测试
使用PostMan实现接口自动化测试，关键测试集包括：
- 用户管理API测试集（23个用例）
- 车位管理API测试集（18个用例）
- 预约流程API测试集（31个用例）
- 支付回调API测试集（15个用例）

## 3. 核心功能测试用例

### 3.1 预约锁定功能测试矩阵
| 测试编号 | 场景描述 | 输入数据 | 预期结果 | 优先级 |
|---------|---------|---------|---------|--------|
| RESV-001 | 正常预约锁定 | 车位ID=1,用户ID=U100,锁定时间=30分钟 | 锁定成功,返回预约ID | 高 |
| RESV-002 | 车位已被锁定 | 车位ID=1(已锁定),用户ID=U200 | 返回错误:车位已被占用 | 高 |
| RESV-003 | 锁定超时 | 车位ID=2,锁定后31分钟查询 | 车位状态恢复为"空闲" | 高 |
| RESV-004 | 并发锁定同一车位 | 10个线程同时锁定车位ID=3 | 只有1个线程成功,其他返回失败 | 高 |

### 3.2 支付流程测试用例
```json
// 支付回调测试用例（正常支付场景）
{
  "testCaseId": "PAY-005",
  "title": "支付成功回调处理",
  "request": {
    "outTradeNo": "TEST20251016001",
    "totalFee": 2000,
    "tradeStatus": "SUCCESS",
    "sign": "a1b2c3d4e5f6..."
  },
  "expectedResponse": {
    "code": 200,
    "message": "success",
    "data": {
      "orderStatus": "PAID",
      "reservationStatus": "CONFIRMED"
    }
  }
}
```

## 4. 性能测试方案

### 4.1 测试指标定义
- 响应时间：95%请求 < 500ms，99%请求 < 1000ms
- 吞吐量：每秒处理预约请求 ≥ 100 TPS
- 资源占用：CPU利用率 < 70%，内存使用 < 80%
- 数据库：查询响应时间 < 200ms，事务成功率 100%

### 4.2 压力测试场景设计
1. **基础场景**：模拟500用户同时浏览车位列表
2. **核心场景**：模拟300用户同时预约同一时段车位
3. **极限场景**：逐步增加用户至1000，观察系统瓶颈

### 4.3 性能监控指标
```yaml
# Prometheus监控配置示例
scrape_configs:
  - job_name: 'parking-system'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['192.168.1.100:8080']
    metrics_relabel_configs:
      - source_labels: [__name__]
        regex: 'http_server_requests_seconds_sum'
        action: keep
```

## 5. 缺陷管理流程

### 5.1 缺陷分级标准
- **P0（阻断）**：核心功能不可用（如无法预约车位）
- **P1（严重）**：功能部分可用但影响主要流程（如支付偶发失败）
- **P2（一般）**：功能可用但有明显体验问题（如页面加载缓慢）
- **P3（轻微）**：界面/文案问题，不影响功能使用

### 5.2 缺陷修复流程
1. 测试人员提交缺陷（JIRA）→ 2. 开发人员认领修复 → 3. 单元测试验证 → 
4. 回归测试验证 → 5. 缺陷关闭（需通过CI自动测试）

## 6. 质量门禁与验收标准

### 6.1 代码质量门禁
- 单元测试覆盖率 ≥ 80%
- SonarQube代码质量评分 ≥ 85分
- 代码重复率 < 5%
- 无严重安全漏洞

### 6.2 验收通过标准
- 所有P0/P1级别缺陷100%修复并验证通过
- 性能测试指标达到设计要求（响应时间/吞吐量）
- 核心业务场景测试通过率100%
- 文档完整性检查通过（API文档/测试报告/用户手册）

## 7. 持续集成/持续部署配置

### 7.1 CI流程配置（GitLab CI示例）
```yaml
stages:
  - test
  - build
  - deploy

unit_test:
  stage: test
  script:
    - ./mvnw test
  artifacts:
    reports:
      junit: target/surefire-reports/TEST-*.xml

code_quality:
  stage: test
  script:
    - ./mvnw sonar:sonar
```

### 7.2 自动化部署流程
1. 代码合并至develop分支 → 2. 自动运行单元测试/集成测试 → 
3. 构建Docker镜像并推送仓库 → 4. 自动部署至测试环境 → 
5. 运行系统测试 → 6. 手动确认后部署至生产环境