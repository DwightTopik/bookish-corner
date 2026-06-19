import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/core/theme/highlight_colors.dart';
import 'package:bookish_corner/core/widgets/highlight_color_picker.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';
import 'package:bookish_corner/features/reader/domain/reader_palette.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';

/// Редактор заметки / цитаты. Открывается full-screen из selection-меню (новая
/// заметка) или из меню тапа по хайлайту (правка существующей).
class ReaderNoteEditorScreen extends ConsumerStatefulWidget {
  const ReaderNoteEditorScreen({
    super.key,
    required this.bookId,
    required this.text,
    required this.charStart,
    required this.charEnd,
    required this.chapterIndex,
    required this.initialColor,
    this.initialNote,
    this.existingId,
  });

  final String bookId;

  /// Выделенный текст (цитата).
  final String text;
  final int charStart;
  final int charEnd;
  final int chapterIndex;
  final HighlightColor initialColor;

  /// Заполнен при правке существующей заметки.
  final String? initialNote;

  /// Заполнен при правке: id аннотации в БД.
  final String? existingId;

  @override
  ConsumerState<ReaderNoteEditorScreen> createState() =>
      _ReaderNoteEditorScreenState();
}

class _ReaderNoteEditorScreenState
    extends ConsumerState<ReaderNoteEditorScreen> {
  late final TextEditingController _noteCtrl;
  late HighlightColor _color;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.initialNote ?? '');
    _color = widget.initialColor;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(readerAnnotationRepositoryProvider);
    final noteText = _noteCtrl.text.trim();

    if (widget.existingId != null) {
      await repo.updateNote(widget.existingId!, noteText);
      await repo.updateColor(widget.existingId!, _color);
    } else {
      await repo.addAnnotation(ReaderAnnotation(
        id: const Uuid().v4(),
        bookId: widget.bookId,
        type: .note,
        charStart: widget.charStart,
        charEnd: widget.charEnd,
        chapterIndex: widget.chapterIndex,
        text: widget.text,
        noteText: noteText.isEmpty ? null : noteText,
        color: _color,
        createdAt: DateTime.now(),
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(readerBookProvider(widget.bookId));
    final book = bookAsync.asData?.value;
    // Редактор — content-adjacent: красится в текущую тему ридера, а не app-dark.
    final ReaderPalette(:bg, :text, :muted) = ReaderPalette.resolve(
      ref.watch(readerControllerProvider(widget.bookId)).settings.background,
      context.appColors,
    );
    final tint = highlightTint(_color, context.appColors);
    final swatchOpaque = highlightSwatchColor(_color, context.appColors);

    return Scaffold(
      backgroundColor: bg,
      // resizeToAvoidBottomInset: false — тело не сжимается при анимации
      // клавиатуры. Нижний отступ управляется через viewInsetsOf вручную:
      // color picker плавно едет вверх вместе с клавиатурой.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: text),
          onPressed: () => Navigator.pop(context),
        ),
        title: book == null
            ? null
            : Column(
                mainAxisSize: .min,
                children: [
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: .w600,
                      color: text,
                    ),
                  ),
                ],
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.check, color: text),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Padding(
        padding: const .symmetric(
          horizontal: AppDimensions.readerHMarginMin,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // Цитируемый текст с цветной левой полосой.
            IntrinsicHeight(
              child: Row(
                spacing: 10,
                crossAxisAlignment: .stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: swatchOpaque,
                      borderRadius: const .all(.circular(2)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const .all(12),
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: const .all(.circular(8)),
                      ),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: .w600,
                          color: text,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            // Поле заметки.
            Expanded(
              child: TextField(
                controller: _noteCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: .top,
                decoration: InputDecoration(
                  hintText: 'Напишите пару строк',
                  hintStyle: TextStyle(
                    color: muted,
                  ),
                  border: .none,
                ),
                style: TextStyle(
                  fontSize: 15,
                  color: text,
                ),
              ),
            ),
            const Gap(12),
            // Пикер цвета.
            HighlightColorPicker(
              selected: _color,
              onSelect: (c) => setState(() => _color = c),
            ),
            // Нижний отступ: берём максимум keyboard/safe-area, чтобы color
            // picker плавно поднимался с клавиатурой (resizeToAvoidBottomInset: false).
            Gap(math.max(
              MediaQuery.viewInsetsOf(context).bottom,
              MediaQuery.paddingOf(context).bottom,
            ) + 8),
          ],
        ),
      ),
    );
  }
}
