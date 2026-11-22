import 'dart:ui' show Brightness, PointerDeviceKind;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_input_number/flutter_input_number.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(420, 840)),
      child: Center(child: SizedBox(width: 340, child: child)),
    ),
  );
}

void main() {
  group('PrecisionNumberMath & Inline Expression Evaluator', () {
    test('eliminates IEEE 754 floating-point drift on decimal arithmetic', () {
      expect(PrecisionNumberMath.safeAdd(0.1, 0.2), 0.3);
      expect(PrecisionNumberMath.safeSubtract(0.3, 0.1), 0.2);
      expect(PrecisionNumberMath.safeAdd(0.7, 0.1), 0.8);
      expect(PrecisionNumberMath.safeSubtract(1.0, 0.9), 0.1);
      expect(PrecisionNumberMath.safeMultiply(1.25, 4), 5);
      expect(PrecisionNumberMath.safeDivide(10, 4, precision: 2), 2.5);
      expect(PrecisionNumberMath.safeDivide(10, 0), isNull);
    });

    test('rounds, clamps, snaps to step, and computes progress ratios', () {
      expect(PrecisionNumberMath.roundToPrecision(1.005, 2), 1.01);
      expect(PrecisionNumberMath.roundToPrecision(12.6, 0), 13);
      expect(
        PrecisionNumberMath.clampValue(150, min: 0, max: 100, precision: 0),
        100,
      );
      expect(
        PrecisionNumberMath.snapToStep(13, step: 5, base: 0, precision: 0),
        15,
      );
      expect(
        PrecisionNumberMath.progressRatio(25, min: 0, max: 100),
        closeTo(0.25, 1e-6),
      );
      expect(
        PrecisionNumberMath.valueFromProgress(
          0.75,
          min: 0,
          max: 100,
          step: 5,
          precision: 0,
        ),
        75,
      );
    });

    test('evaluates shorthand multipliers and inline math expressions', () {
      expect(PrecisionNumberMath.evaluateExpression('2.5k'), 2500);
      expect(PrecisionNumberMath.evaluateExpression('1.2m'), 1200000);
      expect(PrecisionNumberMath.evaluateExpression('120 + 35'), 155);
      expect(PrecisionNumberMath.evaluateExpression('100 - 15.5'), 84.5);
      expect(PrecisionNumberMath.evaluateExpression('50 * 3'), 150);
      expect(PrecisionNumberMath.evaluateExpression('240 / 4'), 60);
      expect(PrecisionNumberMath.evaluateExpression('(10 + 5) * 4'), 60);
      expect(PrecisionNumberMath.evaluateExpression('200 + 10%'), 220);
      expect(PrecisionNumberMath.evaluateExpression('invalid +'), isNull);
    });
  });

  group('FlutterInputNumberFormat & NumericInputTextFormatter', () {
    test('formats and parses all built-in presets accurately', () {
      const currency = FlutterInputNumberFormat.currency(symbol: r'$');
      expect(currency.format(1250.5, precision: 2), r'$1,250.50');
      expect(currency.parse(r'$1,250.50'), 1250.5);

      const idr = FlutterInputNumberFormat.idr();
      expect(idr.format(1250000, precision: 0), 'Rp 1.250.000');
      expect(idr.parse('Rp 1.250.000'), 1250000);

      const euro = FlutterInputNumberFormat.european(
        symbol: '€',
        padDecimals: true,
      );
      expect(euro.format(1250.5, precision: 2), '€1.250,50');
      expect(euro.parse('€1.250,50'), 1250.5);

      const percent = FlutterInputNumberFormat.percentage();
      expect(percent.format(75.5, precision: 1), '75.5%');
      expect(percent.parse('75.5%'), 75.5);

      const unit = FlutterInputNumberFormat.unit(unit: 'kg');
      expect(unit.format(1250, precision: 0), '1,250 kg');
      expect(unit.parse('1,250 kg'), 1250);

      const compact = FlutterInputNumberFormat.compact(prefix: r'$');
      expect(compact.format(1500), r'$1.5K');
      expect(compact.format(2400000), r'$2.4M');
      expect(compact.parse('2.5k'), 2500);
      expect(compact.parse('100 + 25'), 125);
    });

    test('NumericInputTextFormatter filters invalid characters', () {
      const formatter = NumericInputTextFormatter(
        allowDecimal: true,
        allowNegative: true,
        maxDecimalPlaces: 2,
      );
      const oldVal = TextEditingValue(text: '12.34');
      expect(
        formatter
            .formatEditUpdate(oldVal, const TextEditingValue(text: '12.345'))
            .text,
        '12.34',
      );
      expect(
        formatter
            .formatEditUpdate(oldVal, const TextEditingValue(text: '12.3'))
            .text,
        '12.3',
      );
    });
  });

  group('FlutterInputNumberController', () {
    test(
      'supports step, progress, expressions, undo/redo, and error state',
      () {
        final controller = FlutterInputNumberController(
          value: 10,
          min: 0,
          max: 100,
          step: 5,
        );
        addTearDown(controller.dispose);

        expect(controller.value, 10);
        expect(controller.progress, closeTo(0.10, 1e-6));

        controller.increment();
        expect(controller.value, 15);
        expect(controller.lastStepDirection, 1);

        controller.decrement(10);
        expect(controller.value, 5);
        expect(controller.lastStepDirection, -1);

        controller.setProgress(0.5);
        expect(controller.value, 50);

        controller.evaluateAndSet('50 + 25');
        expect(controller.value, 75);

        expect(controller.canUndo, isTrue);
        controller.undo();
        expect(controller.value, 50);

        expect(controller.canRedo, isTrue);
        controller.redo();
        expect(controller.value, 75);

        controller.triggerError('Exceeds quota');
        expect(controller.errorMessage, 'Exceeds quota');
        expect(controller.errorShakeToken, 1);

        controller.clearError();
        expect(controller.errorMessage, isNull);

        controller.reset();
        expect(controller.value, 10);

        controller.clear();
        expect(controller.value, isNull);
      },
    );
  });

  group('FlutterInputNumber Widget & All 5 Layouts', () {
    testWidgets('renders all 5 layouts and 6 style presets without errors', (
      tester,
    ) async {
      final presets = <FlutterInputNumberStyle>[
        FlutterInputNumberStyle.outlined(),
        FlutterInputNumberStyle.filled(),
        FlutterInputNumberStyle.capsule(),
        FlutterInputNumberStyle.glass(),
        FlutterInputNumberStyle.underlined(),
        FlutterInputNumberStyle.elevated(brightness: Brightness.light),
      ];

      for (final layout in FlutterInputNumberLayout.values) {
        for (final style in presets) {
          await tester.pumpWidget(
            _wrap(
              FlutterInputNumber(
                initialValue: 12,
                min: 0,
                max: 100,
                step: 2,
                layout: layout,
                style: style,
                labelText: layout.displayName,
                helperText: layout.shortDescription,
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 220));
          expect(find.byType(FlutterInputNumber), findsOneWidget);
        }
      }
    });

    testWidgets('increments, decrements, and triggers quick-step chips', (
      tester,
    ) async {
      final controller = FlutterInputNumberController(
        value: 10,
        min: 0,
        max: 50,
        step: 2,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          FlutterInputNumber(
            controller: controller,
            quickSteps: const <num>[-5, 5, 10],
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Increment'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.value, 12);

      await tester.tap(find.bySemanticsLabel('Decrement'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.value, 10);

      await tester.tap(find.text('+10'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.value, 20);

      await tester.tap(find.text('-5'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.value, 15);
    });

    testWidgets('morphingPill expands from collapsed trigger when tapped', (
      tester,
    ) async {
      final controller = FlutterInputNumberController(
        value: 0,
        min: 0,
        max: 10,
        step: 1,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          FlutterInputNumber(
            controller: controller,
            layout: FlutterInputNumberLayout.morphingPill,
            style: FlutterInputNumberStyle.capsule(),
          ),
        ),
      );

      expect(find.text('Add'), findsOneWidget);
      await tester.tap(find.text('Add'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(controller.value, 1);

      await tester.tap(find.bySemanticsLabel('Decrement'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(controller.value, 0);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('scrubSlider adjusts value on horizontal drag', (tester) async {
      final controller = FlutterInputNumberController(
        value: 50,
        min: 0,
        max: 100,
        step: 5,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          FlutterInputNumber(
            controller: controller,
            layout: FlutterInputNumberLayout.scrubSlider,
            motion: const FlutterInputNumberMotion(scrubPixelsPerStep: 10),
          ),
        ),
      );

      await tester.drag(find.byType(FlutterInputNumber), const Offset(35, 0));
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.value, greaterThan(50));
    });

    testWidgets(
      'evaluates inline math expression on submit and supports keyboard/wheel',
      (tester) async {
        final controller = FlutterInputNumberController(
          value: 10,
          min: 0,
          max: 1000,
          step: 5,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _wrap(FlutterInputNumber(controller: controller, largeStep: 50)),
        );

        await tester.enterText(find.byType(EditableText), '100 + 45');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump(const Duration(milliseconds: 200));
        expect(controller.value, 145);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(controller.value, 150);

        await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
        await tester.pump();
        expect(controller.value, 200);

        final center = tester.getCenter(find.byType(FlutterInputNumber));
        final pointer = TestPointer(1, PointerDeviceKind.mouse);
        pointer.hover(center);
        await tester.sendEventToBinding(pointer.scroll(const Offset(0, -20)));
        await tester.pump();
        expect(controller.value, 205);
      },
    );
  });

  group('FlutterInputNumberFormField & InputNumberVectorIcon', () {
    testWidgets('validates, saves, and resets inside Form', (tester) async {
      final formKey = GlobalKey<FormState>();
      num? savedValue;

      await tester.pumpWidget(
        _wrap(
          Form(
            key: formKey,
            child: FlutterInputNumberFormField(
              initialValue: 3,
              min: 1,
              max: 50,
              validator: (val) =>
                  (val == null || val < 5) ? 'Min 5 units required' : null,
              onSaved: (val) => savedValue = val,
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Min 5 units required'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Increment'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Increment'));
      await tester.pump();

      expect(formKey.currentState!.validate(), isTrue);
      formKey.currentState!.save();
      expect(savedValue, 5);

      formKey.currentState!.reset();
      await tester.pump();
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('renders all 16 InputNumberGlyph vector shapes cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Wrap(
            children: <Widget>[
              for (final glyph in InputNumberGlyph.values)
                InputNumberVectorIcon(
                  glyph,
                  size: 18,
                  semanticLabel: glyph.name,
                ),
            ],
          ),
        ),
      );

      expect(
        find.byType(InputNumberVectorIcon),
        findsNWidgets(InputNumberGlyph.values.length),
      );
    });
  });
}
