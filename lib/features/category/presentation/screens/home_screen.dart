import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../domain/models/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddCategoryDialog(
        onConfirm: (name) {
          final category = Category(
            id: const Uuid().v4(),
            name: name,
            createdAt: DateTime.now(),
          );
          context.read<CategoryBloc>().add(CreateCategory(category));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speaking Notes')),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const Center(child: Text('No categories yet.'));
            }
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/category',
                    arguments: category,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  final void Function(String name) onConfirm;

  const _AddCategoryDialog({required this.onConfirm});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final SpeechService _speechService = getIt<SpeechService>();
  String _categoryName = '';

  @override
  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }

  void _toggleListening() {
    if (_speechService.isListening) {
      _speechService.stopListening();
      setState(() {});
    } else {
      _speechService.startListening(
        onResult: (text) {
          setState(() => _categoryName = text);
        },
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _categoryName.isEmpty ? 'Press mic and speak...' : _categoryName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          IconButton(
            iconSize: 48,
            icon: Icon(
              _speechService.isListening ? Icons.mic : Icons.mic_none,
              color: _speechService.isListening ? Colors.red : null,
            ),
            onPressed: _toggleListening,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _categoryName.isEmpty
              ? null
              : () {
                  Navigator.pop(context);
                  widget.onConfirm(_categoryName);
                },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
