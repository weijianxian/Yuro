// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaybackStateImpl _$$PlaybackStateImplFromJson(Map<String, dynamic> json) =>
    _$PlaybackStateImpl(
      work: Work.fromJson(json['work'] as Map<String, dynamic>),
      files: Files.fromJson(json['files'] as Map<String, dynamic>),
      currentFile: Child.fromJson(json['currentFile'] as Map<String, dynamic>),
      playlist: (json['playlist'] as List<dynamic>)
          .map((e) => Child.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentIndex: (json['currentIndex'] as num).toInt(),
      playMode: $enumDecode(_$PlayModeEnumMap, json['playMode']),
      position: (json['position'] as num).toInt(),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$$PlaybackStateImplToJson(_$PlaybackStateImpl instance) =>
    <String, dynamic>{
      'work': instance.work,
      'files': instance.files,
      'currentFile': instance.currentFile,
      'playlist': instance.playlist,
      'currentIndex': instance.currentIndex,
      'playMode': _$PlayModeEnumMap[instance.playMode]!,
      'position': instance.position,
      'timestamp': instance.timestamp,
    };

const _$PlayModeEnumMap = {
  PlayMode.single: 'single',
  PlayMode.loop: 'loop',
  PlayMode.sequence: 'sequence',
};
