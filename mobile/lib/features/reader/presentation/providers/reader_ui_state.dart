import 'package:bookish_corner/features/reader/domain/nav_history.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/domain/toc_entry.dart';

enum ReaderStatus { loading, ready, error }

/// Состояние экрана ридера. Позиция ([progress]) — single source of truth от
/// движка через его поток; chrome (B2) рендерит из этого снимка.
class ReaderUiState {
  const ReaderUiState({
    this.status = ReaderStatus.loading,
    this.progress,
    this.toc = const [],
    this.settings = const ReaderSettings(),
    this.chromeVisible = true,
    this.navHistory = const NavHistory(),
    this.isBookmarked = false,
    this.error,
  });

  final ReaderStatus status;
  final ReaderProgress? progress;
  final List<TocEntry> toc;
  final ReaderSettings settings;
  final bool chromeVisible;

  /// Стек навигации «назад» (наполняется на D6; в A1 — пустой).
  final NavHistory navHistory;

  /// Закладка на текущей позиции (наполняется на D2; в A1 — `false`).
  final bool isBookmarked;

  /// Заполнено при [ReaderStatus.error].
  final Object? error;

  ReaderUiState copyWith({
    ReaderStatus? status,
    ReaderProgress? progress,
    List<TocEntry>? toc,
    ReaderSettings? settings,
    bool? chromeVisible,
    NavHistory? navHistory,
    bool? isBookmarked,
    Object? error,
    bool clearError = false,
  }) {
    return ReaderUiState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      toc: toc ?? this.toc,
      settings: settings ?? this.settings,
      chromeVisible: chromeVisible ?? this.chromeVisible,
      navHistory: navHistory ?? this.navHistory,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
