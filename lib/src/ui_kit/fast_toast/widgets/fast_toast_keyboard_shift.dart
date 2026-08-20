import 'dart:math' as math;
import 'dart:ui' show FlutterView;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../fast_toast_position.dart';

/// Paints [child] with a view-padding / keyboard translation on a compositing
/// layer so inset animation does not rebuild or relayout the toast.
/// 在合成层上按安全区 / 键盘 insets 平移 [child]，键盘动画不触发 rebuild / relayout。
class FastToastKeyboardShift extends SingleChildRenderObjectWidget {
  /// Creates a compositing-only inset shift.
  /// 创建仅走合成层的 inset 平移。
  const FastToastKeyboardShift({
    super.key,
    required this.position,
    super.child,
  });

  /// Toast alignment that selects how insets are applied.
  /// 决定 insets 如何作用的 Toast 位置。
  final FastToastPosition position;

  @override
  RenderFastToastKeyboardShift createRenderObject(BuildContext context) {
    return RenderFastToastKeyboardShift(
      position: position,
      view: View.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFastToastKeyboardShift renderObject,
  ) {
    renderObject
      ..position = position
      ..view = View.of(context);
  }
}

/// Render object that follows keyboard metrics without [markNeedsLayout].
/// 跟随键盘 metrics、但不 [markNeedsLayout] 的 RenderObject。
class RenderFastToastKeyboardShift extends RenderProxyBox
    with WidgetsBindingObserver {
  /// Creates a keyboard-following shift render object.
  /// 创建跟随键盘的平移 RenderObject。
  RenderFastToastKeyboardShift({
    required FastToastPosition position,
    required FlutterView view,
    RenderBox? child,
  }) : _position = position,
       _view = view,
       super(child) {
    _translation = _computeTranslation();
  }

  FastToastPosition _position;
  FlutterView _view;
  Offset _translation = Offset.zero;

  /// Current paint translation in logical pixels.
  /// 当前绘制平移（逻辑像素）。
  @visibleForTesting
  Offset get translation => _translation;

  /// Toast position that selects the translation formula.
  /// 决定平移公式的 Toast 位置。
  FastToastPosition get position => _position;
  set position(FastToastPosition value) {
    if (_position == value) {
      return;
    }
    _position = value;
    _syncTranslation();
  }

  /// Window whose padding / viewInsets drive the translation.
  /// 提供 padding / viewInsets 的窗口。
  FlutterView get view => _view;
  set view(FlutterView value) {
    if (_view == value) {
      return;
    }
    _view = value;
    _syncTranslation();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    WidgetsBinding.instance.addObserver(this);
    _syncTranslation();
  }

  @override
  void detach() {
    WidgetsBinding.instance.removeObserver(this);
    super.detach();
  }

  @override
  void didChangeMetrics() {
    _syncTranslation();
  }

  @override
  OffsetLayer updateCompositedLayer({
    required covariant TransformLayer? oldLayer,
  }) {
    final TransformLayer layer = oldLayer ?? TransformLayer();
    layer.transform = Matrix4.translationValues(
      _translation.dx,
      _translation.dy,
      0,
    );
    return layer;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(_translation.dx, _translation.dy, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintOffset(
      offset: _translation,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return super.hitTestChildren(result, position: transformed);
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<FastToastPosition>('position', _position));
    properties.add(DiagnosticsProperty<Offset>('translation', _translation));
  }

  void _syncTranslation() {
    final Offset next = _computeTranslation();
    if (next == _translation) {
      return;
    }
    _translation = next;
    markNeedsCompositedLayerUpdate();
  }

  Offset _computeTranslation() {
    final double dpr = _view.devicePixelRatio;
    final double insetsBottom = _view.viewInsets.bottom / dpr;
    final double paddingTop = _view.viewPadding.top / dpr;
    final double paddingBottom = _view.viewPadding.bottom / dpr;
    final double gap = _position.edgeInset;

    return switch (_position) {
      FastToastPosition.top => Offset(0, paddingTop + gap),
      FastToastPosition.bottom => Offset(
        0,
        -(math.max(paddingBottom, insetsBottom) + gap),
      ),
      FastToastPosition.center => Offset(0, -insetsBottom / 2),
    };
  }
}
