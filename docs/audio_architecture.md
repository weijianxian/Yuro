# ASMR One App 音频播放架构设计

## 1. 架构概述

本文档描述了 ASMR One App 音频播放功能的架构设计。遵循 Clean Architecture 原则，采用事件驱动架构，将音频播放功能分为核心层、数据层和表现层。

## 2. 目录结构

<pre>
lib/
├── core/
│   └── audio/                      # 音频核心功能
│       ├── audio_player_service.dart    # 音频服务实现
│       ├── i_audio_player_service.dart  # 音频服务接口
│       ├── controllers/                 # 控制器
│       │   └── playback_controller.dart # 播放控制器
│       ├── events/                      # 事件系统
│       │   ├── playback_event.dart     # 事件定义
│       │   └── playback_event_hub.dart # 事件中心
│       ├── models/                      # 数据模型
│       │   ├── audio_track_info.dart   # 音轨信息
│       │   └── playback_context.dart   # 播放上下文
│       ├── notification/                # 通知栏
│       │   └── audio_notification_service.dart
│       ├── state/                       # 状态管理
│       │   └── playback_state_manager.dart
│       ├── storage/                     # 状态持久化
│       │   ├── i_playback_state_repository.dart
│       │   └── playback_state_repository.dart
│       └── utils/                       # 工具类
│           ├── audio_error_handler.dart
│           ├── playlist_builder.dart
│           └── track_info_creator.dart
└── presentation/
    └── viewmodels/
        └── player_viewmodel.dart   # 播放器视图模型
</pre>

## 3. 核心组件设计

### 3.1 音频服务接口 (IAudioPlayerService)

<pre>
abstract class IAudioPlayerService {
  // 基础播放控制
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> previous();
  Future<void> next();
  
  // 上下文管理
  Future<void> playWithContext(PlaybackContext context);
  
  // 状态访问
  AudioTrackInfo? get currentTrack;
  PlaybackContext? get currentContext;
  
  // 状态持久化
  Future<void> savePlaybackState();
  Future<void> restorePlaybackState();
}
</pre>

### 3.2 事件系统 (PlaybackEventHub)

<pre>
class PlaybackEventHub {
  // 主事件流
  final _eventSubject = PublishSubject<PlaybackEvent>();
  
  // 分类事件流
  late final Stream<PlaybackStateEvent> playbackState;
  late final Stream<TrackChangeEvent> trackChange;
  late final Stream<PlaybackContextEvent> contextChange;
  late final Stream<PlaybackProgressEvent> playbackProgress;
  late final Stream<PlaybackErrorEvent> errors;
  
  void emit(PlaybackEvent event);
}
</pre>

## 4. 事件模型

### 4.1 播放事件 (PlaybackEvent)

<pre>
abstract class PlaybackEvent {}

class PlaybackStateEvent extends PlaybackEvent {
  final PlayerState state;
  final Duration position;
  final Duration? duration;
}

class TrackChangeEvent extends PlaybackEvent {
  final AudioTrackInfo track;
  final Child file;
  final Work work;
}

// ... 其他事件定义
</pre>

## 5. 状态管理

### 5.1 播放状态管理器 (PlaybackStateManager)

<pre>
class PlaybackStateManager {
  final AudioPlayer _player;
  final PlaybackEventHub _eventHub;
  final IPlaybackStateRepository _stateRepository;
  
  void initStateListeners();
  void updateContext(PlaybackContext? context);
  void updateTrackInfo(AudioTrackInfo track);
  Future<void> saveState();
  Future<PlaybackState?> loadState();
}
</pre>

## 6. 通知栏集成

### 6.1 通知栏服务 (AudioNotificationService)

<pre>
class AudioNotificationService {
  final AudioPlayer _player;
  final PlaybackEventHub _eventHub;
  AudioHandler? _audioHandler;
  
  Future<void> init();
  void updateMetadata(AudioTrackInfo trackInfo);
}
</pre>

## 7. 技术实现细节

### 7.1 依赖注入

使用 GetIt 进行依赖管理：
- PlaybackEventHub 注册为单例
- AudioPlayerService 注册为懒加载单例
- 所有依赖通过构造函数注入

### 7.2 事件驱动

- 使用 RxDart 实现事件流
- 统一的事件中心管理所有播放相关事件
- 各组件通过事件通信，降低耦合

### 7.3 错误处理

- 统一的错误处理机制
- 错误事件通过 EventHub 传递
- 支持错误追踪和日志记录

## 8. 开发计划

1. 优化播放体验
   - 优化事件处理性能
   - 完善错误处理机制
   - 改进状态同步逻辑

2. 增强功能
   - 添加播放列表功能
   - 支持更多播放模式
   - 优化缓存策略

3. 改进架构
   - 进一步解耦组件
   - 优化依赖注入
   - 完善单元测试
</pre>