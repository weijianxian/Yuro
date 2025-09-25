import 'package:rxdart/rxdart.dart';
import './playback_event.dart';

class PlaybackEventHub {
  // 统一的事件流，处理所有类型的事件
  final _eventSubject = PublishSubject<PlaybackEvent>();

  // 分类后的特定事件流
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

  // 添加新的事件流
  late final Stream<InitialStateEvent> initialState = _eventSubject
      .whereType<InitialStateEvent>();
      
  late final Stream<RequestInitialStateEvent> requestInitialState = _eventSubject
      .whereType<RequestInitialStateEvent>();

  // 添加跳转事件流
  late final Stream<SkipToNextEvent> skipToNext = _eventSubject
      .whereType<SkipToNextEvent>();
      
  late final Stream<SkipToPreviousEvent> skipToPrevious = _eventSubject
      .whereType<SkipToPreviousEvent>();

  // 发送事件
  void emit(PlaybackEvent event) => _eventSubject.add(event);

  // 资源释放
  void dispose() => _eventSubject.close();
} 