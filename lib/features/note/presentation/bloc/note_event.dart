import 'package:flutter/foundation.dart';
import '../../../domain/models/note.dart';

@immutable
sealed class NoteEvent {}

class LoadNotes extends NoteEvent {
  final String categoryId;
  LoadNotes(this.categoryId);
}

class CreateNote extends NoteEvent {
  final Note note;
  CreateNote(this.note);
}

class DeleteNote extends NoteEvent {
  final String id;
  DeleteNote(this.id);
}
