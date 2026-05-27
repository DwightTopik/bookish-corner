import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/reading_status.dart';
import 'package:bookish_corner/features/library/presentation/providers/add_book_action.dart';
import 'package:bookish_corner/features/library/presentation/providers/library_providers.dart';
import 'package:bookish_corner/features/library/presentation/widgets/book_list_tile.dart';
import 'package:bookish_corner/features/library/presentation/widgets/library_empty_state.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    _searchController.clear();
    ref.read(libraryFilterProvider.notifier).setQuery('');
    setState(() => _isSearching = false);
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.elevated,
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

  void _showFilterSheet(BuildContext context) {
    final allBooks = ref.read(booksStreamProvider).value ?? <Book>[];
    final filter = ref.read(libraryFilterProvider);
    final authors = allBooks
        .map((b) => b.author)
        .where((a) => a.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.elevated,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        initialState: filter,
        allAuthors: authors,
        onApply: (format, statuses, selectedAuthors) {
          ref.read(libraryFilterProvider.notifier).applyFilters(
            format: format,
            statuses: statuses,
            authors: selectedAuthors,
          );
        },
        onReset: () => ref.read(libraryFilterProvider.notifier).resetFilters(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors(:bg, :textPrimary, :textSecondary, :accent) =
        context.appColors;
    final filter = ref.watch(libraryFilterProvider);
    final filteredAsync = ref.watch(filteredBooksProvider);
    final allBooksAsync = ref.watch(booksStreamProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: textSecondary),
                onPressed: _stopSearch,
              )
            : null,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _isSearching
              ? _SearchField(
                  key: const ValueKey('search'),
                  controller: _searchController,
                  onChanged: (q) =>
                      ref.read(libraryFilterProvider.notifier).setQuery(q),
                  onClear: _stopSearch,
                )
              : Text(
                  'Мои книги',
                  key: const ValueKey('title'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
        ),
        actions: _isSearching
            ? const []
            : [
                IconButton(
                  icon: Badge(
                    isLabelVisible: filter.hasActiveFilters,
                    backgroundColor: accent,
                    child: Icon(
                      Icons.tune,
                      color:
                          filter.hasActiveFilters ? accent : textSecondary,
                    ),
                  ),
                  onPressed: () => _showFilterSheet(context),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: textSecondary),
                  onPressed: _startSearch,
                ),
                IconButton(
                  icon: Icon(Icons.add, color: textPrimary),
                  onPressed: () => _showAddOptions(context),
                ),
                const SizedBox(width: 4),
              ],
      ),
      body: filteredAsync.when(
        data: (filteredBooks) {
          final isLibraryEmpty = allBooksAsync.value?.isEmpty ?? true;
          if (isLibraryEmpty) {
            return LibraryEmptyView(
              onAddPressed: () => _showAddOptions(context),
            );
          }
          if (filteredBooks.isEmpty) return const _SearchEmptyState();
          return ListView.builder(
            padding: const .symmetric(vertical: 8),
            itemCount: filteredBooks.length,
            itemBuilder: (_, index) =>
                BookListTile(book: filteredBooks[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textSecondary) = context.appColors;
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      style: TextStyle(color: textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Поиск...',
        hintStyle: TextStyle(color: textSecondary),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, color: textSecondary),
          onPressed: onClear,
        ),
      ),
    );
  }
}

@immutable
class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(32),
        child: Text(
          'Ничего не найдено',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

String _formatFilterLabel(FormatFilter f) => switch (f) {
      .all => 'Все',
      .books => 'Книги',
      .audio => 'Аудио',
    };

String _statusLabel(ReadingStatus s) => switch (s) {
      .notStarted => 'Не начата',
      .reading => 'В процессе',
      .finished => 'Прочитана',
    };

@immutable
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialState,
    required this.allAuthors,
    required this.onApply,
    required this.onReset,
  });

  final LibraryFilterState initialState;
  final List<String> allAuthors;
  final void Function(
    FormatFilter format,
    Set<ReadingStatus> statuses,
    Set<String> authors,
  ) onApply;
  final VoidCallback onReset;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late FormatFilter _format;
  late Set<ReadingStatus> _statuses;
  late Set<String> _authors;

  @override
  void initState() {
    super.initState();
    final LibraryFilterState(:format, :statuses, :authors) =
        widget.initialState;
    _format = format;
    _statuses = Set.of(statuses);
    _authors = Set.of(authors);
  }

  void _toggleStatus(ReadingStatus s) => setState(() {
        _statuses = _statuses.contains(s)
            ? (Set.of(_statuses)..remove(s))
            : {..._statuses, s};
      });

  void _toggleAuthor(String a) => setState(() {
        _authors = _authors.contains(a)
            ? (Set.of(_authors)..remove(a))
            : {..._authors, a};
      });

  @override
  Widget build(BuildContext context) {
    final _FilterSheet(:allAuthors, :onApply, :onReset) = widget;
    final AppColors(:accent, :textPrimary, :textSecondary, :border, :surface) =
        context.appColors;

    return SafeArea(
      child: Padding(
        padding: .only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const .all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const Gap(20),
                Text(
                  'Формат',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final f in FormatFilter.values)
                      _Chip(
                        label: _formatFilterLabel(f),
                        selected: _format == f,
                        accent: accent,
                        surface: surface,
                        border: border,
                        textSecondary: textSecondary,
                        onTap: () => setState(() => _format = f),
                      ),
                  ],
                ),
                const Gap(16),
                Text(
                  'Статус',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final s in ReadingStatus.values)
                      _Chip(
                        label: _statusLabel(s),
                        selected: _statuses.contains(s),
                        accent: accent,
                        surface: surface,
                        border: border,
                        textSecondary: textSecondary,
                        onTap: () => _toggleStatus(s),
                      ),
                  ],
                ),
                if (allAuthors.isNotEmpty) ...[
                  const Gap(16),
                  Text(
                    'Автор',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final a in allAuthors)
                        _Chip(
                          label: a,
                          selected: _authors.contains(a),
                          accent: accent,
                          surface: surface,
                          border: border,
                          textSecondary: textSecondary,
                          onTap: () => _toggleAuthor(a),
                        ),
                    ],
                  ),
                ],
                const Gap(20),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          onReset();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textSecondary,
                          side: BorderSide(color: border),
                        ),
                        child: const Text('Сбросить'),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          onApply(_format, _statuses, _authors);
                          Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Применить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.surface,
    required this.border,
    required this.textSecondary,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final Color surface;
  final Color border;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _Chip(:label, :selected, :accent, :surface, :border, :textSecondary,
          :onTap) =
        this;
    final bgColor = selected ? accent.withValues(alpha: 0.15) : surface;
    final borderColor = selected ? accent : border;
    final textColor = selected ? accent : textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: const .all(.circular(20)),
      child: Container(
        padding: const .symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const .all(.circular(20)),
          border: .fromBorderSide(.new(color: borderColor)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
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
