class CategoryModel {
  final String id;
  final String name;
  final String icon; // Icon name or emoji or imageUrl

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return CategoryModel(
      id: docId ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      icon: map['icon'] as String? ?? '🍽️',
    );
  }
}
