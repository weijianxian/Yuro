// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_lists.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarkListsImpl _$$MarkListsImplFromJson(Map<String, dynamic> json) =>
    _$MarkListsImpl(
      playlists: (json['playlists'] as List<dynamic>?)
          ?.map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MarkListsImplToJson(_$MarkListsImpl instance) =>
    <String, dynamic>{
      'playlists': instance.playlists,
      'pagination': instance.pagination,
    };
