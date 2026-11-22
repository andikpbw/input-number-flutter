import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import 'input_number_enums.dart';

/// Pure-Flutter custom-painted vector icon widget for `flutter_input_number`.
///
/// Renders 16 resolution-independent vector glyphs ([InputNumberGlyph]) using
/// `package:flutter/widgets.dart` with zero dependency on Material or
/// Cupertino icon fonts.
class InputNumberVectorIcon extends StatelessWidget {
  /// Creates an [InputNumberVectorIcon] for the given [glyph].
  const InputNumberVectorIcon(
    this.glyph, {
    super.key,
    this.size = 18.0,
    this.color = const Color(0xFFF8FAFC),
    this.strokeWidth = 2.0,
    this.semanticLabel,
  });

  /// The vector glyph shape to paint.
  final InputNumberGlyph glyph;

  /// Logical width and height of the icon canvas.
  final double size;

  /// Stroke and accent color of the glyph.
  final Color color;

  /// Stroke thickness in logical pixels.
  final double strokeWidth;

  /// Optional accessibility label for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final icon = CustomPaint(
      size: Size.square(size),
      painter: _InputNumberVectorIconPainter(
        glyph: glyph,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
    if (semanticLabel == null) {
      return icon;
    }
    return Semantics(label: semanticLabel, image: true, child: icon);
  }
}

class _InputNumberVectorIconPainter extends CustomPainter {
  const _InputNumberVectorIconPainter({
    required this.glyph,
    required this.color,
    required this.strokeWidth,
  });

  final InputNumberGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (glyph) {
      case InputNumberGlyph.plus:
        final pad = w * 0.24;
        canvas.drawLine(Offset(pad, cy), Offset(w - pad, cy), stroke);
        canvas.drawLine(Offset(cx, pad), Offset(cx, h - pad), stroke);

      case InputNumberGlyph.minus:
        final pad = w * 0.24;
        canvas.drawLine(Offset(pad, cy), Offset(w - pad, cy), stroke);

      case InputNumberGlyph.chevronUp:
        final path = Path()
          ..moveTo(w * 0.24, h * 0.63)
          ..lineTo(cx, h * 0.35)
          ..lineTo(w * 0.76, h * 0.63);
        canvas.drawPath(path, stroke);

      case InputNumberGlyph.chevronDown:
        final path = Path()
          ..moveTo(w * 0.24, h * 0.37)
          ..lineTo(cx, h * 0.65)
          ..lineTo(w * 0.76, h * 0.37);
        canvas.drawPath(path, stroke);

      case InputNumberGlyph.chevronLeft:
        final path = Path()
          ..moveTo(w * 0.63, h * 0.24)
          ..lineTo(w * 0.35, cy)
          ..lineTo(w * 0.63, h * 0.76);
        canvas.drawPath(path, stroke);

      case InputNumberGlyph.chevronRight:
        final path = Path()
          ..moveTo(w * 0.37, h * 0.24)
          ..lineTo(w * 0.65, cy)
          ..lineTo(w * 0.37, h * 0.76);
        canvas.drawPath(path, stroke);

      case InputNumberGlyph.close:
        final pad = w * 0.27;
        canvas.drawLine(Offset(pad, pad), Offset(w - pad, h - pad), stroke);
        canvas.drawLine(Offset(w - pad, pad), Offset(pad, h - pad), stroke);

      case InputNumberGlyph.check:
        final path = Path()
          ..moveTo(w * 0.22, h * 0.53)
          ..lineTo(w * 0.43, h * 0.73)
          ..lineTo(w * 0.79, h * 0.29);
        canvas.drawPath(path, stroke);

      case InputNumberGlyph.refresh:
        final rect = Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.30);
        canvas.drawArc(rect, -math.pi * 0.75, math.pi * 1.45, false, stroke);
        final head = Path()
          ..moveTo(w * 0.66, h * 0.18)
          ..lineTo(w * 0.78, h * 0.33)
          ..lineTo(w * 0.60, h * 0.37);
        canvas.drawPath(head, stroke);

      case InputNumberGlyph.sparkles:
        final star = Path()
          ..moveTo(cx, h * 0.14)
          ..quadraticBezierTo(cx, cy, w * 0.86, cy)
          ..quadraticBezierTo(cx, cy, cx, h * 0.86)
          ..quadraticBezierTo(cx, cy, w * 0.14, cy)
          ..quadraticBezierTo(cx, cy, cx, h * 0.14)
          ..close();
        canvas.drawPath(star, fill);

      case InputNumberGlyph.currency:
        canvas.drawLine(Offset(cx, h * 0.16), Offset(cx, h * 0.84), stroke);
        final path = Path()
          ..moveTo(w * 0.68, h * 0.30)
          ..cubicTo(w * 0.68, h * 0.20, w * 0.32, h * 0.20, w * 0.32, h * 0.36)
          ..cubicTo(w * 0.32, h * 0.50, w * 0.68, h * 0.48, w * 0.68, h * 0.64)
          ..cubicTo(w * 0.68, h * 0.79, w * 0.32, h * 0.79, w * 0.32, h * 0.69);
        canvas.drawPath(path, stroke);

      case InputNumberGlyph.percent:
        canvas.drawLine(
          Offset(w * 0.25, h * 0.75),
          Offset(w * 0.75, h * 0.25),
          stroke,
        );
        canvas.drawCircle(Offset(w * 0.32, h * 0.32), w * 0.09, stroke);
        canvas.drawCircle(Offset(w * 0.68, h * 0.68), w * 0.09, stroke);

      case InputNumberGlyph.sliders:
        canvas.drawLine(
          Offset(w * 0.18, h * 0.32),
          Offset(w * 0.82, h * 0.32),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.18, h * 0.68),
          Offset(w * 0.82, h * 0.68),
          stroke,
        );
        canvas.drawCircle(Offset(w * 0.38, h * 0.32), w * 0.10, fill);
        canvas.drawCircle(Offset(w * 0.64, h * 0.68), w * 0.10, fill);

      case InputNumberGlyph.lock:
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.24, h * 0.45, w * 0.52, h * 0.36),
          Radius.circular(w * 0.08),
        );
        canvas.drawRRect(body, stroke);
        final shackle = Rect.fromLTWH(w * 0.33, h * 0.21, w * 0.34, h * 0.36);
        canvas.drawArc(shackle, math.pi, math.pi, false, stroke);

      case InputNumberGlyph.warning:
        final tri = Path()
          ..moveTo(cx, h * 0.18)
          ..lineTo(w * 0.84, h * 0.78)
          ..lineTo(w * 0.16, h * 0.78)
          ..close();
        canvas.drawPath(tri, stroke);
        canvas.drawLine(Offset(cx, h * 0.42), Offset(cx, h * 0.58), stroke);
        canvas.drawCircle(Offset(cx, h * 0.68), strokeWidth * 0.65, fill);

      case InputNumberGlyph.bolt:
        final bolt = Path()
          ..moveTo(w * 0.56, h * 0.14)
          ..lineTo(w * 0.25, h * 0.54)
          ..lineTo(w * 0.50, h * 0.54)
          ..lineTo(w * 0.44, h * 0.86)
          ..lineTo(w * 0.75, h * 0.46)
          ..lineTo(w * 0.50, h * 0.46)
          ..close();
        canvas.drawPath(bolt, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _InputNumberVectorIconPainter oldDelegate) {
    return oldDelegate.glyph != glyph ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
