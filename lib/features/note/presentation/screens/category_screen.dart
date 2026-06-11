import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../category/domain/models/category.dart';
import '../../domain/models/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(LoadNotes(widget.category.id));
  }

  void _showRecordingSheet() {
    final noteBloc = context.read<NoteBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: noteBloc,
        child: _RecordingBottomSheet(
          categoryId: widget.category.id,
          onNoteCreated: () => noteBloc.add(LoadNotes(widget.category.id)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.arrow_back_ios_new,
                size: 18.r, color: AppColors.textPrimary),
          ),
        ),
        title: Text(widget.category.name, style: AppTypography.heading2),
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state.status == NoteStatus.loading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.status == NoteStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                  SizedBox(height: 12.h),
                  Text(
                    AppLocalizations.of(context)!.somethingWentWrong,
                    style: AppTypography.body2
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          if (state.status == NoteStatus.loaded) {
            if (state.notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_none, size: 72.r, color: AppColors.disabled),
                    SizedBox(height: 16.h),
                    Text(
                      AppLocalizations.of(context)!.noNotesYet,
                      style: AppTypography.body2
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
              itemCount: state.notes.length,
              itemBuilder: (ctx, i) {
                final note = state.notes[i];
                return GestureDetector(
                  onTap: () => ctx.push('/note/${note.id}', extra: note),
                  child: _NoteCard(note: note),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRecordingSheet,
        child: const Icon(Icons.mic),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;

  const _NoteCard({required this.note});

  String get _formattedDate {
    final d = note.createdAt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.description, color: AppColors.primary, size: 22.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content.length > 45
                      ? '${note.content.substring(0, 45)}...'
                      : note.content,
                  style: AppTypography.body2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(_formattedDate, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingBottomSheet extends StatefulWidget {
  final String categoryId;
  final VoidCallback onNoteCreated;

  const _RecordingBottomSheet({
    required this.categoryId,
    required this.onNoteCreated,
  });

  @override
  State<_RecordingBottomSheet> createState() => _RecordingBottomSheetState();
}

class _RecordingBottomSheetState extends State<_RecordingBottomSheet> {
  final SpeechService _speechService = getIt<SpeechService>();
  Timer? _timer;
  late NoteBloc _noteBloc;

  @override
  void initState() {
    super.initState();
    _noteBloc = context.read<NoteBloc>();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speechService.stopListening();
    if (_noteBloc.state.isRecording) {
      _noteBloc.add(StopRecording());
    }
    super.dispose();
  }

  String _timerDisplay(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}:00';
  }

  void _toggleRecording(BuildContext context) {
    final noteBloc = context.read<NoteBloc>();
    if (noteBloc.state.isRecording) {
      _speechService.stopListening();
      _timer?.cancel();
      noteBloc.add(StopRecording());
    } else {
      noteBloc.add(StartRecording());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final current = context.read<NoteBloc>().state.recordingSeconds;
        context.read<NoteBloc>().add(UpdateRecordingTimer(current + 1));
      });

      _speechService.startListening(
        onResult: (text) {
          if (text.isEmpty) return;
          final note = Note(
            id: const Uuid().v4(),
            categoryId: widget.categoryId,
            content: text,
            createdAt: DateTime.now(),
          );
          context.read<NoteBloc>().add(CreateNote(note));
          _speechService.stopListening();
          _timer?.cancel();
          context.read<NoteBloc>().add(StopRecording());
          widget.onNoteCreated();
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      buildWhen: (prev, next) =>
          prev.isRecording != next.isRecording ||
          prev.recordingSeconds != next.recordingSeconds,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              24.w, 24.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 40.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${AppLocalizations.of(context)!.recording} ',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.audio,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        ),
                      child: Icon(Icons.close, size: 16.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              _WaveformWidget(isAnimating: state.isRecording),
              SizedBox(height: 32.h),
              Text(
                _timerDisplay(state.recordingSeconds),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 40.h),
              GestureDetector(
                onTap: () => _toggleRecording(context),
                child: Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: state.isRecording ? AppColors.error : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (state.isRecording ? AppColors.error : AppColors.primary)
                                .withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isRecording ? Icons.stop : Icons.mic,
                    color: AppColors.white,
                    size: 36.r,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaveformWidget extends StatefulWidget {
  final bool isAnimating;

  const _WaveformWidget({required this.isAnimating});

  @override
  State<_WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<_WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  List<double> _bars = List.filled(28, 0.1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(() {
        if (widget.isAnimating && mounted) {
          setState(() {
            _bars =
                List.generate(28, (_) => 0.1 + _random.nextDouble() * 0.9);
          });
        }
      });
    if (widget.isAnimating) _controller.repeat();
  }

  @override
  void didUpdateWidget(_WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _controller.repeat();
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      _controller.stop();
      setState(() => _bars = List.filled(28, 0.1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _bars
            .map((h) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 4.w,
                  height: (8 + h * 60).h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary.withValues(alpha: 0.3 + h * 0.7),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
