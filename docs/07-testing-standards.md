
# 07. Testing Standards

> **Complete Flutter Testing Guide** - Unit tests, Widget tests, Integration tests, and BLoC testing standards for production-ready applications.

## 📋 Table of Contents

- [Testing Philosophy](#-testing-philosophy)
- [Test Pyramid Structure](#-test-pyramid-structure)
- [Unit Testing](#-unit-testing)
- [Widget Testing](#-widget-testing)
- [Integration Testing](#-integration-testing)
- [BLoC Testing](#-bloc-testing)
- [Test Utilities & Helpers](#-test-utilities--helpers)
- [Mocking Strategies](#-mocking-strategies)
- [CI/CD Integration](#-cicd-integration)
- [Code Coverage](#-code-coverage)
- [Testing Best Practices](#-testing-best-practices)

## 🎯 Testing Philosophy

### Core Principles
```yaml
Testing Strategy:
  - Write tests first (TDD approach)
  - Test behavior, not implementation
  - Maintain 80%+ code coverage
  - Fast, reliable, isolated tests
  - Readable test descriptions
```

### Test Types Distribution
```
Integration Tests (10%) - E2E user flows
Widget Tests (20%) - UI components
Unit Tests (70%) - Business logic
```

## 🏗️ Test Pyramid Structure

### Project Test Organization
```
test/
├── unit/
│   ├── core/
│   ├── features/
│   └── shared/
├── widget/
│   ├── features/
│   └── shared/
├── integration/
│   ├── flows/
│   └── scenarios/
├── helpers/
│   ├── test_helpers.dart
│   ├── mock_data.dart
│   └── test_utils.dart
└── fixtures/
    ├── api_responses/
    └── test_data/
```

## 🧪 Unit Testing

### Business Logic Testing
```dart
// test/unit/features/auth/domain/use_cases/login_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tUser = User(id: '1', email: tEmail);

    test('should return User when login is successful', () async {
      // Arrange
      when(mockRepository.login(any, any))
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(LoginParams(
        email: tEmail,
        password: tPassword,
      ));

      // Assert
      expect(result, Right(tUser));
      verify(mockRepository.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when login fails', () async {
      // Arrange
      const tFailure = ServerFailure('Login failed');
      when(mockRepository.login(any, any))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(LoginParams(
        email: tEmail,
        password: tPassword,
      ));

      // Assert
      expect(result, const Left(tFailure));
    });
  });
}
```

### Model Testing
```dart
// test/unit/features/auth/data/models/user_model_test.dart
void main() {
  group('UserModel', () {
    const tUserModel = UserModel(
      id: '1',
      email: 'test@example.com',
      name: 'Test User',
    );

    test('should be a subclass of User entity', () {
      expect(tUserModel, isA<User>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': '1',
          'email': 'test@example.com',
          'name': 'Test User',
        };

        // Act
        final result = UserModel.fromJson(jsonMap);

        // Assert
        expect(result, tUserModel);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tUserModel.toJson();

        // Assert
        final expectedMap = {
          'id': '1',
          'email': 'test@example.com',
          'name': 'Test User',
        };
        expect(result, expectedMap);
      });
    });
  });
}
```

## 🎨 Widget Testing

### Custom Widget Testing
```dart
// test/widget/shared/widgets/custom_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('should display correct text and handle tap', (tester) async {
      // Arrange
      bool wasPressed = false;
      const buttonText = 'Test Button';

      // Act
      await tester.pumpWidget(
        TestHelpers.makeTestableWidget(
          child: CustomButton(
            text: buttonText,
            onPressed: () => wasPressed = true,
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Test tap
      await tester.tap(find.byType(CustomButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestHelpers.makeTestableWidget(
          child: const CustomButton(
            text: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });
  });
}
```

### Screen Widget Testing
```dart
// test/widget/features/auth/presentation/pages/login_page_test.dart
void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  group('LoginPage Widget Tests', () {
    testWidgets('should display all required elements', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(
        TestHelpers.makeTestableWidget(
          child: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(CustomButton), findsOneWidget);
    });

    testWidgets('should validate form fields', (tester) async {
      // Test form validation logic
      await tester.pumpWidget(
        TestHelpers.makeTestableWidget(
          child: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Try to submit empty form
      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
```

## 🔄 Integration Testing

### E2E User Flow Testing
```dart
// integration_test/auth_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    testWidgets('complete login flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Fill login form
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Submit form
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.byKey(const Key('home_screen')), findsOneWidget);
    });

    testWidgets('logout flow', (tester) async {
      // Assuming user is already logged in
      await tester.tap(find.byKey(const Key('profile_menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify logout
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
```

## 🧊 BLoC Testing

### BLoC State Testing
```dart
// test/unit/features/auth/presentation/blocs/auth_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    authBloc = AuthBloc(
      login: mockLoginUseCase,
      logout: mockLogoutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(mockLoginUseCase(any))
            .thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockLoginUseCase(any))
            .thenAnswer((_) async => const Left(ServerFailure('Login failed')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        const AuthError('Login failed'),
      ],
    );
  });
}
```

### Cubit Testing
```dart
// test/unit/features/counter/presentation/cubits/counter_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterCubit', () {
    late CounterCubit counterCubit;

    setUp(() {
      counterCubit = CounterCubit();
    });

    tearDown(() {
      counterCubit.close();
    });

    test('initial state is 0', () {
      expect(counterCubit.state, 0);
    });

    blocTest<CounterCubit, int>(
      'emits [1] when increment is called',
      build: () => counterCubit,
      act: (cubit) => cubit.increment(),
      expect: () => [1],
    );

    blocTest<CounterCubit, int>(
      'emits [-1] when decrement is called',
      build: () => counterCubit,
      act: (cubit) => cubit.decrement(),
      expect: () => [-1],
    );
  });
}
```

## 🛠️ Test Utilities & Helpers

### Test Helper Class
```dart
// test/helpers/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  static Widget makeTestableWidget({
    required Widget child,
    ThemeData? theme,
    Locale? locale,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      locale: locale ?? const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      home: child,
    );
  }

  static Widget makeTestableWidgetWithRouter({
    required Widget child,
    String initialRoute = '/',
  }) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        '/': (context) => child,
      },
    );
  }

  static Future<void> pumpWidgetWithMaterialApp(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(
      makeTestableWidget(child: widget),
    );
  }
}
```

### Mock Data Factory
```dart
// test/helpers/mock_data.dart
class MockData {
  static const User mockUser = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
  );

  static List<Product> get mockProducts => [
    const Product(id: '1', name: 'Product 1', price: 100),
    const Product(id: '2', name: 'Product 2', price: 200),
  ];

  static Map<String, dynamic> get userJsonResponse => {
    'id': '1',
    'email': 'test@example.com',
    'name': 'Test User',
    'created_at': '2024-01-01T00:00:00Z',
  };

  static String get successApiResponse => '''
    {
      "success": true,
      "data": ${jsonEncode(userJsonResponse)},
      "message": "Success"
    }
  ''';
}
```

## 🎭 Mocking Strategies

### Repository Mocking
```dart
// test/unit/features/auth/data/repositories/auth_repository_impl_test.dart
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('login', () {
    test('should return User when network call is successful', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.login(any, any))
          .thenAnswer((_) async => tUserModel);

      // Act
      final result = await repository.login('email', 'password');

      // Assert
      verify(mockRemoteDataSource.login('email', 'password'));
      expect(result, equals(Right(tUserModel)));
    });
  });
}
```

### HTTP Client Mocking
```dart
// Using http_mock_adapter for Dio testing
void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ApiService apiService;

  setUp(() {
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    apiService = ApiService(dio);
  });

  group('ApiService', () {
    test('should return user data when API call succeeds', () async {
      // Arrange
      const path = '/auth/login';
      dioAdapter.onPost(
        path,
        (server) => server.reply(200, MockData.userJsonResponse),
        data: anyNamed('data'),
      );

      // Act
      final result = await apiService.login('email', 'password');

      // Assert
      expect(result['id'], '1');
      expect(result['email'], 'test@example.com');
    });
  });
}
```

## 🔄 CI/CD Integration

### GitHub Actions Test Workflow
```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Run analyzer
      run: flutter analyze
      
    - name: Run unit tests
      run: flutter test --coverage
      
    - name: Run widget tests
      run: flutter test test/widget/
      
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
```

### Test Scripts
```bash
#!/bin/bash
# scripts/run_tests.sh

echo "🧪 Running Flutter Tests..."

# Run analyzer
echo "📊 Running analyzer..."
flutter analyze

# Run unit tests with coverage
echo "🔬 Running unit tests..."
flutter test --coverage test/unit/

# Run widget tests
echo "🎨 Running widget tests..."
flutter test test/widget/

# Run integration tests
echo "🔄 Running integration tests..."
flutter test integration_test/

# Generate coverage report
echo "📈 Generating coverage report..."
lcov --list coverage/lcov.info

echo "✅ All tests completed!"
```

## 📊 Code Coverage

### Coverage Configuration
```dart
// test_coverage.yaml
coverage:
  min_coverage: 80
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - '**/main.dart'
    - 'lib/core/constants/**'
    - 'lib/generated/**'
  
  report_on:
    - lib/features/**
    - lib/core/use_cases/**
    - lib/core/utils/**
```

### Coverage Analysis
```bash
# Generate detailed coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# View coverage by package
lcov --list coverage/lcov.info | grep -E "(features|core)"

# Check coverage threshold
flutter test --coverage && \
lcov --summary coverage/lcov.info | \
grep -E "lines......: [0-9]+\.[0-9]+%" | \
awk '{if ($2 < 80.0) exit 1}'
```

## ✅ Testing Best Practices

### Naming Conventions
```dart
// ✅ Good test descriptions
test('should return User when login credentials are valid')
test('should throw ValidationException when email is invalid')
test('should emit AuthLoading then AuthError when network fails')

// ❌ Poor test descriptions  
test('login test')
test('test user validation')
test('bloc test')
```

### Test Organization
```dart
group('AuthBloc', () {
  group('LoginEvent', () {
    group('when credentials are valid', () {
      test('should emit AuthAuthenticated state');
    });
    
    group('when credentials are invalid', () {
      test('should emit AuthError state');
    });
  });
});
```

### Setup and Teardown
```dart
void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;

  setUpAll(() {
    // One-time setup for all tests
    registerFallbackValue(MockUser());
  });

  setUp(() {
    // Setup before each test
    mockRepository = MockAuthRepository();
    authBloc = AuthBloc(mockRepository);
  });

  tearDown(() {
    // Cleanup after each test
    authBloc.close();
  });

  tearDownAll(() {
    // One-time cleanup after all tests
  });
}
```

### Golden Tests
```dart
// test/widget/golden/login_page_golden_test.dart
void main() {
  group('LoginPage Golden Tests', () {
    testWidgets('login page matches golden file', (tester) async {
      await tester.pumpWidget(
        TestHelpers.makeTestableWidget(
          child: const LoginPage(),
        ),
      );
      
      await expectLater(
        find.byType(LoginPage),
        matchesGoldenFile('golden/login_page.png'),
      );
    });
  });
}
```

---

## 📚 Essential Testing Packages

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.5
  mockito: ^5.4.2
  build_runner: ^2.4.7
  http_mock_adapter: ^0.4.4
  integration_test:
    sdk: flutter
  patrol: ^2.6.0  # Advanced integration testing
```

## 🎯 Testing Checklist

- [ ] Unit tests for all use cases and business logic
- [ ] Widget tests for custom widgets and screens  
- [ ] BLoC/Cubit tests for all state management
- [ ] Integration tests for critical user flows
- [ ] Mock all external dependencies
- [ ] Maintain 80%+ code coverage
- [ ] Golden tests for UI consistency
- [ ] Performance tests for heavy operations
- [ ] Error handling tests
- [ ] Edge case coverage

