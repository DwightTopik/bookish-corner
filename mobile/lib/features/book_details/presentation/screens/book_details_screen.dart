// ignore_for_file: prefer_shorthands_with_constructors

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_diagnostics.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_recommendation.dart';
import 'package:bookish_corner/features/book_details/presentation/providers/book_details_providers.dart';
import 'package:bookish_corner/features/book_details/presentation/widgets/book_details_cover.dart';

const _showBookDetailsDebugPanel = bool.fromEnvironment(
  'BOOK_DETAILS_DEBUG_PANEL',
);

class BookDetailsScreen extends ConsumerWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailsBookProvider(bookId));
    final colors = context.appColors;

    return bookAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.bg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: colors.bg,
        body: const Center(child: Text('Не удалось открыть книгу')),
      ),
      data: (book) {
        if (book == null) {
          return Scaffold(
            backgroundColor: colors.bg,
            body: const Center(child: Text('Книга не найдена')),
          );
        }

        final local = BookDetailsMetadata.fromBook(book);
        final info = ref.watch(infoTxtBookDetailsProvider(bookId));
        final enriched = ref.watch(enrichedBookDetailsProvider(bookId));
        final withInfo = local.mergeMissing(info.asData?.value);
        final details = withInfo.mergeMissing(enriched.asData?.value);
        final recommendations = ref.watch(
          bookDetailsRecommendationsProvider(bookId),
        );
        final debugDiagnostics = kDebugMode && _showBookDetailsDebugPanel
            ? ref.watch(bookDetailsDebugDiagnosticsProvider(bookId))
            : null;

        return _DetailsView(
          details: details,
          enrichmentLoading: enriched.isLoading,
          recommendations: recommendations,
          debugDiagnostics: debugDiagnostics,
        );
      },
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView({
    required this.details,
    required this.enrichmentLoading,
    required this.recommendations,
    required this.debugDiagnostics,
  });

  final BookDetailsMetadata details;
  final bool enrichmentLoading;
  final AsyncValue<List<BookDetailsRecommendation>> recommendations;
  final AsyncValue<BookDetailsDebugDiagnostics?>? debugDiagnostics;

  @override
  Widget build(BuildContext context) {
    final AppColors(:bg, :accent) = context.appColors;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(child: _AmbientBackground(accent: accent)),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const .fromLTRB(20, 12, 20, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(title: details.title),
                        _HeroSection(
                          details: details,
                          enrichmentLoading: enrichmentLoading,
                        ),
                        _PrimaryMetadata(details: details),
                        _DescriptionSection(description: details.description),
                        _DetailsGrid(details: details),
                        if (kDebugMode &&
                            _showBookDetailsDebugPanel &&
                            debugDiagnostics != null)
                          _DebugDiagnosticsSection(
                            diagnostics: debugDiagnostics!,
                          ),
                        _RecommendationsSection(
                          recommendations: recommendations,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.46),
          radius: 0.92,
          colors: [
            accent.withValues(alpha: 0.16),
            const Color(0x001A1D21),
            Colors.transparent,
          ],
          stops: const [0, 0.48, 1],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textTertiary) = context.appColors;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Назад',
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 23),
          ),
          const Gap(6),
          Expanded(
            child: Text(
              title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textTertiary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.details, required this.enrichmentLoading});

  final BookDetailsMetadata details;
  final bool enrichmentLoading;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textSecondary, :textTertiary) =
        context.appColors;
    final size = MediaQuery.sizeOf(context);
    final coverSize = (size.shortestSide * 0.72).clamp(240.0, 340.0);

    return Padding(
      padding: const .only(top: 14, bottom: 26),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            child: BookDetailsCover(
              key: ValueKey('${details.coverImagePath}-${details.coverUrl}'),
              coverImagePath: details.coverImagePath,
              coverUrl: details.coverUrl,
              size: coverSize,
            ),
          ),
          const Gap(24),
          if (details.title != null)
            Text(
              details.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontSize: 31,
                height: 1.08,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          if (details.author != null) ...[
            const Gap(10),
            Text(
              details.author!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
          if (details.series != null) ...[
            const Gap(10),
            Text(
              details.series!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (enrichmentLoading) ...[
            const Gap(16),
            _SoftLoadingPill(label: 'Уточняем сведения'),
          ],
        ],
      ),
    );
  }
}

class _SoftLoadingPill extends StatelessWidget {
  const _SoftLoadingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors(:elevated, :textTertiary) = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: elevated.withValues(alpha: 0.52),
        borderRadius: const .all(.circular(999)),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            color: textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PrimaryMetadata extends StatelessWidget {
  const _PrimaryMetadata({required this.details});

  final BookDetailsMetadata details;

  @override
  Widget build(BuildContext context) {
    final categories = _uniqueDisplayValues(details.categories).take(6);
    final items =
        <_MetaItem>[
              _MetaItem(
                Icons.mic_none,
                'читает',
                _displayValue(details.narrator),
              ),
              _MetaItem(
                Icons.schedule,
                'время',
                _durationValue(details.duration),
              ),
              _MetaItem(Icons.calendar_today_outlined, 'год', _year(details)),
              _MetaItem(
                Icons.apartment_outlined,
                'издатель',
                _displayValue(details.publisher),
              ),
              _MetaItem(
                Icons.translate,
                'перевод',
                _displayValue(details.translator),
              ),
              _MetaItem(
                Icons.lock_outline,
                'возраст',
                _ageValue(details.ageRestriction),
              ),
            ]
            .where(
              (item) => item.value != null && item.value!.trim().isNotEmpty,
            )
            .toList();

    if (items.isEmpty && categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const .only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final item in items.take(6)) _InfoTile(item: item),
              ],
            ),
          if (categories.isNotEmpty) ...[
            if (items.isNotEmpty) const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in categories) _GenreChip(label: category),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _year(BookDetailsMetadata details) {
    final date = _dateValue(details.publishedDate ?? details.writtenDate);
    if (date == null) return null;
    final match = RegExp(r'\d{4}').firstMatch(date);
    return match?.group(0) ?? date;
  }
}

class _MetaItem {
  const _MetaItem(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String? value;
}

String? _displayValue(String? value) {
  final cleaned = _dedupeLines(value ?? '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'^[\s:;,\-–—]+|[\s:;,]+$'), '')
      .trim();
  if (cleaned.isEmpty) return null;
  if (_placeholderValues.contains(cleaned.toLowerCase())) return null;
  if (_looksLikeLeakedLabel(cleaned)) return null;
  return cleaned;
}

String? _durationValue(String? value) => _displayValue(value);

String? _ageValue(String? value) {
  final cleaned = _displayValue(value);
  if (cleaned == null) return null;
  final match = RegExp(r'\b(\d{1,2})\s*\+').firstMatch(cleaned);
  return match == null ? null : '${match.group(1)}+';
}

String? _dateValue(String? value) {
  final cleaned = _displayValue(value);
  if (cleaned == null) return null;
  final match = RegExp(r'\b\d{4}(?:\s*[-–—]\s*\d{4})?\b').firstMatch(cleaned);
  return match?.group(0)?.replaceAll(RegExp(r'\s*[-–—]\s*'), '-');
}

String? _isbnValue(String? value) {
  final cleaned = _displayValue(value);
  if (cleaned == null) return null;
  final candidate = cleaned.replaceAll(RegExp(r'[^0-9Xx-]'), '');
  final compact = candidate.replaceAll('-', '');
  if (compact.length != 10 && compact.length != 13) return null;
  return compact.toUpperCase();
}

List<String> _uniqueDisplayValues(List<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    final cleaned = _displayValue(value);
    if (cleaned == null) continue;
    final key = cleaned.toLowerCase();
    if (seen.add(key)) result.add(cleaned);
  }
  return result;
}

String _dedupeLines(String value) {
  final seen = <String>{};
  final lines = value
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty);
  final unique = <String>[];
  for (final line in lines) {
    final key = line.toLowerCase();
    if (seen.add(key)) unique.add(line);
  }
  return unique.join('\n');
}

bool _looksLikeLeakedLabel(String value) {
  final normalized = value.toLowerCase().replaceAll('ё', 'е');
  return RegExp(
    r'\b(дата выхода|isbn|исбн|переводчик|чтец|правообладатель|'
    r'издательство|жанр|описание|оглавление|содержание)\s*[:=：—-]',
    caseSensitive: false,
  ).hasMatch(normalized);
}

const _placeholderValues = {
  'unknown',
  'null',
  'absent',
  'not specified',
  'неизвестно',
  'не указано',
  'нет',
  '-',
};

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.item});

  final _MetaItem item;

  @override
  Widget build(BuildContext context) {
    final AppColors(:elevated, :border, :textSecondary, :textTertiary) =
        context.appColors;
    return Container(
      constraints: const BoxConstraints(minWidth: 138, maxWidth: 252),
      padding: const .symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: elevated.withValues(alpha: 0.54),
        borderRadius: const .all(.circular(14)),
        border: .fromBorderSide(
          BorderSide(color: border.withValues(alpha: 0.42)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 18, color: textTertiary),
          const Gap(9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(3),
                Text(
                  item.value!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    height: 1.18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors(:accent, :textSecondary) = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.11),
        borderRadius: const .all(.circular(999)),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DescriptionSection extends StatefulWidget {
  const _DescriptionSection({required this.description});

  final String? description;

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final description = _cleanDescription(widget.description);
    if (description == null) return const SizedBox.shrink();

    final AppColors(:surface, :border, :textPrimary, :textSecondary, :accent) =
        context.appColors;
    final isLong = description.length > 380;

    return _SectionShell(
      margin: const .only(bottom: 24),
      surfaceColor: surface.withValues(alpha: 0.68),
      borderColor: border.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Описание'),
          const Gap(11),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: Stack(
              children: [
                Text(
                  description,
                  maxLines: isLong && !_expanded ? 9 : null,
                  overflow: isLong && !_expanded
                      ? TextOverflow.fade
                      : TextOverflow.visible,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                if (isLong && !_expanded)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 46,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            surface.withValues(alpha: 0),
                            surface.withValues(alpha: 0.98),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isLong) ...[
            const Gap(10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: .zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Text(
                  _expanded ? 'Свернуть' : 'Показать полностью',
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _cleanDescription(String? value) {
    final cleaned = value
        ?.replaceAll(RegExp(r'\s*\n\s*'), '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
    return cleaned == null || cleaned.isEmpty ? null : cleaned;
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.details});

  final BookDetailsMetadata details;

  @override
  Widget build(BuildContext context) {
    final facts =
        <_Fact>[
              _Fact('Серия', _displayValue(details.series)),
              _Fact('Дата выхода', _dateValue(details.publishedDate)),
              _Fact('Написано', _dateValue(details.writtenDate)),
              _Fact('ISBN', _isbnValue(details.isbn)),
              _Fact('Страниц', _displayValue(details.pageCount)),
              _Fact('Язык', _displayValue(details.language)),
              _Fact('Правообладатель', _displayValue(details.rightHolder)),
            ]
            .where(
              (fact) => fact.value != null && fact.value!.trim().isNotEmpty,
            )
            .toList();

    if (facts.isEmpty) return const SizedBox.shrink();

    return _SectionShell(
      margin: const .only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Сведения'),
          const Gap(8),
          for (final fact in facts) _FactRow(fact: fact),
        ],
      ),
    );
  }
}

class _Fact {
  const _Fact(this.label, this.value);

  final String label;
  final String? value;
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact});

  final _Fact fact;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textSecondary, :textTertiary, :border) = context.appColors;
    final Border rowBorder = Border(
      bottom: BorderSide(color: border.withValues(alpha: 0.36)),
    );
    return Container(
      padding: const .symmetric(vertical: 10),
      decoration: BoxDecoration(border: rowBorder),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Text(
              fact.label,
              style: TextStyle(
                color: textTertiary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              fact.value!,
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                height: 1.24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugDiagnosticsSection extends StatelessWidget {
  const _DebugDiagnosticsSection({required this.diagnostics});

  final AsyncValue<BookDetailsDebugDiagnostics?> diagnostics;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textSecondary, :textTertiary, :error) = context.appColors;
    return _SectionShell(
      margin: const .only(bottom: 28),
      child: diagnostics.when(
        loading: () => Text(
          'DEBUG metadata diagnostics: loading',
          style: TextStyle(color: textTertiary, fontSize: 12),
        ),
        error: (errorValue, _) => Text(
          'DEBUG metadata diagnostics error: $errorValue',
          style: TextStyle(color: error, fontSize: 12),
        ),
        data: (value) {
          if (value == null) {
            return Text(
              'DEBUG metadata diagnostics: book not found',
              style: TextStyle(color: textTertiary, fontSize: 12),
            );
          }
          final BookDetailsDebugDiagnostics(
            :bookId,
            :localPath,
            :infoTxt,
            :googleBooks,
            :finalSummary,
            :hasLocalMetadata,
            :hasInfoTxtMetadata,
            :hasGoogleMetadata,
          ) = value;
          final info = infoTxt;
          final google = googleBooks;
          final infoSummary = info.parsedSummary;
          final InfoTxtLookupDiagnostics(
            :candidatePaths,
            :found,
            :readSucceeded,
            :parseSucceeded,
            :foundPath,
            :errorSummary,
          ) = info;
          final MetadataDebugSummary(
            hasDescription: infoHasDescription,
            series: infoSeries,
            genresCount: infoGenresCount,
            isbn: infoIsbn,
            translator: infoTranslator,
            narrator: infoNarrator,
            rightHolder: infoRightHolder,
            contentsCount: infoContentsCount,
          ) = infoSummary;
          final GoogleBooksLookupDiagnostics(
            :attempted,
            :queryString,
            :statusCode,
            :resultCount,
            errorSummary: googleErrorSummary,
          ) = google;
          final MetadataDebugSummary(
            hasDescription: finalHasDescription,
            visibleFieldCount: finalVisibleFieldCount,
          ) = finalSummary;
          return DefaultTextStyle(
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              height: 1.28,
              fontWeight: FontWeight.w600,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEBUG metadata diagnostics',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(10),
                _DebugLine(label: 'bookId', value: bookId),
                _DebugLine(label: 'localPath', value: localPath),
                _DebugLine(
                  label: 'info candidates checked',
                  value: '${candidatePaths.length}',
                ),
                for (final path in candidatePaths.take(8))
                  _DebugLine(label: 'candidate', value: path),
                _DebugLine(label: 'info found', value: '$found'),
                _DebugLine(label: 'info path', value: foundPath ?? '-'),
                _DebugLine(
                  label: 'info read succeeded',
                  value: '$readSucceeded',
                ),
                _DebugLine(
                  label: 'info parse succeeded',
                  value: '$parseSucceeded',
                ),
                _DebugLine(label: 'info error', value: errorSummary ?? '-'),
                _DebugLine(
                  label: 'info hasDescription',
                  value: '$infoHasDescription',
                ),
                _DebugLine(label: 'info series', value: infoSeries ?? '-'),
                _DebugLine(
                  label: 'info genres count',
                  value: '$infoGenresCount',
                ),
                _DebugLine(label: 'info ISBN', value: infoIsbn ?? '-'),
                _DebugLine(
                  label: 'info translator',
                  value: infoTranslator ?? '-',
                ),
                _DebugLine(label: 'info narrator', value: infoNarrator ?? '-'),
                _DebugLine(
                  label: 'info rightHolder',
                  value: infoRightHolder ?? '-',
                ),
                _DebugLine(
                  label: 'info contents count',
                  value: '$infoContentsCount',
                ),
                const Gap(8),
                _DebugLine(label: 'google attempted', value: '$attempted'),
                _DebugLine(
                  label: 'google query',
                  value: queryString.isEmpty ? '-' : queryString,
                ),
                _DebugLine(
                  label: 'google status',
                  value: statusCode?.toString() ?? '-',
                ),
                _DebugLine(label: 'google result count', value: '$resultCount'),
                _DebugLine(
                  label: 'google error',
                  value: googleErrorSummary ?? '-',
                ),
                const Gap(8),
                _DebugLine(
                  label: 'source flags',
                  value:
                      'local=$hasLocalMetadata, '
                      'infoTxt=$hasInfoTxtMetadata, '
                      'google=$hasGoogleMetadata',
                ),
                _DebugLine(
                  label: 'final hasDescription',
                  value: '$finalHasDescription',
                ),
                _DebugLine(
                  label: 'final visible field count',
                  value: '$finalVisibleFieldCount',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DebugLine extends StatelessWidget {
  const _DebugLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTertiary = context.appColors.textTertiary;
    return Padding(
      padding: const .only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: textTertiary),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.child,
    this.margin = .zero,
    this.surfaceColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets margin;
  final Color? surfaceColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final AppColors(:elevated, :border) = context.appColors;
    return Container(
      margin: margin,
      padding: const .all(16),
      decoration: BoxDecoration(
        color: surfaceColor ?? elevated.withValues(alpha: 0.38),
        borderRadius: const .all(.circular(18)),
        border: .fromBorderSide(
          BorderSide(color: borderColor ?? border.withValues(alpha: 0.32)),
        ),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.appColors.textPrimary;
    return Text(
      title,
      style: TextStyle(
        color: textPrimary,
        fontSize: 20,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.recommendations});

  final AsyncValue<List<BookDetailsRecommendation>> recommendations;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      margin: const .only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Рекомендации'),
          const Gap(16),
          recommendations.when(
            loading: _RecommendationSkeleton.new,
            error: (_, _) => const _RecommendationEmptyState(),
            data: (items) {
              if (items.isEmpty) return const _RecommendationEmptyState();
              return SizedBox(
                height: 178,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Gap(14),
                  itemBuilder: (context, index) =>
                      _RecommendationCard(recommendation: items[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecommendationEmptyState extends StatelessWidget {
  const _RecommendationEmptyState();

  @override
  Widget build(BuildContext context) {
    final AppColors(:surface, :border, :textSecondary, :textTertiary, :accent) =
        context.appColors;
    return Container(
      width: double.infinity,
      padding: const .all(16),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.54),
        borderRadius: const .all(.circular(14)),
        border: .fromBorderSide(
          BorderSide(color: border.withValues(alpha: 0.34)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.14),
            ),
            child: Icon(Icons.auto_awesome, color: accent, size: 19),
          ),
          const Gap(13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Подборка готовится',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(3),
                Text(
                  'Здесь появятся книги, близкие по настроению.',
                  style: TextStyle(
                    color: textTertiary,
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSkeleton extends StatelessWidget {
  const _RecommendationSkeleton();

  @override
  Widget build(BuildContext context) {
    final surface = context.appColors.surface;
    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const Gap(14),
        itemBuilder: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(width: 78, height: 112, color: surface),
            const Gap(10),
            _SkeletonBox(width: 92, height: 12, color: surface),
            const Gap(6),
            _SkeletonBox(width: 68, height: 10, color: surface),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.62),
        borderRadius: const .all(.circular(10)),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final BookDetailsRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final AppColors(:surface, :textSecondary, :textTertiary) =
        context.appColors;
    return SizedBox(
      width: AppDimensions.bookDetailsRecommendationWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const .all(.circular(10)),
            child: SizedBox(
              width: AppDimensions.bookDetailsRecommendationCoverWidth,
              height: AppDimensions.bookDetailsRecommendationCoverHeight,
              child: recommendation.coverUrl == null
                  ? ColoredBox(
                      color: surface,
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: textTertiary,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: recommendation.coverUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => ColoredBox(
                        color: surface,
                        child: Icon(
                          Icons.menu_book_outlined,
                          color: textTertiary,
                        ),
                      ),
                    ),
            ),
          ),
          const Gap(9),
          Text(
            recommendation.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              height: 1.16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(3),
          Text(
            recommendation.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
