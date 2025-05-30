 08. Code Quality & Standards

> **Comprehensive Flutter Code Quality Guide** - Linting rules, documentation standards, code review processes, and quality metrics for maintainable, scalable Flutter applications.

## 📋 Table of Contents

- [Code Quality Philosophy](#-code-quality-philosophy)
- [Linting & Analysis Rules](#-linting--analysis-rules)
- [Code Formatting Standards](#-code-formatting-standards)
- [Documentation Standards](#-documentation-standards)
- [Naming Conventions](#-naming-conventions)
- [File Organization](#-file-organization)
- [Code Review Process](#-code-review-process)
- [Static Analysis Tools](#-static-analysis-tools)
- [Quality Metrics](#-quality-metrics)
- [Pre-commit Hooks](#-pre-commit-hooks)
- [IDE Configuration](#-ide-configuration)
- [Team Standards](#-team-standards)

## 🎯 Code Quality Philosophy

### Core Principles
```yaml
Quality Standards:
  - Code is read more than written
  - Consistency over personal preference
  - Self-documenting code
  - Fail fast, fail clearly
  - Refactor continuously
  - Review everything
```

### Quality Pyramid
```
🔍 Static Analysis (100%)
📝 Documentation (90%)
👥 Code Review (100%)
🧪 Testing (80%+)
📊 Metrics Monitoring (Continuous)
```

### Clean Architecture Compliance
- **Domain Layer**: Pure business logic, no external dependencies
- **Data Layer**: Repository implementations, models, data sources
- **Presentation Layer**: UI components, state management, user interactions
- **Core Layer**: Shared utilities, constants, dependency injection

## 🔍 Linting & Analysis Rules

### Complete analysis_options.yaml
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
    - "**/generated/**"
    - "build/**"
    - "lib/generated/**"
  
  errors:
    # Treat these as errors (build will fail)
    invalid_assignment: error
    missing_required_param: error
    missing_return: error
    dead_code: error
    unused_import: error
    unused_local_variable: error
    prefer_const_constructors: error
    prefer_const_literals_to_create_immutables: error
    
  plugins:
    - dart_code_metrics
    - custom_lint

  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    # STYLE RULES
    - camel_case_types
    - camel_case_extensions
    - file_names
    - library_names
    - library_prefixes
    - non_constant_identifier_names
    - constant_identifier_names
    - directives_ordering
    - lines_longer_than_80_chars
    
    # DOCUMENTATION RULES
    - public_member_api_docs
    - comment_references
    - slash_for_doc_comments
    - package_api_docs
    
    # USAGE RULES
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - avoid_types_as_parameter_names
    - avoid_web_libraries_in_flutter
    - cancel_subscriptions
    - close_sinks
    - control_flow_in_finally
    - empty_statements
    - hash_and_equals
    - invariant_booleans
    - iterable_contains_unrelated_type
    - list_remove_unrelated_type
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - prefer_void_to_null
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_statements
    - unrelated_type_equality_checks
    - use_build_context_synchronously
    - use_key_in_widget_constructors
    - valid_regexps
    
    # DESIGN RULES
    - avoid_catches_without_on_clauses
    - avoid_catching_errors
    - avoid_classes_with_only_static_members
    - avoid_function_literals_in_foreach_calls
    - avoid_positional_boolean_parameters
    - avoid_private_typedef_functions
    - avoid_redundant_argument_values
    - avoid_renaming_method_parameters
    - avoid_return_types_on_setters
    - avoid_returning_null
    - avoid_returning_null_for_void
    - avoid_setters_without_getters
    - avoid_single_cascade_in_expression_statements
    - avoid_unused_constructor_parameters
    - avoid_void_async
    - cascade_invocations
    - join_return_with_assignment
    - missing_whitespace_between_adjacent_strings
    - parameter_assignments
    - prefer_asserts_in_initializer_lists
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_constructors_over_static_methods
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_function_declarations_over_variables
    - prefer_if_elements_to_conditional_expressions
    - prefer_if_null_operators
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_is_not_operator
    - prefer_iterable_whereType
    - prefer_null_aware_operators
    - prefer_spread_collections
    - prefer_typing_uninitialized_variables
    - provide_deprecation_message
    - sort_child_properties_last
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - type_annotate_public_apis
    - unawaited_futures
    - unnecessary_await_in_return
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_getters_setters
    - unnecessary_lambdas
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_checks
    - unnecessary_null_in_if_null_operators
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_raw_strings
    - unnecessary_string_escapes
    - unnecessary_string_interpolations
    - unnecessary_this
    - use_full_hex_values_for_flutter_colors
    - use_function_type_syntax_for_parameters
    - use_rethrow_when_possible
    - use_setters_to_change_properties
    - use_string_buffers
    - use_to_and_as_if_applicable

# Dart Code Metrics Configuration
dart_code_metrics:
  metrics:
    cyclomatic-complexity: 10
    maximum-nesting-level: 5
    number-of-parameters: 6
    source-lines-of-code: 50
    technical-debt:
      threshold: 1
      todo-cost: 161
      ignore-cost: 320
      ignore-for-file-cost: 396
      as-dynamic-cost: 414
      deprecated-annotations-cost: 37
      file-nullsafety-migration-cost: 41
      unit-type: "USD"
  
  metrics-exclude:
    - test/**
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
  
  rules:
    # Architecture Rules
    - avoid-returning-widgets
    - avoid-unnecessary-setstate
    - avoid-wrapping-in-padding
    - prefer-extracting-callbacks
    - prefer-single-widget-per-file:
        ignore-private-widgets: true
    
    # Flutter Performance Rules
    - always-remove-listener
    - avoid-border-all
    - avoid-shrink-wrap-in-lists
    - avoid-unnecessary-setstate
    - avoid-wrapping-in-padding
    - check-for-equals-in-render-object-setters
    - consistent-update-render-object
    - prefer-const-border-radius
    - prefer-extracting-callbacks
    - prefer-single-widget-per-file
    
    # Code Quality Rules
    - avoid-non-null-assertion
    - avoid-unused-parameters
    - member-ordering:
        alphabetize: false
        order:
          - constructors
          - named-constructors
          - factory-constructors
          - getters-setters
          - methods
    
    # Style Rules
    - newline-before-return
    - no-boolean-literal-compare
    - no-empty-block
    - prefer-trailing-comma
    - prefer-conditional-expressions
    - prefer-moving-to-variable
```

### Custom Architecture Rules
```yaml
# .custom_lint.yaml
custom_lint:
  rules:
    # Clean Architecture Enforcement
    - enforce_layered_architecture:
        domain_cannot_import:
          - "package:*/features/*/data/**"
          - "package:*/features/*/presentation/**"
        data_cannot_import:
          - "package:*/features/*/presentation/**"
    
    # Feature Structure Rules
    - require_barrel_exports:
        feature_folders: true
        shared_folders: true
    
    # Naming Convention Rules
    - enforce_repository_naming:
        interface_suffix: "Repository"
        implementation_suffix: "RepositoryImpl"
    
    - enforce_usecase_naming:
        suffix: "UseCase"
        abstract_class: false
    
    - enforce_bloc_naming:
        bloc_suffix: "Bloc"
        cubit_suffix: "Cubit"
        event_suffix: "Event"
        state_suffix: "State"
    
    # Code Quality Rules
    - avoid_hardcoded_strings:
        exclude:
          - test/**
          - "**/*.g.dart"
        allowed_patterns:
          - "^[A-Z_]+$" # Constants
    
    - require_documentation:
        public_members: true
        classes: true
        methods: true
        minimum_length: 10
    
    # Performance Rules
    - avoid_heavy_widget_constructors:
        max_parameters: 5
        suggest_builder_pattern: true
```

## 🎨 Code Formatting Standards

### Dart Format Configuration
```json
// .vscode/settings.json
{
  "dart.lineLength": 80,
  "dart.insertArgumentPlaceholders": false,
  "dart.completeFunctionCalls": false,
  "dart.showTodos": false,
  "editor.formatOnSave": true,
  "editor.formatOnType": true,
  "editor.rulers": [80],
  "editor.wordWrap": "wordWrapColumn",
  "editor.wordWrapColumn": 80,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "files.associations": {
    "*.dart": "dart"
  },
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  }
}
```

### Formatting Examples
```dart
// ✅ CORRECT FORMATTING EXAMPLES

// 1. Line length - max 80 characters
const String longMessage = 'This is a very long string that exceeds '
    'the 80-character limit and should be broken into multiple lines '
    'for better readability and maintainability.';

// 2. Function parameters formatting
Future<Either<Failure, User>> authenticateUser({
  required String email,
  required String password,
  bool rememberMe = false,
  Duration? timeout,
}) async {
  // Implementation
}

// 3. Widget constructor formatting
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.title,
    required this.content,
    this.backgroundColor,
    this.onTap,
    this.elevation = 2.0,
  });

  final String title;
  final Widget content;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8.0),
              content,
            ],
          ),
        ),
      ),
    );
  }
}

// 4. Collection formatting
final List<NavigationItem> navigationItems = [
  const NavigationItem(
    icon: Icons.home,
    label: 'Home',
    route: '/home',
  ),
  const NavigationItem(
    icon: Icons.search,
    label: 'Search',
    route: '/search',
  ),
  const NavigationItem(
    icon: Icons.person,
    label: 'Profile',
    route: '/profile',
  ),
];

// 5. Complex widget tree formatting
Widget buildComplexLayout() {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Complex Layout'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _navigateToSettings(),
        ),
      ],
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Here are your recent activities',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ActivityCard(
                    activity: activity,
                    onTap: () => _handleActivityTap(activity),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _addNewActivity,
      child: const Icon(Icons.add),
    ),
  );
}

// 6. Method chaining and cascade notation
final TextEditingController emailController = TextEditingController()
  ..text = user.email
  ..addListener(_onEmailChanged);

final Paint borderPainter = Paint()
  ..color = Colors.blue
  ..strokeWidth = 2.0
  ..style = PaintingStyle.stroke;

// 7. String interpolation formatting
String generateUserMessage(User user, int unreadCount) {
  return 'Hello ${user.displayName}, you have $unreadCount unread '
      'messages. Last login: ${user.lastLoginAt.toLocal().toString()}';
}

// 8. Conditional expressions
Widget buildUserAvatar(User? user) {
  return user?.profileImageUrl != null
      ? CircleAvatar(
          backgroundImage: NetworkImage(user!.profileImageUrl!),
          radius: 24,
        )
      : const CircleAvatar(
          child: Icon(Icons.person),
          radius: 24,
        );
}
```

### Import Organization Standards
```dart
// ✅ CORRECT IMPORT ORDER

// 1. Dart SDK imports
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// 2. Flutter framework imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party package imports (alphabetical order)
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:json_annotation/json_annotation.dart';

// 4. Project imports - Core layer
import 'package:flutter_master_template/core/constants/api_constants.dart';
import 'package:flutter_master_template/core/error/failures.dart';
import 'package:flutter_master_template/core/usecases/usecase.dart';

// 5. Project imports - Shared components
import 'package:flutter_master_template/shared/widgets/loading_widget.dart';

// 6. Project imports - Feature imports (alphabetical by feature)
import 'package:flutter_master_template/features/auth/domain/entities/user.dart';
import 'package:flutter_master_template/features/auth/domain/repositories/auth_repository.dart';

// 7. Relative imports (same feature/directory)
import '../../../domain/entities/user_entity.dart';
import '../../widgets/auth_form_widget.dart';
import 'auth_event.dart';
import 'auth_state.dart';

// ❌ INCORRECT IMPORT EXAMPLES
import 'package:flutter/material.dart';
import '../../../domain/entities/user_entity.dart'; // Should be after package imports
import 'dart:async'; // Should be first
import 'package:dio/dio.dart';
import 'package:bloc/bloc.dart'; // Should be alphabetical
```

## 📝 Documentation Standards

### Class Documentation Template
```dart
/// A comprehensive authentication service that manages user login, logout,
/// registration, and session handling with support for multiple providers.
///
/// This service follows Clean Architecture principles and integrates with
/// various OAuth providers while maintaining secure local session storage.
/// It provides reactive streams for authentication state changes and supports
/// automatic token refresh functionality.
///
/// ## Key Features:
/// - Multiple authentication providers (Email, Google, Apple, Facebook)
/// - Automatic token refresh and session management
/// - Secure local storage with encryption
/// - Reactive authentication state streams
/// - Biometric authentication support
/// - Password strength validation
///
/// ## Usage Example:
/// ```dart
/// // Initialize the service
/// final authService = AuthService(
///   repository: authRepository,
///   tokenStorage: secureTokenStorage,
/// );
/// 
/// // Listen to authentication state changes
/// authService.authStateStream.listen((state) {
///   switch (state.status) {
///     case AuthStatus.authenticated:
///       navigateToHome();
///       break;
///     case AuthStatus.unauthenticated:
///       navigateToLogin();
///       break;
///     case AuthStatus.loading:
///       showLoadingIndicator();
///       break;
///   }
/// });
/// 
/// // Authenticate with email and password
/// final result = await authService.loginWithEmail(
///   email: 'user@example.com',
///   password: 'securePassword123',
/// );
/// 
/// if (result.isSuccess) {
///   print('Welcome, ${result.user.displayName}!');
/// } else {
///   print('Login failed: ${result.errorMessage}');
/// }
/// ```
///
/// ## Error Handling:
/// The service throws specific exceptions for different error scenarios:
/// - [InvalidCredentialsException] - Invalid email/password combination
/// - [AccountLockedException] - Account temporarily locked due to failed attempts
/// - [NetworkException] - Network connectivity issues
/// - [ServerException] - Backend server errors
/// - [TokenExpiredException] - Authentication token has expired
///
/// ## Security Considerations:
/// - All sensitive data is encrypted before local storage
/// - Passwords are never stored locally
/// - Tokens are automatically refreshed before expiration
/// - Biometric authentication uses device secure enclave
/// - Session timeout is configurable per security requirements
///
/// ## Related Classes:
/// * [AuthRepository] - Data layer interface for authentication operations
/// * [AuthBloc] - State management for authentication UI
/// * [User] - User entity with profile information
/// * [AuthResult] - Result wrapper for authentication operations
/// * [TokenStorage] - Secure storage interface for authentication tokens
///
/// ## Implementation Notes:
/// This implementation follows the Repository pattern and depends on
/// abstractions rather than concrete implementations. All dependencies
/// are injected through the constructor to maintain testability and
/// loose coupling.
///
/// @since 1.0.0
/// @author Flutter Master Template Team
class AuthService {
  /// Creates an [AuthService] instance with required dependencies.
  ///
  /// The [repository] parameter is required and handles all data operations
  /// including remote API calls and local storage management.
  ///
  /// The [tokenStorage] parameter is optional and defaults to [SecureTokenStorage]
  /// if not provided. This storage handles secure persistence of authentication
  /// tokens and sensitive user data.
  ///
  /// The [validator] parameter is optional and defaults to [DefaultAuthValidator]
  /// for input validation of email addresses, passwords, and user data.
  ///
  /// ## Example:
  /// ```dart
  /// final authService = AuthService(
  ///   repository: GetIt.instance<AuthRepository>(),
  ///   tokenStorage: SecureTokenStorage(),
  ///   validator: StrictAuthValidator(),
  /// );
  /// ```
  ///
  /// @throws [ArgumentError] if [repository] is null
  /// @throws [StateError] if service is already initialized
  AuthService({
    required AuthRepository repository,
    TokenStorage? tokenStorage,
    AuthValidator? validator,
  }) : _repository = repository,
       _tokenStorage = tokenStorage ?? SecureTokenStorage(),
       _validator = validator ?? DefaultAuthValidator() {
    _initializeService();
  }

  /// The repository interface for authentication data operations.
  ///
  /// This handles all data layer communications including:
  /// - Remote API authentication requests
  /// - Local user data persistence
  /// - Token management and refresh operations
  /// - Cache management for offline support
  final AuthRepository _repository;

  /// Secure storage for authentication tokens and sensitive data.
  ///
  /// All stored data is encrypted using device-specific keys and follows
  /// platform security best practices. On iOS, this uses Keychain Services,
  /// and on Android, it uses EncryptedSharedPreferences.
  final TokenStorage _tokenStorage;

  /// Validator for authentication input data.
  ///
  /// Provides validation for:
  /// - Email address format and domain restrictions
  /// - Password strength and complexity requirements
  /// - Username format and availability
  /// - Phone number format validation
  final AuthValidator _validator;

  /// Current authenticated user information.
  ///
  /// Returns `null` if no user is currently authenticated.
  /// This value is automatically updated when authentication state changes.
  ///
  /// ## Example:
  /// ```dart
  /// final user = authService.currentUser;
  /// if (user != null) {
  ///   print('Logged in as: ${user.displayName}');
  /// } else {
  ///   print('Not authenticated');
  /// }
  /// ```
  User? get currentUser => _currentUser;
  User? _currentUser;

  /// Stream of authentication state changes.
  ///
  /// Emits [AuthState] updates whenever the authentication status changes:
  /// - [AuthState.initial] - Service is initializing
  /// - [AuthState.loading] - Authentication operation in progress
  /// - [AuthState.authenticated] - User successfully authenticated
  /// - [AuthState.unauthenticated] - User not authenticated or logged out
  /// - [AuthState.error] - Authentication error occurred
  ///
  /// This stream is broadcast and can have multiple listeners. It automatically
  /// emits the current state to new subscribers.
  ///
  /// ## Example:
  /// ```dart
  /// authService.authStateStream.listen((state) {
  ///   switch (state.status) {
  ///     case AuthStatus.authenticated:
  ///       // Navigate to authenticated sections
  ///       context.go('/home');
  ///       break;
  ///     case AuthStatus.unauthenticated:
  ///       // Navigate to login screen
  ///       context.go('/login');
  ///       break;
  ///     case AuthStatus.error:
  ///       // Show error message
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(content: Text(state.errorMessage ?? 'Authentication failed')),
  ///       );
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<AuthState> get authStateStream => _authStateController.stream;

  /// Authenticates a user using email and password credentials.
  ///
  /// This method performs comprehensive validation of input parameters,
  /// communicates with the authentication backend, and manages local
  /// session storage upon successful authentication.
  ///
  /// ## Validation Rules:
  /// - Email must be a valid format (RFC 5322 compliant)
  /// - Email domain must not be blacklisted
  /// - Password must meet minimum complexity requirements
  /// - Account must not be locked or suspended
  ///
  /// ## Security Features:
  /// - Rate limiting prevents brute force attacks
  /// - Failed attempts are tracked and reported
  /// - Credentials are transmitted over HTTPS only
  /// - Session tokens are securely stored locally
  ///
  /// ## Parameters:
  /// * [email] - User's email address (required, non-empty)
  /// * [password] - User's password (required, minimum 8 characters)
  /// * [rememberMe] - Whether to persist session across app restarts
  /// * [deviceId] - Optional device identifier for session tracking
  ///
  /// ## Returns:
  /// A [Future] that completes with [AuthResult] containing:
  /// - [AuthResult.success] with [User] data on successful authentication
  /// - [AuthResult.failure] with specific error information on failure
  ///
  /// ## Common Error Scenarios:
  /// | Error Type | Cause | Recommended Action |
  /// |------------|-------|-------------------|
  /// | [InvalidCredentialsException] | Wrong email/password | Show "Invalid credentials" message |
  /// | [AccountLockedException] | Too many failed attempts | Show "Account temporarily locked" |
  /// | [NetworkException] | No internet connection | Show "Check internet connection" |
  /// | [ServerException] | Backend server error | Show "Service temporarily unavailable" |
  /// | [ValidationException] | Invalid input format | Show specific validation errors |
  ///
  /// ## Usage Examples:
  /// ```dart
  /// // Basic login
  /// final result = await authService.loginWithEmail(
  ///   email: 'user@example.com',
  ///   password: 'mySecurePassword123',
  /// );
  /// 
  /// // Handle result
  /// if (result.isSuccess) {
  ///   print('Welcome, ${result.user.displayName}!');
  ///   navigateToHomePage();
  /// } else {
  ///   showErrorDialog(result.errorMessage);
  /// }
  /// 
  /// // Login with remember me option
  /// final persistentResult = await authService.loginWithEmail(
  ///   email: emailController.text,
  ///   password: passwordController.text,
  ///   rememberMe: rememberMeCheckbox.value,
  /// );
  /// 
  /// // Login with device tracking
  /// final deviceInfo = await DeviceInfoPlugin().androidInfo;
  /// final trackedResult = await authService.loginWithEmail(
  ///   email: user.email,
  ///   password: user.password,
  ///   deviceId: deviceInfo.androidId,
  /// );
  /// ```
  ///
  /// ## State Changes:
  /// This method triggers the following authentication state changes:
  /// 1. [AuthState.loading] - When authentication starts
  /// 2. [AuthState.authenticated] - On successful authentication
  /// 3. [AuthState.error] - On authentication failure
  ///
  /// ## Performance Considerations:
  /// - Network timeout is set to 30 seconds
  /// - Concurrent login attempts are queued
  /// - Failed attempts are cached to prevent duplicate requests
  /// - Biometric authentication may be prompted on supported devices
  ///
  /// @throws [ArgumentError] if [email] or [password] is null or empty
  /// @throws [StateError] if another authentication operation is in progress
  /// @throws [ValidationException] if input validation fails
  /// @throws [NetworkException] if network connectivity is unavailable
  /// @throws [ServerException] if backend authentication fails
  /// @throws [AccountLockedException] if account is temporarily locked
  ///
  /// @since 1.0.0
  /// @see [registerWithEmail] for user registration
  /// @see [loginWithBiometrics] for biometric authentication
  /// @see [resetPassword] for password recovery
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
    String? deviceId,
  }) async {
    // Implementation details...
  }
}
```

### Method Documentation Examples
```dart
// ✅ SIMPLE METHOD DOCUMENTATION
/// Returns `true` if a user is currently authenticated.
bool get isAuthenticated => _currentUser != null;

// ✅ DETAILED METHOD DOCUMENTATION
/// Validates user registration input according to business rules.
///
/// Performs comprehensive validation including:
/// - Email format validation (RFC 5322)
/// - Password strength requirements (8+ chars, mixed case, numbers, symbols)
/// - Username availability check
/// - Terms of service acceptance
///
/// ## Validation Rules:
/// - Email must be valid format and not already registered
/// - Password must contain at least 8 characters
/// - Password must include uppercase, lowercase, number, and symbol
/// - Username must be 3-20 characters, alphanumeric only
/// - Age must be 13+ years (COPPA compliance)
///
/// ## Example:
/// ```dart
/// final input = RegistrationInput(
///   email: 'newuser@example.com',
///   password: 'SecureP@ss123',
///   username: 'newuser2024',
///   birthDate: DateTime(1990, 1, 1),
///   termsAccepted: true,
/// );
/// 
/// final validation = await validateRegistrationInput(input);
/// if (validation.isValid) {
///   proceedWithRegistration();
/// } else {
///   showValidationErrors(validation.errors);
/// }
/// ```
///
/// ## Returns:
/// [ValidationResult] containing:
/// - `isValid`: Whether all validation passes
/// - `errors`: List of specific validation error messages
/// - `warnings`: List of non-blocking warnings
///
/// ## Throws:
/// - [NetworkException] if email availability check fails
/// - [ValidationException] if critical validation rules fail
///
/// @since 1.0.0
Future<ValidationResult> validateRegistrationInput(
  RegistrationInput input,
) async {
  // Implementation
}

// ✅ WIDGET DOCUMENTATION
/// A reusable authentication form widget that handles user login and registration.
///
/// This widget provides a consistent authentication interface across the
/// application with built-in validation, error handling, and accessibility
/// features. It supports both email/password and social authentication methods.
///
/// ## Features:
/// - Real-time input validation with visual feedback
/// - Password strength indicator
/// - Social login buttons (Google, Apple, Facebook)
/// - Accessibility support with semantic labels
/// - Responsive design for various screen sizes
/// - Loading states with proper user feedback
///
/// ## Example Usage:
```dart
/// ```dart
/// // Basic usage with email/password only
/// AuthFormWidget(
///   mode: AuthMode.login,
///   onSubmit: (credentials) async {
///     final result = await authService.loginWithEmail(
///       email: credentials.email,
///       password: credentials.password,
///     );
///     return result;
///   },
/// )
///
/// // Full-featured form with social login
/// AuthFormWidget(
///   mode: AuthMode.register,
///   enableSocialLogin: true,
///   socialProviders: [
///     SocialProvider.google,
///     SocialProvider.apple,
///   ],
///   onSubmit: (credentials) => authService.registerWithEmail(credentials),
///   onSocialLogin: (provider) => authService.loginWithSocial(provider),
///   onForgotPassword: () => Navigator.pushNamed(context, '/forgot-password'),
/// )
/// ```
///
/// ## Customization:
/// The widget can be customized through [AuthFormTheme] and supports:
/// - Custom color schemes
/// - Custom button styles
/// - Custom validation rules
/// - Custom error messages
/// - Custom loading indicators
///
/// ## Accessibility:
/// - All form fields have semantic labels
/// - Error messages are announced to screen readers
/// - Tab navigation follows logical order
/// - High contrast mode support
/// - Font scaling support
///
/// @param [mode] The authentication mode (login or register)
/// @param [onSubmit] Callback when form is submitted with valid credentials
/// @param [enableSocialLogin] Whether to show social login options
/// @param [socialProviders] List of enabled social authentication providers
/// @param [onSocialLogin] Callback when social login button is pressed
/// @param [theme] Custom theme for the form appearance
/// @param [validator] Custom validator for form inputs
///
/// @since 1.0.0
class AuthFormWidget extends StatefulWidget {
  // Implementation...
}
```

### README Documentation Template
```markdown
# Authentication Feature

A comprehensive authentication system built with Clean Architecture principles, supporting multiple authentication providers and secure session management.

## 🏗️ Architecture Overview

This feature follows Clean Architecture with clear separation of concerns:

```
presentation/     # UI Layer (Widgets, BLoC, Pages)
    ├── bloc/           # State Management
    ├── pages/          # Screen Widgets  
    └── widgets/        # Reusable Components
domain/          # Business Logic Layer
    ├── entities/       # Business Models
    ├── repositories/   # Data Contracts
    └── usecases/       # Business Rules
data/            # Data Layer (APIs, Storage)
    ├── datasources/    # Data Sources
    ├── models/         # Data Models
    └── repositories/   # Data Implementations
```

## 🚀 Key Features

### Authentication Methods
- ✅ Email/Password authentication
- ✅ Social login (Google, Apple, Facebook)
- ✅ Biometric authentication (Face ID, Touch ID, Fingerprint)
- ✅ Phone number verification
- ✅ Magic link authentication

### Security Features
- 🔒 End-to-end encryption for sensitive data
- 🔐 Secure token storage using device keychain
- 🛡️ Automatic token refresh
- 🚫 Brute force protection with rate limiting
- 📱 Device fingerprinting for suspicious activity detection

### User Experience
- ⚡ Real-time form validation
- 🎨 Consistent Material Design 3 UI
- ♿ Full accessibility support
- 🌍 Multi-language support
- 📱 Responsive design for all screen sizes

## 📦 Components

### Core Classes

#### AuthBloc
Manages authentication state using BLoC pattern.

**States:**
- `AuthInitial` - Initial state before any authentication attempt
- `AuthLoading` - Authentication operation in progress
- `AuthAuthenticated` - User successfully authenticated
- `AuthUnauthenticated` - User not authenticated or logged out
- `AuthError` - Authentication failed with error details

**Events:**
- `AuthLoginRequested` - Trigger email/password login
- `AuthSocialLoginRequested` - Trigger social provider login
- `AuthBiometricLoginRequested` - Trigger biometric authentication
- `AuthLogoutRequested` - Trigger user logout
- `AuthTokenRefreshRequested` - Refresh authentication token

#### AuthRepository
Abstract interface defining authentication data operations.

**Methods:**
```dart
Future<Either<Failure, User>> loginWithEmail(String email, String password);
Future<Either<Failure, User>> loginWithSocial(SocialProvider provider);
Future<Either<Failure, User>> loginWithBiometrics();
Future<Either<Failure, User>> registerWithEmail(RegistrationData data);
Future<Either<Failure, void>> logout();
Future<Either<Failure, User>> getCurrentUser();
Future<Either<Failure, void>> resetPassword(String email);
```

#### AuthService
High-level service providing authentication functionality.

**Features:**
- Automatic session management
- Token refresh handling
- Secure credential storage
- Authentication state streaming
- Multi-provider support

## 🔧 Setup & Configuration

### 1. Dependencies
Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dio: ^5.3.2
  get_it: ^7.6.4
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.6
  google_sign_in: ^6.1.5
  sign_in_with_apple: ^5.0.0
```

### 2. Platform Configuration

#### Android Setup
```xml
<!-- android/app/src/main/res/values/strings.xml -->
<resources>
    <string name="google_sign_in_client_id">YOUR_GOOGLE_CLIENT_ID</string>
</resources>
```

#### iOS Setup
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>google</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 3. Dependency Injection Setup
```dart
// core/di/injection_container.dart
void initAuthFeature() {
  // BLoC
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    logoutUseCase: sl(),
    getCurrentUserUseCase: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
}
```

## 📱 Usage Examples

### Basic Login Flow
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: AuthFormWidget(
              mode: AuthMode.login,
              isLoading: state is AuthLoading,
              onSubmit: (credentials) {
                context.read<AuthBloc>().add(
                  AuthLoginRequested(
                    email: credentials.email,
                    password: credentials.password,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

### Social Login Implementation
```dart
class SocialLoginButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialLoginButton(
          provider: SocialProvider.google,
          onPressed: () {
            context.read<AuthBloc>().add(
              AuthSocialLoginRequested(SocialProvider.google),
            );
          },
        ),
        SocialLoginButton(
          provider: SocialProvider.apple,
          onPressed: () {
            context.read<AuthBloc>().add(
              AuthSocialLoginRequested(SocialProvider.apple),
            );
          },
        ),
      ],
    );
  }
}
```

### Biometric Authentication
```dart
class BiometricLoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ElevatedButton.icon(
          icon: Icon(Icons.fingerprint),
          label: Text('Login with Biometrics'),
          onPressed: state is AuthLoading ? null : () {
            context.read<AuthBloc>().add(
              AuthBiometricLoginRequested(),
            );
          },
        );
      },
    );
  }
}
```

## 🧪 Testing

### Unit Tests
```bash
# Run all authentication unit tests
flutter test test/unit/features/auth/

# Run specific test files
flutter test test/unit/features/auth/domain/usecases/login_usecase_test.dart
```

### Widget Tests
```bash
# Run authentication widget tests
flutter test test/widget/features/auth/
```

### Integration Tests
```bash
# Run complete authentication flow tests
flutter test integration_test/auth_flow_test.dart
```

### Test Coverage
Current test coverage: **94%**

- Domain Layer: 98%
- Data Layer: 92%
- Presentation Layer: 91%

## 🔐 Security Considerations

### Data Protection
- All sensitive data encrypted at rest
- Network communications use TLS 1.3
- Credentials never stored in plain text
- Automatic session timeout after inactivity

### Authentication Security
- Password hashing with bcrypt
- JWT tokens with short expiration
- Refresh token rotation
- Device binding for enhanced security

### Privacy Compliance
- GDPR compliant data handling
- User consent management
- Data retention policies
- Right to erasure implementation

## 🚀 Future Enhancements

### Planned Features
- [ ] Multi-factor authentication (2FA)
- [ ] Passwordless authentication
- [ ] Single Sign-On (SSO) integration
- [ ] Account linking between providers
- [ ] Advanced fraud detection
- [ ] Behavioral biometrics

### Performance Improvements
- [ ] Lazy loading of authentication providers
- [ ] Improved caching strategies
- [ ] Reduced app startup time
- [ ] Enhanced offline support

## 📊 Analytics & Monitoring

### Tracked Events
- Login attempts and success rates
- Social provider usage statistics
- Biometric authentication adoption
- Session duration and patterns
- Error rates and types

### Performance Metrics
- Authentication response times
- Token refresh success rates
- Biometric authentication speed
- User drop-off rates in flows

## 🤝 Contributing

### Code Style
- Follow Clean Architecture principles
- Use meaningful variable names
- Write comprehensive documentation
- Include unit tests for all business logic
- Follow the established naming conventions

### Pull Request Process
1. Create feature branch from `develop`
2. Implement changes with tests
3. Update documentation
4. Run quality checks
5. Create pull request with description

## 📄 License

This authentication feature is part of the Flutter Master Template project and is licensed under the MIT License.
```

## 🏷️ Naming Conventions

### File Naming Standards
```
✅ CORRECT EXAMPLES:
user_profile_screen.dart          # Screens/Pages
auth_repository_impl.dart         # Repository implementations
login_use_case.dart              # Use cases
custom_text_field_widget.dart    # Widgets
api_constants.dart               # Constants
string_extensions.dart           # Extensions
auth_bloc.dart                   # BLoC classes
user_model.dart                  # Data models
server_failure.dart              # Error classes

❌ INCORRECT EXAMPLES:
UserProfileScreen.dart           # Should be snake_case
authRepository.dart              # Missing implementation suffix
LoginUseCase.dart               # Should be snake_case
customTextField.dart            # Missing widget suffix
APIConstants.dart               # Should be api_constants
StringExt.dart                  # Should be string_extensions
AuthBLoC.dart                   # Should be auth_bloc
usermodel.dart                  # Should be user_model
serverfailure.dart              # Should be server_failure
```

### Class Naming Standards
```dart
// ✅ CORRECT CLASS NAMES

// Entities (Domain Layer)
class User extends Equatable {}
class Product extends Equatable {}
class Order extends Equatable {}

// Models (Data Layer)
class UserModel extends User {}
class ProductModel extends Product {}
class OrderModel extends Order {}

// Repositories (Interfaces)
abstract class AuthRepository {}
abstract class ProductRepository {}
abstract class OrderRepository {}

// Repository Implementations
class AuthRepositoryImpl implements AuthRepository {}
class ProductRepositoryImpl implements ProductRepository {}
class OrderRepositoryImpl implements OrderRepository {}

// Use Cases
class LoginUseCase implements UseCase<User, LoginParams> {}
class GetProductsUseCase implements UseCase<List<Product>, NoParams> {}
class CreateOrderUseCase implements UseCase<Order, CreateOrderParams> {}

// BLoC Classes
class AuthBloc extends Bloc<AuthEvent, AuthState> {}
class ProductBloc extends Bloc<ProductEvent, ProductState> {}
class OrderBloc extends Bloc<OrderEvent, OrderState> {}

// Events
abstract class AuthEvent extends Equatable {}
class LoginRequested extends AuthEvent {}
class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}

// Widgets
class LoginScreen extends StatefulWidget {}
class ProductCard extends StatelessWidget {}
class CustomButton extends StatelessWidget {}

// Services
class ApiService {}
class StorageService {}
class NotificationService {}

// Failures/Exceptions
class ServerFailure extends Failure {}
class NetworkFailure extends Failure {}
class CacheFailure extends Failure {}

// ❌ INCORRECT CLASS NAMES
class user {} // Should be PascalCase
class userModel {} // Should be PascalCase
class authRepository {} // Should be PascalCase
class LoginUC {} // Should be LoginUseCase
class AuthBLoC {} // Should be AuthBloc
class login_screen {} // Should be PascalCase
class customButton {} // Should be PascalCase
class APIService {} // Should be ApiService
class HTTPClient {} // Should be HttpClient
```

### Variable and Method Naming
```dart
// ✅ CORRECT VARIABLE AND METHOD NAMES
class AuthService {
  // Constants - SCREAMING_SNAKE_CASE
  static const int MAX_LOGIN_ATTEMPTS = 3;
  static const String DEFAULT_ERROR_MESSAGE = 'Authentication failed';
  static const Duration TOKEN_REFRESH_INTERVAL = Duration(minutes: 15);
  
  // Private fields - _camelCase
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  final StreamController<AuthState> _authStateController;
  bool _isInitialized = false;
  
  // Public properties - camelCase
  User? currentUser;
  List<String> validationErrors = [];
  AuthConfiguration authConfig;
  
  // Methods - camelCase with descriptive names
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}
  
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {}
  
  Future<void> logoutAndClearSession() async {}
  
  // Boolean getters/methods - is/has/can/should prefix
  bool get isUserAuthenticated => currentUser != null;
  bool get hasValidSession => _tokenStorage.hasValidToken();
  bool get canUserAccessPremiumFeatures => currentUser?.isPremium ?? false;
  
  bool shouldRefreshToken() => _tokenStorage.isTokenExpiringSoon();
  bool hasPermission(String permission) => currentUser?.hasPermission(permission) ?? false;
  
  // Stream getters - descriptive names
  Stream<AuthState> get authStateStream => _authStateController.stream;
  Stream<User?> get currentUserStream => _userController.stream;
  
  // Private methods - _camelCase
  Future<void> _initializeAuthService() async {}
  void _handleAuthStateChange(AuthState newState) {}
  bool _validateCredentials(String email, String password) {}
}

// ❌ INCORRECT VARIABLE AND METHOD NAMES
class AuthService {
  static const int max_login_attempts = 3; // Should be SCREAMING_SNAKE_CASE
  static const String DefaultErrorMessage = 'Failed'; // Should be SCREAMING_SNAKE_CASE
  
  final AuthRepository AuthRepository; // Should be _camelCase and private
  bool IsAuthenticated = false; // Should be camelCase
  List<String> validation_errors = []; // Should be camelCase
  
  Future<void> LoginWithEmailAndPassword() async {} // Should be camelCase
  bool UserAuthenticated() => true; // Should use 'is' prefix
  bool Check_Permission(String perm) => false; // Should be camelCase
  
  Stream<AuthState> AuthStream() => Stream.empty(); // Should be authStateStream
}
```

### Enum Naming Standards
```dart
// ✅ CORRECT ENUM NAMING
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  expired,
}

enum SocialProvider {
  google,
  apple,
  facebook,
  twitter,
  github,
}

enum UserRole {
  admin,
  moderator,
  user,
  guest,
}

enum NetworkConnectionType {
  wifi,
  mobile,
  ethernet,
  bluetooth,
  none,
}

enum ValidationErrorType {
  invalidEmail,
  weakPassword,
  missingField,
  duplicateValue,
  formatError,
}

// Enhanced enums with methods
enum AuthProvider {
  email('Email & Password'),
  google('Google'),
  apple('Apple ID'),
  facebook('Facebook');

  const AuthProvider(this.displayName);
  
  final String displayName;
  
  bool get requiresExternalApp => this != AuthProvider.email;
  bool get supportsBiometrics => this == AuthProvider.apple;
}

// ❌ INCORRECT ENUM NAMING
enum authStatus {} // Should be PascalCase
enum AUTH_STATUS {} // Should be PascalCase, not SCREAMING_SNAKE_CASE
enum AuthenticationStatus {} // Too verbose, should be AuthStatus
enum SocialProviders {} // Should be singular
enum USER_ROLES {} // Should be PascalCase
```

### Extension Naming
```dart
// ✅ CORRECT EXTENSION NAMING
extension StringExtensions on String {
  bool get isValidEmail => EmailValidator.validate(this);
  bool get isValidPassword => length >= 8;
  String get capitalizeFirst => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

extension DateTimeExtensions on DateTime {
  bool get isToday => DateUtils.isSameDay(this, DateTime.now());
  bool get isYesterday => DateUtils.isSameDay(this, DateTime.now().subtract(Duration(days: 1)));
  String get timeAgo => DateTimeUtils.timeAgoSinceDate(this);
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  NavigatorState get navigator => Navigator.of(this);
  
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

extension AuthStateExtensions on AuthState {
  bool get isLoading => this is AuthLoading;
  bool get isAuthenticated => this is AuthAuthenticated;
  bool get hasError => this is AuthError;
  
  String? get errorMessage => this is AuthError ? (this as AuthError).message : null;
}

// ❌ INCORRECT EXTENSION NAMING
extension stringExt on String {} // Should be PascalCase
extension StringExt on String {} // Should be StringExtensions
extension String_Extensions on String {} // Should be StringExtensions
extension StringUtils on String {} // Should be StringExtensions
```

## 📁 File Organization

### Feature-Based Structure (Following Clean Architecture)
```
lib/
├── core/                          # Shared application core
│   ├── constants/
│   │   ├── api_constants.dart     # API endpoints, keys, timeouts
│   │   ├── app_constants.dart     # App-wide constants
│   │   ├── design_constants.dart  # Design tokens, spacing, sizes
│   │   └── route_constants.dart   # Navigation route constants
│   ├── di/                        # Dependency Injection
│   │   ├── injection_container.dart
│   │   └── service_locator.dart
│   ├── error/                     # Error handling
│   │   ├── failures.dart          # Base failure classes
│   │   ├── exceptions.dart        # Exception definitions
│   │   └── error_handler.dart     # Global error handling
│   ├── network/                   # Network layer
│   │   ├── api_client.dart        # Dio HTTP client setup
│   │   ├── network_info.dart      # Network connectivity
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   └── retry_interceptor.dart
│   │   └── endpoints/
│   │       ├── auth_endpoints.dart
│   │       └── user_endpoints.dart
│   ├── utils/                     # Utility functions
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart
│   │   │   ├── date_time_extensions.dart
│   │   │   ├── build_context_extensions.dart
│   │   │   └── list_extensions.dart
│   │   ├── helpers/
│   │   │   ├── date_helper.dart
│   │   │   ├── url_helper.dart
│   │   │   └── platform_helper.dart
│   │   ├── validators/
│   │   │   ├── email_validator.dart
│   │   │   ├── password_validator.dart
│   │   │   └── phone_validator.dart
│   │   └── formatters/
│   │       ├── currency_formatter.dart
│   │       ├── date_formatter.dart
│   │       └── phone_formatter.dart
│   ├── usecases/                  # Base use case
│   │   ├── usecase.dart
│   │   └── usecase_params.dart
│   ├── security/                  # Security utilities
│   │   ├── encryption_service.dart
│   │   ├── secure_storage.dart
│   │   └── biometric_service.dart
│   └── theme/                     # App theming
│       ├── app_theme.dart
│       ├── color_scheme.dart
│       ├── typography.dart
│       └── component_themes.dart
├── features/                      # Feature modules
│   ├── authentication/            # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_data_source.dart
│   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   └── biometric_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   ├── auth_response_model.dart
│   │   │   │   └── login_request_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user_entity.dart
│   │   │   │   └── auth_token_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_use_case.dart
│   │   │       ├── logout_use_case.dart
│   │   │       ├── register_use_case.dart
│   │   │       ├── forgot_password_use_case.dart
│   │   │       └── get_current_user_use_case.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   ├── auth_state.dart
│   │       │   └── registration_cubit.dart
│   │       ├── pages/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   ├── forgot_password_screen.dart
│   │       │   └── profile_screen.dart
│   │       └── widgets/
│   │           ├── login_form_widget.dart
│   │           ├── registration_form_widget.dart
│   │           ├── social_login_buttons_widget.dart
│   │           ├── biometric_login_widget.dart
│   │           └── password_strength_indicator_widget.dart
│   ├── home/                      # Home feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   └── profile/                   # Profile feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/                        # Shared widgets & components
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── custom_elevated_button.dart
│   │   │   ├── custom_text_button.dart
│   │   │   ├── custom_outlined_button.dart
│   │   │   └── loading_button.dart
│   │   ├── inputs/
│   │   │   ├── custom_text_field.dart
│   │   │   ├── custom_dropdown.dart
│   │   │   ├── custom_checkbox.dart
│   │   │   └── password_field.dart
│   │   ├── indicators/
│   │   │   ├── loading_indicator.dart
│   │   │   ├── progress_indicator.dart
│   │   │   └── connectivity_indicator.dart
│   │   ├── dialogs/
│   │   │   ├── confirmation_dialog.dart
│   │   │   ├── error_dialog.dart
│   │   │   └── loading_dialog.dart
│   │   └── layouts/
│   │       ├── app_scaffold.dart
│   │       ├── responsive_layout.dart
│   │       └── safe_area_wrapper.dart
│   ├── components/
│   │   ├── empty_state_component.dart
│   │   ├── error_state_component.dart
│   │   └── refresh_component.dart
│   └── services/
│       ├── storage_service.dart
│       ├── notification_service.dart
│       └── analytics_service.dart
└── main.dart                      # App entry point
```

### Barrel Export Files
```dart
// lib/features/authentication/authentication.dart
// Main barrel export for authentication feature

// Domain layer exports
export 'domain/entities/user_entity.dart';
export 'domain/entities/auth_token_entity.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/usecases/login_use_case.dart';
export 'domain/usecases/logout_use_case.dart';
export 'domain/usecases/register_use_case.dart';
export 'domain/usecases/get_current_user_use_case.dart';

// Data layer exports (only interfaces, not implementations)
export 'data/models/user_model.dart';
export 'data/models/auth_response_model.dart';

// Presentation layer exports
export 'presentation/bloc/auth_bloc.dart';
export 'presentation/bloc/auth_event.dart';
export 'presentation/bloc/auth_state.dart';
export 'presentation/pages/login_screen.dart';
export 'presentation/pages/register_screen.dart';
export 'presentation/widgets/login_form_widget.dart';
export 'presentation/widgets/social_login_buttons_widget.dart';

// lib/shared/shared.dart
// Barrel export for shared components
export 'widgets/buttons/custom_elevated_button.dart';
export 'widgets/buttons/custom_text_button.dart';
export 'widgets/inputs/custom_text_field.dart';
export 'widgets/indicators/loading_indicator.dart';
export 'widgets/dialogs/confirmation_dialog.dart';
export 'widgets/layouts/app_scaffold.dart';
export 'components/empty_state_component.dart';
export 'services/storage_service.dart';

// lib/core/core.dart
// Barrel export for core utilities
export 'constants/api_constants.dart';
export 'constants/app_constants.dart';
export 'error/failures.dart';
export 'error/exceptions.dart';
export 'network/api_client.dart';
export 'utils/extensions/string_extensions.dart';
export 'utils/extensions/build_context_extensions.dart';
export 'utils/validators/email_validator.dart';
export 'usecases/usecase.dart';
export 'theme/app_theme.dart';
