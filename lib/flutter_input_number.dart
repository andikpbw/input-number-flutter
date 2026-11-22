/// Modern, lightweight, zero-dependency numeric input and stepper widget
/// library for Flutter.
///
/// Built 100% on pure `package:flutter/widgets.dart` — zero external packages
/// and zero deprecated `package:flutter/material.dart` or `cupertino.dart`
/// imports — ready for Flutter 3.29 through Flutter 3.50+.
///
/// Provides [FlutterInputNumber] (and its concise alias [InputNumber]),
/// [FlutterInputNumberFormField] ([InputNumberFormField]),
/// [FlutterInputNumberController] ([InputNumberController]),
/// [FlutterInputNumberFormat] ([InputNumberFormat]),
/// [FlutterInputNumberStyle] ([InputNumberStyle]),
/// [FlutterInputNumberMotion] ([InputNumberMotion]),
/// [FlutterInputNumberLayout] ([InputNumberLayout]),
/// [InputNumberVectorIcon], and [PrecisionNumberMath].
library;

import 'src/flutter_input_number_form_field.dart';
import 'src/flutter_input_number_widget.dart';
import 'src/input_number_controller.dart';
import 'src/input_number_enums.dart';
import 'src/input_number_format.dart';
import 'src/input_number_style.dart';
import 'src/precision_number_math.dart';

export 'src/flutter_input_number_form_field.dart';
export 'src/flutter_input_number_widget.dart';
export 'src/input_number_controller.dart';
export 'src/input_number_enums.dart';
export 'src/input_number_format.dart';
export 'src/input_number_style.dart';
export 'src/input_number_vector_icon.dart';
export 'src/precision_number_math.dart';

/// Concise alias for [FlutterInputNumber].
typedef InputNumber = FlutterInputNumber;

/// Concise alias for [FlutterInputNumberFormField].
typedef InputNumberFormField = FlutterInputNumberFormField;

/// Concise alias for [FlutterInputNumberController].
typedef InputNumberController = FlutterInputNumberController;

/// Concise alias for [FlutterInputNumberFormat].
typedef InputNumberFormat = FlutterInputNumberFormat;

/// Concise alias for [FlutterInputNumberStyle].
typedef InputNumberStyle = FlutterInputNumberStyle;

/// Concise alias for [FlutterInputNumberMotion].
typedef InputNumberMotion = FlutterInputNumberMotion;

/// Concise alias for [FlutterInputNumberLayout].
typedef InputNumberLayout = FlutterInputNumberLayout;

/// Concise alias for [FlutterInputNumberPreset].
typedef InputNumberPreset = FlutterInputNumberPreset;

/// Concise alias for [FlutterInputNumberSize].
typedef InputNumberSize = FlutterInputNumberSize;

/// Concise alias for [PrecisionNumberMath].
typedef NumberMath = PrecisionNumberMath;
