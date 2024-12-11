# 音频核心功能

此文档仅供参考，实际实现可能随项目发展而变化。

## 当前架构

### 1. 音频服务 (AudioPlayerService)
- 单例模式实现
- 基于 just_audio 包
- 通过 GetIt 注入管理

<pre>
class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  AudioTrackInfo? _currentTrack;
  
  // 单例实现
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
}
</pre>

### 2. 音频状态管理 (MiniPlayerViewModel)
- 通过 GetIt 实现全局单例
- 使用 ChangeNotifier 管理状态
- 负责 UI 和音频服务的交互

<pre>
class MiniPlayerViewModel extends ChangeNotifier {
  final IAudioPlayerService _audioService = GetIt.I<IAudioPlayerService>();
  Track? _currentTrack;
  bool _isPlaying = false;
  Duration? _position;
  Duration? _duration;
}
</pre>

### 3. UI 组件
- MiniPlayer: 迷你播放器组件
- MiniPlayerControls: 播放控制组件
- MiniPlayerProgress: 进度条组件

### 4. 依赖注入
通过 GetIt 管理所有依赖：
<pre>
void setupServiceLocator() {
  getIt.registerLazySingleton<IAudioPlayerService>(() => AudioPlayerService());
  getIt.registerLazySingleton<MiniPlayerViewModel>(() => MiniPlayerViewModel());
}
</pre>

## 待实现功能

1. 播放列表管理
2. 播放模式控制
3. 音频缓存
4. 播放历史记录
5. 完整播放器界面

## 注意事项

- 此架构文档仅供参考
- 可根据需求随时调整
- 优先考虑实际开发需求
- 保持灵活性和可扩展性
 