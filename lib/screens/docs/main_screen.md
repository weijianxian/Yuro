# 应用架构说明

## MainScreen 架构

### 概述
MainScreen 采用集中式的状态管理架构，作为应用的主要页面容器，它负责：
1. 管理所有主要页面的 ViewModel
2. 提供统一的状态管理入口
3. 确保 ViewModel 的单一实例

### 核心原则

1. **ViewModel 单一实例**
   - 所有页面的 ViewModel 都在 MainScreen 中初始化
   - 子页面通过 Provider 获取 ViewModel，不创建自己的实例
   - 确保状态的一致性和可预测性

2. **状态提供机制**
   - 使用 MultiProvider 在顶层提供所有 ViewModel
   - 子页面使用 context.read 或 Provider.of 获取 ViewModel
   - 避免重复创建 ViewModel 实例

3. **生命周期管理**
   - MainScreen 负责 ViewModel 的创建和销毁
   - 在 initState 中初始化所有 ViewModel
   - 在 dispose 中释放所有资源

### 子页面开发指南

1. **ViewModel 访问**   ```dart
   // 推荐使用 context.read 获取 ViewModel
   final viewModel = context.read<HomeViewModel>();
   
   // 或者使用 Provider.of（效果相同）
   final viewModel = Provider.of<HomeViewModel>(context, listen: false);   ```

2. **状态监听**   ```dart
   // 使用 Consumer 监听状态变化
   Consumer<HomeViewModel>(
     builder: (context, viewModel, child) {
       // 使用 viewModel 的状态
     },
   )   ```

3. **注意事项**
   - 不要在子页面中创建新的 ViewModel 实例
   - 使用 AutomaticKeepAliveClientMixin 保持页面状态
   - 在 initState 中进行必要的初始化

### 常见问题

1. **重复实例问题**
   - 症状：状态更新不生效
   - 原因：子页面创建了新的 ViewModel 实例
   - 解决：使用 MainScreen 提供的 ViewModel

2. **状态同步问题**
   - 症状：不同页面状态不同步
   - 原因：使用了多个 ViewModel 实例
   - 解决：确保使用 MainScreen 提供的单一实例