// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthRespImpl _$$AuthRespImplFromJson(Map<String, dynamic> json) =>
    _$AuthRespImpl(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String?,
    );

Map<String, dynamic> _$$AuthRespImplToJson(_$AuthRespImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
    };
