class DeviceModel {
  final String id;
  final String childId;
  final String deviceName;
  final String? deviceModel;
  final String? osVersion;
  final DateTime? lastActiveAt;
  final bool isCurrent;
  final bool isActive;
  final DateTime createdAt;

  const DeviceModel({
    required this.id,
    required this.childId,
    required this.deviceName,
    this.deviceModel,
    this.osVersion,
    this.lastActiveAt,
    this.isCurrent = false,
    this.isActive = true,
    required this.createdAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      deviceName: json['device_name'] as String,
      deviceModel: json['device_model'] as String?,
      osVersion: json['os_version'] as String?,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      isCurrent: json['is_current'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'device_name': deviceName,
      'device_model': deviceModel,
      'os_version': osVersion,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'is_current': isCurrent,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DeviceModel copyWith({
    bool? isCurrent,
    bool? isActive,
    DateTime? lastActiveAt,
  }) {
    return DeviceModel(
      id: id,
      childId: childId,
      deviceName: deviceName,
      deviceModel: deviceModel,
      osVersion: osVersion,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isCurrent: isCurrent ?? this.isCurrent,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
