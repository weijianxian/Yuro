// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlists_with_exist_statu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaylistsWithExistStatuImpl _$$PlaylistsWithExistStatuImplFromJson(
        Map<String, dynamic> json) =>
    _$PlaylistsWithExistStatuImpl(
      playlists: (json['playlists'] as List<dynamic>?)
          ?.map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PlaylistsWithExistStatuImplToJson(
        _$PlaylistsWithExistStatuImpl instance) =>
    <String, dynamic>{
      'playlists': instance.playlists,
      'pagination': instance.pagination,
    };
