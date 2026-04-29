class RewardBox {
  final String id;
  final String parentId;
  final String? childId; // null = applies to all children of parent
  final String? childName; // populated when read
  final int targetStars;
  final int currentStars; // populated when read
  final String rewardDescription;
  final DateTime expiresAt;
  final bool isClaimed;
  final DateTime? claimedAt;
  final DateTime createdAt;

  const RewardBox({
    required this.id,
    required this.parentId,
    this.childId,
    this.childName,
    required this.targetStars,
    this.currentStars = 0,
    required this.rewardDescription,
    required this.expiresAt,
    this.isClaimed = false,
    this.claimedAt,
    required this.createdAt,
  });

  double get progress {
    if (targetStars == 0) return 0;
    return (currentStars / targetStars).clamp(0.0, 1.0);
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory RewardBox.fromJson(Map<String, dynamic> json) {
    return RewardBox(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      childId: json['child_id'] as String?,
      childName: json['child_name'] as String?,
      targetStars: json['target_stars'] as int? ?? 0,
      currentStars: json['current_stars'] as int? ?? 0,
      rewardDescription: json['reward_description'] as String? ?? '',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isClaimed: json['is_claimed'] as bool? ?? false,
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'child_id': childId,
      'target_stars': targetStars,
      'reward_description': rewardDescription,
      'expires_at': expiresAt.toIso8601String(),
      'is_claimed': isClaimed,
    };
  }

  RewardBox copyWith({
    String? id,
    String? parentId,
    String? childId,
    String? childName,
    int? targetStars,
    int? currentStars,
    String? rewardDescription,
    DateTime? expiresAt,
    bool? isClaimed,
    DateTime? claimedAt,
    DateTime? createdAt,
  }) {
    return RewardBox(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      targetStars: targetStars ?? this.targetStars,
      currentStars: currentStars ?? this.currentStars,
      rewardDescription: rewardDescription ?? this.rewardDescription,
      expiresAt: expiresAt ?? this.expiresAt,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}