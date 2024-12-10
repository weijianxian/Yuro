// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'i18n.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$I18nImpl _$$I18nImplFromJson(Map<String, dynamic> json) => _$I18nImpl(
      enUs: json['en-us'] == null
          ? null
          : EnUs.fromJson(json['en-us'] as Map<String, dynamic>),
      jaJp: json['ja-jp'] == null
          ? null
          : JaJp.fromJson(json['ja-jp'] as Map<String, dynamic>),
      zhCn: json['zh-cn'] == null
          ? null
          : ZhCn.fromJson(json['zh-cn'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$I18nImplToJson(_$I18nImpl instance) =>
    <String, dynamic>{
      'en-us': instance.enUs,
      'ja-jp': instance.jaJp,
      'zh-cn': instance.zhCn,
    };
