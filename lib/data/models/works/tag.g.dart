// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
      id: (json['id'] as num?)?.toInt(),
      i18n: json['i18n'] == null
          ? null
          : I18n.fromJson(json['i18n'] as Map<String, dynamic>),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
      'id': instance.id,
      'i18n': instance.i18n,
      'name': instance.name,
    };
