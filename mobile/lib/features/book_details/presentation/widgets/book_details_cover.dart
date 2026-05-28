import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';

class BookDetailsCover extends StatefulWidget {
  const BookDetailsCover({
    super.key,
    required this.coverImagePath,
    required this.coverUrl,
    required this.size,
  });

  final String? coverImagePath;
  final String? coverUrl;
  final double size;

  @override
  State<BookDetailsCover> createState() => _BookDetailsCoverState();
}

class _BookDetailsCoverState extends State<BookDetailsCover> {
  Color? _dominant;

  @override
  void initState() {
    super.initState();
    _extract();
  }

  @override
  void didUpdateWidget(covariant BookDetailsCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverImagePath != widget.coverImagePath ||
        oldWidget.coverUrl != widget.coverUrl) {
      _extract();
    }
  }

  Future<void> _extract() async {
    final provider = _imageProvider();
    if (provider == null) {
      _setDominant(null);
      return;
    }
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 16,
      );
      if (!mounted) return;
      _setDominant(_pickColor(palette));
    } catch (_) {
      if (!mounted) return;
      _setDominant(null);
    }
  }

  ImageProvider<Object>? _imageProvider() {
    final path = widget.coverImagePath;
    if (path != null && File(path).existsSync()) {
      return FileImage(File(path));
    }
    final url = widget.coverUrl;
    if (url != null && url.trim().isNotEmpty) {
      return CachedNetworkImageProvider(url);
    }
    return null;
  }

  void _setDominant(Color? color) {
    setState(() {
      _dominant = color;
    });
  }

  Color? _pickColor(PaletteGenerator palette) {
    bool ok(Color? c) {
      if (c == null) return false;
      final hsl = HSLColor.fromColor(c);
      return hsl.saturation > 0.35 &&
          hsl.lightness > 0.25 &&
          hsl.lightness < 0.70;
    }

    final candidates = [
      palette.vibrantColor?.color,
      palette.lightVibrantColor?.color,
      palette.darkVibrantColor?.color,
      palette.mutedColor?.color,
      palette.dominantColor?.color,
    ];
    for (final color in candidates) {
      if (ok(color)) return color;
    }
    return palette.dominantColor?.color;
  }

  @override
  Widget build(BuildContext context) {
    final AppColors(:accent, :surface, :textTertiary) = context.appColors;
    final glowSize = widget.size * AppDimensions.bookDetailsGlowScale;
    final glowColor = _dominant ?? accent;

    return SizedBox.square(
      dimension: glowSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: AppDimensions.bookDetailsGlowBlurSigma,
                sigmaY: AppDimensions.bookDetailsGlowBlurSigma,
              ),
              child: Center(
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowColor.withValues(alpha: 0.58),
                  ),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const .all(
              .circular(AppDimensions.bookDetailsCoverRadius),
            ),
            child: SizedBox.square(
              dimension: widget.size,
              child: _CoverImage(
                coverImagePath: widget.coverImagePath,
                coverUrl: widget.coverUrl,
                placeholderColor: surface,
                iconColor: textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.coverImagePath,
    required this.coverUrl,
    required this.placeholderColor,
    required this.iconColor,
  });

  final String? coverImagePath;
  final String? coverUrl;
  final Color placeholderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final path = coverImagePath;
    if (path != null && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    final url = coverUrl;
    if (url != null && url.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) =>
            _Placeholder(color: placeholderColor, iconColor: iconColor),
        placeholder: (_, _) =>
            _Placeholder(color: placeholderColor, iconColor: iconColor),
      );
    }
    return _Placeholder(color: placeholderColor, iconColor: iconColor);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.color, required this.iconColor});

  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Icon(Icons.menu_book_outlined, color: iconColor),
    );
  }
}
