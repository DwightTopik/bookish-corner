import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';

class CoverGlow extends StatefulWidget {
  const CoverGlow({super.key, required this.coverPath, required this.size});

  final String? coverPath;
  final double size;

  @override
  State<CoverGlow> createState() => _CoverGlowState();
}

class _CoverGlowState extends State<CoverGlow> {
  Color? _dominant;
  String? _resolvedPath;

  @override
  void initState() {
    super.initState();
    _extract();
  }

  @override
  void didUpdateWidget(covariant CoverGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverPath != widget.coverPath) {
      _extract();
    }
  }

  Future<void> _extract() async {
    final path = widget.coverPath;
    if (path == null || !File(path).existsSync()) {
      _setCoverState(dominant: null, resolvedPath: null);
      return;
    }
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        FileImage(File(path)),
        maximumColorCount: 16,
      );
      final color = _pickColor(palette);
      if (!mounted) return;
      _setCoverState(dominant: color, resolvedPath: path);
    } catch (_) {
      if (!mounted) return;
      _setCoverState(dominant: null, resolvedPath: path);
    }
  }

  void _setCoverState({
    required Color? dominant,
    required String? resolvedPath,
  }) {
    setState(() {
      _dominant = dominant;
      _resolvedPath = resolvedPath;
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
    for (final c in candidates) {
      if (ok(c)) return c;
    }
    return palette.dominantColor?.color;
  }

  @override
  Widget build(BuildContext context) {
    final AppColors(:accent, :surface, :textTertiary) = context.appColors;
    final glowColor = _dominant ?? accent;
    final glowSize = widget.size * AppDimensions.playerGlowScale;
    final coverPath = widget.coverPath;
    final hasCover = coverPath != null && File(coverPath).existsSync();

    return SizedBox.square(
      dimension: glowSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: AppDimensions.playerGlowBlurSigma,
                sigmaY: AppDimensions.playerGlowBlurSigma,
              ),
              child: Center(
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const .all(
              .circular(AppDimensions.playerCoverRadius),
            ),
            child: SizedBox.square(
              dimension: widget.size,
              child: hasCover
                  ? Image.file(
                      File(coverPath),
                      fit: BoxFit.cover,
                      key: ValueKey(_resolvedPath ?? coverPath),
                    )
                  : ColoredBox(
                      color: surface,
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: textTertiary,
                        size: widget.size * 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
