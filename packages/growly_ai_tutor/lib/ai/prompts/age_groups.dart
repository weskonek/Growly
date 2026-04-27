import 'package:growly_core/growly_core.dart';

class AgeGroupConfig {
  final AgeGroup ageGroup;
  final String name;
  final int minAge;
  final int maxAge;
  final List<String> subjects;
  final String tutorMode;
  final double speechRate;
  final double pitch;

  const AgeGroupConfig({
    required this.ageGroup,
    required this.name,
    required this.minAge,
    required this.maxAge,
    required this.subjects,
    required this.tutorMode,
    required this.speechRate,
    required this.pitch,
  });
}

class AgeGroupConfigs {
  static const earlyChildhood = AgeGroupConfig(
    ageGroup: AgeGroup.earlyChildhood,
    name: 'Balita',
    minAge: 2,
    maxAge: 5,
    subjects: [' angka', ' huruf', ' bentuk', ' warna', ' cerita'],
    tutorMode: 'story',
    speechRate: 0.4,
    pitch: 1.1,
  );

  static const primary = AgeGroupConfig(
    ageGroup: AgeGroup.primary,
    name: 'Sekolah Dasar Awal',
    minAge: 6,
    maxAge: 9,
    subjects: ['membaca', 'matematika', 'sains', 'kreativitas'],
    tutorMode: 'story_math',
    speechRate: 0.5,
    pitch: 1.0,
  );

  static const upperPrimary = AgeGroupConfig(
    ageGroup: AgeGroup.upperPrimary,
    name: 'Sekolah Dasar Lanjut',
    minAge: 10,
    maxAge: 12,
    subjects: ['matematika', 'sains', 'bahasa', 'IPS'],
    tutorMode: 'math_homework',
    speechRate: 0.55,
    pitch: 1.0,
  );

  static const teen = AgeGroupConfig(
    ageGroup: AgeGroup.teen,
    name: 'Remaja',
    minAge: 13,
    maxAge: 18,
    subjects: ['matematika', 'sains', 'bahasa', 'IPA', 'IPS'],
    tutorMode: 'homework',
    speechRate: 0.6,
    pitch: 1.0,
  );

  static AgeGroupConfig fromAgeGroup(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.earlyChildhood:
        return earlyChildhood;
      case AgeGroup.primary:
        return primary;
      case AgeGroup.upperPrimary:
        return upperPrimary;
      case AgeGroup.teen:
        return teen;
    }
  }

  static AgeGroupConfig fromAge(int age) {
    if (age <= 5) return earlyChildhood;
    if (age <= 9) return primary;
    if (age <= 12) return upperPrimary;
    return teen;
  }
}