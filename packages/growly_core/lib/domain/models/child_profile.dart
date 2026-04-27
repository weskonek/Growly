import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_profile.freezed.dart';
part 'child_profile.g.dart';

enum AgeGroup {
  earlyChildhood, // 2-5
  primary, // 6-9
  upperPrimary, // 10-12
  teen, // 13-18
}

@freezed
class ChildProfile with _$ChildProfile {
  const factory ChildProfile({
    required String id,
    required String name,
    required DateTime birthDate,
    String? avatarUrl,
    required AgeGroup ageGroup,
    required String parentId,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? pin,
    @Default({}) Map<String, dynamic> settings,
  }) = _ChildProfile;

  factory ChildProfile.fromJson(Map<String, dynamic> json) =>
      _$ChildProfileFromJson(json);
}

extension ChildProfileX on ChildProfile {
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String get ageDisplay => '$age tahun';

  static AgeGroup calculateAgeGroup(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age <= 5) return AgeGroup.earlyChildhood;
    if (age <= 9) return AgeGroup.primary;
    if (age <= 12) return AgeGroup.upperPrimary;
    return AgeGroup.teen;
  }
}