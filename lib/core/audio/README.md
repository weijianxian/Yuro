# 音频核心功能

## 当前架构

### 1. 事件驱动系统
- 基于 RxDart 的事件中心
- 统一的事件定义和处理
- 支持事件过滤和转换

### 2. 核心服务 (AudioPlayerService)
- 实现 IAudioPlayerService 接口
- 通过依赖注入管理依赖
- 负责协调各个组件

### 3. 状态管理
- PlaybackStateManager 负责状态维护
- 通过 EventHub 发送状态更新
- 支持状态持久化

### 4. 通知栏集成
- 基于 audio_service 包
- 响应系统媒体控制
- 支持后台播放

### 5. 依赖注入
通过 GetIt 管理所有依赖：
<pre>
void setupServiceLocator() {
  // 注册 EventHub
  getIt.registerLazySingleton(() => PlaybackEventHub());
  
  // 注册音频服务
  getIt.registerLazySingleton<IAudioPlayerService>(
    () => AudioPlayerService(
      eventHub: getIt(),
      stateRepository: getIt(),
    ),
  );
}
</pre>

## 注意事项

- 所有状态更新通过 EventHub 传递
- 避免组件间直接调用
- 优先使用依赖注入
- 保持组件职责单一
 