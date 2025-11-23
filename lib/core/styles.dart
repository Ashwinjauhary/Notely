import 'package:flutter/material.dart';

class AppStyles {
  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius circularRadius = BorderRadius.all(Radius.circular(50));

  // Padding
  static const EdgeInsets xsPadding = EdgeInsets.all(xs);
  static const EdgeInsets smPadding = EdgeInsets.all(sm);
  static const EdgeInsets mdPadding = EdgeInsets.all(md);
  static const EdgeInsets lgPadding = EdgeInsets.all(lg);
  static const EdgeInsets xlPadding = EdgeInsets.all(xl);

  static const EdgeInsets smHorizontalPadding = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets mdHorizontalPadding = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets lgHorizontalPadding = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets smVerticalPadding = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets mdVerticalPadding = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets lgVerticalPadding = EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  // Margins
  static const EdgeInsets smMargin = EdgeInsets.all(sm);
  static const EdgeInsets mdMargin = EdgeInsets.all(md);
  static const EdgeInsets lgMargin = EdgeInsets.all(lg);

  // Shadows
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> heavyShadow = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Animation Durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceInOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.smooth;

  // Card Styles
  static BoxDecoration cardDecoration(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: color ?? theme.cardColor,
      borderRadius: lgRadius,
      boxShadow: theme.brightness == Brightness.dark ? mediumShadow : lightShadow,
    );
  }

  static BoxDecoration noteCardDecoration(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: color ?? theme.cardColor,
      borderRadius: mdRadius,
      boxShadow: theme.brightness == Brightness.dark ? [] : lightShadow,
      border: Border.all(
        color: theme.dividerColor.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 2,
      padding: mdHorizontalPadding,
      shape: RoundedRectangleBorder(borderRadius: mdRadius),
    );
  }

  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      side: BorderSide(color: theme.colorScheme.primary),
      padding: mdHorizontalPadding,
      shape: RoundedRectangleBorder(borderRadius: mdRadius),
    );
  }

  static ButtonStyle textButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      padding: smHorizontalPadding,
      shape: RoundedRectangleBorder(borderRadius: smRadius),
    );
  }

  // Input Decoration
  static InputDecoration searchInputDecoration(BuildContext context, {String? hint}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint ?? 'Search notes...',
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
      ),
      prefixIcon: Icon(Icons.search, color: theme.iconTheme.color?.withOpacity(0.6)),
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: mdRadius,
        borderSide: BorderSide.none,
      ),
      contentPadding: mdHorizontalPadding,
    );
  }

  static InputDecoration textInputDecoration(BuildContext context, {String? hint, String? label}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
      ),
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: mdRadius,
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: mdRadius,
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: mdRadius,
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      contentPadding: mdHorizontalPadding,
    );
  }
}
