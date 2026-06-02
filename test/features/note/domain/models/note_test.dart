import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_notes/features/note/domain/models/note.dart';

void main() {
  final createdAt = DateTime(2024, 6, 15);

  final note = Note(
    id: 'note-1',
    categoryId: 'cat-1',
    userId: 'user-1',
    content: 'Hello world',
    createdAt: createdAt,
  );

  group('Note', () {
    test('toJson includes all fields when userId is set', () {
      final json = note.toJson();
      expect(json['id'], 'note-1');
      expect(json['categoryId'], 'cat-1');
      expect(json['userId'], 'user-1');
      expect(json['content'], 'Hello world');
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('toJson omits userId when null', () {
      final noUser = Note(id: 'n', categoryId: 'c', userId: null, content: 'x', createdAt: createdAt);
      expect(noUser.toJson().containsKey('userId'), isFalse);
    });

    test('fromJson round-trips correctly', () {
      final json = note.toJson();
      final restored = Note.fromJson(json);
      expect(restored.id, note.id);
      expect(restored.categoryId, note.categoryId);
      expect(restored.userId, note.userId);
      expect(restored.content, note.content);
      expect(restored.createdAt, note.createdAt);
    });

    test('fromJson parses null userId', () {
      final json = {
        'id': 'n',
        'categoryId': 'c',
        'content': 'x',
        'createdAt': createdAt.toIso8601String(),
      };
      final n = Note.fromJson(json);
      expect(n.userId, isNull);
    });
  });
}
