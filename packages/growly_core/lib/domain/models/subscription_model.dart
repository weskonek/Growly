enum SubscriptionTier {
  free,
  premiumFamily,
  premiumAiTutor,
  schoolInstitution;

  String get key {
    switch (this) {
      case SubscriptionTier.free:
        return 'free';
      case SubscriptionTier.premiumFamily:
        return 'premium_family';
      case SubscriptionTier.premiumAiTutor:
        return 'premium_ai_tutor';
      case SubscriptionTier.schoolInstitution:
        return 'school_institution';
    }
  }

  static SubscriptionTier fromString(String? value) {
    switch (value) {
      case 'premium_family':
        return SubscriptionTier.premiumFamily;
      case 'premium_ai_tutor':
        return SubscriptionTier.premiumAiTutor;
      case 'school_institution':
        return SubscriptionTier.schoolInstitution;
      default:
        return SubscriptionTier.free;
    }
  }

  int get childLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 2;
      case SubscriptionTier.premiumFamily:
      case SubscriptionTier.schoolInstitution:
        return 99;
      case SubscriptionTier.premiumAiTutor:
        return 2;
    }
  }

  int get aiTutorDailyLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 5;
      case SubscriptionTier.premiumFamily:
      case SubscriptionTier.premiumAiTutor:
      case SubscriptionTier.schoolInstitution:
        return 999;
    }
  }

  bool get aiTutorEnabled {
    return this != SubscriptionTier.free;
  }

  bool get unlimitedChildren {
    return this == SubscriptionTier.premiumFamily || this == SubscriptionTier.schoolInstitution;
  }
}

class SubscriptionModel {
  final String id;
  final String parentId;
  final SubscriptionTier tier;
  final String status;
  final String? billingCycle;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? cancelledAt;
  final String? externalSubscriptionId;
  final String? externalCustomerId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubscriptionModel({
    required this.id,
    required this.parentId,
    required this.tier,
    required this.status,
    this.billingCycle,
    this.trialEndsAt,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelledAt,
    this.externalSubscriptionId,
    this.externalCustomerId,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      tier: SubscriptionTier.fromString(json['tier'] as String?),
      status: json['status'] as String? ?? 'active',
      billingCycle: json['billing_cycle'] as String?,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'] as String)
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      externalSubscriptionId: json['external_subscription_id'] as String?,
      externalCustomerId: json['external_customer_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'tier': tier.key,
      'status': status,
      'billing_cycle': billingCycle,
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'current_period_start': currentPeriodStart?.toIso8601String(),
      'current_period_end': currentPeriodEnd?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'external_subscription_id': externalSubscriptionId,
      'external_customer_id': externalCustomerId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isTrialing => trialEndsAt != null && trialEndsAt!.isAfter(DateTime.now());
}
