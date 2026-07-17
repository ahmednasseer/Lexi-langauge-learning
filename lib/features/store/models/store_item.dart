enum StoreCategory { avatar, frame, background, gems, bundle }

class StoreItem {
  final String id;
  final String name;
  final String description;
  final StoreCategory category;
  final int price;
  final String? imageUrl;
  final bool isPremium;
  final bool isLimited;
  final DateTime? availableUntil;
  final Map<String, dynamic>? metadata;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    this.isPremium = false,
    this.isLimited = false,
    this.availableUntil,
    this.metadata,
  });

  String get priceDisplay => '$price 💎';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category.name,
    'price': price,
    'imageUrl': imageUrl,
    'isPremium': isPremium,
    'isLimited': isLimited,
    'availableUntil': availableUntil?.toIso8601String(),
    'metadata': metadata,
  };

  factory StoreItem.fromJson(Map<String, dynamic> json) => StoreItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    category: StoreCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => StoreCategory.avatar),
    price: json['price'] ?? 0,
    imageUrl: json['imageUrl'],
    isPremium: json['isPremium'] ?? false,
    isLimited: json['isLimited'] ?? false,
    availableUntil: json['availableUntil'] != null ? DateTime.parse(json['availableUntil']) : null,
    metadata: json['metadata'],
  );

  static List<StoreItem> getAllItems() {
    return [
      // Avatars
      const StoreItem(id: 'avatar_1', name: 'Lexi Boy', description: 'Default avatar', category: StoreCategory.avatar, price: 0),
      const StoreItem(id: 'avatar_2', name: 'Scholar', description: 'Wise scholar avatar', category: StoreCategory.avatar, price: 100),
      const StoreItem(id: 'avatar_3', name: 'Warrior', description: 'Brave warrior avatar', category: StoreCategory.avatar, price: 150),
      const StoreItem(id: 'avatar_4', name: 'Wizard', description: 'Magical wizard avatar', category: StoreCategory.avatar, price: 200),
      const StoreItem(id: 'avatar_5', name: 'Ninja', description: 'Stealthy ninja avatar', category: StoreCategory.avatar, price: 250),

      // Frames
      const StoreItem(id: 'frame_1', name: 'Silver Frame', description: 'Elegant silver frame', category: StoreCategory.frame, price: 50),
      const StoreItem(id: 'frame_2', name: 'Gold Frame', description: 'Luxurious gold frame', category: StoreCategory.frame, price: 150),
      const StoreItem(id: 'frame_3', name: 'Diamond Frame', description: 'Premium diamond frame', category: StoreCategory.frame, price: 300),
      const StoreItem(id: 'frame_4', name: 'Fire Frame', description: 'Animated fire frame', category: StoreCategory.frame, price: 400, isLimited: true),
      const StoreItem(id: 'frame_5', name: 'Galaxy Frame', description: 'Cosmic galaxy frame', category: StoreCategory.frame, price: 500, isPremium: true),

      // Backgrounds
      const StoreItem(id: 'bg_1', name: 'Ocean', description: 'Calming ocean background', category: StoreCategory.background, price: 75),
      const StoreItem(id: 'bg_2', name: 'Mountain', description: 'Majestic mountain view', category: StoreCategory.background, price: 75),
      const StoreItem(id: 'bg_3', name: 'City', description: 'Urban city skyline', category: StoreCategory.background, price: 100),
      const StoreItem(id: 'bg_4', name: 'Space', description: 'Cosmic space background', category: StoreCategory.background, price: 200),
      const StoreItem(id: 'bg_5', name: 'Golden', description: 'Premium golden background', category: StoreCategory.background, price: 350, isPremium: true),

      // Gems
      const StoreItem(id: 'gems_100', name: '100 Gems', description: 'Starter pack', category: StoreCategory.gems, price: 0, metadata: {'gems': 100, 'bonus': 0}),
      const StoreItem(id: 'gems_500', name: '500 Gems', description: 'Popular pack', category: StoreCategory.gems, price: 499, metadata: {'gems': 500, 'bonus': 50}),
      const StoreItem(id: 'gems_1000', name: '1000 Gems', description: 'Best value', category: StoreCategory.gems, price: 999, metadata: {'gems': 1000, 'bonus': 150}),
      const StoreItem(id: 'gems_2500', name: '2500 Gems', description: 'Mega pack', category: StoreCategory.gems, price: 1999, metadata: {'gems': 2500, 'bonus': 500}),

      // Bundles
      const StoreItem(id: 'bundle_starter', name: 'Starter Bundle', description: '500 Gems + Silver Frame', category: StoreCategory.bundle, price: 399, metadata: {'gems': 500, 'items': ['frame_1']}),
      const StoreItem(id: 'bundle_pro', name: 'Pro Bundle', description: '1500 Gems + Gold Frame + Ocean BG', category: StoreCategory.bundle, price: 999, metadata: {'gems': 1500, 'items': ['frame_2', 'bg_1']}),
      const StoreItem(id: 'bundle_ultimate', name: 'Ultimate Bundle', description: '3000 Gems + Diamond Frame + All BGs', category: StoreCategory.bundle, price: 1999, metadata: {'gems': 3000, 'items': ['frame_3', 'bg_1', 'bg_2', 'bg_3']}),
    ];
  }

  static List<StoreItem> getItemsByCategory(StoreCategory category) {
    return getAllItems().where((item) => item.category == category).toList();
  }
}
