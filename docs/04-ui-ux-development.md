Perfect başkan! 🔥 **Dördüncü döküman:**

## 🎯 **04. UI/UX Development Rules**

**"Create new file"** → **Dosya yolu:** `docs/04-ui-ux-development.md`

**İçerik:**

# 🎨 UI/UX Development Rules

## Overview

User interface and experience are critical for Flutter applications. This guide establishes comprehensive standards for creating beautiful, accessible, and performant UIs using **Material Design 3**, responsive design principles, and custom component patterns.

## Material Design 3 Implementation

### Theme Configuration Standards

```dart
// core/theme/app_theme.dart
class AppTheme {
  // Color seeds for dynamic theming
  static const Color _primarySeed = Color(0xFF6750A4);
  static const Color _secondarySeed = Color(0xFF625B71);
  static const Color _tertiarySeed = Color(0xFF7D5260);

  // Custom color palette
  static const ColorPalette lightPalette = ColorPalette(
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF21005D),
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1D192B),
    // ... more colors
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cardTheme,
    appBarTheme: _appBarTheme,
    bottomNavigationBarTheme: _bottomNavigationBarTheme,
    navigationBarTheme: _navigationBarTheme,
    dialogTheme: _dialogTheme,
    snackBarTheme: _snackBarTheme,
    chipTheme: _chipTheme,
    dividerTheme: _dividerTheme,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme,
    // ... same component themes
  );

  // Typography scale following Material Design 3
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );

  // Button themes
  static ElevatedButtonThemeData get _elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 1,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: const Size(64, 40),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
  );

  static OutlinedButtonThemeData get _outlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: const Size(64, 40),
      side: const BorderSide(width: 1),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
  );

  static FilledButtonThemeData get _filledButtonTheme => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: const Size(64, 40),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
  );

  // Input decoration theme
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    helperStyle: const TextStyle(fontSize: 12),
    errorStyle: const TextStyle(fontSize: 12),
  );

  // Card theme
  static CardTheme get _cardTheme => CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
  );

  // AppBar theme
  static AppBarTheme get _appBarTheme => const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 3,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
  );
}
```

### Color System Standards

```dart
// core/theme/app_colors.dart
class AppColors {
  // Semantic colors for consistent usage
  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  static const Color warning = Color(0xFFFF9800);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarningContainer = Color(0xFFE65100);

  static const Color info = Color(0xFF2196F3);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFBBDEFB);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // Brand colors
  static const Color brandPrimary = Color(0xFF6750A4);
  static const Color brandSecondary = Color(0xFF625B71);
  static const Color brandTertiary = Color(0xFF7D5260);

  // Neutral colors
  static const Color neutral10 = Color(0xFF1C1B1F);
  static const Color neutral20 = Color(0xFF313033);
  static const Color neutral30 = Color(0xFF484649);
  static const Color neutral40 = Color(0xFF605D62);
  static const Color neutral50 = Color(0xFF787579);
  static const Color neutral60 = Color(0xFF938F94);
  static const Color neutral70 = Color(0xFFAEA9AF);
  static const Color neutral80 = Color(0xFFCAC4CB);
  static const Color neutral90 = Color(0xFFE6E0E7);
  static const Color neutral95 = Color(0xFFF3EDF4);
  static const Color neutral99 = Color(0xFFFFFBFE);
}
```

## Responsive Design System

### Breakpoint Standards

```dart
// core/responsive/breakpoints.dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double largeDesktop = 1920;

  // Responsive spacing scale
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;
  static const double space3xl = 64;

  // Grid system
  static const int mobileColumns = 4;
  static const int tabletColumns = 8;
  static const int desktopColumns = 12;
}

// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.breakpoints,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Breakpoints? breakpoints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= (breakpoints?.largeDesktop ?? Breakpoints.largeDesktop)) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        } else if (width >= (breakpoints?.desktop ?? Breakpoints.desktop)) {
          return desktop ?? tablet ?? mobile;
        } else if (width >= (breakpoints?.tablet ?? Breakpoints.tablet)) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Screen size extensions
extension ScreenSize on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.desktop;
  bool get isDesktop => screenWidth >= Breakpoints.desktop && screenWidth < Breakpoints.largeDesktop;
  bool get isLargeDesktop => screenWidth >= Breakpoints.largeDesktop;

  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  // Responsive spacing
  double get spacingSm => isMobile ? Breakpoints.spaceSm : Breakpoints.spaceMd;
  double get spacingMd => isMobile ? Breakpoints.spaceMd : Breakpoints.spaceLg;
  double get spacingLg => isMobile ? Breakpoints.spaceLg : Breakpoints.spaceXl;

  // Responsive text scaling
  double get textScaleFactor => MediaQuery.of(this).textScaleFactor;
  bool get isLargeText => textScaleFactor > 1.2;
}
```

### Responsive Layout Examples

```dart
// Example: Responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildGrid(context, 1),
      tablet: _buildGrid(context, 2),
      desktop: _buildGrid(context, 3),
      largeDesktop: _buildGrid(context, 4),
    );
  }

  Widget _buildGrid(BuildContext context, int crossAxisCount) {
    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: _getAspectRatio(crossAxisCount),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  double _getAspectRatio(int crossAxisCount) {
    switch (crossAxisCount) {
      case 1:
        return 16 / 9; // Mobile: wide cards
      case 2:
        return 4 / 3;  // Tablet: square-ish cards
      case 3:
      case 4:
        return 3 / 4;  // Desktop: portrait cards
      default:
        return 1;
    }
  }
}
```

## Custom Widget Standards

### Base Widget Template

```dart
// shared/widgets/base/base_widget.dart
abstract class BaseWidget extends StatelessWidget {
  const BaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      constraints: constraints,
      decoration: decoration,
      child: buildContent(context),
    );
  }

  // Abstract method to be implemented by subclasses
  Widget buildContent(BuildContext context);

  // Override these in subclasses as needed
  EdgeInsetsGeometry? get padding => null;
  EdgeInsetsGeometry? get margin => null;
  BoxConstraints? get constraints => null;
  Decoration? get decoration => null;
}
```

### Custom Button Components

```dart
// shared/widgets/buttons/app_button.dart
enum ButtonVariant { elevated, filled, outlined, text }
enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.elevated,
    this.size = ButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.loadingText,
    this.icon,
    this.tooltip,
    this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isFullWidth;
  final bool isLoading;
  final String? loadingText;
  final Widget? icon;
  final String? tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = _buildButtonChild();

    if (isLoading) {
      buttonChild = _buildLoadingChild(context);
    }

    Widget button = _buildButton(context, buttonChild);

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null && !isLoading,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonChild() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          child,
        ],
      );
    }
    return child;
  }

  Widget _buildLoadingChild(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _getLoadingIndicatorSize(),
          height: _getLoadingIndicatorSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getLoadingIndicatorColor(context),
            ),
          ),
        ),
        if (loadingText != null) ...[
          const SizedBox(width: 8),
          Text(loadingText!),
        ],
      ],
    );
  }

  Widget _buildButton(BuildContext context, Widget child) {
    final style = _getButtonStyle(context);

    switch (variant) {
      case ButtonVariant.elevated:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
      case ButtonVariant.filled:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
    }
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final dimensions = _getButtonDimensions();
    
    return ButtonStyle(
      padding: MaterialStateProperty.all(dimensions.padding),
      minimumSize: MaterialStateProperty.all(dimensions.minimumSize),
      textStyle: MaterialStateProperty.all(dimensions.textStyle),
    );
  }

  _ButtonDimensions _getButtonDimensions() {
    switch (size) {
      case ButtonSize.small:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size(64, 32),
          textStyle: TextStyle(fontSize: 12),
        );
      case ButtonSize.medium:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: Size(64, 40),
          textStyle: TextStyle(fontSize: 14),
        );
      case ButtonSize.large:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: Size(64, 48),
          textStyle: TextStyle(fontSize: 16),
        );
    }
  }

  double _getLoadingIndicatorSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingIndicatorColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (variant) {
      case ButtonVariant.elevated:
      case ButtonVariant.filled:
        return theme.colorScheme.onPrimary;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }
}

class _ButtonDimensions {
  const _ButtonDimensions({
    required this.padding,
    required this.minimumSize,
    required this.textStyle,
  });

  final EdgeInsets padding;
  final Size minimumSize;
  final TextStyle textStyle;
}
```

### Form Components

```dart
// shared/widgets/forms/app_text_field.dart
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.showCharacterCount = false,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool showCharacterCount;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          autofocus: widget.autofocus,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            counterText: widget.showCharacterCount ? null : '',
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }
    return widget.suffixIcon;
  }
}
```

### Card Components

```dart
// shared/widgets/cards/app_card.dart
enum CardVariant { elevated, filled, outlined }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.onLongPress,
    this.variant = CardVariant.elevated,
    this.padding,
    this.margin,
    this.elevation,
    this.semanticLabel,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final CardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget cardContent = _buildCardContent(context);

    if (onTap != null || onLongPress != null) {
      cardContent = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: cardContent,
      );
    }

    Widget card = _buildCard(context, cardContent);

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }

  Widget _buildCardContent(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasHeader()) _buildHeader(context),
          if (_hasHeader()) const SizedBox(height: 16),
          child,
          if (actions != null) ...[
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Widget content) {
    final theme = Theme.of(context);
    
    switch (variant) {
      case CardVariant.elevated:
        return Card(
          elevation: elevation ?? 1,
          child: content,
        );
      case CardVariant.filled:
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceVariant,
          child: content,
        );
      case CardVariant.outlined:
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: content,
        );
    }
  }

  bool _hasHeader() => title != null || leading != null || trailing != null;

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 16),
        ],
        if (title != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        if (trailing != null) ...[
          const SizedBox(width: 16),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions!
          .expand((action) => [action, const SizedBox(width: 8)])
          .take(actions!.length * 2 - 1)
          .toList(),
    );
  }
}
```

## Animation Standards

### Animation Guidelines

```dart
```dart
// core/animations/app_animations.dart
class AppAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Curve constants
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  // Common animation configurations
  static const AnimationConfig fadeIn = AnimationConfig(
    duration: medium,
    curve: easeOut,
  );

  static const AnimationConfig slideUp = AnimationConfig(
    duration: medium,
    curve: easeOut,
  );

  static const AnimationConfig scaleIn = AnimationConfig(
    duration: fast,
    curve: easeOut,
  );

  // Page transition animations
  static Widget slideTransition({
    required Animation<double> animation,
    required Widget child,
    SlideDirection direction = SlideDirection.right,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.up:
        begin = const Offset(0.0, 1.0);
        break;
      case SlideDirection.down:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.left:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.right:
        begin = const Offset(1.0, 0.0);
        break;
    }

    return SlideTransition(
      position: animation.drive(
        Tween(begin: begin, end: Offset.zero).chain(
          CurveTween(curve: easeOut),
        ),
      ),
      child: child,
    );
  }

  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation.drive(
        CurveTween(curve: easeOut),
      ),
      child: child,
    );
  }

  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: animation.drive(
        Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

enum SlideDirection { up, down, left, right }

class AnimationConfig {
  const AnimationConfig({
    required this.duration,
    required this.curve,
  });

  final Duration duration;
  final Curve curve;
}

// Animated widgets
class AnimatedSlideIn extends StatefulWidget {
  const AnimatedSlideIn({
    super.key,
    required this.child,
    this.direction = SlideDirection.up,
    this.duration = AppAnimations.medium,
    this.curve = AppAnimations.easeOut,
    this.delay = Duration.zero,
  });

  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;
  final Duration delay;

  @override
  State<AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.up:
        return const Offset(0.0, 0.5);
      case SlideDirection.down:
        return const Offset(0.0, -0.5);
      case SlideDirection.left:
        return const Offset(-0.5, 0.0);
      case SlideDirection.right:
        return const Offset(0.5, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}
```

## Loading States & Feedback

### Loading Components

```dart
// shared/widgets/loading/loading_widget.dart
enum LoadingType { circular, linear, skeleton, shimmer }

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.size,
    this.color,
  });

  final LoadingType type;
  final String? message;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoadingIndicator(context),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size ?? 24,
          height: size ?? 24,
          child: CircularProgressIndicator(
            valueColor: color != null 
                ? AlwaysStoppedAnimation<Color>(color!) 
                : null,
          ),
        );
      case LoadingType.linear:
        return SizedBox(
          width: size ?? 200,
          child: LinearProgressIndicator(
            valueColor: color != null 
                ? AlwaysStoppedAnimation<Color>(color!) 
                : null,
          ),
        );
      case LoadingType.skeleton:
        return _buildSkeletonLoader();
      case LoadingType.shimmer:
        return _buildShimmerLoader();
    }
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: [
        Container(
          width: size ?? 200,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: (size ?? 200) * 0.7,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: _buildSkeletonLoader(),
    );
  }
}

// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.illustration,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else if (icon != null)
              Icon(
                icon!,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

## Accessibility Implementation

### Semantic Widgets

```dart
// shared/widgets/accessibility/semantic_wrapper.dart
class SemanticWrapper extends StatelessWidget {
  const SemanticWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isSelected = false,
    this.isExpanded,
    this.onTap,
  });

  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool isButton;
  final bool isSelected;
  final bool? isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _buildSemanticLabel(),
      hint: hint,
      value: value,
      button: isButton,
      selected: isSelected,
      expanded: isExpanded,
      onTap: onTap,
      child: child,
    );
  }

  String? _buildSemanticLabel() {
    if (label == null) return null;

    final buffer = StringBuffer(label);
    
    if (value != null && value!.isNotEmpty) {
      buffer.write(', $value');
    }
    
    if (isButton) {
      buffer.write(', button');
    }
    
    if (isSelected) {
      buffer.write(', selected');
    }
    
    if (isExpanded == true) {
      buffer.write(', expanded');
    } else if (isExpanded == false) {
      buffer.write(', collapsed');
    }
    
    return buffer.toString();
  }
}
```

## Design System Guidelines

### Color Usage Guidelines

```dart
// Design system color usage examples
class ColorUsageExamples extends StatelessWidget {
  const ColorUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Primary actions
        AppButton(
          onPressed: () {},
          variant: ButtonVariant.filled,
          child: const Text('Primary Action'),
        ),
        
        // Secondary actions
        AppButton(
          onPressed: () {},
          variant: ButtonVariant.outlined,
          child: const Text('Secondary Action'),
        ),
        
        // Success states
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.successContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.onSuccessContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Success message',
                style: TextStyle(color: AppColors.onSuccessContainer),
              ),
            ],
          ),
        ),
        
        // Error states
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Error message',
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

### Typography Scale Usage

```dart
// Typography usage examples
class TypographyExamples extends StatelessWidget {
  const TypographyExamples({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page titles
        Text(
          'Page Title',
          style: textTheme.headlineLarge,
        ),
        
        // Section titles
        Text(
          'Section Title',
          style: textTheme.headlineMedium,
        ),
        
        // Card titles
        Text(
          'Card Title',
          style: textTheme.titleLarge,
        ),
        
        // Body text
        Text(
          'Body text for reading content. This should be comfortable to read and have good line height.',
          style: textTheme.bodyLarge,
        ),
        
        // Captions and metadata
        Text(
          'Caption or metadata text',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        
        // Button labels
        Text(
          'BUTTON LABEL',
          style: textTheme.labelLarge,
        ),
      ],
    );
  }
}
```

## Testing UI Components

### Widget Testing Standards

```dart
// test/widgets/app_button_test.dart
void main() {
  group('AppButton Widget Tests', () {
    testWidgets('renders with correct text', (WidgetTester tester) async {
      const buttonText = 'Test Button';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              onPressed: () {},
              child: const Text(buttonText),
            ),
          ),
        ),
      );

      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              onPressed: () => wasPressed = true,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('shows loading state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              onPressed: () {},
              isLoading: true,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('respects semantic properties', (WidgetTester tester) async {
      const semanticLabel = 'Save button';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              onPressed: () {},
              semanticLabel: semanticLabel,
              child: const Text('Save'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.label, contains(semanticLabel));
    });
  });
}
```

## Performance Optimization

### Widget Performance Guidelines

```dart
// Performance optimization examples
class PerformantWidget extends StatelessWidget {
  const PerformantWidget({
    super.key,
    required this.data,
  });

  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Good: Use const constructors
        const Text('Static text'),
        
        // ✅ Good: Extract expensive widgets
        _buildExpensiveWidget(),
        
        // ✅ Good: Use ListView.builder for long lists
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ListTile(
                key: ValueKey(data[index]), // ✅ Good: Use keys
                title: Text(data[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ Good: Extract to separate method to avoid rebuilds
  Widget _buildExpensiveWidget() {
    return const ExpensiveWidget();
  }
}

// ✅ Good: Use const constructor
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Expensive widget'),
    );
  }
}
```

## Best Practices Summary

### UI Development Guidelines

1. **Consistency** - Use design system components
2. **Accessibility** - Implement semantic labels and keyboard navigation
3. **Performance** - Use const constructors and optimize rebuilds
4. **Responsiveness** - Design for all screen sizes
5. **Animation** - Use meaningful, purposeful animations
6. **Loading States** - Always provide feedback for async operations
7. **Error Handling** - Show clear, actionable error messages
8. **Testing** - Write comprehensive widget tests

### Common Anti-Patterns

❌ **Avoid:**
- Hardcoded colors and dimensions
- Non-responsive layouts
- Missing accessibility labels
- Overusing animations
- Not handling loading/error states
- Complex widget trees without extraction
- Ignoring platform conventions

✅ **Follow:**
- Design system guidelines
- Material Design 3 principles
- Accessibility best practices
- Performance optimization techniques
- Comprehensive testing strategies


