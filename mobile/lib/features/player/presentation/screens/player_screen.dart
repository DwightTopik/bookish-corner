import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_providers.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_state.dart';
import 'package:bookish_corner/features/player/presentation/widgets/chapters_sheet.dart';
import 'package:bookish_corner/features/player/presentation/widgets/cover_glow.dart';
import 'package:bookish_corner/features/player/presentation/widgets/player_bottom_bar.dart';
import 'package:bookish_corner/features/player/presentation/widgets/player_progress.dart';
import 'package:bookish_corner/features/player/presentation/widgets/player_transport.dart';
import 'package:bookish_corner/features/player/presentation/widgets/sleep_timer_sheet.dart';
import 'package:bookish_corner/features/player/presentation/widgets/speed_picker_sheet.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(playerBookProvider(bookId));
    final playerState = ref.watch(playerProvider);
    final bg = context.appColors.bg;

    return bookAsync.when(
      loading: () => Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: bg,
        body: const Center(child: Text('Не удалось открыть аудиокнигу')),
      ),
      data: (book) {
        if (book == null) {
          return Scaffold(
            backgroundColor: bg,
            body: const Center(child: Text('Аудиокнига не найдена')),
          );
        }
        if (playerState.book?.id != book.id && !playerState.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(playerProvider.notifier).loadBook(book);
          });
        }
        return _PlayerView();
      },
    );
  }
}

class _PlayerView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<_PlayerView> {
  bool _showBookPercent = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProvider);
    final AppColors(:bg, :textPrimary) = context.appColors;
    final book = state.book;
    String bookTitle = '';
    String bookAuthor = '';
    String? coverImagePath;
    if (book != null) {
      final Book(:title, :author, coverImagePath: path) = book;
      bookTitle = title;
      bookAuthor = author;
      coverImagePath = path;
    }
    final size = MediaQuery.sizeOf(context);
    final coverSize = (size.shortestSide * AppDimensions.playerCoverRatio)
        .clamp(
          AppDimensions.playerCoverMinSize,
          AppDimensions.playerCoverMaxSize,
        );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const .symmetric(
            horizontal: AppDimensions.screenHPadding,
            vertical: AppDimensions.screenVPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlayerHeader(bookTitle: bookTitle, bookAuthor: bookAuthor),
              const Spacer(),
              SizedBox(
                height: coverSize,
                child: Center(
                  child: CoverGlow(coverPath: coverImagePath, size: coverSize),
                ),
              ),
              const Gap(AppDimensions.playerBookProgressTopGap),
              _BookProgressSummary(
                state: state,
                showPercent: _showBookPercent,
                onTap: () {
                  setState(() {
                    _showBookPercent = !_showBookPercent;
                  });
                },
              ),
              const Gap(AppDimensions.playerChapterTitleTopGap),
              Text(
                state.currentChapter?.title ?? bookTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(flex: 2),
              PlayerProgress(
                state: state,
                onChanged: (position) {
                  ref.read(playerProvider.notifier).seekTo(position);
                },
              ),
              const Gap(18),
              PlayerTransport(
                playing: state.playing,
                onPrevious: () =>
                    ref.read(playerProvider.notifier).previousChapter(),
                onBack: () => ref
                    .read(playerProvider.notifier)
                    .seekBy(const Duration(seconds: -15)),
                onPlayPause: () =>
                    ref.read(playerProvider.notifier).togglePlay(),
                onForward: () => ref
                    .read(playerProvider.notifier)
                    .seekBy(const Duration(seconds: 30)),
                onNext: () => ref.read(playerProvider.notifier).nextChapter(),
              ),
              const Gap(16),
              PlayerBottomBar(
                state: state,
                onChapters: () => _showSheet(context, const ChaptersSheet()),
                onSleep: () => _showSheet(context, const SleepTimerSheet()),
                onSpeed: () => _showSheet(context, const SpeedPickerSheet()),
                onBookmark: () =>
                    ref.read(playerProvider.notifier).toggleBookmark(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, Widget child) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const .vertical(top: .circular(18)),
        child: child,
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.bookTitle, required this.bookAuthor});

  final String bookTitle;
  final String bookAuthor;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textSecondary, :textTertiary) =
        context.appColors;
    return Row(
      children: [
        IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
          icon: Icon(Icons.keyboard_arrow_down, color: textPrimary),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bookTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(2),
              Text(
                bookAuthor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textTertiary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Ещё',
          onPressed: () {},
          icon: Icon(Icons.more_vert, color: textSecondary),
        ),
      ],
    );
  }
}
