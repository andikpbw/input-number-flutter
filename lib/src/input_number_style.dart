import 'package:flutter/widgets.dart';

import 'input_number_enums.dart';

/// Motion and micro-interaction configuration for [FlutterInputNumber].
@immutable
class FlutterInputNumberMotion {
  /// Creates a [FlutterInputNumberMotion] configuration.
  const FlutterInputNumberMotion({
    this.digitAnimation = InputNumberDigitAnimation.slide,
    this.digitAnimationDuration = const Duration(milliseconds: 180),
    this.containerAnimationDuration = const Duration(milliseconds: 180),
    this.errorShakeDuration = const Duration(milliseconds: 380),
    this.errorShakeAmplitude = 7.0,
    this.buttonPressScale = 0.91,
    this.longPressInitialDelay = const Duration(milliseconds: 380),
    this.longPressInterval = const Duration(milliseconds: 100),
    this.enableTurboAcceleration = true,
    this.enableHaptics = false,
    this.scrubPixelsPerStep = 14.0,
  }) : assert(
         buttonPressScale > 0 && buttonPressScale <= 1.0,
         'buttonPressScale must be in (0.0, 1.0].',
       ),
       assert(
         scrubPixelsPerStep > 0,
         'scrubPixelsPerStep must be greater than 0.',
       );

  /// Transition animation applied to the displayed number when stepping.
  final InputNumberDigitAnimation digitAnimation;

  /// Duration of the digit transition animation.
  final Duration digitAnimationDuration;

  /// Duration of container border, focus ring, and morph transitions.
  final Duration containerAnimationDuration;

  /// Duration of the horizontal damped error shake animation.
  final Duration errorShakeDuration;

  /// Peak horizontal offset in logical pixels during an error shake.
  final double errorShakeAmplitude;

  /// Scale factor applied to a stepper button while pressed.
  final double buttonPressScale;

  /// Initial delay before holding a stepper button starts auto-repeating.
  final Duration longPressInitialDelay;

  /// Base interval between continuous long-press steps.
  final Duration longPressInterval;

  /// Whether holding a stepper button progressively accelerates step speed.
  final bool enableTurboAcceleration;

  /// Whether stepping triggers platform selection haptic feedback.
  final bool enableHaptics;

  /// Horizontal drag distance in logical pixels required to trigger one step
  /// in `scrubSlider` mode (or when drag-to-scrub is enabled).
  final double scrubPixelsPerStep;

  /// Creates a copy of this [FlutterInputNumberMotion] with replaced fields.
  FlutterInputNumberMotion copyWith({
    InputNumberDigitAnimation? digitAnimation,
    Duration? digitAnimationDuration,
    Duration? containerAnimationDuration,
    Duration? errorShakeDuration,
    double? errorShakeAmplitude,
    double? buttonPressScale,
    Duration? longPressInitialDelay,
    Duration? longPressInterval,
    bool? enableTurboAcceleration,
    bool? enableHaptics,
    double? scrubPixelsPerStep,
  }) {
    return FlutterInputNumberMotion(
      digitAnimation: digitAnimation ?? this.digitAnimation,
      digitAnimationDuration:
          digitAnimationDuration ?? this.digitAnimationDuration,
      containerAnimationDuration:
          containerAnimationDuration ?? this.containerAnimationDuration,
      errorShakeDuration: errorShakeDuration ?? this.errorShakeDuration,
      errorShakeAmplitude: errorShakeAmplitude ?? this.errorShakeAmplitude,
      buttonPressScale: buttonPressScale ?? this.buttonPressScale,
      longPressInitialDelay:
          longPressInitialDelay ?? this.longPressInitialDelay,
      longPressInterval: longPressInterval ?? this.longPressInterval,
      enableTurboAcceleration:
          enableTurboAcceleration ?? this.enableTurboAcceleration,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      scrubPixelsPerStep: scrubPixelsPerStep ?? this.scrubPixelsPerStep,
    );
  }
}

/// Visual styling configuration for [FlutterInputNumber].
///
/// Built 100% on pure `package:flutter/widgets.dart` with 6 convenient factory
/// presets ([FlutterInputNumberStyle.outlined], [FlutterInputNumberStyle.filled],
/// [FlutterInputNumberStyle.capsule], [FlutterInputNumberStyle.glass],
/// [FlutterInputNumberStyle.underlined], [FlutterInputNumberStyle.elevated])
/// supporting both [Brightness.light] and [Brightness.dark].
@immutable
class FlutterInputNumberStyle {
  /// Creates a custom [FlutterInputNumberStyle].
  const FlutterInputNumberStyle({
    this.preset = FlutterInputNumberPreset.outlined,
    this.brightness = Brightness.dark,
    this.accentColor = const Color(0xFF6366F1),
    this.height,
    this.width,
    this.borderRadius,
    this.contentPadding,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.disabledBorderColor,
    this.borderWidth,
    this.focusedBorderWidth,
    this.dividerColor,
    this.showDividers,
    this.showProgressTrack = false,
    this.progressTrackColor,
    this.progressFillColor,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.helperStyle,
    this.errorStyle,
    this.textAlign = TextAlign.center,
    this.buttonWidth,
    this.buttonBackgroundColor,
    this.buttonHoverColor,
    this.buttonSplashColor,
    this.buttonIconColor,
    this.buttonDisabledIconColor,
    this.iconSize,
    this.incrementWidget,
    this.decrementWidget,
    this.morphTriggerLabel = '+ Add',
    this.glassBlurSigma = 12.0,
    this.shadows,
  });

  /// Crisp rounded outline style preset.
  factory FlutterInputNumberStyle.outlined({
    Brightness brightness = Brightness.dark,
    Color accentColor = const Color(0xFF6366F1),
    bool showProgressTrack = false,
  }) {
    return FlutterInputNumberStyle(
      preset: FlutterInputNumberPreset.outlined,
      brightness: brightness,
      accentColor: accentColor,
      showProgressTrack: showProgressTrack,
    );
  }

  /// Soft surface-tinted filled style preset.
  factory FlutterInputNumberStyle.filled({
    Brightness brightness = Brightness.dark,
    Color accentColor = const Color(0xFF0EA5E9),
    bool showProgressTrack = false,
  }) {
    return FlutterInputNumberStyle(
      preset: FlutterInputNumberPreset.filled,
      brightness: brightness,
      accentColor: accentColor,
      showProgressTrack: showProgressTrack,
    );
  }

  /// Stadium/pill capsule style preset with circular stepper buttons.
  factory FlutterInputNumberStyle.capsule({
    Brightness brightness = Brightness.dark,
    Color accentColor = const Color(0xFF10B981),
    bool showProgressTrack = false,
  }) {
    return FlutterInputNumberStyle(
      preset: FlutterInputNumberPreset.capsule,
      brightness: brightness,
      accentColor: accentColor,
      showDividers: false,
      showProgressTrack: showProgressTrack,
    );
  }

  /// Translucent frosted glassmorphic style preset.
  factory FlutterInputNumberStyle.glass({
    Brightness brightness = Brightness.dark,
    Color accentColor = const Color(0xFF00F5D4),
    double blurSigma = 14.0,
    bool showProgressTrack = true,
  }) {
    return FlutterInputNumberStyle(
      preset: FlutterInputNumberPreset.glass,
      brightness: brightness,
      accentColor: accentColor,
      glassBlurSigma: blurSigma,
      showProgressTrack: showProgressTrack,
    );
  }

  /// Minimalist bottom-border underlined style preset.
  factory FlutterInputNumberStyle.underlined({
    Brightness brightness = Brightness.dark,
    Color accentColor = const Color(0xFFF59E0B),
    bool showProgressTrack = false,
  }) {
    return FlutterInputNumberStyle(
      preset: FlutterInputNumberPreset.underlined,
      brightness: brightness,
      accentColor: accentColor,
      showDividers: false,
      showProgressTrack: showProgressTrack,
    );
  }

  /// Elevated card style preset with soft ambient depth shadow.
  factory FlutterInputNumberStyle.elevated({
    Brightness brightness = Brightness.dark,
    Color accentColor = const Color(0xFF8B5CF6),
    bool showProgressTrack = false,
  }) {
    return FlutterInputNumberStyle(
      preset: FlutterInputNumberPreset.elevated,
      brightness: brightness,
      accentColor: accentColor,
      showProgressTrack: showProgressTrack,
    );
  }

  /// Visual theme preset.
  final FlutterInputNumberPreset preset;

  /// Color palette brightness (`Brightness.dark` or `Brightness.light`).
  final Brightness brightness;

  /// Primary accent color used for focus rings, active steppers, and progress fill.
  final Color accentColor;

  /// Overall height of the control container.
  final double? height;

  /// Optional fixed width of the control container.
  final double? width;

  /// Corner radius of the outer container.
  final BorderRadius? borderRadius;

  /// Horizontal and vertical padding around the editable numeric field.
  final EdgeInsetsGeometry? contentPadding;

  /// Background fill color when enabled.
  final Color? backgroundColor;

  /// Background fill color when disabled.
  final Color? disabledBackgroundColor;

  /// Default border color when idle.
  final Color? borderColor;

  /// Border color when focused.
  final Color? focusedBorderColor;

  /// Border color when an error is active.
  final Color? errorBorderColor;

  /// Border color when disabled.
  final Color? disabledBorderColor;

  /// Default border stroke width.
  final double? borderWidth;

  /// Focused or error border stroke width.
  final double? focusedBorderWidth;

  /// Color of divider lines between stepper buttons and the input area.
  final Color? dividerColor;

  /// Whether to render dividers between stepper buttons and the text field.
  final bool? showDividers;

  /// Whether to display a live range progress bar along the bottom edge
  /// when `min` and `max` bounds are configured.
  final bool showProgressTrack;

  /// Background track color for the range progress bar.
  final Color? progressTrackColor;

  /// Active fill color for the range progress bar.
  final Color? progressFillColor;

  /// Text style for the numeric input value.
  final TextStyle? textStyle;

  /// Text style for placeholder hint text.
  final TextStyle? hintStyle;

  /// Text style for the optional top label.
  final TextStyle? labelStyle;

  /// Text style for the optional bottom helper text.
  final TextStyle? helperStyle;

  /// Text style for validation error text.
  final TextStyle? errorStyle;

  /// Horizontal alignment of the numeric text inside the field.
  final TextAlign textAlign;

  /// Width of side stepper buttons.
  final double? buttonWidth;

  /// Background color of stepper buttons when idle.
  final Color? buttonBackgroundColor;

  /// Background color of stepper buttons when hovered.
  final Color? buttonHoverColor;

  /// Background color of stepper buttons when actively pressed.
  final Color? buttonSplashColor;

  /// Color of stepper button icons when enabled.
  final Color? buttonIconColor;

  /// Color of stepper button icons when disabled or at a limit bound.
  final Color? buttonDisabledIconColor;

  /// Size of stepper button icons in logical pixels.
  final double? iconSize;

  /// Optional custom widget replacing the built-in increment vector glyph.
  final Widget? incrementWidget;

  /// Optional custom widget replacing the built-in decrement vector glyph.
  final Widget? decrementWidget;

  /// Label shown inside the collapsed pill when using
  /// [FlutterInputNumberLayout.morphingPill] at zero/min.
  final String morphTriggerLabel;

  /// Backdrop blur sigma when using [FlutterInputNumberPreset.glass].
  final double glassBlurSigma;

  /// Custom box shadows applied to the outer container.
  final List<BoxShadow>? shadows;

  /// Resolves all nullable properties into concrete values for rendering.
  ResolvedInputNumberStyle resolve({
    required FlutterInputNumberSize size,
    required FlutterInputNumberLayout layout,
  }) {
    final isDark = brightness == Brightness.dark;

    final defaultHeight = switch (size) {
      FlutterInputNumberSize.small => 36.0,
      FlutterInputNumberSize.medium => 44.0,
      FlutterInputNumberSize.large => 52.0,
    };

    final defaultFontSize = switch (size) {
      FlutterInputNumberSize.small => 13.5,
      FlutterInputNumberSize.medium => 15.5,
      FlutterInputNumberSize.large => 17.5,
    };

    final defaultIconSize = switch (size) {
      FlutterInputNumberSize.small => 14.0,
      FlutterInputNumberSize.medium => 16.5,
      FlutterInputNumberSize.large => 19.0,
    };

    final defaultButtonWidth = switch (size) {
      FlutterInputNumberSize.small =>
        layout == FlutterInputNumberLayout.stackedSpinbox ? 28.0 : 34.0,
      FlutterInputNumberSize.medium =>
        layout == FlutterInputNumberLayout.stackedSpinbox ? 32.0 : 42.0,
      FlutterInputNumberSize.large =>
        layout == FlutterInputNumberLayout.stackedSpinbox ? 38.0 : 48.0,
    };

    final resolvedHeight = height ?? defaultHeight;

    final defaultRadius =
        preset == FlutterInputNumberPreset.capsule ||
            layout == FlutterInputNumberLayout.morphingPill
        ? BorderRadius.circular(resolvedHeight / 2)
        : (preset == FlutterInputNumberPreset.underlined
              ? BorderRadius.zero
              : BorderRadius.circular(12.0));

    final defaultBg = switch (preset) {
      FlutterInputNumberPreset.outlined =>
        isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
      FlutterInputNumberPreset.filled =>
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      FlutterInputNumberPreset.capsule =>
        isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      FlutterInputNumberPreset.glass =>
        isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.62)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.78),
      FlutterInputNumberPreset.underlined => const Color(0x00000000),
      FlutterInputNumberPreset.elevated =>
        isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
    };

    final defaultDisabledBg = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.45)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.65);

    final defaultBorder = switch (preset) {
      FlutterInputNumberPreset.filled =>
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      FlutterInputNumberPreset.glass => accentColor.withValues(alpha: 0.35),
      FlutterInputNumberPreset.elevated =>
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      _ => isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
    };

    final defaultTextColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final defaultMutedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final defaultErrorColor = isDark
        ? const Color(0xFFF87171)
        : const Color(0xFFEF4444);

    final defaultAlign =
        (layout == FlutterInputNumberLayout.splitCapsule ||
            layout == FlutterInputNumberLayout.morphingPill ||
            layout == FlutterInputNumberLayout.scrubSlider)
        ? textAlign
        : (textAlign == TextAlign.center ? TextAlign.start : textAlign);

    final defaultShadows =
        shadows ??
        (preset == FlutterInputNumberPreset.elevated
            ? <BoxShadow>[
                BoxShadow(
                  color: isDark
                      ? const Color(0xFF000000).withValues(alpha: 0.36)
                      : accentColor.withValues(alpha: 0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : const <BoxShadow>[]);

    return ResolvedInputNumberStyle(
      preset: preset,
      brightness: brightness,
      accentColor: accentColor,
      height: resolvedHeight,
      width: width,
      borderRadius: borderRadius ?? defaultRadius,
      contentPadding:
          contentPadding ?? const EdgeInsets.symmetric(horizontal: 12.0),
      backgroundColor: backgroundColor ?? defaultBg,
      disabledBackgroundColor: disabledBackgroundColor ?? defaultDisabledBg,
      borderColor: borderColor ?? defaultBorder,
      focusedBorderColor: focusedBorderColor ?? accentColor,
      errorBorderColor: errorBorderColor ?? defaultErrorColor,
      disabledBorderColor:
          disabledBorderColor ?? defaultBorder.withValues(alpha: 0.4),
      borderWidth: borderWidth ?? 1.2,
      focusedBorderWidth: focusedBorderWidth ?? 1.8,
      dividerColor:
          dividerColor ??
          (isDark
              ? const Color(0xFF334155).withValues(alpha: 0.75)
              : const Color(0xFFE2E8F0)),
      showDividers:
          showDividers ??
          (preset != FlutterInputNumberPreset.underlined &&
              preset != FlutterInputNumberPreset.capsule &&
              layout != FlutterInputNumberLayout.scrubSlider),
      showProgressTrack:
          showProgressTrack || layout == FlutterInputNumberLayout.scrubSlider,
      progressTrackColor:
          progressTrackColor ??
          (isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFFE2E8F0).withValues(alpha: 0.8)),
      progressFillColor: progressFillColor ?? accentColor,
      textStyle:
          textStyle ??
          TextStyle(
            fontSize: defaultFontSize,
            fontWeight: FontWeight.w700,
            color: defaultTextColor,
            letterSpacing: -0.2,
          ),
      hintStyle:
          hintStyle ??
          TextStyle(
            fontSize: defaultFontSize,
            fontWeight: FontWeight.w400,
            color: defaultMutedColor.withValues(alpha: 0.75),
          ),
      labelStyle:
          labelStyle ??
          TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: defaultMutedColor,
          ),
      helperStyle:
          helperStyle ??
          TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: defaultMutedColor,
          ),
      errorStyle:
          errorStyle ??
          TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: defaultErrorColor,
          ),
      textAlign: defaultAlign,
      buttonWidth: buttonWidth ?? defaultButtonWidth,
      buttonBackgroundColor:
          buttonBackgroundColor ??
          (preset == FlutterInputNumberPreset.capsule
              ? accentColor.withValues(alpha: isDark ? 0.16 : 0.12)
              : const Color(0x00000000)),
      buttonHoverColor: buttonHoverColor ?? accentColor.withValues(alpha: 0.14),
      buttonSplashColor:
          buttonSplashColor ?? accentColor.withValues(alpha: 0.24),
      buttonIconColor: buttonIconColor ?? defaultTextColor,
      buttonDisabledIconColor:
          buttonDisabledIconColor ?? defaultMutedColor.withValues(alpha: 0.35),
      iconSize: iconSize ?? defaultIconSize,
      incrementWidget: incrementWidget,
      decrementWidget: decrementWidget,
      morphTriggerLabel: morphTriggerLabel,
      glassBlurSigma: glassBlurSigma,
      shadows: defaultShadows,
    );
  }

  /// Creates a copy of this [FlutterInputNumberStyle] with replaced properties.
  FlutterInputNumberStyle copyWith({
    FlutterInputNumberPreset? preset,
    Brightness? brightness,
    Color? accentColor,
    double? height,
    double? width,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    Color? disabledBorderColor,
    double? borderWidth,
    double? focusedBorderWidth,
    Color? dividerColor,
    bool? showDividers,
    bool? showProgressTrack,
    Color? progressTrackColor,
    Color? progressFillColor,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    TextStyle? labelStyle,
    TextStyle? helperStyle,
    TextStyle? errorStyle,
    TextAlign? textAlign,
    double? buttonWidth,
    Color? buttonBackgroundColor,
    Color? buttonHoverColor,
    Color? buttonSplashColor,
    Color? buttonIconColor,
    Color? buttonDisabledIconColor,
    double? iconSize,
    Widget? incrementWidget,
    Widget? decrementWidget,
    String? morphTriggerLabel,
    double? glassBlurSigma,
    List<BoxShadow>? shadows,
  }) {
    return FlutterInputNumberStyle(
      preset: preset ?? this.preset,
      brightness: brightness ?? this.brightness,
      accentColor: accentColor ?? this.accentColor,
      height: height ?? this.height,
      width: width ?? this.width,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      dividerColor: dividerColor ?? this.dividerColor,
      showDividers: showDividers ?? this.showDividers,
      showProgressTrack: showProgressTrack ?? this.showProgressTrack,
      progressTrackColor: progressTrackColor ?? this.progressTrackColor,
      progressFillColor: progressFillColor ?? this.progressFillColor,
      textStyle: textStyle ?? this.textStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      helperStyle: helperStyle ?? this.helperStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      textAlign: textAlign ?? this.textAlign,
      buttonWidth: buttonWidth ?? this.buttonWidth,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      buttonHoverColor: buttonHoverColor ?? this.buttonHoverColor,
      buttonSplashColor: buttonSplashColor ?? this.buttonSplashColor,
      buttonIconColor: buttonIconColor ?? this.buttonIconColor,
      buttonDisabledIconColor:
          buttonDisabledIconColor ?? this.buttonDisabledIconColor,
      iconSize: iconSize ?? this.iconSize,
      incrementWidget: incrementWidget ?? this.incrementWidget,
      decrementWidget: decrementWidget ?? this.decrementWidget,
      morphTriggerLabel: morphTriggerLabel ?? this.morphTriggerLabel,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      shadows: shadows ?? this.shadows,
    );
  }
}

/// Concrete resolved visual properties produced by [FlutterInputNumberStyle.resolve].
@immutable
class ResolvedInputNumberStyle {
  /// Creates a [ResolvedInputNumberStyle].
  const ResolvedInputNumberStyle({
    required this.preset,
    required this.brightness,
    required this.accentColor,
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.contentPadding,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.disabledBorderColor,
    required this.borderWidth,
    required this.focusedBorderWidth,
    required this.dividerColor,
    required this.showDividers,
    required this.showProgressTrack,
    required this.progressTrackColor,
    required this.progressFillColor,
    required this.textStyle,
    required this.hintStyle,
    required this.labelStyle,
    required this.helperStyle,
    required this.errorStyle,
    required this.textAlign,
    required this.buttonWidth,
    required this.buttonBackgroundColor,
    required this.buttonHoverColor,
    required this.buttonSplashColor,
    required this.buttonIconColor,
    required this.buttonDisabledIconColor,
    required this.iconSize,
    required this.incrementWidget,
    required this.decrementWidget,
    required this.morphTriggerLabel,
    required this.glassBlurSigma,
    required this.shadows,
  });

  /// Active visual theme preset.
  final FlutterInputNumberPreset preset;

  /// Active palette brightness.
  final Brightness brightness;

  /// Primary accent color.
  final Color accentColor;

  /// Concrete control height.
  final double height;

  /// Optional fixed control width.
  final double? width;

  /// Resolved corner radius.
  final BorderRadius borderRadius;

  /// Resolved padding around the editable numeric field.
  final EdgeInsetsGeometry contentPadding;

  /// Resolved background color when enabled.
  final Color backgroundColor;

  /// Resolved background color when disabled.
  final Color disabledBackgroundColor;

  /// Resolved idle border color.
  final Color borderColor;

  /// Resolved focused border color.
  final Color focusedBorderColor;

  /// Resolved error border color.
  final Color errorBorderColor;

  /// Resolved disabled border color.
  final Color disabledBorderColor;

  /// Resolved idle border width.
  final double borderWidth;

  /// Resolved focused border width.
  final double focusedBorderWidth;

  /// Resolved divider color.
  final Color dividerColor;

  /// Whether dividers are visible.
  final bool showDividers;

  /// Whether the range progress track is visible.
  final bool showProgressTrack;

  /// Resolved background color of the progress track.
  final Color progressTrackColor;

  /// Resolved active fill color of the progress track.
  final Color progressFillColor;

  /// Resolved text style for the number value.
  final TextStyle textStyle;

  /// Resolved text style for placeholder text.
  final TextStyle hintStyle;

  /// Resolved text style for top label text.
  final TextStyle labelStyle;

  /// Resolved text style for bottom helper text.
  final TextStyle helperStyle;

  /// Resolved text style for validation error text.
  final TextStyle errorStyle;

  /// Resolved horizontal alignment of the text.
  final TextAlign textAlign;

  /// Resolved width of stepper buttons.
  final double buttonWidth;

  /// Resolved idle background color of stepper buttons.
  final Color buttonBackgroundColor;

  /// Resolved hover color of stepper buttons.
  final Color buttonHoverColor;

  /// Resolved pressed color of stepper buttons.
  final Color buttonSplashColor;

  /// Resolved icon color for enabled stepper buttons.
  final Color buttonIconColor;

  /// Resolved icon color for disabled stepper buttons.
  final Color buttonDisabledIconColor;

  /// Resolved icon size in logical pixels.
  final double iconSize;

  /// Optional custom increment widget.
  final Widget? incrementWidget;

  /// Optional custom decrement widget.
  final Widget? decrementWidget;

  /// Label displayed inside the collapsed morphing pill trigger.
  final String morphTriggerLabel;

  /// Backdrop blur sigma for glass preset.
  final double glassBlurSigma;

  /// Resolved container box shadows.
  final List<BoxShadow> shadows;
}
