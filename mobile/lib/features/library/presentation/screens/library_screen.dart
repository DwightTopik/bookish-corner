import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/library/presentation/providers/add_book_action.dart';
import 'package:bookish_corner/features/library/presentation/providers/library_providers.dart';
import 'package:bookish_corner/features/library/presentation/widgets/book_list_tile.dart';
import 'package:bookish_corner/features/library/presentation/widgets/library_empty_state.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    final elevated = context.appColors.elevated;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: elevated,
      builder: (sheetCtx) => _AddBookSheet(
        onAddBook: () {
          Navigator.of(sheetCtx).pop();
          pickAndAddBook(ref);
        },
        onAddFolder: () {
          final messenger = ScaffoldMessenger.of(sheetCtx);
          Navigator.of(sheetCtx).pop();
          pickAndAddFolder(messenger, ref);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors(:bg, :textPrimary, :textSecondary) = context.appColors;
    final booksAsync = ref.watch(booksStreamProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          'Мои книги',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search, color: textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add, color: textPrimary),
            onPressed: () => _showAddOptions(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: booksAsync.when(
        data: (books) {
          if (books.isEmpty) return const LibraryEmptyView();
          return ListView.builder(
            padding: const .symmetric(vertical: 8),
            itemCount: books.length,
            itemBuilder: (context, index) => BookListTile(book: books[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const .all(32),
            child: Text(
              'Не удалось загрузить библиотеку',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddBookSheet extends StatelessWidget {
  const _AddBookSheet({
    required this.onAddBook,
    required this.onAddFolder,
  });

  final VoidCallback onAddBook;
  final VoidCallback onAddFolder;

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.appColors.textPrimary;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.menu_book_outlined, color: textPrimary),
            title: Text(
              'Добавить книгу',
              style: TextStyle(color: textPrimary),
            ),
            onTap: onAddBook,
          ),
          ListTile(
            leading: Icon(Icons.folder_outlined, color: textPrimary),
            title: Text(
              'Добавить аудиокнигу',
              style: TextStyle(color: textPrimary),
            ),
            onTap: onAddFolder,
          ),
        ],
      ),
    );
  }
}
