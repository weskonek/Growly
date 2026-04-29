enum StoreCategory {
  avatar,
  profile,
  badge,
  premium,
}

extension StoreCategoryX on StoreCategory {
  String get displayName {
    switch (this) {
      case StoreCategory.avatar:
        return 'Avatar';
      case StoreCategory.profile:
        return 'Profil';
      case StoreCategory.badge:
        return 'Badge';
      case StoreCategory.premium:
        return 'Premium';
    }
  }
}

class StoreItem {
  final String id;
  final String name;
  final String? description;
  final int priceStars;
  final StoreCategory category;
  final String? emoji;
  final String? imageUrl;
  final bool isOwned;

  const StoreItem({
    required this.id,
    required this.name,
    this.description,
    required this.priceStars,
    required this.category,
    this.emoji,
    this.imageUrl,
    this.isOwned = false,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceStars: json['price_stars'] as int,
      category: StoreCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => StoreCategory.avatar,
      ),
      emoji: json['emoji'] as String?,
      imageUrl: json['image_url'] as String?,
      isOwned: json['is_owned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_stars': priceStars,
      'category': category.name,
      'emoji': emoji,
      'image_url': imageUrl,
    };
  }

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    int? priceStars,
    StoreCategory? category,
    String? emoji,
    String? imageUrl,
    bool? isOwned,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceStars: priceStars ?? this.priceStars,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      isOwned: isOwned ?? this.isOwned,
    );
  }
}