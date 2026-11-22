## 1.0.0

* Initial stable release of `flutter_input_number`.
* **Zero External Dependencies & Flutter 3.50+ Future-Proof**:
  * Built 100% on pure `package:flutter/widgets.dart` with zero deprecated `package:flutter/material.dart` or `package:flutter/cupertino.dart` imports.
  * Works out of the box with `package:material_ui/material_ui.dart`, `package:cupertino_ui/cupertino_ui.dart`, legacy Material, or custom `WidgetsApp` design systems across Android, iOS, Web (including WASM), macOS, Windows, and Linux.
* **5 Signature Interactive Layouts (`FlutterInputNumberLayout`)**:
  * `FlutterInputNumberLayout.splitCapsule` — Tactile split stepper (`[-] 24 [+]`) with spring press physics and rolling odometer digit animations.
  * `FlutterInputNumberLayout.stackedSpinbox` — Desktop & SaaS precision spinbox (`1,250.50 [▲/▼]`) with dual vertical micro-steppers.
  * `FlutterInputNumberLayout.inlineCompact` — Compact trailing stepper buttons (`42.0 kg [-][+]`) for dense forms and inspector panels.
  * `FlutterInputNumberLayout.scrubSlider` — Horizontal drag-to-scrub numeric slider (`[◄ ──●── ►] 75%`) with live fill-progress gauge track and direct tap-to-edit support.
  * `FlutterInputNumberLayout.morphingPill` — E-commerce & quick-commerce morphing pill that expands smoothly from an action pill (`+ Add`) into a full `[-] N [+]` capsule stepper when above zero.
* **6 Modern Visual Theme Presets (`FlutterInputNumberStyle`)**:
  * Built-in `outlined`, `filled`, `capsule`, `glass` (frosted glassmorphic), `underlined`, and `elevated` presets with full Light & Dark mode support.
* **IEEE-754 Precision Math & Inline Expression Evaluator (`PrecisionNumberMath`)**:
  * Eliminates floating-point drift (`0.1 + 0.2 == 0.3` guaranteed).
  * Supports shorthand suffix multipliers (`2.5k` -> `2500`, `1.2m` -> `1200000`) and inline arithmetic expressions (`120 + 35` -> `155`, `50 * 3` -> `150`) directly inside the input field.
* **Locale & Unit Formatting (`FlutterInputNumberFormat`)**:
  * Built-in presets for `standard`, `decimal`, `currency`, `european`, `idr`, `percentage`, `unit`, and `compact` formatting plus `NumericInputTextFormatter`.
* **Reactive Controller (`FlutterInputNumberController`) & `FlutterInputNumberFormField`**:
  * Full programmatic control with `increment()`, `decrement()`, `setValue()`, `setProgress()`, `snapToStep()`, `evaluateExpression()`, `undo()`, `redo()`, `triggerError()`, `reset()`, and `clear()`.
  * Native `FormField<num>` integration for validation, saving, and error shake feedback.
* **Built-in Vector Icons (`InputNumberVectorIcon`)**:
  * 16 resolution-independent custom-painted vector glyphs with zero icon-font dependencies.
