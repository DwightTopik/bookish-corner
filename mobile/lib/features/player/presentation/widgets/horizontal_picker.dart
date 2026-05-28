import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';

class HorizontalPicker<T> extends StatefulWidget {
  const HorizontalPicker({
    super.key,
    required this.values,
    required this.labelFor,
    required this.initialIndex,
    required this.onSettled,
    this.onChanged,
    this.settleDelay = const Duration(seconds: 2),
  });

  final List<T> values;
  final String Function(T value) labelFor;
  final int initialIndex;
  final void Function(T value) onSettled;
  final void Function(T value)? onChanged;
  final Duration settleDelay;

  @override
  State<HorizontalPicker<T>> createState() => _HorizontalPickerState<T>();
}

class _HorizontalPickerState<T> extends State<HorizontalPicker<T>> {
  late final PageController _controller;
  late int _selected;
  Timer? _settleTimer;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex.clamp(0, widget.values.length - 1);
    _controller = PageController(
      viewportFraction: AppDimensions.sheetPickerViewportFraction,
      initialPage: _selected,
    );
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HorizontalPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialIndex.clamp(0, widget.values.length - 1);
    if (next == _selected || next == oldWidget.initialIndex) return;
    _settleTimer?.cancel();
    _selected = next;
    if (_controller.hasClients) {
      _controller.jumpToPage(next);
    }
  }

  void _scheduleSettle() {
    _settleTimer?.cancel();
    _settleTimer = Timer(widget.settleDelay, () {
      widget.onSettled(widget.values[_selected]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textTertiary, :accent) = context.appColors;
    return SizedBox(
      height: AppDimensions.sheetPickerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.values.length,
            onPageChanged: (i) {
              setState(() => _selected = i);
              widget.onChanged?.call(widget.values[i]);
              _scheduleSettle();
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  double page = widget.initialIndex.toDouble();
                  if (_controller.hasClients &&
                      _controller.position.haveDimensions) {
                    page = _controller.page ?? _selected.toDouble();
                  }
                  final delta = (index - page).abs().clamp(0.0, 1.0);
                  final fontSize =
                      AppDimensions.sheetPickerNeighborFont +
                      (AppDimensions.sheetPickerSelectedFont -
                              AppDimensions.sheetPickerNeighborFont) *
                          (1 - delta);
                  final color = Color.lerp(textPrimary, textTertiary, delta)!;
                  return Center(
                    child: Padding(
                      padding: const .symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          widget.labelFor(widget.values[index]),
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: color,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 16,
            child: SizedBox.square(
              dimension: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
