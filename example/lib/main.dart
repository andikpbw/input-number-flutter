import 'package:flutter/widgets.dart';
import 'package:flutter_input_number/flutter_input_number.dart';

void main() {
  runApp(const InputNumberStudioApp());
}

/// Interactive showcase app demonstrating all 5 animated layouts and 6 visual
/// presets of `flutter_input_number` using pure `package:flutter/widgets.dart`
/// (zero Material or Cupertino dependencies).
class InputNumberStudioApp extends StatelessWidget {
  /// Creates an [InputNumberStudioApp].
  const InputNumberStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Flutter Input Number Studio',
      color: const Color(0xFF6366F1),
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        );
      },
      home: const InputNumberStudioScreen(),
    );
  }
}

/// Primary interactive screen for the Flutter Input Number Studio.
class InputNumberStudioScreen extends StatefulWidget {
  /// Creates an [InputNumberStudioScreen].
  const InputNumberStudioScreen({super.key});

  @override
  State<InputNumberStudioScreen> createState() =>
      _InputNumberStudioScreenState();
}

class _InputNumberStudioScreenState extends State<InputNumberStudioScreen> {
  final FlutterInputNumberController _cartController =
      FlutterInputNumberController(value: 3, min: 0, max: 20, step: 1);
  final FlutterInputNumberController _priceController =
      FlutterInputNumberController(
        value: 1250.50,
        min: 0,
        max: 10000,
        step: 25,
        precision: 2,
      );
  final FlutterInputNumberController _scrubController =
      FlutterInputNumberController(
        value: 75,
        min: 0,
        max: 100,
        step: 5,
        precision: 0,
      );
  final FlutterInputNumberController _morphController =
      FlutterInputNumberController(value: 2, min: 0, max: 15, step: 1);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isDark = true;
  FlutterInputNumberLayout _activeLayout =
      FlutterInputNumberLayout.splitCapsule;

  @override
  void dispose() {
    _cartController.dispose();
    _priceController.dispose();
    _scrubController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  Brightness get _brightness => _isDark ? Brightness.dark : Brightness.light;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC);
    final cardBg = _isDark ? const Color(0xFF131B2E) : const Color(0xFFFFFFFF);
    final borderColor = _isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final textPrimary = _isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textSecondary = _isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return ColoredBox(
      color: bgColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top bar
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'flutter_input_number',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pure widgets.dart • 5 Layouts • Precision Math',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isDark = !_isDark),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const InputNumberVectorIcon(
                            InputNumberGlyph.sparkles,
                            size: 14,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isDark ? 'Dark Mode' : 'Light Mode',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Layout switcher chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final layout in FlutterInputNumberLayout.values)
                    GestureDetector(
                      onTap: () => setState(() => _activeLayout = layout),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _activeLayout == layout
                              ? const Color(0xFF6366F1)
                              : cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _activeLayout == layout
                                ? const Color(0xFF6366F1)
                                : borderColor,
                          ),
                        ),
                        child: Text(
                          layout.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _activeLayout == layout
                                ? const Color(0xFFFFFFFF)
                                : textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Card 1: Active Interactive Layout Playground
              _buildCard(
                cardBg: cardBg,
                borderColor: borderColor,
                title: '1. ${_activeLayout.displayName} Showcase',
                subtitle: _activeLayout.shortDescription,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                child: FlutterInputNumber(
                  controller: _cartController,
                  layout: _activeLayout,
                  size: FlutterInputNumberSize.large,
                  labelText: 'Order Quantity',
                  helperText: 'Tap +/- or hold for turbo repeat • Undo/Redo',
                  quickSteps: const <num>[-5, 5, 10],
                  style: FlutterInputNumberStyle.outlined(
                    brightness: _brightness,
                    accentColor: const Color(0xFF6366F1),
                    showProgressTrack: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Card 2: Morphing Quick-Commerce Pill
              _buildCard(
                cardBg: cardBg,
                borderColor: borderColor,
                title: '2. Morphing Quick-Commerce Pill',
                subtitle: 'Collapses to + Add at 0 and expands into a capsule',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Artisan Espresso Beans (250g)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 142,
                      child: FlutterInputNumber(
                        controller: _morphController,
                        layout: FlutterInputNumberLayout.morphingPill,
                        style: FlutterInputNumberStyle.capsule(
                          brightness: _brightness,
                          accentColor: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Card 3: Scrub Slider + Glassmorphism
              _buildCard(
                cardBg: cardBg,
                borderColor: borderColor,
                title: '3. Horizontal Scrub Slider (Drag Left/Right)',
                subtitle: 'Drag anywhere on the bar or tap to enter exact %',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                child: FlutterInputNumber(
                  controller: _scrubController,
                  layout: FlutterInputNumberLayout.scrubSlider,
                  format: const FlutterInputNumberFormat.percentage(),
                  style: FlutterInputNumberStyle.glass(
                    brightness: _brightness,
                    accentColor: const Color(0xFF00F5D4),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Card 4: Stacked Spinbox + Inline Math Expressions
              _buildCard(
                cardBg: cardBg,
                borderColor: borderColor,
                title: '4. Currency Spinbox + Inline Math (Try "1200 + 50")',
                subtitle: 'Supports USD/IDR/EUR formatting & 2.5k shorthand',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                child: FlutterInputNumber(
                  controller: _priceController,
                  layout: FlutterInputNumberLayout.stackedSpinbox,
                  format: const FlutterInputNumberFormat.currency(symbol: r'$'),
                  style: FlutterInputNumberStyle.filled(
                    brightness: _brightness,
                    accentColor: const Color(0xFF0EA5E9),
                    showProgressTrack: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Card 5: FormField Validation
              _buildCard(
                cardBg: cardBg,
                borderColor: borderColor,
                title: '5. FormField Validation & Damped Error Shake',
                subtitle: 'Minimum wholesale order validation (min 5 units)',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FlutterInputNumberFormField(
                        initialValue: 3,
                        min: 1,
                        max: 100,
                        step: 1,
                        precision: 0,
                        layout: FlutterInputNumberLayout.inlineCompact,
                        format: const FlutterInputNumberFormat.unit(
                          unit: 'boxes',
                        ),
                        style: FlutterInputNumberStyle.elevated(
                          brightness: _brightness,
                          accentColor: const Color(0xFF8B5CF6),
                        ),
                        validator: (val) {
                          if (val == null) {
                            return 'Please specify box count';
                          }
                          if (val < 5) {
                            return 'Minimum wholesale order is 5 boxes';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _formKey.currentState?.validate(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Validate Order Form',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color cardBg,
    required Color borderColor,
    required String title,
    required String subtitle,
    required Color textPrimary,
    required Color textSecondary,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(fontSize: 12, color: textSecondary)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
