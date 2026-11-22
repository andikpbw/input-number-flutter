import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'precision_number_math.dart';

/// Signature for a custom number display formatter callback.
typedef FlutterInputNumberFormatterCallback = String Function(num? value);

/// Signature for a custom number text parser callback.
typedef FlutterInputNumberParserCallback = num? Function(String text);

/// Formatting and parsing configuration for [FlutterInputNumber].
///
/// Supports thousand grouping separators, custom decimal separators,
/// text prefixes and suffixes (such as currency symbols or physical units),
/// compact notation (`1.5K`, `2.4M`), fixed decimal padding, shorthand
/// multipliers (`2.5k`), and inline arithmetic evaluation (`120 + 35`).
@immutable
class FlutterInputNumberFormat {
  /// Creates a [FlutterInputNumberFormat] configuration.
  const FlutterInputNumberFormat({
    this.thousandSeparator,
    this.decimalSeparator = '.',
    this.prefix = '',
    this.suffix = '',
    this.padDecimals = false,
    this.useCompactNotation = false,
    this.allowExpressions = true,
    this.customFormatter,
    this.customParser,
  }) : assert(
         decimalSeparator != thousandSeparator,
         'decimalSeparator and thousandSeparator must not be identical.',
       );

  /// Standard ungrouped numeric format using `.` as the decimal separator.
  const FlutterInputNumberFormat.standard({
    this.padDecimals = false,
    this.allowExpressions = true,
  }) : thousandSeparator = null,
       decimalSeparator = '.',
       prefix = '',
       suffix = '',
       useCompactNotation = false,
       customFormatter = null,
       customParser = null;

  /// Grouped decimal format (for example, `1,250,000.50`).
  const FlutterInputNumberFormat.decimal({
    this.thousandSeparator = ',',
    this.decimalSeparator = '.',
    this.padDecimals = false,
    this.allowExpressions = true,
  }) : prefix = '',
       suffix = '',
       useCompactNotation = false,
       customFormatter = null,
       customParser = null,
       assert(
         decimalSeparator != thousandSeparator,
         'decimalSeparator and thousandSeparator must not be identical.',
       );

  /// Currency format (for example, `$1,250.50` or `£420.00`).
  const FlutterInputNumberFormat.currency({
    String symbol = r'$',
    this.thousandSeparator = ',',
    this.decimalSeparator = '.',
    this.padDecimals = true,
    this.allowExpressions = true,
    bool symbolAtEnd = false,
  }) : prefix = symbolAtEnd ? '' : symbol,
       suffix = symbolAtEnd ? symbol : '',
       useCompactNotation = false,
       customFormatter = null,
       customParser = null,
       assert(
         decimalSeparator != thousandSeparator,
         'decimalSeparator and thousandSeparator must not be identical.',
       );

  /// Indonesian Rupiah currency format (for example, `Rp 1.250.000`).
  const FlutterInputNumberFormat.idr({
    String symbol = 'Rp ',
    this.thousandSeparator = '.',
    this.decimalSeparator = ',',
    this.padDecimals = false,
    this.allowExpressions = true,
  }) : prefix = symbol,
       suffix = '',
       useCompactNotation = false,
       customFormatter = null,
       customParser = null,
       assert(
         decimalSeparator != thousandSeparator,
         'decimalSeparator and thousandSeparator must not be identical.',
       );

  /// European format using `.` for thousands and `,` for decimals
  /// (for example, `1.250,50` or `€1.250,50`).
  const FlutterInputNumberFormat.european({
    String symbol = '',
    this.thousandSeparator = '.',
    this.decimalSeparator = ',',
    this.padDecimals = false,
    this.allowExpressions = true,
    bool symbolAtEnd = false,
  }) : prefix = symbolAtEnd ? '' : symbol,
       suffix = symbolAtEnd ? symbol : '',
       useCompactNotation = false,
       customFormatter = null,
       customParser = null,
       assert(
         decimalSeparator != thousandSeparator,
         'decimalSeparator and thousandSeparator must not be identical.',
       );

  /// Percentage format (for example, `75.5%`).
  const FlutterInputNumberFormat.percentage({
    this.suffix = '%',
    this.thousandSeparator,
    this.decimalSeparator = '.',
    this.padDecimals = false,
    this.allowExpressions = true,
  }) : prefix = '',
       useCompactNotation = false,
       customFormatter = null,
       customParser = null,
       assert(
         decimalSeparator != thousandSeparator,
         'decimalSeparator and thousandSeparator must not be identical.',
       );

  /// Physical or UI measurement unit format (for example, `1,250 kg` or `24 px`).
  const FlutterInputNumberFormat.unit({
    required String unit,
    this.thousandSeparator = ',',
    this.decimalSeparator = '.',
    this.padDecimals = false,
    this.allowExpressions = true,
    bool spaceBeforeUnit = true,
  }) : prefix = '',
       suffix = spaceBeforeUnit ? ' $unit' : unit,
       useCompactNotation = false,
       customFormatter = null,
       customParser = null,
       assert(
         decimalSeparator != thousandSeparator,
         'decimalSeparator and thousandSeparator must not be identical.',
       );

  /// Compact abbreviated format (for example, `1.5K`, `2.4M`, `1.2B`).
  const FlutterInputNumberFormat.compact({
    this.prefix = '',
    this.suffix = '',
    this.decimalSeparator = '.',
    this.allowExpressions = true,
  }) : thousandSeparator = ',',
       padDecimals = false,
       useCompactNotation = true,
       customFormatter = null,
       customParser = null;

  /// Optional character used to group thousands (for example, `','` or `'.'`).
  final String? thousandSeparator;

  /// Character used to separate the integer part from the fractional part.
  final String decimalSeparator;

  /// Text prepended to the formatted number (for example, `'$'` or `'Rp '`).
  final String prefix;

  /// Text appended to the formatted number (for example, `'%'` or `' kg'`).
  final String suffix;

  /// Whether to pad trailing decimal zeros when `precision > 0`.
  final bool padDecimals;

  /// Whether numbers `>= 1000` are abbreviated using `K`, `M`, or `B`.
  final bool useCompactNotation;

  /// Whether inline expressions (`120 + 35`, `2.5k`) are evaluated during parsing.
  final bool allowExpressions;

  /// Optional callback that overrides the built-in display formatting logic.
  final FlutterInputNumberFormatterCallback? customFormatter;

  /// Optional callback that overrides the built-in text parsing logic.
  final FlutterInputNumberParserCallback? customParser;

  /// Formats [value] into a display string according to this configuration.
  ///
  /// When [includeAffixes] is `false`, [prefix], [suffix], and compact
  /// abbreviations are omitted so the user can edit raw digits smoothly.
  String format(num? value, {int? precision, bool includeAffixes = true}) {
    if (customFormatter != null && includeAffixes) {
      return customFormatter!(value);
    }
    if (value == null || value.isNaN || value.isInfinite) {
      return '';
    }

    final rounded = precision != null
        ? PrecisionNumberMath.roundToPrecision(value, precision)
        : value;
    final isNegative = rounded < 0;
    final absValue = rounded.abs();

    if (useCompactNotation && includeAffixes && absValue >= 1000) {
      final String compactCore;
      if (absValue >= 1000000000) {
        compactCore =
            '${_trimTrailingZeros((absValue / 1000000000).toStringAsFixed(1)).replaceAll('.', decimalSeparator)}B';
      } else if (absValue >= 1000000) {
        compactCore =
            '${_trimTrailingZeros((absValue / 1000000).toStringAsFixed(1)).replaceAll('.', decimalSeparator)}M';
      } else {
        compactCore =
            '${_trimTrailingZeros((absValue / 1000).toStringAsFixed(1)).replaceAll('.', decimalSeparator)}K';
      }
      final sign = isNegative ? '-' : '';
      return '$sign$prefix$compactCore$suffix';
    }

    String rawNumber;
    if (precision != null && precision == 0) {
      rawNumber = absValue.round().toString();
    } else if (precision != null && padDecimals) {
      rawNumber = absValue.toStringAsFixed(precision.clamp(0, 12));
    } else if (precision != null) {
      rawNumber = _trimTrailingZeros(
        absValue.toStringAsFixed(precision.clamp(0, 12)),
      );
    } else if (absValue is int || absValue == absValue.roundToDouble()) {
      rawNumber = absValue.toInt().toString();
    } else {
      rawNumber = absValue.toString();
    }

    final parts = rawNumber.split('.');
    var integerPart = parts[0];
    final fractionalPart = parts.length > 1 ? parts[1] : null;

    final groupSep = thousandSeparator;
    if (includeAffixes &&
        groupSep != null &&
        groupSep.isNotEmpty &&
        integerPart.length > 3) {
      final buffer = StringBuffer();
      final length = integerPart.length;
      for (var i = 0; i < length; i++) {
        if (i > 0 && (length - i) % 3 == 0) {
          buffer.write(groupSep);
        }
        buffer.write(integerPart[i]);
      }
      integerPart = buffer.toString();
    }

    final formattedCore = fractionalPart != null && fractionalPart.isNotEmpty
        ? '$integerPart$decimalSeparator$fractionalPart'
        : integerPart;

    final sign = isNegative ? '-' : '';
    if (!includeAffixes) {
      return '$sign$formattedCore';
    }
    return '$sign$prefix$formattedCore$suffix';
  }

  /// Parses a user-entered or formatted [text] into a [num] value.
  ///
  /// Supports formatted strings, shorthand (`2.5k`, `1.2m`), and inline
  /// arithmetic expressions (`120 + 35`) when [allowExpressions] is `true`.
  num? parse(String text, {int? precision}) {
    if (customParser != null) {
      return customParser!(text);
    }
    var cleaned = text.trim();
    if (cleaned.isEmpty) {
      return null;
    }

    if (prefix.isNotEmpty) {
      cleaned = cleaned.replaceAll(prefix, '');
      final trimmedPrefix = prefix.trim();
      if (trimmedPrefix.isNotEmpty) {
        cleaned = cleaned.replaceAll(trimmedPrefix, '');
      }
    }
    if (suffix.isNotEmpty) {
      cleaned = cleaned.replaceAll(suffix, '');
      final trimmedSuffix = suffix.trim();
      if (trimmedSuffix.isNotEmpty) {
        cleaned = cleaned.replaceAll(trimmedSuffix, '');
      }
    }

    final groupSep = thousandSeparator;
    if (groupSep != null && groupSep.isNotEmpty) {
      cleaned = cleaned.replaceAll(groupSep, '');
    }

    if (decimalSeparator != '.') {
      cleaned = cleaned.replaceAll(decimalSeparator, '.');
    }

    cleaned = cleaned.trim();
    if (cleaned.isEmpty ||
        cleaned == '-' ||
        cleaned == '+' ||
        cleaned == '.' ||
        cleaned == '-.') {
      return null;
    }

    final intVal = int.tryParse(cleaned);
    if (intVal != null) {
      return precision != null
          ? PrecisionNumberMath.roundToPrecision(intVal, precision)
          : intVal;
    }
    final doubleVal = double.tryParse(cleaned);
    if (doubleVal != null) {
      return PrecisionNumberMath.roundToPrecision(doubleVal, precision);
    }

    if (allowExpressions) {
      return PrecisionNumberMath.evaluateExpression(
        cleaned,
        precision: precision,
      );
    }
    return null;
  }

  /// Creates a copy of this [FlutterInputNumberFormat] with updated properties.
  FlutterInputNumberFormat copyWith({
    String? thousandSeparator,
    bool clearThousandSeparator = false,
    String? decimalSeparator,
    String? prefix,
    String? suffix,
    bool? padDecimals,
    bool? useCompactNotation,
    bool? allowExpressions,
    FlutterInputNumberFormatterCallback? customFormatter,
    FlutterInputNumberParserCallback? customParser,
  }) {
    return FlutterInputNumberFormat(
      thousandSeparator: clearThousandSeparator
          ? null
          : (thousandSeparator ?? this.thousandSeparator),
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      padDecimals: padDecimals ?? this.padDecimals,
      useCompactNotation: useCompactNotation ?? this.useCompactNotation,
      allowExpressions: allowExpressions ?? this.allowExpressions,
      customFormatter: customFormatter ?? this.customFormatter,
      customParser: customParser ?? this.customParser,
    );
  }

  static String _trimTrailingZeros(String input) {
    if (!input.contains('.')) {
      return input;
    }
    var result = input.replaceFirst(RegExp(r'0+$'), '');
    result = result.replaceFirst(RegExp(r'\.$'), '');
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FlutterInputNumberFormat &&
        other.thousandSeparator == thousandSeparator &&
        other.decimalSeparator == decimalSeparator &&
        other.prefix == prefix &&
        other.suffix == suffix &&
        other.padDecimals == padDecimals &&
        other.useCompactNotation == useCompactNotation &&
        other.allowExpressions == allowExpressions &&
        other.customFormatter == customFormatter &&
        other.customParser == customParser;
  }

  @override
  int get hashCode => Object.hash(
    thousandSeparator,
    decimalSeparator,
    prefix,
    suffix,
    padDecimals,
    useCompactNotation,
    allowExpressions,
    customFormatter,
    customParser,
  );
}

/// A [TextInputFormatter] that filters numeric input for [FlutterInputNumber].
///
/// Validates negative signs, decimal separators, decimal precision, and
/// optionally allows inline arithmetic characters (`+`, `-`, `*`, `/`, `k`, `m`, `b`)
/// when [allowExpressions] is `true`.
class NumericInputTextFormatter extends TextInputFormatter {
  /// Creates a [NumericInputTextFormatter].
  const NumericInputTextFormatter({
    this.allowDecimal = true,
    this.allowNegative = true,
    this.allowExpressions = false,
    this.decimalSeparator = '.',
    this.thousandSeparator,
    this.maxDecimalPlaces,
  });

  /// Whether fractional decimal input is permitted.
  final bool allowDecimal;

  /// Whether negative numbers (leading `-`) are permitted.
  final bool allowNegative;

  /// Whether inline expression characters (`+`, `-`, `*`, `/`, `(`, `)`, `k`, `m`, `b`)
  /// are permitted while typing.
  final bool allowExpressions;

  /// Character recognized as the decimal separator.
  final String decimalSeparator;

  /// Optional character recognized as the thousand grouping separator.
  final String? thousandSeparator;

  /// Maximum number of digits allowed after the decimal separator.
  final int? maxDecimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }
    if (allowExpressions) {
      final validExpr = RegExp(
        r'^[0-9\s\+\-\*\/×÷\(\)\.,kKmMbB%]*$',
      ).hasMatch(text);
      return validExpr ? newValue : oldValue;
    }
    if (_isValidStandardNumber(text)) {
      return newValue;
    }
    return oldValue;
  }

  bool _isValidStandardNumber(String text) {
    var normalized = text;
    final groupSep = thousandSeparator;
    if (groupSep != null && groupSep.isNotEmpty) {
      normalized = normalized.replaceAll(groupSep, '');
    }

    var hasDec = false;
    var decimalsCount = 0;

    for (var i = 0; i < normalized.length; i++) {
      final ch = normalized[i];
      if (ch == '-') {
        if (!allowNegative || i != 0) {
          return false;
        }
        continue;
      }
      final isDec =
          ch == decimalSeparator || (decimalSeparator == ',' && ch == '.');
      if (isDec) {
        if (!allowDecimal || hasDec) {
          return false;
        }
        if (maxDecimalPlaces != null && maxDecimalPlaces! <= 0) {
          return false;
        }
        hasDec = true;
        continue;
      }
      final code = ch.codeUnitAt(0);
      final isDigit = code >= 48 && code <= 57;
      if (!isDigit) {
        return false;
      }
      if (hasDec) {
        decimalsCount++;
        if (maxDecimalPlaces != null && decimalsCount > maxDecimalPlaces!) {
          return false;
        }
      }
    }
    return true;
  }
}
