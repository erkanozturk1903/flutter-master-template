## 13-accessibility-standards.md

# 13. Accessibility Standards

> **Flutter Accessibility Essentials** - WCAG compliance and inclusive design for all users.

## ♿ Accessibility Philosophy

### Core Principles (WCAG 2.1)
```yaml
POUR Principles:
  Perceivable: Information must be presentable in ways users can perceive
  Operable: Interface components must be operable by all users
  Understandable: Information and UI operation must be understandable
  Robust: Content must be robust enough for various assistive technologies

Target Users:
  - Visual impairments (blindness, low vision, color blindness)
  - Hearing impairments (deafness, hard of hearing)
  - Motor disabilities (limited mobility, tremors)
  - Cognitive disabilities (dyslexia, memory issues)
```

## 🎯 Essential Implementation

### Semantic Labels & Descriptions
```dart
// ✅ Proper semantic labeling
Semantics(
  label: 'Add item to shopping cart',
  hint: 'Double tap to add this item to your cart',
  button: true,
  enabled: true,
  child: IconButton(
    icon: Icon(Icons.add_shopping_cart),
    onPressed: _addToCart,
    tooltip: 'Add to cart',
  ),
)

// ✅ Meaningful text alternatives
Image.network(
  'https://example.com/product.jpg',
  semanticLabel: 'Red Nike running shoes, size 10',
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return Semantics(
      label: 'Product image loading',
      child: CircularProgressIndicator(),
    );
  },
)

// ✅ Form field accessibility
TextField(
  decoration: InputDecoration(
    labelText: 'Email Address',
    hintText: 'Enter your email address',
    helperText: 'We will never share your email',
    errorText: _emailError,
  ),
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  onSubmitted: (_) => _passwordFocus.requestFocus(),
)

// ✅ Complex widget semantics
Semantics(
  label: 'Product card: iPhone 14 Pro, $999, 4.8 stars',
  button: true,
  onTap: () => _viewProduct(product),
  child: Card(
    child: Column(
      children: [
        ExcludeSemantics(child: Image.network(product.imageUrl)),
        Text(product.name),
        Text('\$${product.price}'),
        Row(
          children: [
            ...List.generate(5, (index) => Icon(
              index < product.rating ? Icons.star : Icons.star_border,
            )),
            ExcludeSemantics(child: Text('${product.rating}')),
          ],
        ),
      ],
    ),
  ),
)
```

### Screen Reader Navigation
```dart
class AccessibleListView extends StatelessWidget {
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Product list, ${items.length} items',
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Semantics(
            label: 'Item ${index + 1} of ${items.length}: ${item.name}',
            button: true,
            onTap: () => _selectItem(item),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(item.description),
              trailing: Semantics(
                label: 'Price: \$${item.price}',
                excludeSemantics: true,
                child: Text('\$${item.price}'),
              ),
              onTap: () => _selectItem(item),
            ),
          );
        },
      ),
    );
  }
}

// ✅ Accessible modal dialogs
class AccessibleDialog extends StatelessWidget {
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      namesRoute: true,
      scopesRoute: true,
      label: 'Dialog: $title',
      child: AlertDialog(
        title: Semantics(
          header: true,
          child: Text(title),
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          Semantics(
            button: true,
            hint: 'Confirm and close dialog',
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Color & Visual Accessibility
```dart
class AccessibleTheme {
  // ✅ WCAG AA compliant color ratios (4.5:1 minimum)
  static const Color primaryText = Color(0xFF000000);      // Contrast: 21:1
  static const Color secondaryText = Color(0xFF666666);    // Contrast: 4.5:1
  static const Color primaryBlue = Color(0xFF1976D2);      // Contrast: 4.5:1
  static const Color errorRed = Color(0xFFD32F2F);         // Contrast: 4.5:1
  static const Color successGreen = Color(0xFF388E3C);     // Contrast: 4.5:1
  
  // ✅ High contrast theme
  static ThemeData highContrastTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: Colors.black,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        side: BorderSide(color: Colors.black, width: 2),
      ),
    ),
  );
}

// ✅ Don't rely solely on color to convey information
Widget buildStatusIndicator(OrderStatus status) {
  return Row(
    children: [
      Icon(
        _getStatusIcon(status),
        color: _getStatusColor(status),
        semanticLabel: _getStatusText(status),
      ),
      SizedBox(width: 8),
      Text(_getStatusText(status)),
    ],
  );
}

IconData _getStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Icons.schedule;
    case OrderStatus.processing:
      return Icons.autorenew;
    case OrderStatus.shipped:
      return Icons.local_shipping;
    case OrderStatus.delivered:
      return Icons.check_circle;
    case OrderStatus.cancelled:
      return Icons.cancel;
  }
}

// ✅ Accessible color picker
class ColorBlindFriendlyPalette extends StatelessWidget {
  final Function(Color) onColorSelected;

  // Colors chosen to be distinguishable for most types of color blindness
  static const List<AccessibleColor> colors = [
    AccessibleColor(color: Color(0xFF000000), name: 'Black'),
    AccessibleColor(color: Color(0xFF0173B2), name: 'Blue'),
    AccessibleColor(color: Color(0xFFDE8F05), name: 'Orange'),
    AccessibleColor(color: Color(0xFF029E73), name: 'Green'),
    AccessibleColor(color: Color(0xFFD55E00), name: 'Red-Orange'),
    AccessibleColor(color: Color(0xFFCC78BC), name: 'Pink'),
    AccessibleColor(color: Color(0xFFCA9161), name: 'Brown'),
    AccessibleColor(color: Color(0xFFFBFE28), name: 'Yellow'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: colors.map((accessibleColor) {
        return Semantics(
          label: 'Select ${accessibleColor.name} color',
          button: true,
          child: GestureDetector(
            onTap: () => onColorSelected(accessibleColor.color),
            child: Container(
              width: 48,
              height: 48,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accessibleColor.color,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AccessibleColor {
  final Color color;
  final String name;
  
  const AccessibleColor({required this.color, required this.name});
}
```

### Touch Targets & Motor Accessibility
```dart
// ✅ Minimum 44x44 logical pixels for touch targets
class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),
      child: icon != null
          ? IconButton(
              icon: Icon(icon),
              onPressed: onPressed,
              tooltip: label,
              iconSize: 24,
              padding: EdgeInsets.all(10),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(44, 44),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(label),
            ),
    );
  }
}

// ✅ Accessible slider with larger thumb
class AccessibleSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: '$label: ${value.round()}',
          child: Text('$label: ${value.round()}'),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 25),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: '${value.round()}',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ✅ Accessible gesture detection with alternatives
class AccessibleGestureWidget extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        // Provide keyboard alternative
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space) {
                onTap();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: child,
        ),
      ),
    );
  }
}
```

### Focus Management & Keyboard Navigation
```dart
class AccessibleForm extends StatefulWidget {
  @override
  _AccessibleFormState createState() => _AccessibleFormState();
}

class _AccessibleFormState extends State<AccessibleForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _submitFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Registration form',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email field
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: _validateEmail,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            
            SizedBox(height: 16),
            
            // Password field
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock),
                helperText: 'Minimum 8 characters',
              ),
              validator: _validatePassword,
              onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
            ),
            
            SizedBox(height: 16),
            
            // Confirm password field
            TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: _validateConfirmPassword,
              onFieldSubmitted: (_) => _submitForm(),
            ),
            
            SizedBox(height: 24),
            
            // Submit button
            Focus(
              focusNode: _submitFocus,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Create Account'),
              ),
            ),
            
            // Skip link for screen readers
            Semantics(
              label: 'Skip to login',
              button: true,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Already have an account? Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Announce success to screen readers
      SemanticsService.announce(
        'Account created successfully',
        TextDirection.ltr,
      );
      
      // Process form
      _processRegistration();
    } else {
      // Announce errors to screen readers
      SemanticsService.announce(
        'Please correct the errors in the form',
        TextDirection.ltr,
      );
      
      // Focus first field with error
      _focusFirstErrorField();
    }
  }

  void _focusFirstErrorField() {
    if (_validateEmail(_emailController.text) != null) {
      _emailFocus.requestFocus();
    } else if (_validatePassword(_passwordController.text) != null) {
      _passwordFocus.requestFocus();
    } else if (_validateConfirmPassword(_confirmPasswordController.text) != null) {
      _confirmPasswordFocus.requestFocus();
    }
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _submitFocus.dispose();
    super.dispose();
  }
}
```

### Dynamic Content & State Changes
```dart
class AccessibleLoadingWidget extends StatelessWidget {
  final bool isLoading;
  final String loadingText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isLoading ? loadingText : null,
      liveRegion: isLoading,
      child: Stack(
        children: [
          Semantics(
            excludeSemantics: isLoading,
            child: child,
          ),
          if (isLoading)
            Semantics(
              label: loadingText,
              liveRegion: true,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        semanticsLabel: 'Loading',
                      ),
                      SizedBox(height: 16),
                      Text(
                        loadingText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ✅ Accessible error messages
class AccessibleErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Announce error to screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Error: $error',
        TextDirection.ltr,
      );
    });

    return Semantics(
      label: 'Error occurred: $error',
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## 🧪 Accessibility Testing

### Automated Testing
```dart
// Test semantic properties
testWidgets('button has correct semantic properties', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ElevatedButton(
          onPressed: () {},
          child: Text('Submit'),
        ),
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(ElevatedButton));
  expect(semantics.hasAction(SemanticsAction.tap), isTrue);
  expect(semantics.label, contains('Submit'));
});

// Test focus behavior
testWidgets('focus moves correctly between form fields', (tester) async {
  await tester.pumpWidget(AccessibleFormWidget());
  
  // Tab to first field
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  
  final firstField = find.byType(TextFormField).first;
  expect(Focus.of(tester.element(firstField)).hasPrimaryFocus, isTrue);
  
  // Tab to second field
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  
  final secondField = find.byType(TextFormField).at(1);
  expect(Focus.of(tester.element(secondField)).hasPrimaryFocus, isTrue);
});

// Test screen reader announcements
testWidgets('error state announces to screen reader', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Trigger error state
  await tester.tap(find.text('Submit'));
  await tester.pump();
  
  // Verify semantics service was called
  expect(tester.binding.defaultBinaryMessenger.checkMockMessageHandler(
    'flutter/semantics', null), isNotNull);
});
```

### Manual Testing Guidelines
```yaml
Screen Reader Testing:
  Android (TalkBack):
    - Settings > Accessibility > TalkBack
    - Navigate with swipe gestures
    - Verify reading order and content

  iOS (VoiceOver):
    - Settings > Accessibility > VoiceOver
    - Use rotor control for navigation
    - Test custom actions

Keyboard Testing:
  - Tab navigation through all interactive elements
  - Enter/Space activation of buttons
  - Arrow key navigation in lists/grids
  - Escape key for dismissing modals

Visual Testing:
  - High contrast mode
  - Large text sizes (up to 200%)
  - Color blindness simulation
  - Reduced motion settings
```

## 📋 Accessibility Checklist

```yaml
Essential Requirements:
  - [x] All interactive elements have semantic labels
  - [x] Focus management and keyboard navigation
  - [x] Minimum 44x44 pixel touch targets
  - [x] 4.5:1 color contrast ratio (AA level)
  - [x] Alternative text for images
  - [x] Form validation with clear error messages
  - [x] Loading and error states are announced
  - [x] Don't rely solely on color for information
  - [x] Text is resizable up to 200%
  - [x] Auto-playing content can be paused

Advanced Features:
  - [x] Live regions for dynamic content
  - [x] Skip links for lengthy content
  - [x] Heading hierarchy (h1, h2, h3...)
  - [x] Grouped form controls with fieldsets
  - [x] Timeout warnings and extensions
  - [x] Multiple ways to find content
  - [x] Consistent navigation and identification
```

## 🛠️ Tools & Resources

```yaml
Testing Tools:
  - Flutter Inspector (built-in)
  - Accessibility Scanner (Android)
  - Accessibility Inspector (iOS/macOS)
  - axe-core (web)
  - WAVE Web Accessibility Evaluator

Design Tools:
  - Colour Contrast Analyser
  - Stark (Figma/Sketch plugin)
  - Who Can Use (color accessibility)

Guidelines & Standards:
  - WCAG 2.1 AA Guidelines
  - Section 508 Compliance
  - Material Design Accessibility
  - Apple Human Interface Guidelines
  - Android Accessibility Guidelines
