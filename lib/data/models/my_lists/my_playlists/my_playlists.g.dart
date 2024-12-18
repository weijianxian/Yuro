// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_playlists.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MyPlaylistsImpl _$$MyPlaylistsImplFromJson(Map<String, dynamic> json) =>
    _$MyPlaylistsImpl(
      playlists: (json['playlists'] as List<dynamic>?)
          ?.map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MyPlaylistsImplToJson(_$MyPlaylistsImpl instance) =>
    <String, dynamic>{
      'playlists': instance.playlists,
      'pagination': instance.pagination,
    };
