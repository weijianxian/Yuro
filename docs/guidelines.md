# ASMR Music App Development Guidelines
# ASMR Music App 开发准则

## Important Notice | 重要说明

These guidelines are living documents that will evolve with the project. Any changes in practice must be reflected in these guidelines, especially the architecture section which must stay consistent with the actual project structure.

本准则是一个动态文档，会随项目发展而演进。实践中的任何变更都必须更新到本准则中，特别是架构部分必须与实际项目结构保持一致。

## 1. Architecture Design Guidelines | 架构设计准则

### 1.1 Decoupling Principles | 解耦原则
- Follow SOLID principles strictly | 严格遵循 SOLID 原则
- Use dependency injection | 使用依赖注入管理组件依赖
- Implement BLoC pattern | 采用 BLoC 模式分离业务逻辑和UI
- Define interfaces for inter-module communication | 使用接口定义模块间通信契约

### 1.2 Modularization Principles | 模块化原则
- Divide modules by functionality | 按功能划分模块
- Follow single responsibility principle | 遵循单一职责原则
- Clear interface communication | 模块间通过清晰的接口通信
- Share common components | 共享组件放置在 common/shared 目录下

### 1.3 Code Organization | 代码组织
<pre>
lib/
├── core/                 # Core functionality | 核心功能
│   ├── di/              # Dependency injection | 依赖注入
│   ├── theme/           # Theme configuration | 主题配置
│   └── utils/           # Utilities | 工具类
├── data/                # Data layer | 数据层
│   ├── models/          # Data models | 数据模型
│   ├── repositories/    # Data repositories | 数据仓库
│   └── services/        # Service implementations | 服务实现
├── domain/              # Domain layer | 领域层
│   ├── entities/        # Business entities | 业务实体
│   └── repositories/    # Repository interfaces | 仓库接口
├── presentation/        # Presentation layer | 表现层
│   ├── blocs/          # State management | 状态管理
│   ├── screens/        # Pages | 页面
│   └── widgets/        # Components | 组件
└── common/             # Common functionality | 通用功能
    ├── constants/      # Constants | 常量
    └── extensions/     # Extensions | 扩展方法
</pre>

## 2. UI/UX Design Guidelines | UI/UX 设计准则

### 2.1 Interface Design | 界面设计
- Follow Material Design 3 | 遵循 Material Design 3 设计规范
- Consistent color theme and typography | 使用一致的颜色主题和字体
- Maintain visual hierarchy | 保持视觉层次感和空间布局的平衡
- Pixel-perfect alignment | 注重细节，保持像素级别的对齐

### 2.2 Animation Effects | 动画效果
- Use Flutter's built-in animation system | 使用 Flutter 内置动画系统
- Animation duration: 200-300ms | 所有动画持续时间保持在 200-300ms 之间
- Use curve animations (Curves.easeInOut) | 使用曲线动画
- Smooth page transitions | 实现平滑的页面转场效果
- Meaningful micro-interactions | 添加有意义的微交互动画

### 2.3 Performance Optimization | 性能优化
- Use const constructors | 使用 const 构造器
- Proper use of StatelessWidget | 合理使用 StatelessWidget
- Avoid complex calculations in build | 避免在 build 方法中进行复杂计算
- Use ListView.builder for long lists | 使用 ListView.builder 处理长列表
- Image compression and caching | 图片资源进行适当压缩和缓存

## 3. Code Quality Guidelines | 代码质量准则

### 3.1 Code Style | 代码风格
- Follow Dart style guide | 遵循 Dart 官方代码风格指南
- Use dartfmt | 使用 dartfmt 格式化代码
- Type safety | 类型安全，避��使用 dynamic
- Proper documentation | 添加必要的注释，特别是复杂业务逻辑

### 3.2 Testing Standards | 测试规范
- Unit test coverage > 80% | 单元测试覆盖率要求 > 80%
- Widget testing | 编写 Widget 测试验证UI行为
- Integration testing | 集成测试覆盖关键业务流程
- Dependency isolation | 使用 mock 进行依赖隔离

## 4. Version Control Guidelines | 版本控制准则

### 4.1 Git Standards | Git 规范
- Feature Branch workflow | 使用 Feature Branch 工作流
- Angular commit convention | commit 信息遵循 Angular 规范
- Regular code reviews | 定期进行代码审查
- Stable main branch | 保持 main 分支稳定可用

### 4.2 Release Standards | 发布规范
- Semantic versioning | 遵循语义化版本控制
- Clear changelog | 每次发布都要有清晰的更新日志
- Complete testing before release | 重要版本发布前进行完整测试
- Documentation updates | 保留每个版本的文档更新

## 5. Project Management Guidelines | 项目管理准则

### 5.1 Documentation Management | 文档管理
- API documentation | 及时更新 API 文档
- Clear README | 维护清晰的 README
- Design decisions | 记录重要的设计决策
- User and developer guides | 编写用户指南和开发指南

### 5.2 Issue Tracking | 问题追踪
- Track bugs and features | 使用 Issue 跟踪 bug 和新功能
- Proper labeling | 为每个 Issue 添加适当的标签
- Task traceability | 保持任务的可追踪性
- Regular status updates | 定期回顾和更新任务状态 