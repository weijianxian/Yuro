// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      loggedIn: json['loggedIn'] as bool?,
      name: json['name'] as String?,
      group: json['group'] as String?,
      email: json['email'],
      recommenderUuid: json['recommenderUuid'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'loggedIn': instance.loggedIn,
      'name': instance.name,
      'group': instance.group,
      'email': instance.email,
      'recommenderUuid': instance.recommenderUuid,
    };
