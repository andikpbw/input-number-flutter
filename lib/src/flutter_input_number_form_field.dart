import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_input_number_widget.dart';
import 'input_number_controller.dart';
import 'input_number_enums.dart';
import 'input_number_format.dart';
import 'input_number_style.dart';

/// A [FormField] wrapper around [FlutterInputNumber] that integrates seamlessly
/// with Flutter's [Form] widget for validation, saving, and resetting.
///
/// Built 100% on pure `package:flutter/widgets.dart` with zero deprecated
/// `package:flutter/material.dart` imports.
class FlutterInputNumberFormField extends FormField<num> {
  /// Creates a [FlutterInputNumberFormField].
  FlutterInputNumberFormField({
    super.key,
    this.controller,
    num? initialValue,
    num? min,
    num? max,
    num? step,
    num? largeStep,
    int? precision,
    ValueChanged<num?>? onChanged,
    ValueChanged<num?>? onSubmitted,
    ValueChanged<num>? onStep,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled = true,
    super.restorationId,
    FlutterInputNumberFormat format = const FlutterInputNumberFormat.standard(),
    FlutterInputNumberLayout layout = FlutterInputNumberLayout.splitCapsule,
    FlutterInputNumberSize size = FlutterInputNumberSize.medium,
    FlutterInputNumberStyle style = const FlutterInputNumberStyle(),
    FlutterInputNumberMotion motion = const FlutterInputNumberMotion(),
    FocusNode? focusNode,
    bool readOnly = false,
    bool autofocus = false,
    bool allowEmpty = true,
    bool clampOnBlur = true,
    bool snapToStepOnBlur = false,
    bool selectAllOnFocus = false,
    bool enableLongPress = true,
    bool enableDragScrub = false,
    bool enableKeyboardStep = true,
    bool enableMouseWheel = true,
    bool mouseWheelRequiresFocus = true,
    bool showClearButton = false,
    List<num> quickSteps = const <num>[],
    String? hintText,
    String? labelText,
    String? helperText,
    String? semanticLabel,
    String incrementSemanticLabel = 'Increment',
    String decrementSemanticLabel = 'Decrement',
    Widget? prefixWidget,
    Widget? suffixWidget,
    Widget? leading,
    Widget? trailing,
    TextInputAction? textInputAction,
  }) : super(
         initialValue: controller != null ? controller.value : initialValue,
         builder: (FormFieldState<num> field) {
           final state = field as _FlutterInputNumberFormFieldState;
           void handleChanged(num? value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return FlutterInputNumber(
             controller: state._effectiveController,
             min: min,
             max: max,
             step: step,
             largeStep: largeStep,
             precision: precision,
             onChanged: handleChanged,
             onSubmitted: onSubmitted,
             onStep: onStep,
             format: format,
             layout: layout,
             size: size,
             style: style,
             motion: motion,
             focusNode: focusNode,
             enabled: enabled,
             readOnly: readOnly,
             autofocus: autofocus,
             allowEmpty: allowEmpty,
             clampOnBlur: clampOnBlur,
             snapToStepOnBlur: snapToStepOnBlur,
             selectAllOnFocus: selectAllOnFocus,
             enableLongPress: enableLongPress,
             enableDragScrub: enableDragScrub,
             enableKeyboardStep: enableKeyboardStep,
             enableMouseWheel: enableMouseWheel,
             mouseWheelRequiresFocus: mouseWheelRequiresFocus,
             showClearButton: showClearButton,
             quickSteps: quickSteps,
             hintText: hintText,
             labelText: labelText,
             helperText: helperText,
             errorText: field.errorText,
             semanticLabel: semanticLabel,
             incrementSemanticLabel: incrementSemanticLabel,
             decrementSemanticLabel: decrementSemanticLabel,
             prefixWidget: prefixWidget,
             suffixWidget: suffixWidget,
             leading: leading,
             trailing: trailing,
             textInputAction: textInputAction,
           );
         },
       );

  /// Optional external controller managing the numeric value and bounds.
  final FlutterInputNumberController? controller;

  @override
  FormFieldState<num> createState() => _FlutterInputNumberFormFieldState();
}

class _FlutterInputNumberFormFieldState extends FormFieldState<num> {
  FlutterInputNumberController? _internalController;

  FlutterInputNumberFormField get _formField =>
      widget as FlutterInputNumberFormField;

  FlutterInputNumberController get _effectiveController =>
      _formField.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (_formField.controller == null) {
      _internalController = FlutterInputNumberController(
        value: widget.initialValue,
      );
    }
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FlutterInputNumberFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_formField.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _handleControllerChanged,
      );

      if (_formField.controller == null) {
        _internalController ??= FlutterInputNumberController(
          value: oldWidget.controller?.value ?? widget.initialValue,
        );
      } else {
        _internalController?.dispose();
        _internalController = null;
      }

      _effectiveController.addListener(_handleControllerChanged);
      if (value != _effectiveController.value) {
        setValue(_effectiveController.value);
      }
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChanged);
    _internalController?.dispose();
    super.dispose();
  }

  @override
  void didChange(num? value) {
    super.didChange(value);
    if (_effectiveController.value != value) {
      _effectiveController.setValue(value);
    }
  }

  @override
  void reset() {
    super.reset();
    _effectiveController.setValue(widget.initialValue);
  }

  void _handleControllerChanged() {
    if (_effectiveController.value != value) {
      didChange(_effectiveController.value);
    }
  }
}
