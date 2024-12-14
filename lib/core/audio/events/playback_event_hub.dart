import 'package:rxdart/rxdart.dart';
import './playback_event.dart';

class PlaybackEventHub {
  // 单例实现
  static final PlaybackEventHub _instance = PlaybackEventHub._internal();
  factory PlaybackEventHub() => _instance;
  PlaybackEventHub._internal();

  // 主事件流
  final _eventSubject = PublishSubject<PlaybackEvent>();

  // 分类事件流
  late final Stream<PlaybackStateEvent> playbackState = _eventSubject
      .whereType<PlaybackStateEvent>()
      .distinct();
      
  late final Stream<TrackChangeEvent> trackChange = _eventSubject
      .whereType<TrackChangeEvent>();
      
  late final Stream<PlaybackContextEvent> contextChange = _eventSubject
      .whereType<PlaybackContextEvent>();
      
  late final Stream<PlaybackProgressEvent> playbackProgress = _eventSubject
      .whereType<PlaybackProgressEvent>()
      .distinct((prev, next) => prev.position == next.position);
      
  late final Stream<PlaybackErrorEvent> errors = _eventSubject
      .whereType<PlaybackErrorEvent>();

  // 发送事件
  void emit(PlaybackEvent event) => _eventSubject.add(event);

  // 资源释放
  void dispose() => _eventSubject.close();
} 