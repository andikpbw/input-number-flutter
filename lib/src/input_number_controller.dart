import 'package:flutter/foundation.dart';

import 'precision_number_math.dart';

/// Reactive controller for [FlutterInputNumber] that manages numeric value,
/// bounds, step increment, decimal precision, undo/redo history, and
/// validation error shake state.
///
/// Extends [ValueNotifier] so it can be observed directly with
/// `ValueListenableBuilder<num?>` or `ListenableBuilder`.
class FlutterInputNumberController extends ValueNotifier<num?> {
  /// Creates a [FlutterInputNumberController].
  FlutterInputNumberController({
    num? value,
    num? min,
    num? max,
    num step = 1,
    int? precision,
    this.maxHistoryLength = 32,
  }) : assert(step > 0, 'step must be greater than 0.'),
       assert(
         min == null || max == null || min <= max,
         'min must be less than or equal to max.',
       ),
       assert(
         precision == null || (precision >= 0 && precision <= 12),
         'precision must be between 0 and 12.',
       ),
       _initialValue = value,
       _min = min,
       _max = max,
       _step = step,
       _precision = precision,
       super(
         value != null
             ? PrecisionNumberMath.clampValue(
                 value,
                 min: min,
                 max: max,
                 precision: precision,
               )
             : null,
       ) {
    _undoStack.add(super.value);
  }

  final num? _initialValue;
  num? _min;
  num? _max;
  num _step;
  int? _precision;
  String? _errorMessage;
  int _errorShakeToken = 0;
  int _lastStepDirection = 0;

  /// Maximum number of value snapshots kept in the undo stack.
  final int maxHistoryLength;

  final List<num?> _undoStack = <num?>[];
  final List<num?> _redoStack = <num?>[];

  /// Initial numeric value provided when this controller was created.
  num? get initialValue => _initialValue;

  /// Minimum allowed numeric value, or `null` if unbounded below.
  num? get min => _min;

  /// Maximum allowed numeric value, or `null` if unbounded above.
  num? get max => _max;

  /// Default increment and decrement step delta.
  num get step => _step;

  /// Decimal precision to round values to, or `null` for automatic precision.
  int? get precision => _precision;

  /// Active validation or boundary error message, or `null` when valid.
  String? get errorMessage => _errorMessage;

  /// Monotonically increasing counter incremented each time [triggerError] is called.
  int get errorShakeToken => _errorShakeToken;

  /// Direction of the most recent step (`1` for increment, `-1` for decrement, `0` otherwise).
  int get lastStepDirection => _lastStepDirection;

  /// Current [value] rounded to an [int], or `null` if empty.
  int? get intValue => value?.round();

  /// Current [value] converted to a [double], or `null` if empty.
  double? get doubleValue => value?.toDouble();

  /// Whether a non-null numeric value is currently held.
  bool get hasValue => value != null;

  /// Normalized progress ratio (`0.0` to `1.0`) between [min] and [max].
  double get progress =>
      PrecisionNumberMath.progressRatio(value, min: _min, max: _max);

  /// Whether the current [value] is at or below [min].
  bool get isAtMin => _min != null && value != null && value! <= _min!;

  /// Whether the current [value] is at or above [max].
  bool get isAtMax => _max != null && value != null && value! >= _max!;

  /// Whether the value can be incremented without exceeding [max].
  bool get canIncrement {
    if (_max == null) {
      return true;
    }
    final current = value;
    if (current == null) {
      return true;
    }
    return current < _max!;
  }

  /// Whether the value can be decremented without falling below [min].
  bool get canDecrement {
    if (_min == null) {
      return true;
    }
    final current = value;
    if (current == null) {
      return true;
    }
    return current > _min!;
  }

  /// Whether an earlier value exists in the undo history stack.
  bool get canUndo => _undoStack.length > 1;

  /// Whether a value exists in the redo history stack.
  bool get canRedo => _redoStack.isNotEmpty;

  @override
  set value(num? newValue) {
    setValue(newValue);
  }

  /// Sets the current numeric [newValue].
  ///
  /// When [clamp] is `true` (the default), [newValue] is clamped to `[min, max]`
  /// and rounded to [precision].
  void setValue(num? newValue, {bool clamp = true, bool recordHistory = true}) {
    if (newValue == null) {
      _lastStepDirection = 0;
      _commitValue(null, recordHistory: recordHistory);
      return;
    }
    if (newValue.isNaN || newValue.isInfinite) {
      return;
    }
    final resolved = clamp
        ? PrecisionNumberMath.clampValue(
            newValue,
            min: _min,
            max: _max,
            precision: _precision,
          )
        : (_precision != null
              ? PrecisionNumberMath.roundToPrecision(newValue, _precision)
              : newValue);
    final current = super.value;
    if (current != null) {
      _lastStepDirection = resolved > current
          ? 1
          : (resolved < current ? -1 : 0);
    } else {
      _lastStepDirection = 1;
    }
    _commitValue(resolved, recordHistory: recordHistory);
  }

  /// Increments the current value by [customStep] (or [step] if omitted).
  ///
  /// Returns the updated numeric value.
  num increment([num? customStep]) {
    final delta = customStep ?? _step;
    assert(delta > 0, 'increment step must be greater than 0.');
    final current = value;
    final num next;
    if (current == null) {
      next = PrecisionNumberMath.clampValue(
        _defaultBaseline(),
        min: _min,
        max: _max,
        precision: _precision,
      );
    } else {
      final sum = PrecisionNumberMath.safeAdd(
        current,
        delta,
        precision: _precision,
      );
      next = PrecisionNumberMath.clampValue(
        sum,
        min: _min,
        max: _max,
        precision: _precision,
      );
    }
    _lastStepDirection = 1;
    _commitValue(next, recordHistory: true);
    return next;
  }

  /// Decrements the current value by [customStep] (or [step] if omitted).
  ///
  /// Returns the updated numeric value.
  num decrement([num? customStep]) {
    final delta = customStep ?? _step;
    assert(delta > 0, 'decrement step must be greater than 0.');
    final current = value;
    final num next;
    if (current == null) {
      next = PrecisionNumberMath.clampValue(
        _defaultBaseline(),
        min: _min,
        max: _max,
        precision: _precision,
      );
    } else {
      final diff = PrecisionNumberMath.safeSubtract(
        current,
        delta,
        precision: _precision,
      );
      next = PrecisionNumberMath.clampValue(
        diff,
        min: _min,
        max: _max,
        precision: _precision,
      );
    }
    _lastStepDirection = -1;
    _commitValue(next, recordHistory: true);
    return next;
  }

  /// Sets [value] from a normalized progress [ratio] (`0.0` to `1.0`)
  /// between [min] and [max].
  ///
  /// Does nothing if [min] or [max] is `null`.
  num? setProgress(double ratio, {bool snap = true}) {
    if (_min == null || _max == null || _max! <= _min!) {
      return value;
    }
    final next = PrecisionNumberMath.valueFromProgress(
      ratio,
      min: _min!,
      max: _max!,
      step: snap ? _step : null,
      precision: _precision,
    );
    setValue(next);
    return value;
  }

  /// Snaps the current [value] to the nearest valid multiple of [step].
  num? snapToStep() {
    final current = value;
    if (current == null) {
      return null;
    }
    final snapped = PrecisionNumberMath.snapToStep(
      current,
      step: _step,
      base: _min ?? 0,
      precision: _precision,
    );
    setValue(snapped);
    return value;
  }

  /// Evaluates a math expression or shorthand string (such as `'120 + 35'`
  /// or `'2.5k'`) and updates [value] if valid.
  ///
  /// Returns the evaluated value, or `null` if parsing failed.
  num? evaluateAndSet(String expression, {bool clamp = true}) {
    final evaluated = PrecisionNumberMath.evaluateExpression(
      expression,
      precision: _precision,
    );
    if (evaluated == null) {
      return null;
    }
    setValue(evaluated, clamp: clamp);
    return value;
  }

  /// Reverts [value] to the previous snapshot in history.
  num? undo() {
    if (!canUndo) {
      return value;
    }
    final current = _undoStack.removeLast();
    _redoStack.add(current);
    final previous = _undoStack.last;
    _lastStepDirection = -1;
    super.value = previous;
    return previous;
  }

  /// Re-applies the most recently undone value from the redo stack.
  num? redo() {
    if (!canRedo) {
      return value;
    }
    final next = _redoStack.removeLast();
    _undoStack.add(next);
    _lastStepDirection = 1;
    super.value = next;
    return next;
  }

  /// Triggers an error message and increments [errorShakeToken] to play the
  /// damped horizontal error shake animation on attached widgets.
  void triggerError([String? message]) {
    _errorMessage = message;
    _errorShakeToken++;
    notifyListeners();
  }

  /// Clears any active [errorMessage] set by [triggerError].
  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// Updates the constraints ([min], [max], [step], [precision]) on this
  /// controller and optionally clamps the current [value] to the new bounds.
  void updateBounds({
    num? min,
    bool clearMin = false,
    num? max,
    bool clearMax = false,
    num? step,
    int? precision,
    bool clearPrecision = false,
    bool clampCurrentValue = true,
  }) {
    final nextMin = clearMin ? null : (min ?? _min);
    final nextMax = clearMax ? null : (max ?? _max);
    final nextStep = step ?? _step;
    final nextPrecision = clearPrecision ? null : (precision ?? _precision);

    assert(nextStep > 0, 'step must be greater than 0.');
    assert(
      nextMin == null || nextMax == null || nextMin <= nextMax,
      'min must be less than or equal to max.',
    );
    assert(
      nextPrecision == null || (nextPrecision >= 0 && nextPrecision <= 12),
      'precision must be between 0 and 12.',
    );

    final changed =
        _min != nextMin ||
        _max != nextMax ||
        _step != nextStep ||
        _precision != nextPrecision;

    _min = nextMin;
    _max = nextMax;
    _step = nextStep;
    _precision = nextPrecision;

    if (clampCurrentValue && value != null) {
      final clamped = PrecisionNumberMath.clampValue(
        value!,
        min: _min,
        max: _max,
        precision: _precision,
      );
      if (clamped != value) {
        _commitValue(clamped, recordHistory: false);
        return;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Resets [value] back to [initialValue] and clears any error message.
  void reset() {
    _errorMessage = null;
    setValue(_initialValue);
  }

  /// Clears [value] to `null`.
  void clear() {
    _lastStepDirection = 0;
    _commitValue(null, recordHistory: true);
  }

  void _commitValue(num? next, {required bool recordHistory}) {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    if (recordHistory && (_undoStack.isEmpty || _undoStack.last != next)) {
      _undoStack.add(next);
      if (_undoStack.length > maxHistoryLength) {
        _undoStack.removeAt(0);
      }
      _redoStack.clear();
    }
    if (super.value == next) {
      notifyListeners();
    } else {
      super.value = next;
    }
  }

  num _defaultBaseline() {
    if (_min != null && 0 < _min!) {
      return _min!;
    }
    if (_max != null && 0 > _max!) {
      return _max!;
    }
    return 0;
  }
}
