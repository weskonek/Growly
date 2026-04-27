// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildProfileImpl _$$ChildProfileImplFromJson(Map<String, dynamic> json) =>
    _$ChildProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      avatarUrl: json['avatarUrl'] as String?,
      ageGroup: $enumDecode(_$AgeGroupEnumMap, json['ageGroup']),
      parentId: json['parentId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      pin: json['pin'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ChildProfileImplToJson(_$ChildProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'birthDate': instance.birthDate.toIso8601String(),
      'avatarUrl': instance.avatarUrl,
      'ageGroup': _$AgeGroupEnumMap[instance.ageGroup]!,
      'parentId': instance.parentId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'pin': instance.pin,
      'settings': instance.settings,
    };

const _$AgeGroupEnumMap = {
  AgeGroup.earlyChildhood: 'earlyChildhood',
  AgeGroup.primary: 'primary',
  AgeGroup.upperPrimary: 'upperPrimary',
  AgeGroup.teen: 'teen',
};
