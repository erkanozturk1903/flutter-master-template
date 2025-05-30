🧭 Navigation & Routing

## Overview

Modern Flutter applications require robust navigation systems that support deep linking, web URLs, and complex navigation flows. This guide establishes comprehensive standards using **GoRouter** as the primary navigation solution for declarative, type-safe routing.

## GoRouter Implementation (Primary)

### Core Benefits

1. **Declarative Routing** - Define routes in a centralized configuration
2. **Deep Linking** - Automatic support for web URLs and mobile deep links
3. **Type Safety** - Compile-time route validation
4. **Web Support** - Browser navigation (back/forward) works seamlessly
5. **Navigation Guards** - Built-in authentication and permission checks

### Router Configuration Structure

```dart
// core/router/app_router.dart
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    initialLocation: _getInitialLocation(),
    redirect: _redirect,
    routes: _routes,
    errorBuilder: _errorBuilder,
  );

  // Route definitions
  static final List<RouteBase> _routes = [
    // Authentication routes (full screen)
    GoRoute(
      path: '/login',
      name: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    
    // Main app with shell navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'profile',
              name: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/products',
          name: AppRoutes.products,
          builder: (context, state) => const ProductsScreen(),
          routes: [
            GoRoute(
              path: '/:productId',
              name: AppRoutes.productDetail,
              builder: (context, state) {
                final productId = state.pathParameters['productId']!;
                final variant = state.uri.queryParameters['variant'];
                return ProductDetailScreen(
                  productId: productId,
                  variant: variant,
                );
              },
            ),
            GoRoute(
              path: '/category/:categoryId',
              name: AppRoutes.productCategory,
              builder: (context, state) {
                final categoryId = state.pathParameters['categoryId']!;
                final sortBy = state.uri.queryParameters['sort'] ?? 'name';
                return ProductCategoryScreen(
                  categoryId: categoryId,
                  sortBy: sortBy,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/cart',
          name: AppRoutes.cart,
          builder: (context, state) => const CartScreen(),
          routes: [
            GoRoute(
              path: '/checkout',
              name: AppRoutes.checkout,
              builder: (context, state) => const CheckoutScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          name: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: '/profile',
              name: AppRoutes.profileSettings,
              builder: (context, state) => const ProfileSettingsScreen(),
            ),
            GoRoute(
              path: '/notifications',
              name: AppRoutes.notificationSettings,
              builder: (context, state) => const NotificationSettingsScreen(),
            ),
            GoRoute(
              path: '/privacy',
              name: AppRoutes.privacySettings,
              builder: (context, state) => const PrivacySettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/orders',
          name: AppRoutes.orders,
          builder: (context, state) => const OrdersScreen(),
          routes: [
            GoRoute(
              path: '/:orderId',
              name: AppRoutes.orderDetail,
              builder: (context, state) {
                final orderId = state.pathParameters['orderId']!;
                return OrderDetailScreen(orderId: orderId);
              },
            ),
          ],
        ),
      ],
    ),
    
    // Modal routes
    GoRoute(
      path: '/search',
      name: AppRoutes.search,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
            ),
            child: child,
          );
        },
      ),
    ),
  ];

  // Initial location logic
  static String _getInitialLocation() {
    final isAuthenticated = getIt<AuthService>().isAuthenticated;
    return isAuthenticated ? '/' : '/login';
  }

  // Navigation guard
  static String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = getIt<AuthService>().isAuthenticated;
    final isAuthRoute = _isAuthRoute(state.location);
    final isPublicRoute = _isPublicRoute(state.location);

    // Allow access to public routes
    if (isPublicRoute) return null;

    // Redirect to login if not authenticated and not on auth route
    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    // Redirect to home if authenticated and on auth route
    if (isAuthenticated && isAuthRoute) {
      return '/';
    }

    // Check user permissions for protected routes
    if (!_hasPermissionForRoute(state.location)) {
      return '/unauthorized';
    }

    return null; // No redirect needed
  }

  // Error handling
  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return ErrorScreen(
      error: state.error?.toString() ?? 'Unknown error',
      onRetry: () => context.go('/'),
    );
  }

  // Helper methods
  static bool _isAuthRoute(String location) {
    const authRoutes = ['/login', '/register', '/forgot-password'];
    return authRoutes.contains(location);
  }

  static bool _isPublicRoute(String location) {
    const publicRoutes = ['/privacy-policy', '/terms-of-service'];
    return publicRoutes.contains(location);
  }

  static bool _hasPermissionForRoute(String location) {
    // Implement permission checking logic
    final userRole = getIt<AuthService>().currentUser?.role;
    
    if (location.startsWith('/admin')) {
      return userRole == UserRole.admin;
    }
    
    if (location.startsWith('/moderator')) {
      return userRole == UserRole.admin || userRole == UserRole.moderator;
    }
    
    return true; // Allow access to regular routes
  }
}
```

### Route Names Constants

```dart
// core/router/app_routes.dart
class AppRoutes {
  // Authentication
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  
  // Main app
  static const String home = 'home';
  static const String profile = 'profile';
  
  // Products
  static const String products = 'products';
  static const String productDetail = 'product-detail';
  static const String productCategory = 'product-category';
  
  // Shopping
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String orders = 'orders';
  static const String orderDetail = 'order-detail';
  
  // Settings
  static const String settings = 'settings';
  static const String profileSettings = 'profile-settings';
  static const String notificationSettings = 'notification-settings';
  static const String privacySettings = 'privacy-settings';
  
  // Modal/Overlay
  static const String search = 'search';
  
  // Error
  static const String unauthorized = 'unauthorized';
  static const String notFound = 'not-found';
}
```

## Type-Safe Navigation Extensions

### Navigation Extension Methods

```dart
// core/router/navigation_extensions.dart
extension GoRouterExtensions on BuildContext {
  // Authentication navigation
  void goToLogin() => go('/login');
  void goToRegister() => go('/register');
  void goToForgotPassword() => go('/forgot-password');
  
  // Main app navigation
  void goToHome() => go('/');
  void goToProfile() => go('/profile');
  
  // Product navigation
  void goToProducts() => go('/products');
  
  void goToProductDetail(String productId, {String? variant}) {
    String path = '/products/$productId';
    if (variant != null) {
      path += '?variant=$variant';
    }
    go(path);
  }
  
  void goToProductCategory(String categoryId, {String sortBy = 'name'}) {
    go('/products/category/$categoryId?sort=$sortBy');
  }
  
  // Shopping navigation
  void goToCart() => go('/cart');
  void goToCheckout() => go('/cart/checkout');
  
  void goToOrders() => go('/orders');
  void goToOrderDetail(String orderId) => go('/orders/$orderId');
  
  // Settings navigation
  void goToSettings() => go('/settings');
  void goToProfileSettings() => go('/settings/profile');
  void goToNotificationSettings() => go('/settings/notifications');
  
  // Modal navigation
  void showSearch() => push('/search');
  
  // Utility methods
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
  
  void goToWithClearStack(String location) {
    go(location);
    // Clear navigation stack for fresh start
  }
  
  // Named route navigation with parameters
  void goToNamedRoute(String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }
}

// Usage examples
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text('\$${product.price}'),
        onTap: () => context.goToProductDetail(
          product.id,
          variant: product.defaultVariant,
        ),
      ),
    );
  }
}
```

## Shell Navigation Implementation

### Main Shell Structure

```dart
// shared/layouts/main_shell.dart
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavBar(),
      drawer: const AppDrawer(),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).location;
    
    return NavigationBar(
      selectedIndex: _getSelectedIndex(currentLocation),
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          selectedIcon: Icon(Icons.shopping_bag),
          label: 'Products',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/products')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/orders')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/settings')) return 4;
    return 0; // Default to home
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goToHome();
        break;
      case 1:
        context.goToProducts();
        break;
      case 2:
        context.goToCart();
        break;
      case 3:
        context.goToOrders();
        break;
      case 4:
        context.goToProfile();
        break;
    }
  }
}
```

## Deep Linking & URL Handling

### URL Structure Standards

```
// Authentication
/login
/register
/forgot-password

// Main content
/                           # Home
/profile                    # User profile
/products                   # Product list
/products/123               # Product detail
/products/123?variant=red   # Product with variant
/products/category/electronics?sort=price  # Category with sorting
/cart                       # Shopping cart
/cart/checkout             # Checkout process
/orders                    # Order history
/orders/ORD-123            # Order detail
/settings                  # Settings
/settings/profile          # Profile settings
/settings/notifications    # Notification settings

// Modal/Overlay
/search                    # Search overlay
```

### Deep Link Handler

```dart
// core/services/deep_link_service.dart
class DeepLinkService {
  static void initialize() {
    // Handle incoming deep links when app is running
    _linkStream = linkStream.listen(
      _handleIncomingLink,
      onError: (err) => debugPrint('Deep link error: $err'),
    );
    
    // Handle deep link when app is launched
    _handleInitialLink();
  }

  static StreamSubscription<String>? _linkStream;

  static Future<void> _handleInitialLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error handling initial link: $e');
    }
  }

  static void _handleIncomingLink(String link) {
    final uri = Uri.parse(link);
    
    // Route based on deep link structure
    switch (uri.pathSegments.first) {
      case 'product':
        if (uri.pathSegments.length > 1) {
          final productId = uri.pathSegments[1];
          final variant = uri.queryParameters['variant'];
          AppRouter.router.go('/products/$productId${variant != null ? '?variant=$variant' : ''}');
        }
        break;
        
      case 'category':
        if (uri.pathSegments.length > 1) {
          final categoryId = uri.pathSegments[1];
          final sort = uri.queryParameters['sort'] ?? 'name';
          AppRouter.router.go('/products/category/$categoryId?sort=$sort');
        }
        break;
        
      case 'order':
        if (uri.pathSegments.length > 1) {
          final orderId = uri.pathSegments[1];
          AppRouter.router.go('/orders/$orderId');
        }
        break;
        
      case 'profile':
        AppRouter.router.go('/profile');
        break;
        
      case 'cart':
        AppRouter.router.go('/cart');
        break;
        
      default:
        AppRouter.router.go('/');
    }
  }

  static void dispose() {
    _linkStream?.cancel();
  }
}

// Usage in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await di.init();
  DeepLinkService.initialize();
  
  runApp(const MyApp());
}
```

## Custom Page Transitions

### Transition Animations

```dart
// core/router/page_transitions.dart
class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final RouteTransitionsBuilder transitionsBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
    );
  }
}

// Predefined transition builders
class PageTransitions {
  static RouteTransitionsBuilder get slideFromBottom => (
    context,
    animation,
    secondaryAnimation,
    child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: child,
    );
  };

  static RouteTransitionsBuilder get slideFromRight => (
    context,
    animation,
    secondaryAnimation,
    child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: child,
    );
  };

  static RouteTransitionsBuilder get fadeIn => (
    context,
    animation,
    secondaryAnimation,
    child,
  ) {
    return FadeTransition(
      opacity: animation.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: child,
    );
  };

  static RouteTransitionsBuilder get scaleUp => (
    context,
    animation,
    secondaryAnimation,
    child,
  ) {
    return ScaleTransition(
      scale: animation.drive(
        Tween(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  };
}

// Usage in route definitions
GoRoute(
  path: '/product-detail/:id',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: ProductDetailScreen(
      productId: state.pathParameters['id']!,
    ),
    transitionsBuilder: PageTransitions.slideFromRight,
  ),
),
```

## Navigation State Management

### Navigation State BLoC

```dart
// features/navigation/presentation/bloc/navigation_bloc.dart
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
  @override
  List<Object> get props => [];
}

class NavigateToRoute extends NavigationEvent {
  const NavigateToRoute(this.route, {this.clearStack = false});
  
  final String route;
  final bool clearStack;
  
  @override
  List<Object> get props => [route, clearStack];
}

class NavigateBack extends NavigationEvent {
  const NavigateBack();
}

class NavigationHistoryChanged extends NavigationEvent {
  const NavigationHistoryChanged(this.currentRoute);
  
  final String currentRoute;
  
  @override
  List<Object> get props => [currentRoute];
}

abstract class NavigationState extends Equatable {
  const NavigationState();
  @override
  List<Object> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigationInProgress extends NavigationState {}

class NavigationCompleted extends NavigationState {
  const NavigationCompleted(this.currentRoute);
  
  final String currentRoute;
  
  @override
  List<Object> get props => [currentRoute];
}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial()) {
    on<NavigateToRoute>(_onNavigateToRoute);
    on<NavigateBack>(_onNavigateBack);
    on<NavigationHistoryChanged>(_onNavigationHistoryChanged);
  }

  final List<String> _navigationHistory = [];

  Future<void> _onNavigateToRoute(
    NavigateToRoute event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationInProgress());
    
    try {
      if (event.clearStack) {
        _navigationHistory.clear();
      }
      
      _navigationHistory.add(event.route);
      
      // Perform navigation
      AppRouter.router.go(event.route);
      
      emit(NavigationCompleted(event.route));
    } catch (e) {
      // Handle navigation error
      emit(NavigationCompleted(_navigationHistory.last));
    }
  }

  Future<void> _onNavigateBack(
    NavigateBack event,
    Emitter<NavigationState> emit,
  ) async {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      final previousRoute = _navigationHistory.last;
      
      AppRouter.router.go(previousRoute);
      emit(NavigationCompleted(previousRoute));
    }
  }

  void _onNavigationHistoryChanged(
    NavigationHistoryChanged event,
    Emitter<NavigationState> emit,
  ) {
    if (_navigationHistory.isEmpty || _navigationHistory.last != event.currentRoute) {
      _navigationHistory.add(event.currentRoute);
    }
    emit(NavigationCompleted(event.currentRoute));
  }

  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
}
```

## Testing Navigation

### Navigation Testing

```dart
// test/navigation/app_router_test.dart
void main() {
  group('AppRouter', () {
    testWidgets('redirects to login when not authenticated', (tester) async {
      // Mock auth service to return false
      when(mockAuthService.isAuthenticated).thenReturn(false);
      
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );
      
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('allows access to home when authenticated', (tester) async {
      // Mock auth service to return true
      when(mockAuthService.isAuthenticated).thenReturn(true);
      
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );
      
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('navigates to product detail with correct parameters', (tester) async {
      const productId = 'test-product-123';
      
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
          routerDelegate: AppRouter.router.routerDelegate,
        ),
      );
      
      // Navigate to product detail
      AppRouter.router.go('/products/$productId');
      await tester.pumpAndSettle();
      
      expect(find.byType(ProductDetailScreen), findsOneWidget);
      
      // Verify product ID is passed correctly
      final productDetailWidget = tester.widget<ProductDetailScreen>(
        find.byType(ProductDetailScreen),
      );
      expect(productDetailWidget.productId, equals(productId));
    });
  });
}
```

## Best Practices Summary

### Navigation Guidelines

1. **Centralized Configuration** - Define all routes in one place
2. **Type Safety** - Use extensions for compile-time safety
3. **Deep Link Support** - Handle all navigation scenarios
4. **Navigation Guards** - Implement proper authentication checks
5. **Error Handling** - Always provide fallback routes
6. **Performance** - Use shell routes for better UX
7. **Testing** - Test all navigation scenarios

### Common Patterns

- Use named routes for better maintainability
- Implement navigation extensions for type safety
- Handle navigation state in BLoC when needed
- Test navigation flows thoroughly
- Support web navigation patterns
- Implement proper error boundaries

### Anti-Patterns to Avoid

- Don't use Navigator.push directly (use GoRouter)
- Avoid hardcoded route strings in widgets
- Don't ignore navigation guards
- Avoid complex navigation logic in widgets
- Don't forget to handle deep links

