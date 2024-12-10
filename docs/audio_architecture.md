# ASMR One App 音频播放架构设计

## 1. 架构概述

本文档描述了 ASMR One App 音频播放功能的架构设计。遵循 Clean Architecture 原则，将音频播放功能分为核心层、数据层、领域层和表现层。

## 2. 目录结构

<pre>
lib/
├── core/
│   └── audio/                    # 音频核心功能
│       ├── audio_service.dart    # 音频服务接口
│       ├── audio_player.dart     # 播放器实现
│       └── playlist_manager.dart # 播放列表管理
│
├── data/
│   ├── models/
│   │   └── audio/
│   │       ├── audio_track.dart  # 音频轨道模型
│   │       └── playlist.dart     # 播放列表模型
│   └── repositories/
│       └── audio/
│           └── audio_repository_impl.dart # 音频仓库实现
│
├── domain/
│   └── repositories/
│       └── audio/
│           └── i_audio_repository.dart    # 音频仓库接口
│
└── presentation/
    ├── screens/
    │   └── player/
    │       ├── player_screen.dart   # 播放器页面
    │       └── mini_player.dart     # 迷你播放器
    ├── viewmodels/
    │   └── player/
    │       └── player_viewmodel.dart # 播放器视图模型
    └── widgets/
        └── player/
            ├── player_controls.dart  # 播放控制组件
            └── progress_bar.dart     # 进度条组件
</pre>

## 3. 核心组件设计

### 3.1 音频服务 (AudioService)

<pre>
abstract class AudioService {
  // 播放控制
  Future<void> play(AudioTrack track);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  
  // 播放状态
  Stream<PlaybackState> get playbackState;
  Stream<Duration> get position;
  
  // 播放列表管理
  Future<void> addToPlaylist(AudioTrack track);
  Future<void> removeFromPlaylist(AudioTrack track);
}
</pre>

### 3.2 播放列表管理器 (PlaylistManager)

<pre>
class PlaylistManager {
  // 播放列表操作
  Future<void> addTrack(AudioTrack track);
  Future<void> removeTrack(AudioTrack track);
  Future<void> clearPlaylist();
  
  // 播放顺序控制
  Future<void> shuffle();
  Future<void> setRepeatMode(RepeatMode mode);
  
  // 状态获取
  List<AudioTrack> get playlist;
  AudioTrack? get currentTrack;
}
</pre>

## 4. 数据模型

### 4.1 音频轨道模型 (AudioTrack)

<pre>
@freezed
class AudioTrack with _$AudioTrack {
  factory AudioTrack({
    required String id,
    required String title,
    required String url,
    String? artist,
    Duration? duration,
    String? coverUrl,
  }) = _AudioTrack;
}
</pre>

### 4.2 播放状态模型 (PlaybackState)

<pre>
enum PlaybackState {
  none,
  loading,
  playing,
  paused,
  stopped,
  error
}
</pre>

## 5. 视图模型设计

### 5.1 播放器视图模型 (PlayerViewModel)

<pre>
class PlayerViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PlaylistManager _playlistManager;
  
  // 状态管理
  PlaybackState get playbackState => _playbackState;
  Duration get position => _position;
  AudioTrack? get currentTrack => _currentTrack;
  
  // 播放控制
  Future<void> playTrack(AudioTrack track);
  Future<void> togglePlayPause();
  Future<void> seekTo(Duration position);
  
  // 播放列表操作
  Future<void> addToPlaylist(AudioTrack track);
  Future<void> removeFromPlaylist(AudioTrack track);
}
</pre>

## 6. 用户界面组件

### 6.1 播放器页面结构

- 主播放器界面 (PlayerScreen)
- 迷你播放器 (MiniPlayer)
- 播放控制组件 (PlayerControls)
- 进度条组件 (ProgressBar)
- 音量控制组件 (VolumeSlider)

### 6.2 交互设计

- 手势控制��左右滑动切换曲目，上下滑动调节音量
- 进度条拖动：支持精确定位
- 播放列表管理：支持拖拽排序
- 迷你播放器：支持展开/收起动画

## 7. 技术实现细节

### 7.1 音频引擎选择

使用 just_audio 包作为音频播放引擎：
- 支持多平台
- 支持后台播放
- 支持流媒体
- 性能优秀
- 社区活跃

### 7.2 缓存策略

- 音频文件缓存：使用 just_audio_cache
- 元数据缓存：使用 shared_preferences
- 播放历史：使用 sqflite

## 8. 开发计划

1. 第一阶段：基础播放
   - 实现核心播放功能
   - 完成基础UI组件
   - 支持单曲播放

2. 第二阶段：播放控制
   - 实现进度控制
   - 实现音量控制
   - 添加播放列表功能

3. 第三阶段：增强功能
   - 实现后台播放
   - 添加缓存支持
   - 优化播放体验

4. 第四阶段：完善优化
   - UI/UX 改进
   - 性能优化
   - 错误处理完善 