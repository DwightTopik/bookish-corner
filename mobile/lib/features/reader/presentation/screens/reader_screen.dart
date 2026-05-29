import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_ui_state.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_bottom_panel.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_gesture_layer.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_immersive_footer.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_toolbar.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_top_bar.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_view.dart';

/// Экран ридера эл. книги. Источник title/author — [readerBookProvider]; позиция
/// и видимость chrome — [readerControllerProvider]. Оболочка (chrome) построена
/// на фейк-движке (B2); реальный рендер придёт с fb2-движком.
class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(readerBookProvider(bookId));
    final bg = context.appColors.bg;

    return bookAsync.when(
      loading: () => Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: bg,
        body: const Center(child: Text('Не удалось открыть книгу')),
      ),
      data: (book) {
        if (book == null) {
          return Scaffold(
            backgroundColor: bg,
            body: const Center(child: Text('Книга не найдена')),
          );
        }
        return _ReaderChrome(bookId: bookId, book: book);
      },
    );
  }
}

class _ReaderChrome extends ConsumerWidget {
  const _ReaderChrome({required this.bookId, required this.book});

  final String bookId;
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readerControllerProvider(bookId));
    final bg = context.appColors.bg;

    return switch (state.status) {
      .loading => Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      .error => Scaffold(
        backgroundColor: bg,
        body: const Center(child: Text('Не удалось открыть книгу')),
      ),
      .ready => _ReaderReadyView(bookId: bookId, book: book, state: state),
    };
  }
}

class _ReaderReadyView extends ConsumerWidget {
  const _ReaderReadyView({
    required this.bookId,
    required this.book,
    required this.state,
  });

  final String bookId;
  final Book book;
  final ReaderUiState state;

  // Источник появится позже (связанная аудиоверсия книги); в B2 всегда false →
  // кнопка «Слушать» в тулбаре не рендерится.
  static const bool _hasAudioVersion = false;

  ReaderControllerNotifier _notifier(WidgetRef ref) =>
      ref.read(readerControllerProvider(bookId).notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = context.appColors.bg;
    final chromeVisible = state.chromeVisible;
    final progress = state.progress;
    final currentPage = progress?.currentPage ?? 1;
    final totalPages = progress?.totalPages ?? 1;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Слой 0 — поверхность рендера.
          Positioned.fill(child: ReaderView(bookId: bookId)),
          // Слой 1 — прозрачные жесты (всегда активны, под панелями).
          Positioned.fill(
            child: ReaderGestureLayer(
              onPrev: () => _notifier(ref).prevPage(),
              onNext: () => _notifier(ref).nextPage(),
              onToggle: () => _notifier(ref).toggleChrome(),
            ),
          ),
          // Иммерсивный футер — виден при скрытом chrome.
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: const Duration(
                milliseconds: AppDimensions.readerChromeAnimMs,
              ),
              opacity: chromeVisible ? 0 : 1,
              child: ReaderImmersiveFooter(
                currentPage: currentPage,
                totalPages: totalPages,
              ),
            ),
          ),
          // Top bar — выезжает сверху.
          Align(
            alignment: Alignment.topCenter,
            child: _ChromeOverlay(
              visible: chromeVisible,
              slideFrom: const Offset(0, -1),
              child: ReaderTopBar(
                title: book.title,
                author: book.author,
                onClose: () => context.pop(),
                onMenu: () {}, // D4: sheet «О книге / Поиск / Прочитано».
              ),
            ),
          ),
          // Нижний блок (панель + тулбар) — выезжает снизу.
          Align(
            alignment: Alignment.bottomCenter,
            child: _ChromeOverlay(
              visible: chromeVisible,
              slideFrom: const Offset(0, 1),
              child: DecoratedBox(
                decoration: BoxDecoration(color: bg.withValues(alpha: 0.92)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReaderBottomPanel(
                      state: state,
                      onSeek: (value) => _notifier(ref).seekTo(value),
                      onBack: () {}, // D6: undo навигации.
                      onForward: () {}, // D6: redo навигации.
                    ),
                    ReaderToolbar(
                      isBookmarked: state.isBookmarked,
                      hasAudioVersion: _hasAudioVersion,
                      onChapters: () {}, // D5: sheet оглавления.
                      onNotebook: () {}, // E: экран блокнота.
                      onListen: () {}, // связанная аудиоверсия.
                      onSettings: () {}, // B3: sheet настроек.
                      onBookmark: () {}, // D2: тоггл закладки.
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Анимированный overlay chrome: fade + slide. Когда скрыт — уезжает в сторону
/// [slideFrom] и перестаёт перехватывать тапы ([IgnorePointer]). Контент
/// ([ReaderView]) при тоггле не двигается.
class _ChromeOverlay extends StatelessWidget {
  const _ChromeOverlay({
    required this.visible,
    required this.slideFrom,
    required this.child,
  });

  final bool visible;
  final Offset slideFrom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(
      milliseconds: AppDimensions.readerChromeAnimMs,
    );
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: duration,
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : slideFrom,
        child: AnimatedOpacity(
          duration: duration,
          opacity: visible ? 1 : 0,
          child: child,
        ),
      ),
    );
  }
}
