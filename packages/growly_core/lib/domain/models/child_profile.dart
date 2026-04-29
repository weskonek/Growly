enum AgeGroup {
  earlyChildhood, // 2-5
  primary, // 6-9
  upperPrimary, // 10-12
  teen, // 13-18
}

class ChildProfile {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? avatarUrl;
  final AgeGroup ageGroup;
  final String parentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? pin;
  final Map<String, dynamic> settings;
  final bool safeModeEnabled;
  final String? pairingCode;
  final String? gender;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    this.avatarUrl,
    required this.ageGroup,
    required this.parentId,
    required this.createdAt,
    this.updatedAt,
    this.pin,
    this.settings = const {},
    this.safeModeEnabled = false,
    this.pairingCode,
    this.gender,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      avatarUrl: json['avatar_url'] as String?,
      ageGroup: AgeGroup.values[json['age_group'] as int],
      parentId: json['parent_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      pin: json['pin'] as String?,
      settings: (json['settings'] as Map<String, dynamic>?) ?? {},
      safeModeEnabled: json['safe_mode_enabled'] as bool? ?? false,
      pairingCode: json['pairing_code'] as String?,
      gender: json['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'avatar_url': avatarUrl,
      'age_group': ageGroup.index,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'settings': settings,
      'safe_mode_enabled': safeModeEnabled,
      'pairing_code': pairingCode,
      'gender': gender,
    };
  }

  int get age {
    final now = DateTime.now();
    int calculatedAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      calculatedAge--;
    }
    return calculatedAge;
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

  ChildProfile copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? avatarUrl,
    AgeGroup? ageGroup,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pin,
    Map<String, dynamic>? settings,
    bool? safeModeEnabled,
    String? pairingCode,
    String? gender,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ageGroup: ageGroup ?? this.ageGroup,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pin: pin ?? this.pin,
      settings: settings ?? this.settings,
      safeModeEnabled: safeModeEnabled ?? this.safeModeEnabled,
      pairingCode: pairingCode ?? this.pairingCode,
      gender: gender ?? this.gender,
    );
  }
}