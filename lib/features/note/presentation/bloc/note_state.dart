import 'package:flutter/foundation.dart';
import '../../domain/models/note.dart';

enum NoteStatus { initial, loading, loaded, success, error }

@immutable
class NoteState {
  final NoteStatus status;
  final List<Note> notes;
  final String? error;
  final String? selectedCategoryId;
  final bool isRecording;
  final int recordingSeconds;

  const NoteState({
    this.status = NoteStatus.initial,
    this.notes = const [],
    this.error,
    this.selectedCategoryId,
    this.isRecording = false,
    this.recordingSeconds = 0,
  });

  NoteState copyWith({
    NoteStatus? status,
    List<Note>? notes,
    String? error,
    String? selectedCategoryId,
    bool clearSelectedCategoryId = false,
    bool? isRecording,
    int? recordingSeconds,
  }) {
    return NoteState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      error: error ?? this.error,
      selectedCategoryId: clearSelectedCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      isRecording: isRecording ?? this.isRecording,
      recordingSeconds: recordingSeconds ?? this.recordingSeconds,
    );
  }
}
