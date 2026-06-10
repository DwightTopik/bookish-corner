import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Прозрачная обёртка, сообщающая фактический размер своего ребёнка после
/// layout. Колбэк [onChange] вызывается в post-frame (нельзя менять состояние
/// во время layout-фазы), только при реальном изменении размера.
///
/// Применение — измерить высоту динамического chrome (зависит от системного
/// масштаба шрифта, локали), чтобы не хардкодить её константой.
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      MeasureSizeRenderBox(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant MeasureSizeRenderBox renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class MeasureSizeRenderBox extends RenderProxyBox {
  MeasureSizeRenderBox(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final Size newSize = child?.size ?? .zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}
