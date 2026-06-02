import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_notes/features/category/domain/models/category.dart';

void main() {
  final createdAt = DateTime(2024);

  final category = Category(
    id: 'cat-1',
    name: 'Work',
    userId: 'user-1',
    createdAt: createdAt,
  );

  group('Category', () {
    test('toJson includes all fields when userId is set', () {
      final json = category.toJson();
      expect(json['id'], 'cat-1');
      expect(json['name'], 'Work');
      expect(json['userId'], 'user-1');
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('toJson omits userId when null', () {
      final noUser = Category(id: 'c', name: 'N', createdAt: createdAt);
      expect(noUser.toJson().containsKey('userId'), isFalse);
    });

    test('fromJson round-trips correctly', () {
      final json = category.toJson();
      final restored = Category.fromJson(json);
      expect(restored.id, category.id);
      expect(restored.name, category.name);
      expect(restored.userId, category.userId);
      expect(restored.createdAt, category.createdAt);
    });

    test('fromJson parses null userId', () {
      final json = {'id': 'c', 'name': 'N', 'createdAt': createdAt.toIso8601String()};
      final c = Category.fromJson(json);
      expect(c.userId, isNull);
    });
  });
}
