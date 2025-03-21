import 'package:flutter/rendering.dart';

/// A custom [BoxBorder] that paints a gradient border around a box.
/// 一个自定义的 [BoxBorder]，用于在盒子周围绘制渐变边框。
///
/// This border can be used to create gradient borders for both rectangular and circular shapes.
/// The gradient and width of the border can be customized through the constructor parameters.
/// 这个边框可以用于创建矩形和圆形的渐变边框。
/// 边框的渐变效果和宽度可以通过构造函数参数进行自定义。
class GradientBoxBorders extends BoxBorder {
  final Gradient gradient;
  final double width;

  /// Creates a gradient border with the specified [gradient] and [width].
  /// 创建一个具有指定 [gradient] 和 [width] 的渐变边框。
  ///
  /// The [gradient] parameter defines how the border's color will transition.
  /// [gradient] 参数定义了边框颜色的过渡方式。
  ///
  /// The [width] parameter determines the thickness of the border.
  /// [width] 参数决定了边框的粗细。
  const GradientBoxBorders({required this.gradient, required this.width});

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  /// Creates and configures a [Paint] object for drawing the gradient border.
  /// 创建并配置一个用于绘制渐变边框的 [Paint] 对象。
  ///
  /// The [rect] parameter defines the area where the gradient will be applied.
  /// [rect] 参数定义了渐变效果将被应用的区域。
  Paint _getPaint(Rect rect) {
    return Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
  }

  /// Draws a rectangular border with optional rounded corners.
  /// 绘制一个可选带有圆角的矩形边框。
  ///
  /// [canvas] is the canvas to draw on.
  /// [canvas] 是用于绘制的画布。
  ///
  /// [rect] defines the area to draw the border around.
  /// [rect] 定义了要绘制边框的区域。
  ///
  /// [paint] contains the gradient and stroke configuration.
  /// [paint] 包含了渐变和描边的配置。
  ///
  /// [borderRadius] optionally defines the corner radius for rounded corners.
  /// [borderRadius] 可选参数，定义了圆角的半径。
  void _drawRectangle(
    Canvas canvas,
    Rect rect,
    Paint paint,
    BorderRadius? borderRadius,
  ) {
    final path = Path();
    if (borderRadius != null) {
      path.addRRect(borderRadius.toRRect(rect));
    } else {
      path.addRect(rect);
    }
    canvas.drawPath(path, paint);
  }

  /// Draws a circular border.
  /// 绘制一个圆形边框。
  ///
  /// [canvas] is the canvas to draw on.
  /// [canvas] 是用于绘制的画布。
  ///
  /// [rect] defines the area to draw the border around.
  /// [rect] 定义了要绘制边框的区域。
  ///
  /// [paint] contains the gradient and stroke configuration.
  /// [paint] 包含了渐变和描边的配置。
  void _drawCircle(Canvas canvas, Rect rect, Paint paint) {
    final path = Path()..addOval(rect);
    canvas.drawPath(path, paint);
  }

  @override

  /// Paints the gradient border on the canvas.
  /// 在画布上绘制渐变边框。
  ///
  /// This method handles both rectangular and circular border shapes.
  /// 这个方法可以处理矩形和圆形两种边框形状。
  ///
  /// For rectangular borders, it supports optional rounded corners through [borderRadius].
  /// 对于矩形边框，通过 [borderRadius] 参数支持可选的圆角效果。
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = _getPaint(rect);

    switch (shape) {
      case BoxShape.rectangle:
        _drawRectangle(canvas, rect, paint, borderRadius);
        break;
      case BoxShape.circle:
        _drawCircle(canvas, rect, paint);
        break;
    }
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  @override
  BorderSide get top => BorderSide.none;
}
