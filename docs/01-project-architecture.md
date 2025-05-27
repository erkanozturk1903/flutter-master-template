Perfect kral! 🔥 **Tek tek gidelim!** Böylece her bölüm kendi commit'ine sahip olur ve düzenli olur.

## 🎯 **İlk Döküman: 01. Project Architecture**

**"Create new file"** → **Dosya yolu:** `docs/01-project-architecture.md`

**İçerik:**

# 🏗️ Project Architecture & Structure

## Overview

This guide establishes the foundational architecture patterns for Flutter Master Template projects. We follow **Clean Architecture** principles with **feature-first organization** to ensure scalability, maintainability, and testability.

## Clean Architecture Implementation

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │     Widgets     │  │      BLoC       │  │    Pages    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │    Entities     │  │   Use Cases     │  │ Repositories│ │
│  │   (Business)    │  │   (Business     │  │ (Interfaces)│ │
│  │                 │  │    Logic)       │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │     Models      │  │  Data Sources   │  │ Repositories│ │
│  │                 │  │ (Remote/Local)  │  │(Implementations)│
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Direction

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** depends on **nothing** (pure business logic)

## Folder Structure Standards

### Complete Project Structure

```
lib/
├── core/                          # Shared application core
│   ├── constants/
│   │   ├── app_constants.dart     # App-wide constants
│   │   ├── api_constants.dart     # API endpoints & keys
│   │   └── design_constants.dart  # Design tokens
│   ├── di/                        # Dependency Injection
│   │   ├── injection_container.dart
│   │   └── service_locator.dart
│   ├── error/                     # Error handling
│   │   ├── failures.dart
│   │   ├── exceptions.dart
│   │   └── error_handler.dart
│   ├── network/                   # Network layer
│   │   ├── api_client.dart
│   │   ├── network_info.dart
│   │   └── interceptors/
│   ├── utils/                     # Utility functions
│   │   ├── extensions/
│   │   ├── helpers/
│   │   └── validators/
│   ├── usecases/                  # Base use case
│   │   └── usecase.dart
│   └── theme/                     # App theming
│       ├── app_theme.dart
│       ├── colors.dart
│       └── typography.dart
├── features/                      # Feature modules
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_data_source.dart
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── register_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │           ├── auth_form.dart
│   │           └── social_login_buttons.dart
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/                        # Shared widgets & components
│   ├── widgets/
│   │   ├── custom_app_bar.dart
│   │   ├── loading_widget.dart
│   │   ├── error_widget.dart
│   │   └── form_widgets/
│   ├── components/
│   └── layouts/
└── main.dart                      # App entry point
```

## File Naming Conventions

### Strict Naming Rules

```dart
// Screens/Pages
home_screen.dart
user_profile_screen.dart
settings_screen.dart

// Widgets
custom_button_widget.dart
user_card_widget.dart
loading_indicator_widget.dart

// Models
user_model.dart
product_model.dart
api_response_model.dart

// Services
auth_service.dart
api_service.dart
storage_service.dart

// Repositories
user_repository.dart          // Interface
user_repository_impl.dart     // Implementation

// Use Cases
get_user_profile_usecase.dart
login_user_usecase.dart

// BLoCs/Cubits
auth_bloc.dart
auth_state.dart
auth_event.dart

// Constants
app_constants.dart
api_constants.dart
route_constants.dart

// Extensions
string_extensions.dart
date_time_extensions.dart

// Utils
validators.dart
helpers.dart
formatters.dart
```

## Import Organization

### Mandatory Import Order

```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// 2. Flutter libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// 3. Third-party packages (alphabetical)
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

// 4. Local imports (relative paths)
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// 5. Current directory imports (last)
import 'auth_event.dart';
import 'auth_state.dart';
```

## Dependency Injection Setup

### GetIt Configuration

```dart
// core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Authentication
  // Bloc
  sl.registerFactory(() => AuthBloc(
    loginUsecase: sl(),
    logoutUsecase: sl(),
    getCurrentUserUsecase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => Dio());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
```

### Injectable Alternative

```dart
// For larger projects, consider using injectable for automatic DI generation
@InjectableInit()
void configureDependencies() => getIt.init();

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(@factoryParam this.loginUsecase) : super(AuthInitial());
  
  final LoginUsecase loginUsecase;
}
```

## Feature Development Pattern

### Creating a New Feature

1. **Create Feature Folder**
```bash
mkdir -p lib/features/new_feature/{data,domain,presentation}
mkdir -p lib/features/new_feature/data/{datasources,models,repositories}
mkdir -p lib/features/new_feature/domain/{entities,repositories,usecases}
mkdir -p lib/features/new_feature/presentation/{bloc,pages,widgets}
```

2. **Domain Layer First** (Business Logic)
```dart
// entities/product.dart
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
  });
  
  final String id;
  final String name;
  final double price;
  
  @override
  List<Object> get props => [id, name, price];
}

// repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProduct(String id);
}

// usecases/get_products.dart
class GetProducts implements UseCase<List<Product>, NoParams> {
  const GetProducts(this.repository);
  
  final ProductRepository repository;
  
  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) {
    return repository.getProducts();
  }
}
```

3. **Data Layer** (Implementation)
```dart
// models/product_model.dart
@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}

// repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts();
        await localDataSource.cacheProducts(remoteProducts);
        return Right(remoteProducts.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final localProducts = await localDataSource.getCachedProducts();
        return Right(localProducts.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }
}
```

4. **Presentation Layer** (UI + State Management)
```dart
// bloc/product_bloc.dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({required this.getProducts}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }
  
  final GetProducts getProducts;
  
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    
    final result = await getProducts(NoParams());
    
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
```

## Best Practices Summary

### Architecture Guidelines

1. **Single Responsibility** - Each class has one reason to change
2. **Dependency Inversion** - Depend on abstractions, not concretions
3. **Interface Segregation** - Create focused, cohesive interfaces
4. **Separation of Concerns** - Keep business logic separate from UI
5. **Testability** - Design for easy unit testing

### Code Organization

1. **Feature-First** - Organize by business features, not technical layers
2. **Consistent Naming** - Use clear, descriptive names
3. **Proper Imports** - Follow import organization rules
4. **Documentation** - Document complex business logic
5. **Modularity** - Keep features independent and reusable

### Team Collaboration

1. **Code Reviews** - Enforce architecture patterns in reviews
2. **Documentation** - Keep architecture decisions documented
3. **Consistency** - Use templates and generators for new features
4. **Standards** - Establish and maintain coding standards
5. **Training** - Ensure team understands architecture principles

