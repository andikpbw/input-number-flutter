/// Signature layouts for [FlutterInputNumber] controls.
enum FlutterInputNumberLayout {
  /// Tactile split stepper with decrement on the left, value in the center,
  /// and increment on the right (`[-] 24 [+]`).
  splitCapsule,

  /// Desktop and SaaS spinbox with the numeric field on the left and
  /// vertically stacked increment/decrement micro-buttons on the right
  /// (`1,250.50 [▲/▼]`).
  stackedSpinbox,

  /// Compact side-by-side trailing stepper buttons on the right edge
  /// (`42.0 kg [-][+]`).
  inlineCompact,

  /// Interactive horizontal drag-to-scrub numeric slider with a live
  /// fill-progress gauge bar and tap-to-type editing (`[◄ ──●── ►] 75%`).
  scrubSlider,

  /// Quick-commerce morphing pill that displays a compact action trigger
  /// (`+ Add`) when at or below minimum/zero and smoothly expands into a
  /// full `[-] N [+]` capsule stepper when active.
  morphingPill,
}

/// Extension metadata for [FlutterInputNumberLayout].
extension FlutterInputNumberLayoutX on FlutterInputNumberLayout {
  /// Human-readable display title for this layout.
  String get displayName {
    switch (this) {
      case FlutterInputNumberLayout.splitCapsule:
        return 'Split Capsule';
      case FlutterInputNumberLayout.stackedSpinbox:
        return 'Stacked Spinbox';
      case FlutterInputNumberLayout.inlineCompact:
        return 'Inline Compact';
      case FlutterInputNumberLayout.scrubSlider:
        return 'Scrub Slider';
      case FlutterInputNumberLayout.morphingPill:
        return 'Morphing Pill';
    }
  }

  /// Short description of the interaction model for this layout.
  String get shortDescription {
    switch (this) {
      case FlutterInputNumberLayout.splitCapsule:
        return 'Balanced left/right steppers + rolling digits';
      case FlutterInputNumberLayout.stackedSpinbox:
        return 'Desktop dual vertical spinbox + inline math';
      case FlutterInputNumberLayout.inlineCompact:
        return 'Trailing compact steppers for dense forms';
      case FlutterInputNumberLayout.scrubSlider:
        return 'Drag left/right to scrub + live gauge track';
      case FlutterInputNumberLayout.morphingPill:
        return 'Morphs from + Add chip into full stepper capsule';
    }
  }
}

/// Visual theme presets for [FlutterInputNumberStyle].
enum FlutterInputNumberPreset {
  /// Crisp rounded outline with subtle focus halo.
  outlined,

  /// Soft surface-tinted container with high contrast buttons.
  filled,

  /// Stadium/pill shaped container with circular stepper triggers.
  capsule,

  /// Translucent frosted glassmorphic surface with specular border.
  glass,

  /// Minimalist bottom-accent border for editorial and table layouts.
  underlined,

  /// Floating card container with soft ambient shadow depth.
  elevated,
}

/// Preset size dimensions for [FlutterInputNumber].
enum FlutterInputNumberSize {
  /// Compact height (`36.0` logical pixels by default).
  small,

  /// Standard ergonomic height (`44.0` logical pixels by default).
  medium,

  /// Prominent touch-friendly height (`52.0` logical pixels by default).
  large,
}

/// Digit transition animation styles when stepping between numeric values.
enum InputNumberDigitAnimation {
  /// Vertical odometer-style roll (slides up when incrementing, down when decrementing).
  slide,

  /// Subtle spring scale pulse on value change.
  scale,

  /// Smooth cross-fade between values.
  fade,

  /// Instant value update with no transition animation.
  none,
}

/// Built-in pure-Flutter vector icon glyphs for [InputNumberVectorIcon].
enum InputNumberGlyph {
  /// Plus (`+`) glyph.
  plus,

  /// Minus (`-`) glyph.
  minus,

  /// Upward chevron (`▲`) glyph.
  chevronUp,

  /// Downward chevron (`▼`) glyph.
  chevronDown,

  /// Leftward chevron (`◄`) glyph.
  chevronLeft,

  /// Rightward chevron (`►`) glyph.
  chevronRight,

  /// Close / clear (`×`) glyph.
  close,

  /// Checkmark (`✓`) glyph.
  check,

  /// Refresh / reset circular arrow glyph.
  refresh,

  /// AI / magic sparkles glyph.
  sparkles,

  /// Currency dollar/coin glyph.
  currency,

  /// Percentage (`%`) glyph.
  percent,

  /// Scrub / sliders adjustment glyph.
  sliders,

  /// Lock / read-only padlock glyph.
  lock,

  /// Warning / validation alert triangle glyph.
  warning,

  /// Turbo / lightning bolt glyph.
  bolt,
}
