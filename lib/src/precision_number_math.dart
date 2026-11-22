import 'dart:math' as math;

/// Precision-safe decimal arithmetic and inline expression evaluation utilities
/// for `flutter_input_number`.
///
/// Standard IEEE 754 floating-point operations often introduce representation
/// drift (for example, `0.1 + 0.2 == 0.30000000000000004`).
/// [PrecisionNumberMath] scales operands into exact integer space before
/// computing results, and also supports shorthand multipliers (`2.5k`, `1.2m`)
/// and inline arithmetic expressions (`120 + 35`, `50 * 3`).
abstract final class PrecisionNumberMath {
  static const int _maxPrecision = 12;

  /// Adds [a] and [b] without IEEE 754 floating-point drift.
  ///
  /// Example:
  /// ```dart
  /// PrecisionNumberMath.safeAdd(0.1, 0.2); // 0.3
  /// ```
  static num safeAdd(num a, num b, {int? precision}) {
    if (precision == null && a is int && b is int) {
      return a + b;
    }
    final targetPrecision = _resolvePrecision(a, b, precision);
    final factor = _pow10(targetPrecision);
    final scaledA = (a * factor).round();
    final scaledB = (b * factor).round();
    final result = (scaledA + scaledB) / factor;
    return normalizeNum(result, precision: targetPrecision);
  }

  /// Subtracts [b] from [a] without IEEE 754 floating-point drift.
  ///
  /// Example:
  /// ```dart
  /// PrecisionNumberMath.safeSubtract(0.3, 0.1); // 0.2
  /// ```
  static num safeSubtract(num a, num b, {int? precision}) {
    if (precision == null && a is int && b is int) {
      return a - b;
    }
    final targetPrecision = _resolvePrecision(a, b, precision);
    final factor = _pow10(targetPrecision);
    final scaledA = (a * factor).round();
    final scaledB = (b * factor).round();
    final result = (scaledA - scaledB) / factor;
    return normalizeNum(result, precision: targetPrecision);
  }

  /// Multiplies [a] and [b] and rounds to [precision] decimal places.
  static num safeMultiply(num a, num b, {int? precision}) {
    if (precision == null && a is int && b is int) {
      return a * b;
    }
    final targetPrecision = (precision ?? (decimalPlaces(a) + decimalPlaces(b)))
        .clamp(0, _maxPrecision);
    return normalizeNum(a * b, precision: targetPrecision);
  }

  /// Divides [a] by [b] and rounds to [precision] decimal places.
  ///
  /// Returns `null` if [b] is zero.
  static num? safeDivide(num a, num b, {int? precision}) {
    if (b == 0) {
      return null;
    }
    final raw = a / b;
    final targetPrecision = (precision ?? 6).clamp(0, _maxPrecision);
    return normalizeNum(raw, precision: targetPrecision);
  }

  /// Rounds [value] to [precision] decimal places.
  ///
  /// When [precision] is `0`, returns an [int].
  static num roundToPrecision(num value, int? precision) {
    if (value.isNaN || value.isInfinite) {
      return value;
    }
    if (precision == null) {
      return normalizeNum(value);
    }
    final clamped = precision.clamp(0, _maxPrecision);
    if (clamped == 0) {
      return value.round();
    }
    final factor = _pow10(clamped);
    final epsilon = value >= 0 ? 1e-12 : -1e-12;
    final scaled = ((value * factor) + epsilon).round();
    return normalizeNum(scaled / factor, precision: clamped);
  }

  /// Clamps [value] within optional [min] and [max] bounds and applies
  /// optional decimal [precision].
  static num clampValue(num value, {num? min, num? max, int? precision}) {
    var result = value;
    if (min != null && result < min) {
      result = min;
    }
    if (max != null && result > max) {
      result = max;
    }
    return roundToPrecision(result, precision);
  }

  /// Snaps [value] to the nearest valid step multiple relative to [base].
  static num snapToStep(
    num value, {
    required num step,
    num base = 0,
    int? precision,
  }) {
    if (step <= 0) {
      return roundToPrecision(value, precision);
    }
    final targetPrecision =
        precision ??
        math.max(
          decimalPlaces(value),
          math.max(decimalPlaces(step), decimalPlaces(base)),
        );
    final steps = ((value - base) / step).round();
    final snapped = base + (steps * step);
    return roundToPrecision(snapped, targetPrecision);
  }

  /// Computes a normalized progress ratio (`0.0` to `1.0`) for [value]
  /// between [min] and [max].
  ///
  /// Returns `0.0` if [value], [min], or [max] is `null`, or if `max <= min`.
  static double progressRatio(num? value, {num? min, num? max}) {
    if (value == null || min == null || max == null || max <= min) {
      return 0.0;
    }
    final ratio = (value - min) / (max - min);
    return ratio.clamp(0.0, 1.0).toDouble();
  }

  /// Maps a normalized [ratio] (`0.0` to `1.0`) to a numeric value between
  /// [min] and [max], optionally snapped to [step] and rounded to [precision].
  static num valueFromProgress(
    double ratio, {
    required num min,
    required num max,
    num? step,
    int? precision,
  }) {
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final raw = min + ((max - min) * clampedRatio);
    final stepped = (step != null && step > 0)
        ? snapToStep(raw, step: step, base: min, precision: precision)
        : raw;
    return clampValue(stepped, min: min, max: max, precision: precision);
  }

  /// Returns the number of decimal places in [value].
  static int decimalPlaces(num value) {
    if (value is int || value.isNaN || value.isInfinite) {
      return 0;
    }
    final text = value.toString().toLowerCase();
    if (text.contains('e-')) {
      final parts = text.split('e-');
      final exp = int.tryParse(parts[1]) ?? 0;
      final mantissaDecimals = parts[0].contains('.')
          ? parts[0].split('.')[1].length
          : 0;
      return (exp + mantissaDecimals).clamp(0, _maxPrecision);
    }
    final dotIndex = text.indexOf('.');
    if (dotIndex == -1) {
      return 0;
    }
    return (text.length - dotIndex - 1).clamp(0, _maxPrecision);
  }

  /// Normalizes [value] into an [int] when it has no fractional component,
  /// or a rounded [double] otherwise.
  static num normalizeNum(num value, {int? precision}) {
    if (value.isNaN || value.isInfinite) {
      return value;
    }
    final fixed = precision != null
        ? double.parse(value.toStringAsFixed(precision.clamp(0, _maxPrecision)))
        : value.toDouble();
    if (fixed == fixed.roundToDouble()) {
      return fixed.round();
    }
    return fixed;
  }

  /// Evaluates a numeric string, shorthand multiplier (`2.5k`, `1.2m`, `3b`),
  /// or inline arithmetic expression (`120 + 35`, `50 * 3`, `(10 + 5) * 2`).
  ///
  /// Returns `null` if [input] cannot be evaluated into a finite number.
  static num? evaluateExpression(String input, {int? precision}) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final parser = _InlineExpressionParser(cleaned);
    final value = parser.parse();
    if (value == null || value.isNaN || value.isInfinite) {
      return null;
    }
    return roundToPrecision(value, precision);
  }

  static int _resolvePrecision(num a, num b, int? explicitPrecision) {
    if (explicitPrecision != null) {
      return explicitPrecision.clamp(0, _maxPrecision);
    }
    return math.max(decimalPlaces(a), decimalPlaces(b)).clamp(0, _maxPrecision);
  }

  static double _pow10(int exponent) {
    return math.pow(10, exponent).toDouble();
  }
}

class _InlineExpressionParser {
  _InlineExpressionParser(this.source);

  final String source;
  int _index = 0;

  num? parse() {
    final result = _parseAddSubtract();
    _skipWhitespace();
    if (result == null || _index < source.length) {
      return null;
    }
    return result;
  }

  num? _parseAddSubtract() {
    final first = _parseMultiplyDivide();
    if (first == null) {
      return null;
    }
    var left = first;
    while (true) {
      _skipWhitespace();
      if (_index >= source.length) {
        break;
      }
      final op = source[_index];
      if (op != '+' && op != '-') {
        break;
      }
      _index++;
      final right = _parseMultiplyDivide();
      if (right == null) {
        return null;
      }
      // Check if right token was immediately followed by '%' for percentage add/sub
      _skipWhitespace();
      var effectiveRight = right;
      if (_index < source.length && source[_index] == '%') {
        _index++;
        effectiveRight = left * (right / 100.0);
      }
      left = op == '+'
          ? PrecisionNumberMath.safeAdd(left, effectiveRight)
          : PrecisionNumberMath.safeSubtract(left, effectiveRight);
    }
    return left;
  }

  num? _parseMultiplyDivide() {
    final first = _parseUnary();
    if (first == null) {
      return null;
    }
    var left = first;
    while (true) {
      _skipWhitespace();
      if (_index >= source.length) {
        break;
      }
      final op = source[_index];
      if (op != '*' && op != '/' && op != '×' && op != '÷') {
        break;
      }
      _index++;
      final right = _parseUnary();
      if (right == null) {
        return null;
      }
      if (op == '*' || op == '×') {
        left = PrecisionNumberMath.safeMultiply(left, right);
      } else {
        if (right == 0) {
          return null;
        }
        final divided = PrecisionNumberMath.safeDivide(left, right);
        if (divided == null) {
          return null;
        }
        left = divided;
      }
    }
    return left;
  }

  num? _parseUnary() {
    _skipWhitespace();
    if (_index >= source.length) {
      return null;
    }
    final ch = source[_index];
    if (ch == '+') {
      _index++;
      return _parseUnary();
    }
    if (ch == '-') {
      _index++;
      final inner = _parseUnary();
      return inner == null ? null : -inner;
    }
    if (ch == '(') {
      _index++;
      final inner = _parseAddSubtract();
      _skipWhitespace();
      if (inner == null || _index >= source.length || source[_index] != ')') {
        return null;
      }
      _index++;
      return _applySuffixMultiplier(inner);
    }
    return _parseNumberWithSuffix();
  }

  num? _parseNumberWithSuffix() {
    _skipWhitespace();
    final start = _index;
    var hasDot = false;
    while (_index < source.length) {
      final ch = source[_index];
      final code = ch.codeUnitAt(0);
      final isDigit = code >= 48 && code <= 57;
      if (isDigit) {
        _index++;
      } else if (ch == '.' && !hasDot) {
        hasDot = true;
        _index++;
      } else {
        break;
      }
    }
    if (_index == start) {
      return null;
    }
    final token = source.substring(start, _index);
    if (token == '.') {
      return null;
    }
    final parsed = num.tryParse(token);
    if (parsed == null) {
      return null;
    }
    return _applySuffixMultiplier(parsed);
  }

  num _applySuffixMultiplier(num base) {
    if (_index < source.length) {
      final suffix = source[_index].toLowerCase();
      if (suffix == 'k') {
        _index++;
        return PrecisionNumberMath.safeMultiply(base, 1000);
      }
      if (suffix == 'm') {
        _index++;
        return PrecisionNumberMath.safeMultiply(base, 1000000);
      }
      if (suffix == 'b') {
        _index++;
        return PrecisionNumberMath.safeMultiply(base, 1000000000);
      }
    }
    return base;
  }

  void _skipWhitespace() {
    while (_index < source.length && source[_index].trim().isEmpty) {
      _index++;
    }
  }
}
