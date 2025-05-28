
# 14. Internationalization

> **Flutter i18n Essentials** - Multi-language support, localization, and global market readiness.

## 🌍 Internationalization Philosophy

### Core Concepts
```yaml
i18n Goals:
  - Support multiple languages and regions
  - Adapt to local cultures and preferences
  - Handle text direction (LTR/RTL)
  - Format dates, numbers, and currencies properly
  - Provide seamless user experience globally

Key Components:
  - Text translation (l10n)
  - Date/time formatting
  - Number and currency formatting
  - Text direction handling
  - Cultural adaptations
```

## 🚀 Setup & Configuration

### pubspec.yaml Configuration
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true # Enable l10n generation

dev_dependencies:
  intl_utils: ^2.8.5 # For ARB file generation
```

### l10n.yaml Configuration
```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/generated/l10n
nullable-getter: false
synthetic-package: false
```

### Main App Setup
```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Master App',
      
      // Localization delegates
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Supported locales
      supportedLocales: [
        Locale('en', 'US'), // English (US)
        Locale('es', 'ES'), // Spanish (Spain)
        Locale('fr', 'FR'), // French (France)
        Locale('de', 'DE'), // German (Germany)
        Locale('ja', 'JP'), // Japanese (Japan)
        Locale('ar', 'SA'), // Arabic (Saudi Arabia)
        Locale('zh', 'CN'), // Chinese (China)
        Locale('tr', 'TR'), // Turkish (Turkey)
      ],
      
      // Locale resolution strategy
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if device locale is supported
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // Fallback to English
        return Locale('en', 'US');
      },
      
      home: HomeScreen(),
    );
  }
}
```

## 📝 Translation Files (ARB Format)

### English (app_en.arb)
```json
{
  "@@locale": "en",
  "appTitle": "Flutter Master App",
  "welcome": "Welcome",
  "welcomeMessage": "Welcome back, {name}!",
  "@welcomeMessage": {
    "description": "Welcome message with user name",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  },
  
  "login": "Login",
  "logout": "Logout",
  "email": "Email",
  "password": "Password",
  "forgotPassword": "Forgot Password?",
  
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Number of items with pluralization",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  },
  
  "lastSeen": "Last seen {date}",
  "@lastSeen": {
    "description": "Last seen date",
    "placeholders": {
      "date": {
        "type": "DateTime",
        "format": "yMMMd"
      }
    }
  },
  
  "price": "Price: {amount}",
  "@price": {
    "description": "Price with currency formatting",
    "placeholders": {
      "amount": {
        "type": "double",
        "format": "currency",
        "optionalParameters": {
          "symbol": "$"
        }
      }
    }
  },
  
  "validationEmailRequired": "Email is required",
  "validationEmailInvalid": "Please enter a valid email",
  "validationPasswordRequired": "Password is required",
  "validationPasswordTooShort": "Password must be at least 8 characters",
  
  "buttonSave": "Save",
  "buttonCancel": "Cancel",
  "buttonDelete": "Delete",
  "buttonEdit": "Edit",
  
  "errorNetworkConnection": "Please check your internet connection",
  "errorServerError": "Server error. Please try again later",
  "errorUnknown": "An unexpected error occurred"
}
```

### Spanish (app_es.arb)
```json
{
  "@@locale": "es",
  "appTitle": "Aplicación Flutter Master",
  "welcome": "Bienvenido",
  "welcomeMessage": "¡Bienvenido de vuelta, {name}!",
  
  "login": "Iniciar Sesión",
  "logout": "Cerrar Sesión",
  "email": "Correo Electrónico",
  "password": "Contraseña",
  "forgotPassword": "¿Olvidaste tu contraseña?",
  
  "itemCount": "{count, plural, =0{Sin elementos} =1{1 elemento} other{{count} elementos}}",
  "lastSeen": "Última vez visto {date}",
  "price": "Precio: {amount}",
  
  "validationEmailRequired": "El correo electrónico es obligatorio",
  "validationEmailInvalid": "Por favor ingresa un correo válido",
  "validationPasswordRequired": "La contraseña es obligatoria",
  "validationPasswordTooShort": "La contraseña debe tener al menos 8 caracteres",
  
  "buttonSave": "Guardar",
  "buttonCancel": "Cancelar",
  "buttonDelete": "Eliminar",
  "buttonEdit": "Editar",
  
  "errorNetworkConnection": "Por favor verifica tu conexión a internet",
  "errorServerError": "Error del servidor. Inténtalo de nuevo más tarde",
  "errorUnknown": "Ocurrió un error inesperado"
}
```

### Arabic (app_ar.arb) - RTL Support
```json
{
  "@@locale": "ar",
  "appTitle": "تطبيق فلاتر ماستر",
  "welcome": "مرحباً",
  "welcomeMessage": "مرحباً بعودتك، {name}!",
  
  "login": "تسجيل الدخول",
  "logout": "تسجيل الخروج",
  "email": "البريد الإلكتروني",
  "password": "كلمة المرور",
  "forgotPassword": "نسيت كلمة المرور؟",
  
  "itemCount": "{count, plural, =0{لا توجد عناصر} =1{عنصر واحد} =2{عنصران} few{{count} عناصر} many{{count} عنصراً} other{{count} عنصر}}",
  "lastSeen": "آخر ظهور {date}",
  "price": "السعر: {amount}",
  
  "validationEmailRequired": "البريد الإلكتروني مطلوب",
  "validationEmailInvalid": "يرجى إدخال بريد إلكتروني صحيح",
  "validationPasswordRequired": "كلمة المرور مطلوبة",
  "validationPasswordTooShort": "يجب أن تكون كلمة المرور 8 أحرف على الأقل",
  
  "buttonSave": "حفظ",
  "buttonCancel": "إلغاء",
  "buttonDelete": "حذف",
  "buttonEdit": "تعديل"
}
```

## 🎯 Implementation Examples

### Basic Text Localization
```dart
class LocalizedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple text
            Text(
              l10n.welcome,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            SizedBox(height: 16),
            
            // Text with parameters
            Text(l10n.welcomeMessage('John')),
            
            SizedBox(height: 16),
            
            // Pluralization
            Text(l10n.itemCount(0)),  // "No items"
            Text(l10n.itemCount(1)),  // "1 item"
            Text(l10n.itemCount(5)),  // "5 items"
            
            SizedBox(height: 16),
            
            // Date formatting
            Text(l10n.lastSeen(DateTime.now())),
            
            SizedBox(height: 16),
            
            // Currency formatting
            Text(l10n.price(29.99)),
          ],
        ),
      ),
    );
  }
}
```

### Form Validation with Localization
```dart
class LocalizedForm extends StatefulWidget {
  @override
  _LocalizedFormState createState() => _LocalizedFormState();
}

class _LocalizedFormState extends State<LocalizedForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: l10n.email,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return l10n.validationEmailRequired;
              }
              if (!_isValidEmail(value!)) {
                return l10n.validationEmailInvalid;
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.password,
              hintText: l10n.password,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return l10n.validationPasswordRequired;
              }
              if (value!.length < 8) {
                return l10n.validationPasswordTooShort;
              }
              return null;
            },
          ),
          
          SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.buttonCancel),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(l10n.login),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Process login
    }
  }
}
```

### RTL Support Implementation
```dart
class RTLSupportWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
          // Automatically handles RTL layout
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Text('Menu'),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                trailing: Icon(
                  isRTL ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 16, // Adapts to text direction
            end: 16,
            top: 16,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row that adapts to text direction
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Expanded(child: Text('User Profile')),
                  Icon(Icons.edit),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Using DirectionalityAware widgets
              Container(
                padding: EdgeInsetsDirectional.all(16),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(color: Colors.blue, width: 4),
                  ),
                ),
                child: Text('This border adapts to text direction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Number and Currency Formatting
```dart
class FormattingExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Number formatting
    final numberFormat = NumberFormat.decimalPattern(locale.toString());
    final currencyFormat = NumberFormat.currency(
      locale: locale.toString(),
      symbol: _getCurrencySymbol(locale),
    );
    
    // Date formatting
    final dateFormat = DateFormat.yMMMd(locale.toString());
    final timeFormat = DateFormat.Hm(locale.toString());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Numbers:'),
        Text(numberFormat.format(1234567.89)),
        
        SizedBox(height: 8),
        
        Text('Currency:'),
        Text(currencyFormat.format(29.99)),
        Text(currencyFormat.format(1234.56)),
        
        SizedBox(height: 8),
        
        Text('Dates:'),
        Text(dateFormat.format(DateTime.now())),
        Text(timeFormat.format(DateTime.now())),
        
        SizedBox(height: 8),
        
        Text('Relative Time:'),
        Text(_formatRelativeTime(DateTime.now().subtract(Duration(hours: 2)))),
      ],
    );
  }

  String _getCurrencySymbol(Locale locale) {
    switch (locale.countryCode) {
      case 'US': return '\$';
      case 'ES': return '€';
      case 'JP': return '¥';
      case 'SA': return 'ر.س';
      case 'TR': return '₺';
      default: return '\$';
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}
```

### Language Switching
```dart
class LanguageSwitcher extends StatelessWidget {
  final Function(Locale) onLanguageChanged;

  const LanguageSwitcher({required this.onLanguageChanged});

  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(locale: Locale('en', 'US'), name: 'English', flag: '🇺🇸'),
    LanguageOption(locale: Locale('es', 'ES'), name: 'Español', flag: '🇪🇸'),
    LanguageOption(locale: Locale('fr', 'FR'), name: 'Français', flag: '🇫🇷'),
    LanguageOption(locale: Locale('de', 'DE'), name: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(locale: Locale('ja', 'JP'), name: '日本語', flag: '🇯🇵'),
    LanguageOption(locale: Locale('ar', 'SA'), name: 'العربية', flag: '🇸🇦'),
    LanguageOption(locale: Locale('zh', 'CN'), name: '中文', flag: '🇨🇳'),
    LanguageOption(locale: Locale('tr', 'TR'), name: 'Türkçe', flag: '🇹🇷'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    
    return PopupMenuButton<Locale>(
      icon: Icon(Icons.language),
      tooltip: 'Change Language',
      onSelected: onLanguageChanged,
      itemBuilder: (context) {
        return supportedLanguages.map((language) {
          final isSelected = language.locale.languageCode == currentLocale.languageCode;
          
          return PopupMenuItem<Locale>(
            value: language.locale,
            child: Row(
              children: [
                Text(language.flag, style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Expanded(child: Text(language.name)),
                if (isSelected)
                  Icon(Icons.check, color: Theme.of(context).primaryColor),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

class LanguageOption {
  final Locale locale;
  final String name;
  final String flag;

  const LanguageOption({
    required this.locale,
    required this.name,
    required this.flag,
  });
}

// Main app with language switching
class LocalizedApp extends StatefulWidget {
  @override
  _LocalizedAppState createState() => _LocalizedAppState();
}

class _LocalizedAppState extends State<LocalizedApp> {
  Locale _currentLocale = Locale('en', 'US');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _currentLocale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageSwitcher.supportedLanguages
          .map((lang) => lang.locale)
          .toList(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Internationalized App'),
          actions: [
            LanguageSwitcher(
              onLanguageChanged: (locale) {
                setState(() {
                  _currentLocale = locale;
                });
              },
            ),
          ],
        ),
        body: LocalizedContent(),
      ),
    );
  }
}
```

## 🛠️ Advanced Features

### Custom Locale Delegates
```dart
class CustomLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'de', 'ja', 'ar', 'zh', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Load translations from remote source if needed
    if (await _shouldLoadRemoteTranslations(locale)) {
      await _loadRemoteTranslations(locale);
    }
    
    return AppLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;

  Future<bool> _shouldLoadRemoteTranslations(Locale locale) async {
    // Check if we need to fetch updated translations
    return false; // Simplified
  }

  Future<void> _loadRemoteTranslations(Locale locale) async {
    // Fetch and cache remote translations
  }
}
```

### Context Extensions for Easy Access
```dart
extension LocalizationExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
  
  String get languageCode => Localizations.localeOf(this).languageCode;
  
  String get countryCode => Localizations.localeOf(this).countryCode ?? '';
}

// Usage example
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.l10n.welcome),
        if (context.isRTL) 
          Text('RTL Layout Active'),
        Text('Language: ${context.languageCode}'),
      ],
    );
  }
}
```

## 🧪 Testing Internationalization

### Widget Testing
```dart
testWidgets('displays localized text correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('es', 'ES'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
      home: MyLocalizedWidget(),
    ),
  );

  // Verify Spanish text is displayed
  expect(find.text('Iniciar Sesión'), findsOneWidget);
  expect(find.text('Login'), findsNothing);
});

testWidgets('handles RTL layout correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('ar', 'SA'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'SA')],
      home: MyRTLWidget(),
    ),
  );

  // Verify RTL layout
  final widget = tester.widget<Directionality>(find.byType(Directionality));
  expect(widget.textDirection, TextDirection.rtl);
});
```

## 📋 i18n Checklist

```yaml
Implementation Checklist:
  - [x] ARB files for all supported languages
  - [x] Proper locale delegates setup
  - [x] Text direction support (LTR/RTL)
  - [x] Date/time formatting
  - [x] Number/currency formatting
  - [x] Pluralization rules
  - [x] Form validation messages
  - [x] Error messages localization
  - [x] Accessibility labels translation
  - [x] Images with text alternatives

Quality Assurance:
  - [x] Native speaker review
  - [x] Cultural appropriateness check
  - [x] UI layout testing (text expansion)
  - [x] Font support verification
  - [x] Keyboard input testing
  - [x] Date/currency format validation

Performance:
  - [x] Lazy loading of translations
  - [x] Translation caching
  - [x] Minimal app size impact
  - [x] Fast locale switching
```

## 🌐 Best Practices

```yaml
Translation Management:
  - Use professional translators for production
  - Implement translation key naming conventions
  - Provide context for translators
  - Regular translation updates and reviews
  - Version control for translation files

Technical Implementation:
  - Extract all user-facing strings
  - Use ICU message format for complex cases
  - Handle text expansion (25-30% longer in other languages)
  - Test with longest translation
  - Provide fallback for missing translations

Cultural Considerations:
  - Date/time formats vary by region
  - Currency symbols and formatting
  - Color meanings differ across cultures
  - Icons may have different meanings
  - Reading patterns (LTR vs RTL)
