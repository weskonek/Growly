enum NotificationType {
  info,
  warning,
  achievement,
  alert,
  subscription,
}

class NotificationModel {
  final String id;
  final String parentId;
  final String? childId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.parentId,
    this.childId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      childId: json['child_id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == (json['type'] as String? ?? 'info'),
        orElse: () => NotificationType.info,
      ),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      parentId: parentId,
      childId: childId,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
