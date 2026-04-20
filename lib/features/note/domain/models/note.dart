class Note {
  final String id;
  final String categoryId;
  final String content;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.categoryId,
    required this.content,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
