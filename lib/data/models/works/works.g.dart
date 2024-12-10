// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'works.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorksImpl _$$WorksImplFromJson(Map<String, dynamic> json) => _$WorksImpl(
      works: (json['works'] as List<dynamic>?)
          ?.map((e) => Work.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WorksImplToJson(_$WorksImpl instance) =>
    <String, dynamic>{
      'works': instance.works,
      'pagination': instance.pagination,
    };
