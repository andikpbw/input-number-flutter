import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'input_number_controller.dart';
import 'input_number_enums.dart';
import 'input_number_format.dart';
import 'input_number_style.dart';
import 'input_number_vector_icon.dart';
import 'precision_number_math.dart';

/// A modern, lightweight, zero-dependency numeric input and stepper widget
/// for Flutter.
///
/// Built 100% on pure `package:flutter/widgets.dart` (zero deprecated
/// `package:flutter/material.dart` or `cupertino.dart` imports) so it runs
/// seamlessly across Flutter 3.29 through Flutter 3.50+ on Android, iOS, Web,
/// macOS, Windows, and Linux.
///
/// Supports 5 interactive layouts ([FlutterInputNumberLayout]), 6 visual theme
/// presets ([FlutterInputNumberPreset]), IEEE-754 precision-safe decimal math,
/// inline arithmetic expression evaluation (`120 + 35`, `2.5k`), horizontal
/// drag-to-scrub gesturing, long-press turbo acceleration, rolling odometer
/// digit animations, quick-step chips, keyboard shortcuts, and mouse wheel
/// stepping.
class FlutterInputNumber extends StatefulWidget {
  /// Creates a [FlutterInputNumber] widget.
  const FlutterInputNumber({
    super.key,
    this.controller,
    this.value,
    this.initialValue,
    this.min,
    this.max,
    this.step,
    this.largeStep,
    this.precision,
    this.onChanged,
    this.onSubmitted,
    this.onStep,
    this.format = const FlutterInputNumberFormat.standard(),
    this.layout = FlutterInputNumberLayout.splitCapsule,
    this.size = FlutterInputNumberSize.medium,
    this.style = const FlutterInputNumberStyle(),
    this.motion = const FlutterInputNumberMotion(),
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.allowEmpty = true,
    this.clampOnBlur = true,
    this.snapToStepOnBlur = false,
    this.selectAllOnFocus = false,
    this.enableLongPress = true,
    this.enableDragScrub = false,
    this.enableKeyboardStep = true,
    this.enableMouseWheel = true,
    this.mouseWheelRequiresFocus = true,
    this.showClearButton = false,
    this.quickSteps = const <num>[],
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    this.incrementSemanticLabel = 'Increment',
    this.decrementSemanticLabel = 'Decrement',
    this.prefixWidget,
    this.suffixWidget,
    this.leading,
    this.trailing,
    this.textInputAction,
  }) : assert(step == null || step > 0, 'step must be greater than 0.'),
       assert(
         largeStep == null || largeStep > 0,
         'largeStep must be greater than 0.',
       ),
       assert(
         min == null || max == null || min <= max,
         'min must be less than or equal to max.',
       ),
       assert(
         precision == null || (precision >= 0 && precision <= 12),
         'precision must be between 0 and 12.',
       );

  /// Optional external controller managing the numeric value, bounds, and history.
  final FlutterInputNumberController? controller;

  /// Controlled numeric value when [controller] is not provided.
  final num? value;

  /// Initial numeric value when both [controller] and [value] are `null`.
  final num? initialValue;

  /// Minimum allowed numeric value, or `null` if unbounded below.
  final num? min;

  /// Maximum allowed numeric value, or `null` if unbounded above.
  final num? max;

  /// Step delta applied when incrementing or decrementing (defaults to `1`).
  final num? step;

  /// Large step delta applied on `PageUp` / `PageDown` keys (defaults to `step * 10`).
  final num? largeStep;

  /// Number of decimal places to round values to (`0` for integers).
  final int? precision;

  /// Called whenever the numeric value changes.
  final ValueChanged<num?>? onChanged;

  /// Called when the user commits the value (pressing Enter/Done or on blur).
  final ValueChanged<num?>? onSubmitted;

  /// Called specifically when a value change is triggered by a stepper action,
  /// keyboard arrow, mouse wheel, scrub drag, or quick-step chip.
  final ValueChanged<num>? onStep;

  /// Formatting and parsing configuration for the displayed number.
  final FlutterInputNumberFormat format;

  /// Interactive layout arrangement of the control.
  final FlutterInputNumberLayout layout;

  /// Preset size dimensions of the control.
  final FlutterInputNumberSize size;

  /// Visual theme and styling overrides.
  final FlutterInputNumberStyle style;

  /// Motion, digit animation, and haptics configuration.
  final FlutterInputNumberMotion motion;

  /// Optional external [FocusNode] for managing keyboard focus.
  final FocusNode? focusNode;

  /// Whether the control is interactive.
  final bool enabled;

  /// Whether direct keyboard text editing is disabled while stepper buttons
  /// remain active.
  final bool readOnly;

  /// Whether the input requests focus automatically on mount.
  final bool autofocus;

  /// Whether the input is allowed to hold a `null` (empty) value.
  final bool allowEmpty;

  /// Whether manually typed out-of-range values are clamped to `[min, max]`
  /// on blur/submit.
  final bool clampOnBlur;

  /// Whether manually typed values are snapped to the nearest multiple of
  /// [step] on blur/submit.
  final bool snapToStepOnBlur;

  /// Whether all text in the input field is selected automatically when focused.
  final bool selectAllOnFocus;

  /// Whether holding a stepper button triggers continuous auto-repeat.
  final bool enableLongPress;

  /// Whether horizontal dragging over the value area scrubs the numeric value
  /// even in non-`scrubSlider` layouts.
  final bool enableDragScrub;

  /// Whether `ArrowUp`, `ArrowDown`, `PageUp`, and `PageDown` keys adjust
  /// the value while focused.
  final bool enableKeyboardStep;

  /// Whether scrolling the mouse wheel over the widget adjusts the value.
  final bool enableMouseWheel;

  /// Whether mouse wheel stepping requires the widget to have keyboard focus.
  final bool mouseWheelRequiresFocus;

  /// Whether to show a quick clear button (`×`) when the field has a non-null value.
  final bool showClearButton;

  /// Optional list of quick-step delta chips rendered below the control
  /// (for example, `[-10, -5, 5, 10]`).
  final List<num> quickSteps;

  /// Placeholder text displayed when the input value is `null`.
  final String? hintText;

  /// Optional label text displayed above the input control.
  final String? labelText;

  /// Optional helper caption displayed below the input control.
  final String? helperText;

  /// Optional error message displayed below the input control; also activates
  /// the error border state.
  final String? errorText;

  /// Optional accessibility label for the input field.
  final String? semanticLabel;

  /// Accessibility label for the increment button.
  final String incrementSemanticLabel;

  /// Accessibility label for the decrement button.
  final String decrementSemanticLabel;

  /// Optional widget rendered inside the input area before the value.
  final Widget? prefixWidget;

  /// Optional widget rendered inside the input area after the value.
  final Widget? suffixWidget;

  /// Optional widget rendered at the leading edge of the outer container.
  final Widget? leading;

  /// Optional widget rendered at the trailing edge of the outer container.
  final Widget? trailing;

  /// Action button label for the soft keyboard (for example, [TextInputAction.done]).
  final TextInputAction? textInputAction;

  @override
  State<FlutterInputNumber> createState() => _FlutterInputNumberState();
}

class _FlutterInputNumberState extends State<FlutterInputNumber>
    with SingleTickerProviderStateMixin {
  FlutterInputNumberController? _internalController;
  late final TextEditingController _textController;
  FocusNode? _internalFocusNode;
  late final AnimationController _shakeController;

  bool _isUpdatingFromText = false;
  bool _isFocused = false;
  int _observedShakeToken = 0;
  double _scrubAccumulator = 0.0;

  FlutterInputNumberController get _effectiveController =>
      widget.controller ?? _internalController!;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;

  num? get _effectiveMin => widget.min ?? widget.controller?.min;
  num? get _effectiveMax => widget.max ?? widget.controller?.max;
  num get _effectiveStep => widget.step ?? widget.controller?.step ?? 1;
  num get _effectiveLargeStep => widget.largeStep ?? (_effectiveStep * 10);
  int? get _effectivePrecision =>
      widget.precision ?? widget.controller?.precision;

  bool get _isScrubEnabled =>
      widget.enabled &&
      (widget.layout == FlutterInputNumberLayout.scrubSlider ||
          widget.enableDragScrub);

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: widget.motion.errorShakeDuration,
    );

    if (widget.controller == null) {
      _internalController = FlutterInputNumberController(
        value: widget.value ?? widget.initialValue,
        min: widget.min,
        max: widget.max,
        step: widget.step ?? 1,
        precision: widget.precision,
      );
    } else {
      _syncExternalControllerBounds();
    }

    _observedShakeToken = _effectiveController.errorShakeToken;

    _textController = TextEditingController(
      text: _formatForDisplay(_effectiveController.value, forEditing: false),
    );

    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _effectiveFocusNode.addListener(_handleFocusChange);
    _effectiveController.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant FlutterInputNumber oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.motion.errorShakeDuration !=
        oldWidget.motion.errorShakeDuration) {
      _shakeController.duration = widget.motion.errorShakeDuration;
    }

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(
        _handleFocusChange,
      );
      if (widget.focusNode == null && _internalFocusNode == null) {
        _internalFocusNode = FocusNode();
      }
      _effectiveFocusNode.addListener(_handleFocusChange);
      _isFocused = _effectiveFocusNode.hasFocus;
    }

    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _handleControllerChange,
      );
      if (widget.controller == null) {
        _internalController ??= FlutterInputNumberController(
          value:
              widget.value ??
              oldWidget.controller?.value ??
              widget.initialValue,
          min: widget.min,
          max: widget.max,
          step: widget.step ?? 1,
          precision: widget.precision,
        );
      } else {
        _internalController?.dispose();
        _internalController = null;
        _syncExternalControllerBounds();
      }
      _observedShakeToken = _effectiveController.errorShakeToken;
      _effectiveController.addListener(_handleControllerChange);
      _syncTextWithController(force: true);
    } else {
      if (widget.controller == null) {
        _internalController!.updateBounds(
          min: widget.min,
          clearMin: widget.min == null,
          max: widget.max,
          clearMax: widget.max == null,
          step: widget.step ?? 1,
          precision: widget.precision,
          clearPrecision: widget.precision == null,
          clampCurrentValue: widget.clampOnBlur,
        );
        if (widget.value != oldWidget.value) {
          _internalController!.setValue(
            widget.value,
            clamp: widget.clampOnBlur,
          );
        }
      } else {
        _syncExternalControllerBounds();
      }
    }

    if (widget.errorText != oldWidget.errorText &&
        widget.errorText != null &&
        widget.errorText!.isNotEmpty) {
      _playErrorShake();
    }

    if (widget.format != oldWidget.format ||
        widget.precision != oldWidget.precision) {
      _syncTextWithController(force: !_isFocused);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _effectiveFocusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    _effectiveController.removeListener(_handleControllerChange);
    _internalController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _playErrorShake() {
    if (!mounted) {
      return;
    }
    _shakeController.forward(from: 0.0);
  }

  void _syncExternalControllerBounds() {
    final ext = widget.controller;
    if (ext == null) {
      return;
    }
    if (widget.min != null ||
        widget.max != null ||
        widget.step != null ||
        widget.precision != null) {
      ext.updateBounds(
        min: widget.min ?? ext.min,
        max: widget.max ?? ext.max,
        step: widget.step ?? ext.step,
        precision: widget.precision ?? ext.precision,
        clampCurrentValue: widget.clampOnBlur,
      );
    }
  }

  String _formatForDisplay(num? val, {required bool forEditing}) {
    if (val == null) {
      return '';
    }
    if (forEditing && !widget.readOnly) {
      final rawFormat = FlutterInputNumberFormat(
        decimalSeparator: widget.format.decimalSeparator,
        padDecimals: false,
      );
      return rawFormat.format(
        val,
        precision: _effectivePrecision,
        includeAffixes: false,
      );
    }
    return widget.format.format(
      val,
      precision: _effectivePrecision,
      includeAffixes: true,
    );
  }

  void _handleControllerChange() {
    if (_effectiveController.errorShakeToken != _observedShakeToken) {
      _observedShakeToken = _effectiveController.errorShakeToken;
      _playErrorShake();
    }
    if (_isUpdatingFromText) {
      return;
    }
    _syncTextWithController();
  }

  void _syncTextWithController({bool force = false}) {
    final currentValue = _effectiveController.value;
    if (_isFocused && !widget.readOnly && !force) {
      final currentParsed = widget.format.parse(
        _textController.text,
        precision: _effectivePrecision,
      );
      if (currentParsed == currentValue &&
          (currentValue != null || _textController.text.trim().isEmpty)) {
        return;
      }
    }
    final formatted = _formatForDisplay(
      currentValue,
      forEditing: _isFocused && !widget.readOnly,
    );
    if (_textController.text != formatted) {
      _textController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _handleFocusChange() {
    final hasFocus = _effectiveFocusNode.hasFocus;
    if (_isFocused == hasFocus) {
      return;
    }
    setState(() => _isFocused = hasFocus);

    if (hasFocus) {
      if (!widget.readOnly) {
        final editableText = _formatForDisplay(
          _effectiveController.value,
          forEditing: true,
        );
        final selection = widget.selectAllOnFocus
            ? TextSelection(baseOffset: 0, extentOffset: editableText.length)
            : TextSelection.collapsed(offset: editableText.length);
        _textController.value = TextEditingValue(
          text: editableText,
          selection: selection,
        );
      }
    } else {
      _commitEditingText(notifySubmit: true);
    }
  }

  void _onTextChanged(String rawText) {
    if (!widget.enabled || widget.readOnly) {
      return;
    }
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      if (widget.allowEmpty) {
        _isUpdatingFromText = true;
        final previous = _effectiveController.value;
        _effectiveController.clear();
        _isUpdatingFromText = false;
        if (previous != null) {
          widget.onChanged?.call(null);
        }
      }
      return;
    }

    // Only live-update on pure numbers while typing; expressions like "120 + "
    // are committed on submit/blur so intermediate operators aren't lost.
    final isIntermediateExpression = RegExp(
      r'[\+\-\*\/×÷\(\)kKmMbB%]$',
    ).hasMatch(trimmed);
    if (isIntermediateExpression) {
      return;
    }

    final parsed = widget.format.parse(trimmed, precision: _effectivePrecision);
    if (parsed == null) {
      return;
    }

    final min = _effectiveMin;
    final max = _effectiveMax;
    final inBounds =
        (min == null || parsed >= min) && (max == null || parsed <= max);

    if (inBounds || !widget.clampOnBlur) {
      _isUpdatingFromText = true;
      final previous = _effectiveController.value;
      _effectiveController.setValue(parsed, clamp: widget.clampOnBlur);
      _isUpdatingFromText = false;
      if (_effectiveController.value != previous) {
        widget.onChanged?.call(_effectiveController.value);
      }
    }
  }

  void _commitEditingText({required bool notifySubmit}) {
    final rawText = _textController.text.trim();
    final previous = _effectiveController.value;

    if (rawText.isEmpty) {
      if (widget.allowEmpty) {
        _effectiveController.clear();
      } else {
        final fallback = _effectiveMin ?? 0;
        _effectiveController.setValue(fallback, clamp: widget.clampOnBlur);
      }
    } else {
      final parsed = widget.format.parse(
        rawText,
        precision: _effectivePrecision,
      );
      if (parsed != null) {
        var resolved = parsed;
        if (widget.snapToStepOnBlur) {
          resolved = PrecisionNumberMath.snapToStep(
            resolved,
            step: _effectiveStep,
            base: _effectiveMin ?? 0,
            precision: _effectivePrecision,
          );
        }
        final min = _effectiveMin;
        final max = _effectiveMax;
        final outOfBounds =
            (min != null && resolved < min) || (max != null && resolved > max);
        if (outOfBounds && widget.clampOnBlur) {
          _playErrorShake();
        }
        _effectiveController.setValue(resolved, clamp: widget.clampOnBlur);
      } else if (widget.allowEmpty) {
        _effectiveController.clear();
      } else {
        _effectiveController.setValue(
          previous ?? _effectiveMin ?? 0,
          clamp: widget.clampOnBlur,
        );
      }
    }

    _syncTextWithController(force: true);

    final current = _effectiveController.value;
    if (current != previous) {
      widget.onChanged?.call(current);
    }
    if (notifySubmit) {
      widget.onSubmitted?.call(current);
    }
  }

  void _performStep({required bool isIncrement, num? customStep}) {
    if (!widget.enabled) {
      return;
    }
    if (_isFocused && !widget.readOnly) {
      final rawText = _textController.text.trim();
      final parsed = widget.format.parse(
        rawText,
        precision: _effectivePrecision,
      );
      if (parsed != null && parsed != _effectiveController.value) {
        _effectiveController.setValue(parsed, clamp: widget.clampOnBlur);
      }
    }

    final previous = _effectiveController.value;
    final delta = (customStep ?? _effectiveStep).abs();
    final next = isIncrement
        ? _effectiveController.increment(delta)
        : _effectiveController.decrement(delta);

    _syncTextWithController(force: true);

    if (next != previous) {
      if (widget.motion.enableHaptics) {
        HapticFeedback.selectionClick();
      }
      widget.onStep?.call(next);
      widget.onChanged?.call(next);
    } else {
      _playErrorShake();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _handleClear() {
    if (!widget.enabled || !widget.allowEmpty) {
      return;
    }
    final previous = _effectiveController.value;
    _effectiveController.clear();
    _syncTextWithController(force: true);
    if (previous != null) {
      widget.onChanged?.call(null);
    }
    setState(() {});
  }

  void _handleScrubDragUpdate(DragUpdateDetails details) {
    if (!_isScrubEnabled) {
      return;
    }
    _scrubAccumulator += details.delta.dx;
    final threshold = widget.motion.scrubPixelsPerStep;
    while (_scrubAccumulator.abs() >= threshold) {
      final isInc = _scrubAccumulator > 0;
      _scrubAccumulator += isInc ? -threshold : threshold;
      if (isInc && _effectiveController.canIncrement) {
        _performStep(isIncrement: true);
      } else if (!isInc && _effectiveController.canDecrement) {
        _performStep(isIncrement: false);
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled || !widget.enableKeyboardStep) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      if (_effectiveController.canIncrement) {
        _performStep(isIncrement: true);
      } else {
        _playErrorShake();
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      if (_effectiveController.canDecrement) {
        _performStep(isIncrement: false);
      } else {
        _playErrorShake();
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      if (_effectiveController.canIncrement) {
        _performStep(isIncrement: true, customStep: _effectiveLargeStep);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      if (_effectiveController.canDecrement) {
        _performStep(isIncrement: false, customStep: _effectiveLargeStep);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!widget.enabled || !widget.enableMouseWheel) {
      return;
    }
    if (widget.mouseWheelRequiresFocus && !_isFocused) {
      return;
    }
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy < 0 && _effectiveController.canIncrement) {
        _performStep(isIncrement: true);
      } else if (event.scrollDelta.dy > 0 &&
          _effectiveController.canDecrement) {
        _performStep(isIncrement: false);
      }
    }
  }

  bool get _isMorphCollapsed {
    if (widget.layout != FlutterInputNumberLayout.morphingPill) {
      return false;
    }
    if (_isFocused) {
      return false;
    }
    final val = _effectiveController.value;
    final min = _effectiveMin ?? 0;
    return val == null || val <= min;
  }

  @override
  Widget build(BuildContext context) {
    final resolved = widget.style.resolve(
      size: widget.size,
      layout: widget.layout,
    );

    return ListenableBuilder(
      listenable: _effectiveController,
      builder: (context, _) {
        final effectiveError =
            widget.errorText ?? _effectiveController.errorMessage;
        final hasError = effectiveError != null && effectiveError.isNotEmpty;

        final canInc = widget.enabled && _effectiveController.canIncrement;
        final canDec = widget.enabled && _effectiveController.canDecrement;

        final activeBorderColor = !widget.enabled
            ? resolved.disabledBorderColor
            : (hasError
                  ? resolved.errorBorderColor
                  : (_isFocused
                        ? resolved.focusedBorderColor
                        : resolved.borderColor));

        final activeBorderWidth = (_isFocused || hasError) && widget.enabled
            ? resolved.focusedBorderWidth
            : resolved.borderWidth;

        final boxBorder = resolved.preset == FlutterInputNumberPreset.underlined
            ? Border(
                bottom: BorderSide(
                  color: activeBorderColor,
                  width: activeBorderWidth,
                ),
              )
            : Border.all(color: activeBorderColor, width: activeBorderWidth);

        final bgColor = widget.enabled
            ? resolved.backgroundColor
            : resolved.disabledBackgroundColor;

        Widget innerRow;
        if (_isMorphCollapsed) {
          innerRow = _buildCollapsedMorphPill(resolved, canInc);
        } else {
          innerRow = Row(
            children: <Widget>[
              if (widget.leading != null) widget.leading!,
              if (widget.layout == FlutterInputNumberLayout.splitCapsule ||
                  widget.layout == FlutterInputNumberLayout.morphingPill ||
                  widget.layout ==
                      FlutterInputNumberLayout.scrubSlider) ...<Widget>[
                _buildDecrementButton(resolved, canDec),
                if (resolved.showDividers) _buildVerticalDivider(resolved),
              ],
              Expanded(child: _buildValueArea(resolved)),
              if (widget.layout == FlutterInputNumberLayout.splitCapsule ||
                  widget.layout == FlutterInputNumberLayout.morphingPill ||
                  widget.layout ==
                      FlutterInputNumberLayout.scrubSlider) ...<Widget>[
                if (resolved.showDividers) _buildVerticalDivider(resolved),
                _buildIncrementButton(resolved, canInc),
              ],
              if (widget.layout ==
                  FlutterInputNumberLayout.inlineCompact) ...<Widget>[
                if (resolved.showDividers) _buildVerticalDivider(resolved),
                _buildDecrementButton(resolved, canDec),
                if (resolved.showDividers) _buildVerticalDivider(resolved),
                _buildIncrementButton(resolved, canInc),
              ],
              if (widget.layout ==
                  FlutterInputNumberLayout.stackedSpinbox) ...<Widget>[
                if (resolved.showDividers) _buildVerticalDivider(resolved),
                _buildStackedSpinboxButtons(resolved, canInc, canDec),
              ],
              if (widget.trailing != null) widget.trailing!,
            ],
          );
        }

        final showProgress =
            resolved.showProgressTrack &&
            _effectiveMin != null &&
            _effectiveMax != null &&
            _effectiveMax! > _effectiveMin! &&
            !_isMorphCollapsed;

        Widget containerBody = Stack(
          children: <Widget>[
            if (widget.layout == FlutterInputNumberLayout.scrubSlider &&
                showProgress)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _effectiveController.progress,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: resolved.progressFillColor.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),
            Positioned.fill(child: innerRow),
            if (showProgress)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 3.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: resolved.progressTrackColor),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _effectiveController.progress,
                      heightFactor: 1.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: hasError
                              ? resolved.errorBorderColor
                              : resolved.progressFillColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );

        if (resolved.preset == FlutterInputNumberPreset.glass) {
          containerBody = BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: resolved.glassBlurSigma,
              sigmaY: resolved.glassBlurSigma,
            ),
            child: containerBody,
          );
        }

        Widget control = Listener(
          onPointerSignal: _handlePointerSignal,
          child: Focus(
            onKeyEvent: _handleKeyEvent,
            child: AnimatedContainer(
              duration: widget.motion.containerAnimationDuration,
              curve: Curves.easeOutCubic,
              height: resolved.height,
              width: resolved.width,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius:
                    resolved.preset == FlutterInputNumberPreset.underlined
                    ? null
                    : resolved.borderRadius,
                border: boxBorder,
                boxShadow: resolved.shadows,
              ),
              clipBehavior:
                  resolved.preset == FlutterInputNumberPreset.underlined
                  ? Clip.none
                  : Clip.antiAlias,
              child: containerBody,
            ),
          ),
        );

        // Wrap in damped horizontal error shake animation
        control = AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final t = _shakeController.value;
            if (t == 0.0 || t == 1.0) {
              return child!;
            }
            final damped =
                math.sin(t * math.pi * 4.0) *
                (1.0 - t) *
                widget.motion.errorShakeAmplitude;
            return Transform.translate(offset: Offset(damped, 0), child: child);
          },
          child: control,
        );

        final hasOuterColumn =
            widget.labelText != null ||
            widget.helperText != null ||
            hasError ||
            widget.quickSteps.isNotEmpty;

        if (hasOuterColumn) {
          control = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.labelText != null) ...<Widget>[
                Text(
                  widget.labelText!,
                  style: hasError
                      ? resolved.labelStyle.copyWith(
                          color: resolved.errorBorderColor,
                        )
                      : resolved.labelStyle,
                ),
                const SizedBox(height: 6),
              ],
              control,
              if (widget.quickSteps.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                _buildQuickStepChips(resolved),
              ],
              if (hasError) ...<Widget>[
                const SizedBox(height: 4),
                Text(effectiveError, style: resolved.errorStyle),
              ] else if (widget.helperText != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(widget.helperText!, style: resolved.helperStyle),
              ],
            ],
          );
        }

        return Semantics(
          label: widget.semanticLabel ?? widget.labelText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          textField: true,
          child: control,
        );
      },
    );
  }

  Widget _buildCollapsedMorphPill(
    ResolvedInputNumberStyle resolved,
    bool canInc,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canInc ? () => _performStep(isIncrement: true) : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              resolved.accentColor,
              resolved.accentColor.withValues(alpha: 0.82),
            ],
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const InputNumberVectorIcon(
                InputNumberGlyph.plus,
                size: 15,
                color: Color(0xFFFFFFFF),
                strokeWidth: 2.3,
              ),
              const SizedBox(width: 6),
              Text(
                resolved.morphTriggerLabel.replaceFirst(RegExp(r'^\+\s*'), ''),
                style: resolved.textStyle.copyWith(
                  color: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueArea(ResolvedInputNumberStyle resolved) {
    final allowNegative = _effectiveMin == null || _effectiveMin! < 0;
    final allowDecimal =
        _effectivePrecision == null || _effectivePrecision! > 0;
    final hasClear =
        widget.showClearButton &&
        widget.enabled &&
        !widget.readOnly &&
        widget.allowEmpty &&
        _effectiveController.hasValue;

    final formattedDisplay = _formatForDisplay(
      _effectiveController.value,
      forEditing: false,
    );

    final isShowingPlaceholder = formattedDisplay.isEmpty;
    final displayString = isShowingPlaceholder
        ? (widget.hintText ?? '')
        : formattedDisplay;
    final displayStyle = isShowingPlaceholder
        ? resolved.hintStyle
        : resolved.textStyle;

    final textAlignment = switch (resolved.textAlign) {
      TextAlign.left || TextAlign.start => Alignment.centerLeft,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      _ => Alignment.center,
    };

    final animatedDisplay = _buildAnimatedDisplayText(
      displayString: displayString,
      displayStyle: displayStyle,
      alignment: textAlignment,
    );

    Widget valueStack = Stack(
      alignment: textAlignment,
      children: <Widget>[
        if (!widget.readOnly)
          Opacity(
            opacity: _isFocused ? 1.0 : 0.0,
            child: EditableText(
              controller: _textController,
              focusNode: _effectiveFocusNode,
              style: resolved.textStyle,
              cursorColor: resolved.accentColor,
              backgroundCursorColor: const Color(0xFF94A3B8),
              textAlign: resolved.textAlign,
              keyboardType: TextInputType.numberWithOptions(
                signed: allowNegative,
                decimal: allowDecimal,
              ),
              textInputAction: widget.textInputAction,
              autofocus: widget.autofocus,
              readOnly: !widget.enabled || widget.readOnly,
              selectionColor: resolved.accentColor.withValues(alpha: 0.25),
              inputFormatters: <TextInputFormatter>[
                NumericInputTextFormatter(
                  allowDecimal: allowDecimal,
                  allowNegative: allowNegative,
                  allowExpressions: widget.format.allowExpressions,
                  decimalSeparator: widget.format.decimalSeparator,
                  thousandSeparator: widget.format.thousandSeparator,
                  maxDecimalPlaces: _effectivePrecision,
                ),
              ],
              onChanged: _onTextChanged,
              onEditingComplete: () {},
              onSubmitted: (_) => _commitEditingText(notifySubmit: true),
            ),
          ),
        if (!_isFocused || widget.readOnly)
          IgnorePointer(child: animatedDisplay),
      ],
    );

    valueStack = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled && !widget.readOnly
          ? () {
              if (!_effectiveFocusNode.hasFocus) {
                _effectiveFocusNode.requestFocus();
              }
            }
          : null,
      onHorizontalDragUpdate: _isScrubEnabled ? _handleScrubDragUpdate : null,
      child: Padding(
        padding: resolved.contentPadding,
        child: Row(
          children: <Widget>[
            if (widget.prefixWidget != null) ...<Widget>[
              widget.prefixWidget!,
              const SizedBox(width: 6),
            ],
            if (widget.layout ==
                FlutterInputNumberLayout.scrubSlider) ...<Widget>[
              InputNumberVectorIcon(
                InputNumberGlyph.sliders,
                size: 13,
                color: resolved.accentColor.withValues(alpha: 0.85),
                strokeWidth: 1.8,
              ),
              const SizedBox(width: 6),
            ],
            Expanded(child: valueStack),
            if (hasClear)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleClear,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InputNumberVectorIcon(
                    InputNumberGlyph.close,
                    size: resolved.iconSize * 0.85,
                    color: resolved.hintStyle.color ?? const Color(0xFF94A3B8),
                  ),
                ),
              ),
            if (widget.suffixWidget != null) ...<Widget>[
              const SizedBox(width: 6),
              widget.suffixWidget!,
            ],
          ],
        ),
      ),
    );

    return valueStack;
  }

  Widget _buildAnimatedDisplayText({
    required String displayString,
    required TextStyle displayStyle,
    required Alignment alignment,
  }) {
    final mode = widget.motion.digitAnimation;
    final direction = _effectiveController.lastStepDirection;

    if (mode == InputNumberDigitAnimation.none) {
      return Align(
        alignment: alignment,
        child: Text(
          displayString,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: displayStyle,
        ),
      );
    }

    return AnimatedSwitcher(
      duration: widget.motion.digitAnimationDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        if (mode == InputNumberDigitAnimation.scale) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.86, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        }
        if (mode == InputNumberDigitAnimation.fade) {
          return FadeTransition(opacity: animation, child: child);
        }
        // Vertical odometer roll
        final isIncoming = child.key == ValueKey<String>(displayString);
        final yOffset = direction >= 0
            ? (isIncoming ? 0.45 : -0.45)
            : (isIncoming ? -0.45 : 0.45);
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, yOffset),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Align(
        key: ValueKey<String>(displayString),
        alignment: alignment,
        child: Text(
          displayString,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: displayStyle,
        ),
      ),
    );
  }

  Widget _buildIncrementButton(ResolvedInputNumberStyle resolved, bool canInc) {
    final iconColor = canInc
        ? resolved.buttonIconColor
        : resolved.buttonDisabledIconColor;
    final defaultGlyph = widget.layout == FlutterInputNumberLayout.scrubSlider
        ? InputNumberGlyph.chevronRight
        : InputNumberGlyph.plus;

    return _PureStepperButton(
      width: resolved.buttonWidth,
      height: resolved.height,
      enabled: canInc,
      enableLongPress: widget.enableLongPress,
      enableAcceleration: widget.motion.enableTurboAcceleration,
      initialDelay: widget.motion.longPressInitialDelay,
      interval: widget.motion.longPressInterval,
      pressScale: widget.motion.buttonPressScale,
      backgroundColor: resolved.buttonBackgroundColor,
      hoverColor: resolved.buttonHoverColor,
      splashColor: resolved.buttonSplashColor,
      semanticLabel: widget.incrementSemanticLabel,
      onStep: () => _performStep(isIncrement: true),
      child:
          resolved.incrementWidget ??
          InputNumberVectorIcon(
            defaultGlyph,
            size: resolved.iconSize,
            color: iconColor,
          ),
    );
  }

  Widget _buildDecrementButton(ResolvedInputNumberStyle resolved, bool canDec) {
    final iconColor = canDec
        ? resolved.buttonIconColor
        : resolved.buttonDisabledIconColor;
    final defaultGlyph = widget.layout == FlutterInputNumberLayout.scrubSlider
        ? InputNumberGlyph.chevronLeft
        : InputNumberGlyph.minus;

    return _PureStepperButton(
      width: resolved.buttonWidth,
      height: resolved.height,
      enabled: canDec,
      enableLongPress: widget.enableLongPress,
      enableAcceleration: widget.motion.enableTurboAcceleration,
      initialDelay: widget.motion.longPressInitialDelay,
      interval: widget.motion.longPressInterval,
      pressScale: widget.motion.buttonPressScale,
      backgroundColor: resolved.buttonBackgroundColor,
      hoverColor: resolved.buttonHoverColor,
      splashColor: resolved.buttonSplashColor,
      semanticLabel: widget.decrementSemanticLabel,
      onStep: () => _performStep(isIncrement: false),
      child:
          resolved.decrementWidget ??
          InputNumberVectorIcon(
            defaultGlyph,
            size: resolved.iconSize,
            color: iconColor,
          ),
    );
  }

  Widget _buildStackedSpinboxButtons(
    ResolvedInputNumberStyle resolved,
    bool canInc,
    bool canDec,
  ) {
    final incColor = canInc
        ? resolved.buttonIconColor
        : resolved.buttonDisabledIconColor;
    final decColor = canDec
        ? resolved.buttonIconColor
        : resolved.buttonDisabledIconColor;
    final stackedIconSize = (resolved.iconSize * 0.76).clamp(10.0, 16.0);

    return SizedBox(
      width: resolved.buttonWidth,
      height: resolved.height,
      child: Column(
        children: <Widget>[
          Expanded(
            child: _PureStepperButton(
              width: resolved.buttonWidth,
              enabled: canInc,
              enableLongPress: widget.enableLongPress,
              enableAcceleration: widget.motion.enableTurboAcceleration,
              initialDelay: widget.motion.longPressInitialDelay,
              interval: widget.motion.longPressInterval,
              pressScale: widget.motion.buttonPressScale,
              backgroundColor: resolved.buttonBackgroundColor,
              hoverColor: resolved.buttonHoverColor,
              splashColor: resolved.buttonSplashColor,
              semanticLabel: widget.incrementSemanticLabel,
              onStep: () => _performStep(isIncrement: true),
              child:
                  resolved.incrementWidget ??
                  InputNumberVectorIcon(
                    InputNumberGlyph.chevronUp,
                    size: stackedIconSize,
                    color: incColor,
                  ),
            ),
          ),
          if (resolved.showDividers)
            Container(
              height: 1,
              width: resolved.buttonWidth,
              color: resolved.dividerColor,
            ),
          Expanded(
            child: _PureStepperButton(
              width: resolved.buttonWidth,
              enabled: canDec,
              enableLongPress: widget.enableLongPress,
              enableAcceleration: widget.motion.enableTurboAcceleration,
              initialDelay: widget.motion.longPressInitialDelay,
              interval: widget.motion.longPressInterval,
              pressScale: widget.motion.buttonPressScale,
              backgroundColor: resolved.buttonBackgroundColor,
              hoverColor: resolved.buttonHoverColor,
              splashColor: resolved.buttonSplashColor,
              semanticLabel: widget.decrementSemanticLabel,
              onStep: () => _performStep(isIncrement: false),
              child:
                  resolved.decrementWidget ??
                  InputNumberVectorIcon(
                    InputNumberGlyph.chevronDown,
                    size: stackedIconSize,
                    color: decColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStepChips(ResolvedInputNumberStyle resolved) {
    final isDark = resolved.brightness == Brightness.dark;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        for (final delta in widget.quickSteps)
          if (delta != 0)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.enabled
                  ? () => _performStep(
                      isIncrement: delta > 0,
                      customStep: delta.abs(),
                    )
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: resolved.accentColor.withValues(
                    alpha: isDark ? 0.14 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: resolved.accentColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  delta > 0 ? '+$delta' : '$delta',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: resolved.accentColor,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildVerticalDivider(ResolvedInputNumberStyle resolved) {
    return Container(
      width: 1,
      height: double.infinity,
      color: resolved.dividerColor,
    );
  }
}

class _PureStepperButton extends StatefulWidget {
  const _PureStepperButton({
    required this.child,
    required this.enabled,
    required this.onStep,
    required this.pressScale,
    this.width,
    this.height,
    this.enableLongPress = true,
    this.enableAcceleration = true,
    this.initialDelay = const Duration(milliseconds: 380),
    this.interval = const Duration(milliseconds: 100),
    this.backgroundColor = const Color(0x00000000),
    this.hoverColor = const Color(0x146366F1),
    this.splashColor = const Color(0x286366F1),
    this.semanticLabel,
  });

  final Widget child;
  final bool enabled;
  final VoidCallback onStep;
  final double pressScale;
  final double? width;
  final double? height;
  final bool enableLongPress;
  final bool enableAcceleration;
  final Duration initialDelay;
  final Duration interval;
  final Color backgroundColor;
  final Color hoverColor;
  final Color splashColor;
  final String? semanticLabel;

  @override
  State<_PureStepperButton> createState() => _PureStepperButtonState();
}

class _PureStepperButtonState extends State<_PureStepperButton> {
  Timer? _initialTimer;
  Timer? _repeatTimer;
  int _tickCount = 0;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void didUpdateWidget(covariant _PureStepperButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled) {
      _stopRepeating();
    }
  }

  @override
  void dispose() {
    _stopRepeating();
    super.dispose();
  }

  void _startRepeating() {
    if (!widget.enabled) {
      return;
    }
    _stopRepeating();
    setState(() => _isPressed = true);
    widget.onStep();

    if (!widget.enableLongPress) {
      return;
    }
    _initialTimer = Timer(widget.initialDelay, () {
      if (!mounted || !_isPressed || !widget.enabled) {
        return;
      }
      _scheduleNextTick();
    });
  }

  void _scheduleNextTick() {
    if (!mounted || !_isPressed || !widget.enabled) {
      return;
    }
    _tickCount++;
    widget.onStep();

    var currentIntervalMs = widget.interval.inMilliseconds;
    if (widget.enableAcceleration) {
      if (_tickCount > 25) {
        currentIntervalMs = (currentIntervalMs * 0.22).round();
      } else if (_tickCount > 15) {
        currentIntervalMs = (currentIntervalMs * 0.42).round();
      } else if (_tickCount > 6) {
        currentIntervalMs = (currentIntervalMs * 0.68).round();
      }
      if (currentIntervalMs < 18) {
        currentIntervalMs = 18;
      }
    }

    _repeatTimer = Timer(
      Duration(milliseconds: currentIntervalMs),
      _scheduleNextTick,
    );
  }

  void _stopRepeating() {
    _initialTimer?.cancel();
    _initialTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    _tickCount = 0;
    if (_isPressed && mounted) {
      setState(() => _isPressed = false);
    } else {
      _isPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = !widget.enabled
        ? widget.backgroundColor
        : (_isPressed
              ? widget.splashColor
              : (_isHovered ? widget.hoverColor : widget.backgroundColor));

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) {
          if (mounted) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          if (mounted) {
            setState(() => _isHovered = false);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.enabled ? (_) => _startRepeating() : null,
          onTapUp: widget.enabled ? (_) => _stopRepeating() : null,
          onTapCancel: widget.enabled ? _stopRepeating : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            width: widget.width,
            height: widget.height,
            color: effectiveBg,
            alignment: Alignment.center,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 95),
              scale: _isPressed && widget.enabled ? widget.pressScale : 1.0,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
