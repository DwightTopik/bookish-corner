import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/book_format.dart';
import 'package:bookish_corner/features/library/domain/reading_status.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookForm();
}

class _AddBookForm extends ConsumerState<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _narratorController = TextEditingController();

  String? _filePath;
  String? _fileName;
  int? _fileSize;
  BookFormat? _format;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _narratorController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: BookFormat.pickerExtensions,
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return;

    final PlatformFile(:path, :name, :size) = file;
    final format = BookFormat.fromExtension(p.extension(name));
    if (format == null) return;

    setState(() {
      _filePath = path;
      _fileName = name;
      _fileSize = size;
      _format = format;
      if (_titleController.text.isEmpty) {
        _titleController.text = p.basenameWithoutExtension(name);
      }
    });
  }

  Future<void> _save() async {
    final path = _filePath;
    final format = _format;
    if (path == null || format == null) return;
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _saving = true);

    final narrator = _narratorController.text.trim();
    final book = Book(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      narrator: format.isAudio && narrator.isNotEmpty ? narrator : null,
      filePath: path,
      format: format,
      fileSize: _fileSize,
      addedAt: DateTime.now(),
      readingStatus: ReadingStatus.notStarted,
    );

    await ref.read(bookRepositoryProvider).addBook(book);
    if (mounted) context.pop();
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  @override
  Widget build(BuildContext context) {
    final AppColors(:bg, :textPrimary, :accent, :border) = context.appColors;
    final hasFile = _filePath != null;
    final canSave =
        hasFile && _titleController.text.trim().isNotEmpty && !_saving;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          'Добавить книгу',
          style: TextStyle(color: textPrimary),
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: ListView(
        padding: const .all(16),
        children: [
          OutlinedButton.icon(
            onPressed: _saving ? null : _pickFile,
            icon: const Icon(Icons.attach_file),
            label: const Text('Выбрать файл'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: .new(color: border),
              padding: const .symmetric(vertical: 14),
            ),
          ),
          if (hasFile) ...[
            const Gap(16),
            _FileInfoCard(
              fileName: _fileName ?? '',
              format: _format!,
              sizeLabel: _fileSize != null ? _formatBytes(_fileSize!) : null,
            ),
            const Gap(16),
            _LabeledField(
              label: 'Название',
              controller: _titleController,
              onChanged: (_) => setState(() {}),
            ),
            const Gap(12),
            _LabeledField(
              label: 'Автор',
              controller: _authorController,
            ),
            if (_format!.isAudio) ...[
              const Gap(12),
              _LabeledField(
                label: 'Чтец',
                controller: _narratorController,
              ),
            ],
            const Gap(24),
            FilledButton(
              onPressed: canSave ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const .symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Сохранить'),
            ),
          ],
        ],
      ),
    );
  }
}

class _FileInfoCard extends StatelessWidget {
  const _FileInfoCard({
    required this.fileName,
    required this.format,
    required this.sizeLabel,
  });

  final String fileName;
  final BookFormat format;
  final String? sizeLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors(:elevated, :border, :accent, :textPrimary, :textTertiary) =
        context.appColors;
    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(
        color: elevated,
        borderRadius: const .all(.circular(12)),
        border: .fromBorderSide(.new(color: border)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(
            format.isAudio ? Icons.headphones : Icons.menu_book,
            color: accent,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textPrimary),
                ),
                Text(
                  sizeLabel == null
                      ? format.label
                      : '${format.label} · $sizeLabel',
                  style: TextStyle(fontSize: 12, color: textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textSecondary, :textPrimary, :elevated, :border, :accent) =
        context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: textSecondary),
        ),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: elevated,
            contentPadding: const .all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: const .all(.circular(10)),
              borderSide: .new(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const .all(.circular(10)),
              borderSide: .new(color: accent),
            ),
          ),
        ),
      ],
    );
  }
}
