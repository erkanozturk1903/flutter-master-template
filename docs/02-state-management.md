Süper! 🎉 **İkinci döküman:**

## 🎯 **02. State Management Standards**

**"Create new file"** → **Dosya yolu:** `docs/02-state-management.md`

**İçerik:**

# 🎯 State Management Standards

## Overview

State management is the backbone of any Flutter application. This guide establishes comprehensive standards for managing application state using **BLoC pattern** as the primary approach, with **Cubit** for simpler scenarios and **Riverpod** as an alternative for specific use cases.

## BLoC Pattern Implementation (Primary)

### Core Principles

1. **Unidirectional Data Flow** - Events trigger state changes
2. **Separation of Concerns** - Business logic separate from UI
3. **Testability** - Easy to unit test business logic
4. **Predictability** - State changes are explicit and traceable

### BLoC Architecture Flow

```
┌─────────────┐    Events    ┌─────────────┐    States    ┌─────────────┐
│    Widget   │ ──────────► │    BLoC     │ ──────────► │   Widget    │
│             │             │             │             │  (Rebuild)  │
└─────────────┘             └─────────────┘             └─────────────┘
                                   │
                                   ▼
                            ┌─────────────┐
                            │  Use Cases  │
                            │ (Business   │
                            │   Logic)    │
                            └─────────────┘
```

### Event Definition Standards

```dart
// Base event class
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Specific events
class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  List<Object?> get props => [isAuthenticated];
}

// Events with optional parameters
class LoadUserProfile extends AuthEvent {
  const LoadUserProfile({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}
```

### State Definition Standards

```dart
// Base state class
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Loading states
class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthLoginLoading extends AuthState {
  const AuthLoginLoading();
}

// Success states
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    this.isFirstLogin = false,
  });

  final User user;
  final bool isFirstLogin;

  @override
  List<Object?> get props => [user, isFirstLogin];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// Error states
class AuthError extends AuthState {
  const AuthError({
    required this.message,
    this.errorCode,
  });

  final String message;
  final String? errorCode;

  @override
  List<Object?> get props => [message, errorCode];
}

class AuthLoginError extends AuthState {
  const AuthLoginError({
    required this.message,
    this.fieldErrors,
  });

  final String message;
  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}
```

### BLoC Implementation Standards

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
    required this.registerUsecase,
  }) : super(const AuthInitial()) {
    // Register event handlers
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoadUserProfile>(_onLoadUserProfile);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    
    // Initialize with current auth status
    add(const LoadUserProfile());
  }

  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final RegisterUsecase registerUsecase;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoginLoading());

    final result = await loginUsecase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(AuthLoginError(
            message: failure.message,
            fieldErrors: failure.fieldErrors,
          ));
        } else {
          emit(AuthLoginError(message: failure.message));
        }
      },
      (user) {
        emit(AuthAuthenticated(
          user: user,
          isFirstLogin: user.isFirstLogin,
        ));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUsecase(NoParams());

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    if (!event.forceRefresh && state is AuthAuthenticated) {
      return; // Don't reload if already authenticated and not forced
    }

    emit(const AuthLoading());

    final result = await getCurrentUserUsecase(NoParams());

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated) {
      add(const LoadUserProfile(forceRefresh: true));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    // Clean up resources if needed
    return super.close();
  }
}
```

### BLoC Widget Integration

```dart
// BlocProvider setup
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: const AuthView(),
    );
  }
}

// BlocBuilder usage
class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle side effects
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            if (state.isFirstLogin) {
              context.go('/welcome');
            } else {
              context.go('/home');
            }
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthLoginLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AuthUnauthenticated || state is AuthLoginError) {
            return const LoginForm();
          }

          if (state is AuthAuthenticated) {
            return const HomeScreen();
          }

          return const LoginForm(); // Default fallback
        },
      ),
    );
  }
}

// Specific BlocBuilder for optimization
class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        // Only rebuild when user data changes
        return current is AuthAuthenticated && 
               (previous is! AuthAuthenticated || 
                previous.user != current.user);
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return UserCard(user: state.user);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```

## Cubit for Simple State (Secondary)

### When to Use Cubit

- Simple state without complex business logic
- UI-focused state (toggles, form validation)
- Local component state
- Quick prototyping

### Cubit Implementation

```dart
// Simple toggle cubit
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void toggleTheme() {
    switch (state) {
      case ThemeMode.system:
        emit(ThemeMode.light);
        break;
      case ThemeMode.light:
        emit(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        emit(ThemeMode.system);
        break;
    }
  }

  void setTheme(ThemeMode theme) => emit(theme);
}

// Counter cubit with state
class CounterState extends Equatable {
  const CounterState({
    required this.count,
    this.isLoading = false,
    this.error,
  });

  final int count;
  final bool isLoading;
  final String? error;

  CounterState copyWith({
    int? count,
    bool? isLoading,
    String? error,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [count, isLoading, error];
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(count: 0));

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }

  Future<void> incrementAsync() async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(
        count: state.count + 1,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void reset() => emit(const CounterState(count: 0));
}
```

## Riverpod Alternative (For Specific Cases)

### When to Use Riverpod

- Small to medium projects
- Rapid prototyping
- Global state with simple dependencies
- Team prefers functional programming

### Provider Definitions

```dart
// Simple providers
final counterProvider = StateProvider<int>((ref) => 0);

final userProvider = FutureProvider<User>((ref) async {
  final authService = ref.read(authServiceProvider);
  return authService.getCurrentUser();
});

// StateNotifier for complex state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUsecase: ref.read(loginUsecaseProvider),
    logoutUsecase: ref.read(logoutUsecaseProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required this.loginUsecase,
    required this.logoutUsecase,
  }) : super(const AuthInitial());

  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;

  Future<void> login(String email, String password) async {
    state = const AuthLoading();

    final result = await loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthError(message: failure.message),
      (user) => state = AuthAuthenticated(user: user),
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();
    
    final result = await logoutUsecase(NoParams());
    
    result.fold(
      (failure) => state = AuthError(message: failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }
}

// Family providers for parameterized data
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.getUser(userId);
});
```

### Consumer Widget Usage

```dart
class AuthView extends ConsumerWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: authState.when(
        initial: () => const LoginForm(),
        loading: () => const Center(child: CircularProgressIndicator()),
        authenticated: (user) => HomeScreen(user: user),
        unauthenticated: () => const LoginForm(),
        error: (message) => ErrorWidget(message: message),
      ),
    );
  }
}

// Listening to changes
class UserProfileView extends ConsumerWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    final authState = ref.watch(authStateProvider);
    
    if (authState is AuthAuthenticated) {
      return UserCard(user: authState.user);
    }
    
    return const SizedBox.shrink();
  }
}
```

## State Management Best Practices

### General Guidelines

1. **Single Source of Truth** - One state holder per feature
2. **Immutable State** - Never mutate state objects directly
3. **Explicit State Changes** - All state changes should be traceable
4. **Error Handling** - Always handle both success and failure states
5. **Loading States** - Show appropriate loading indicators

### Performance Optimization

```dart
// Use buildWhen to optimize rebuilds
BlocBuilder<AuthBloc, AuthState>(
  buildWhen: (previous, current) {
    // Only rebuild when authentication status changes
    return previous.runtimeType != current.runtimeType;
  },
  builder: (context, state) {
    return AuthStatusWidget(isAuthenticated: state is AuthAuthenticated);
  },
)

// Use select for granular updates (Riverpod)
final userName = ref.watch(
  userProvider.select((user) => user.when(
    data: (user) => user.name,
    loading: () => 'Loading...',
    error: (_, __) => 'Error',
  )),
);

// Separate BLoCs for different concerns
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  // Handle user profile specific logic
}

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  // Handle user settings specific logic
}
```

### Testing State Management

```dart
// BLoC testing
void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockLoginUsecase mockLoginUsecase;

    setUp(() {
      mockLoginUsecase = MockLoginUsecase();
      authBloc = AuthBloc(loginUsecase: mockLoginUsecase);
    });

    tearDown(() {
      authBloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(mockLoginUsecase(any))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'test@example.com',
        password: 'password',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(user: tUser),
      ],
    );
  });
}
```

### State Persistence

```dart
// Hydrated BLoC for state persistence
class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial());

  @override
  AuthState fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String;
      if (type == 'AuthAuthenticated') {
        return AuthAuthenticated(
          user: User.fromJson(json['user'] as Map<String, dynamic>),
        );
      }
      return const AuthInitial();
    } catch (_) {
      return const AuthInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthAuthenticated) {
      return {
        'type': 'AuthAuthenticated',
        'user': state.user.toJson(),
      };
    }
    return null;
  }
}
```

## Common Patterns and Anti-Patterns

### ✅ Good Patterns

```dart
// Good: Separate events for different actions
class LoadUser extends AuthEvent {}
class RefreshUser extends AuthEvent {}
class UpdateUser extends AuthEvent {}

// Good: Descriptive state names
class UserLoadingState extends UserState {}
class UserLoadedState extends UserState {}
class UserErrorState extends UserState {}

// Good: Handle all state transitions
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    switch (state.runtimeType) {
      case AuthError:
        _showErrorDialog((state as AuthError).message);
        break;
      case AuthAuthenticated:
        _navigateToHome();
        break;
    }
  },
  child: child,
);
```

### ❌ Anti-Patterns

```dart
// Bad: Generic events
class AuthEvent {} // Too generic

// Bad: Mutable state
class AuthState {
  User? user; // Mutable, can cause issues
  void setUser(User user) => this.user = user;
}

// Bad: Business logic in widgets
onPressed: () {
  // Bad: API call in widget
  final response = await apiService.login(email, password);
  if (response.success) {
    Navigator.push(...);
  }
}

// Bad: Not handling all states
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoaded) {
      return UserWidget();
    }
    // Missing other state handling
    return Container(); // What about loading? error?
  },
)
```

## Migration Strategies

### From StatefulWidget to BLoC

```dart
// Before: StatefulWidget with local state
class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> users = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final result = await userRepository.getUsers();
      setState(() {
        users = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }
}

// After: BLoC with proper state management
class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserListBloc()..add(LoadUsers()),
      child: BlocBuilder<UserListBloc, UserListState>(
        builder: (context, state) {
          if (state is UserListLoading) {
            return LoadingWidget();
          } else if (state is UserListLoaded) {
            return UserListWidget(users: state.users);
          } else if (state is UserListError) {
            return ErrorWidget(message: state.message);
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
```

