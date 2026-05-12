class Category {
  final String id;
  final String name;
  final String? userId;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.userId,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (userId != null) 'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
