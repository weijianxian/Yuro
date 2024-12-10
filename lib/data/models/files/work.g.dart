// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkImpl _$$WorkImplFromJson(Map<String, dynamic> json) => _$WorkImpl(
      id: (json['id'] as num?)?.toInt(),
      sourceId: json['source_id'] as String?,
      sourceType: json['source_type'] as String?,
    );

Map<String, dynamic> _$$WorkImplToJson(_$WorkImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_id': instance.sourceId,
      'source_type': instance.sourceType,
    };
