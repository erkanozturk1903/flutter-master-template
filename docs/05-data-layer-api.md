Perfect kral! 🔥 **Beşinci döküman:**

## 🎯 **05. Data Layer & API Integration**

**"Create new file"** → **Dosya yolu:** `docs/05-data-layer-api.md`

**İçerik:**

# 📊 Data Layer & API Integration

## Overview

The data layer is responsible for managing all data operations, including API communication, local storage, and data transformation. This guide establishes comprehensive standards using **Repository Pattern**, **Dio HTTP client**, and **JSON serialization** for robust data management.

## HTTP Client Setup (Dio)

### API Client Configuration

```dart
// core/network/api_client.dart
class ApiClient {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.yourapp.com/v1',
  );
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const Duration _sendTimeout = Duration(seconds: 30);

  late final Dio _dio;
  final String? _baseUrl;

  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? _baseUrl {
    _dio = Dio(_buildBaseOptions());
    _setupInterceptors();
  }

  BaseOptions _buildBaseOptions() {
    return BaseOptions(
      baseUrl: _baseUrl!,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp/1.0',
      },
      responseType: ResponseType.json,
      followRedirects: true,
      maxRedirects: 3,
    );
  }

  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Logging interceptor (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (object) => debugPrint('API: $object'),
        ),
      );
    }

    // Retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: kDebugMode ? debugPrint : null,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          // Retry on network errors and 5xx status codes
          return error.type == DioExceptionType.connectionTimeout ||
                 error.type == DioExceptionType.receiveTimeout ||
                 error.type == DioExceptionType.connectionError ||
                 (error.response?.statusCode != null &&
                  error.response!.statusCode! >= 500);
        },
      ),
    );

    // Auth interceptor
    _dio.interceptors.add(AuthInterceptor());
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add request timestamp
    options.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Add request ID for tracking
    options.headers['X-Request-ID'] = const Uuid().v4();
    
    // Add app version
    options.headers['X-App-Version'] = PackageInfo.fromPlatform().then((info) => info.version);

    if (kDebugMode) {
      debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
      debugPrint('Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('Data: ${options.data}');
      }
    }

    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    }

    // Validate response structure
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (!data.containsKey('success')) {
        // Add success flag if not present
        response.data = {
          'success': response.statusCode == 200,
          'data': data,
        };
      }
    }

    handler.next(response);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
      debugPrint('Message: ${error.message}');
    }

    // Transform DioException to custom exceptions
    final customError = _transformError(error);
    handler.reject(customError);
  }

  DioException _transformError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return error.copyWith(
          error: const NetworkException(
            message: 'Connection timeout. Please check your internet connection.',
            code: 'TIMEOUT',
          ),
        );

      case DioExceptionType.connectionError:
        return error.copyWith(
          error: const NetworkException(
            message: 'No internet connection. Please check your network settings.',
            code: 'NO_CONNECTION',
          ),
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      default:
        return error.copyWith(
          error: NetworkException(
            message: error.message ?? 'Unknown network error occurred.',
            code: 'UNKNOWN',
          ),
        );
    }
  }

  DioException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = 'Server error occurred.';
    String code = 'SERVER_ERROR';

    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? message;
      code = responseData['code'] ?? code;
    }

    switch (statusCode) {
      case 400:
        return error.copyWith(
          error: ValidationException(
            message: message.isEmpty ? 'Invalid request data.' : message,
            code: code,
          ),
        );

      case 401:
        return error.copyWith(
          error: AuthenticationException(
            message: message.isEmpty ? 'Authentication required.' : message,
            code: code,
          ),
        );

      case 403:
        return error.copyWith(
          error: AuthorizationException(
            message: message.isEmpty ? 'Access denied.' : message,
            code: code,
          ),
        );

      case 404:
        return error.copyWith(
          error: NotFoundException(
            message: message.isEmpty ? 'Resource not found.' : message,
            code: code,
          ),
        );

      case 422:
        return error.copyWith(
          error: ValidationException(
            message: message.isEmpty ? 'Validation failed.' : message,
            code: code,
            fieldErrors: _extractFieldErrors(responseData),
          ),
        );

      case 429:
        return error.copyWith(
          error: RateLimitException(
            message: message.isEmpty ? 'Too many requests. Please try again later.' : message,
            code: code,
          ),
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return error.copyWith(
          error: ServerException(
            message: message.isEmpty ? 'Server temporarily unavailable.' : message,
            code: code,
          ),
        );

      default:
        return error.copyWith(
          error: ServerException(
            message: message,
            code: code,
          ),
        );
    }
  }

  Map<String, String>? _extractFieldErrors(dynamic responseData) {
    if (responseData is Map<String, dynamic> && 
        responseData.containsKey('errors') &&
        responseData['errors'] is Map<String, dynamic>) {
      
      final errors = responseData['errors'] as Map<String, dynamic>;
      return errors.map((key, value) => MapEntry(key, value.toString()));
    }
    return null;
  }

  // HTTP Methods
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.get<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // File upload
  Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(
        file.path,
        filename: path.split('/').last,
      ),
      if (additionalFields != null) ...additionalFields,
    });

    return post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }

  // Download file
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }

  void dispose() {
    _dio.close();
  }
}
```

### Authentication Interceptor

```dart
// core/network/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final tokenStorage = getIt<TokenStorage>();
    final accessToken = tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Refresh failed, logout user
        await _handleLogout();
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final tokenStorage = getIt<TokenStorage>();
      final refreshToken = tokenStorage.getRefreshToken();

      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        '${ApiClient._baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String?;

        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
        );

        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    return false;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final tokenStorage = getIt<TokenStorage>();
    final newAccessToken = tokenStorage.getAccessToken();

    requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

    final dio = Dio();
    return dio.fetch(requestOptions);
  }

  Future<void> _handleLogout() async {
    final authBloc = getIt<AuthBloc>();
    authBloc.add(LogoutRequested());
  }
}
```

## Data Models & JSON Serialization

### Base Model Standards

```dart
// core/models/base_model.dart
abstract class BaseModel extends Equatable {
  const BaseModel();

  /// Converts model to JSON
  Map<String, dynamic> toJson();

  /// Creates model from JSON
  /// Should be implemented by concrete classes
  // factory BaseModel.fromJson(Map<String, dynamic> json);

  @override
  List<Object?> get props;

  @override
  String toString() => '$runtimeType(${toJson()})';
}

// Example: User Model
@JsonSerializable()
class UserModel extends BaseModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.role = UserRole.user,
    this.preferences,
    this.metadata,
  });

  final String id;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'avatar_url')
  final String? avatar;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;
  @JsonKey(name: 'is_email_verified')
  final bool isEmailVerified;
  @JsonKey(name: 'is_phone_verified')
  final bool isPhoneVerified;
  final UserRole role;
  final UserPreferences? preferences;
  final Map<String, dynamic>? metadata;

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
  bool get isVerified => isEmailVerified && isPhoneVerified;
  String get displayName => fullName.isEmpty ? email : fullName;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Entity conversion
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      role: role,
      preferences: preferences?.toEntity(),
      metadata: metadata,
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      avatar: entity.avatar,
      phoneNumber: entity.phoneNumber,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastLoginAt: entity.lastLoginAt,
      isEmailVerified: entity.isEmailVerified,
      isPhoneVerified: entity.isPhoneVerified,
      role: entity.role,
      preferences: entity.preferences != null 
          ? UserPreferencesModel.fromEntity(entity.preferences!)
          : null,
      metadata: entity.metadata,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    UserRole? role,
    UserPreferences? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        avatar,
        phoneNumber,
        createdAt,
        updatedAt,
        lastLoginAt,
        isEmailVerified,
        isPhoneVerified,
        role,
        preferences,
        metadata,
      ];
}

@JsonEnum()
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('moderator')
  moderator,
  @JsonValue('user')
  user,
  @JsonValue('guest')
  guest,
}
```

### Complex Model Examples

```dart
// Product Model with variants and categories
@JsonSerializable()
class ProductModel extends BaseModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.currency,
    required this.images,
    required this.category,
    this.variants = const [],
    this.tags = const [],
    this.attributes = const {},
    this.rating,
    this.reviewCount = 0,
    this.inStock = true,
    this.stockQuantity,
    this.sku,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.isActive = true,
    this.isFeatured = false,
    this.seoTitle,
    this.seoDescription,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  final String currency;
  final List<ProductImageModel> images;
  final ProductCategoryModel category;
  final List<ProductVariantModel> variants;
  final List<String> tags;
  final Map<String, dynamic> attributes;
  final double? rating;
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @JsonKey(name: 'in_stock')
  final bool inStock;
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  final String? sku;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'seo_title')
  final String? seoTitle;
  @JsonKey(name: 'seo_description')
  final String? seoDescription;

  // Computed properties
  bool get isOnSale => originalPrice != null && originalPrice! > price;
  double get discountPercentage => 
      isOnSale ? ((originalPrice! - price) / originalPrice!) * 100 : 0;
  String get primaryImageUrl => images.isNotEmpty ? images.first.url : '';
  bool get hasVariants => variants.isNotEmpty;
  bool get isPublished => publishedAt != null && isActive;
  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';
  
  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      currency: currency,
      images: images.map((img) => img.toEntity()).toList(),
      category: category.toEntity(),
      variants: variants.map((variant) => variant.toEntity()).toList(),
      tags: tags,
      attributes: attributes,
      rating: rating,
      reviewCount: reviewCount,
      inStock: inStock,
      stockQuantity: stockQuantity,
      sku: sku,
      createdAt: createdAt,
      updatedAt: updatedAt,
      publishedAt: publishedAt,
      isActive: isActive,
      isFeatured: isFeatured,
      seoTitle: seoTitle,
      seoDescription: seoDescription,
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, price, originalPrice, currency,
        images, category, variants, tags, attributes,
        rating, reviewCount, inStock, stockQuantity, sku,
        createdAt, updatedAt, publishedAt, isActive, isFeatured,
        seoTitle, seoDescription,
      ];
}
```

### API Response Wrapper

```dart
// Generic API response wrapper
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
    this.timestamp,
  });

  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;
  final PaginationMeta? meta;
  final DateTime? timestamp;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  // Success response
  factory ApiResponse.success({
    required T data,
    String? message,
    PaginationMeta? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      meta: meta,
      timestamp: DateTime.now(),
    );
  }

  // Error response
  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      timestamp: DateTime.now(),
    );
  }
}

@JsonSerializable()
class PaginationMeta {
  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'items_per_page')
  final int itemsPerPage;
  @JsonKey(name: 'has_next_page')
  final bool? hasNextPage;
  @JsonKey(name: 'has_previous_page')
  final bool? hasPreviousPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => _$PaginationMetaFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}
```

## Repository Pattern Implementation

### Base Repository

```dart
// core/repositories/base_repository.dart
abstract class BaseRepository<T, ID> {
  Future<Either<Failure, List<T>>> getAll({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
    String? sortBy,
    SortOrder? sortOrder,
  });

  Future<Either<Failure, T>> getById(ID id);
  
  Future<Either<Failure, T>> create(T entity);
  
  Future<Either<Failure, T>> update(ID id, T entity);
  
  Future<Either<Failure, void>> delete(ID id);
  
  Future<Either<Failure, List<T>>> search(String query, {
    int? page,
    int? limit,
  });
}

enum SortOrder { asc, desc }
```

### Repository Implementation

```dart
// features/user/data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<User>>> getAll({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
    String? sortBy,
    SortOrder? sortOrder,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUsers = await remoteDataSource.getAllUsers(
          page: page,
          limit: limit,
          filters: filters,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );

        // Cache successful response
        await localDataSource.cacheUsers(remoteUsers);
        
        return Right(remoteUsers.map((model) => model.toEntity()).toList());
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on Exception catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      try {
        final localUsers = await localDataSource.getCachedUsers(
          filters: filters,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
        return Right(localUsers.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, User>> getById(String id) async {
    // Try cache first for better performance
    try {
      final cachedUser = await localDataSource.getCachedUserById(id);
      if (cachedUser != null && !_isCacheExpired(cachedUser)) {
        return Right(cachedUser.toEntity());
      }
    } on CacheException {
      // Cache miss, continue to network
    }

    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.getUserById(id);
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser.toEntity());
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      }
    } else {
      try {
        final localUser = await localDataSource.getCachedUserById(id);
        if (localUser != null) {
          return Right(localUser.toEntity());
        } else {
          return const Left(CacheFailure(message: 'User not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  ```dart
  @override
  Future<Either<Failure, User>> create(User entity) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = UserModel.fromEntity(entity);
        final createdUser = await remoteDataSource.createUser(userModel);
        
        // Cache the newly created user
        await localDataSource.cacheUser(createdUser);
        
        return Right(createdUser.toEntity());
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.code,
          fieldErrors: e.fieldErrors,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      }
    } else {
      // Queue for offline sync
      await localDataSource.queueForSync(userModel, SyncOperation.create);
      return const Left(NetworkFailure(message: 'No internet connection. Changes will be synced when online.'));
    }
  }

  @override
  Future<Either<Failure, User>> update(String id, User entity) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = UserModel.fromEntity(entity);
        final updatedUser = await remoteDataSource.updateUser(id, userModel);
        
        // Update cache
        await localDataSource.cacheUser(updatedUser);
        
        return Right(updatedUser.toEntity());
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.code,
          fieldErrors: e.fieldErrors,
        ));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      }
    } else {
      // Queue for offline sync
      final userModel = UserModel.fromEntity(entity);
      await localDataSource.queueForSync(userModel, SyncOperation.update);
      await localDataSource.cacheUser(userModel); // Update local cache
      return Right(entity); // Return the entity for optimistic updates
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteUser(id);
        await localDataSource.removeUser(id);
        return const Right(null);
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      }
    } else {
      // Queue for offline sync
      await localDataSource.queueForSync(
        UserModel(id: id, email: '', firstName: '', lastName: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        SyncOperation.delete,
      );
      await localDataSource.removeUser(id); // Remove from local cache
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, List<User>>> search(String query, {
    int? page,
    int? limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final results = await remoteDataSource.searchUsers(
          query,
          page: page,
          limit: limit,
        );
        return Right(results.map((model) => model.toEntity()).toList());
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      }
    } else {
      try {
        final localResults = await localDataSource.searchCachedUsers(query);
        return Right(localResults.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Always try to get fresh data when online
      if (await networkInfo.isConnected) {
        final currentUser = await remoteDataSource.getCurrentUser();
        await localDataSource.cacheCurrentUser(currentUser);
        return Right(currentUser.toEntity());
      } else {
        // Fallback to cached current user
        final cachedUser = await localDataSource.getCurrentUser();
        if (cachedUser != null) {
          return Right(cachedUser.toEntity());
        } else {
          return const Left(CacheFailure(message: 'No cached user data available'));
        }
      }
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> uploadAvatar(String userId, File avatarFile) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.uploadAvatar(userId, avatarFile);
        
        // Refresh user data to get updated avatar URL
        final updatedUser = await remoteDataSource.getUserById(userId);
        await localDataSource.cacheUser(updatedUser);
        
        return const Right(null);
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      }
    } else {
      return const Left(NetworkFailure(message: 'Internet connection required for file upload'));
    }
  }

  bool _isCacheExpired(UserModel cachedUser) {
    const cacheValidityDuration = Duration(minutes: 30);
    final now = DateTime.now();
    final cacheTime = cachedUser.updatedAt;
    return now.difference(cacheTime) > cacheValidityDuration;
  }
}

enum SyncOperation { create, update, delete }
```

## Data Sources Implementation

### Remote Data Source

```dart
// features/user/data/datasources/user_remote_data_source.dart
abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
    String? sortBy,
    SortOrder? sortOrder,
  });

  Future<UserModel> getUserById(String id);
  Future<UserModel> getCurrentUser();
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> updateUser(String id, UserModel user);
  Future<void> deleteUser(String id);
  Future<List<UserModel>> searchUsers(String query, {int? page, int? limit});
  Future<void> uploadAvatar(String userId, File avatarFile);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<UserModel>> getAllUsers({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
    String? sortBy,
    SortOrder? sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (limit != null) queryParameters['limit'] = limit;
    if (sortBy != null) queryParameters['sort_by'] = sortBy;
    if (sortOrder != null) {
      queryParameters['sort_order'] = sortOrder == SortOrder.asc ? 'asc' : 'desc';
    }
    if (filters != null) queryParameters.addAll(filters);

    final response = await apiClient.get<Map<String, dynamic>>(
      '/users',
      queryParameters: queryParameters,
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (json) => json as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException(
        message: apiResponse.message ?? 'Failed to fetch users',
        code: 'FETCH_USERS_FAILED',
      );
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>('/users/$id');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data!,
      (json) => json as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return UserModel.fromJson(apiResponse.data!);
    } else if (response.statusCode == 404) {
      throw NotFoundException(
        message: 'User not found',
        code: 'USER_NOT_FOUND',
      );
    } else {
      throw ServerException(
        message: apiResponse.message ?? 'Failed to fetch user',
        code: 'FETCH_USER_FAILED',
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get<Map<String, dynamic>>('/users/me');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data!,
      (json) => json as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return UserModel.fromJson(apiResponse.data!);
    } else {
      throw ServerException(
        message: apiResponse.message ?? 'Failed to fetch current user',
        code: 'FETCH_CURRENT_USER_FAILED',
      );
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/users',
      data: user.toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data!,
      (json) => json as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return UserModel.fromJson(apiResponse.data!);
    } else {
      throw ServerException(
        message: apiResponse.message ?? 'Failed to create user',
        code: 'CREATE_USER_FAILED',
      );
    }
  }

  @override
  Future<UserModel> updateUser(String id, UserModel user) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '/users/$id',
      data: user.toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data!,
      (json) => json as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return UserModel.fromJson(apiResponse.data!);
    } else {
      throw ServerException(
        message: apiResponse.message ?? 'Failed to update user',
        code: 'UPDATE_USER_FAILED',
      );
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await apiClient.delete('/users/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException(
        message: 'Failed to delete user',
        code: 'DELETE_USER_FAILED',
      );
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query, {int? page, int? limit}) async {
    final queryParameters = <String, dynamic>{
      'q': query,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };

    final response = await apiClient.get<Map<String, dynamic>>(
      '/users/search',
      queryParameters: queryParameters,
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (json) => json as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException(
        message: apiResponse.message ?? 'Search failed',
        code: 'SEARCH_USERS_FAILED',
      );
    }
  }

  @override
  Future<void> uploadAvatar(String userId, File avatarFile) async {
    await apiClient.uploadFile(
      '/users/$userId/avatar',
      avatarFile,
      fieldName: 'avatar',
    );
  }
}
```

### Local Data Source

```dart
// features/user/data/datasources/user_local_data_source.dart
abstract class UserLocalDataSource {
  Future<List<UserModel>> getCachedUsers({
    Map<String, dynamic>? filters,
    String? sortBy,
    SortOrder? sortOrder,
  });
  
  Future<UserModel?> getCachedUserById(String id);
  Future<UserModel?> getCurrentUser();
  Future<void> cacheUsers(List<UserModel> users);
  Future<void> cacheUser(UserModel user);
  Future<void> cacheCurrentUser(UserModel user);
  Future<void> removeUser(String id);
  Future<List<UserModel>> searchCachedUsers(String query);
  Future<void> queueForSync(UserModel user, SyncOperation operation);
  Future<List<PendingSyncModel>> getPendingSyncOperations();
  Future<void> clearCache();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  const UserLocalDataSourceImpl({
    required this.hiveBox,
    required this.sharedPreferences,
  });

  final Box<Map<String, dynamic>> hiveBox;
  final SharedPreferences sharedPreferences;

  static const String _usersKey = 'cached_users';
  static const String _currentUserKey = 'current_user';
  static const String _syncQueueKey = 'sync_queue';

  @override
  Future<List<UserModel>> getCachedUsers({
    Map<String, dynamic>? filters,
    String? sortBy,
    SortOrder? sortOrder,
  }) async {
    final usersData = hiveBox.get(_usersKey);
    if (usersData == null) {
      throw const CacheException(message: 'No cached users found');
    }

    final usersJson = usersData['users'] as List<dynamic>;
    final users = usersJson
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // Apply filters
    var filteredUsers = users;
    if (filters != null && filters.isNotEmpty) {
      filteredUsers = users.where((user) {
        return filters.entries.every((filter) {
          final userJson = user.toJson();
          return userJson[filter.key] == filter.value;
        });
      }).toList();
    }

    // Apply sorting
    if (sortBy != null) {
      filteredUsers.sort((a, b) {
        final aJson = a.toJson();
        final bJson = b.toJson();
        final aValue = aJson[sortBy];
        final bValue = bJson[sortBy];
        
        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return 1;
        if (bValue == null) return -1;
        
        final comparison = aValue.toString().compareTo(bValue.toString());
        return sortOrder == SortOrder.desc ? -comparison : comparison;
      });
    }

    return filteredUsers;
  }

  @override
  Future<UserModel?> getCachedUserById(String id) async {
    try {
      final users = await getCachedUsers();
      return users.firstWhere(
        (user) => user.id == id,
        orElse: () => throw const CacheException(message: 'User not found in cache'),
      );
    } on CacheException {
      return null;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userJson = hiveBox.get(_currentUserKey);
    if (userJson != null) {
      return UserModel.fromJson(userJson);
    }
    return null;
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    final usersData = {
      'users': users.map((user) => user.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await hiveBox.put(_usersKey, usersData);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final users = await getCachedUsers();
      final updatedUsers = users.map((cachedUser) {
        return cachedUser.id == user.id ? user : cachedUser;
      }).toList();

      // Add user if not found
      if (!updatedUsers.any((cachedUser) => cachedUser.id == user.id)) {
        updatedUsers.add(user);
      }

      await cacheUsers(updatedUsers);
    } on CacheException {
      // No cached users exist, create new cache
      await cacheUsers([user]);
    }
  }

  @override
  Future<void> cacheCurrentUser(UserModel user) async {
    await hiveBox.put(_currentUserKey, user.toJson());
  }

  @override
  Future<void> removeUser(String id) async {
    try {
      final users = await getCachedUsers();
      final updatedUsers = users.where((user) => user.id != id).toList();
      await cacheUsers(updatedUsers);
    } on CacheException {
      // No cached users, nothing to remove
    }
  }

  @override
  Future<List<UserModel>> searchCachedUsers(String query) async {
    try {
      final users = await getCachedUsers();
      final lowercaseQuery = query.toLowerCase();
      
      return users.where((user) {
        return user.firstName.toLowerCase().contains(lowercaseQuery) ||
               user.lastName.toLowerCase().contains(lowercaseQuery) ||
               user.email.toLowerCase().contains(lowercaseQuery) ||
               user.fullName.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } on CacheException {
      return [];
    }
  }

  @override
  Future<void> queueForSync(UserModel user, SyncOperation operation) async {
    final syncItem = PendingSyncModel(
      id: const Uuid().v4(),
      entityId: user.id,
      entityType: 'user',
      operation: operation,
      data: user.toJson(),
      createdAt: DateTime.now(),
    );

    final currentQueue = await getPendingSyncOperations();
    currentQueue.add(syncItem);

    final queueData = currentQueue.map((item) => item.toJson()).toList();
    await hiveBox.put(_syncQueueKey, {'items': queueData});
  }

  @override
  Future<List<PendingSyncModel>> getPendingSyncOperations() async {
    final queueData = hiveBox.get(_syncQueueKey);
    if (queueData == null) return [];

    final items = queueData['items'] as List<dynamic>;
    return items
        .map((json) => PendingSyncModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearCache() async {
    await hiveBox.clear();
  }
}

// Pending sync model for offline operations
@JsonSerializable()
class PendingSyncModel {
  const PendingSyncModel({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.operation,
    required this.data,
    required this.createdAt,
  });

  final String id;
  final String entityId;
  final String entityType;
  final SyncOperation operation;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  factory PendingSyncModel.fromJson(Map<String, dynamic> json) => _$PendingSyncModelFromJson(json);
  Map<String, dynamic> toJson() => _$PendingSyncModelToJson(this);
}
```

## Caching Strategies

### Cache Management Service

```dart
// core/cache/cache_manager.dart
class CacheManager {
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);
  static const Duration shortCacheDuration = Duration(minutes: 15);

  final Box<Map<String, dynamic>> _cacheBox;

  CacheManager(this._cacheBox);

  /// Store data in cache with TTL
  Future<void> store<T>(
    String key,
    T data, {
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) async {
    final cacheEntry = CacheEntry(
      data: data is Map<String, dynamic> ? data : _serialize(data),
      expiresAt: DateTime.now().add(duration ?? defaultCacheDuration),
      metadata: metadata ?? {},
    );

    await _cacheBox.put(key, cacheEntry.toJson());
  }

  /// Retrieve data from cache
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? deserializer,
  }) async {
    final cacheData = _cacheBox.get(key);
    if (cacheData == null) return null;

    final cacheEntry = CacheEntry.fromJson(cacheData);
    
    // Check if cache is expired
    if (DateTime.now().isAfter(cacheEntry.expiresAt)) {
      await _cacheBox.delete(key);
      return null;
    }

    if (deserializer != null) {
      return deserializer(cacheEntry.data);
    }

    return cacheEntry.data as T?;
  }

  /// Check if cache entry exists and is valid
  Future<bool> exists(String key) async {
    final cacheData = _cacheBox.get(key);
    if (cacheData == null) return false;

    final cacheEntry = CacheEntry.fromJson(cacheData);
    if (DateTime.now().isAfter(cacheEntry.expiresAt)) {
      await _cacheBox.delete(key);
      return false;
    }

    return true;
  }

  /// Invalidate specific cache entry
  Future<void> invalidate(String key) async {
    await _cacheBox.delete(key);
  }

  /// Invalidate cache entries by pattern
  Future<void> invalidatePattern(String pattern) async {
    final regex = RegExp(pattern);
    final keysToDelete = _cacheBox.keys.where((key) => regex.hasMatch(key.toString()));
    
    for (final key in keysToDelete) {
      await _cacheBox.delete(key);
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _cacheBox.clear();
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    final totalEntries = _cacheBox.length;
    int expiredEntries = 0;
    int validEntries = 0;

    for (final key in _cacheBox.keys) {
      final cacheData = _cacheBox.get(key);
      if (cacheData != null) {
        final cacheEntry = CacheEntry.fromJson(cacheData);
        if (DateTime.now().isAfter(cacheEntry.expiresAt)) {
          expiredEntries++;
        } else {
          validEntries++;
        }
      }
    }

    return CacheStats(
      totalEntries: totalEntries,
      validEntries: validEntries,
      expiredEntries: expiredEntries,
      hitRate: validEntries / totalEntries,
    );
  }

  Map<String, dynamic> _serialize<T>(T data) {
    if (data is Map<String, dynamic>) return data;
    if (data is List) return {'list': data};
    if (data is String) return {'string': data};
    if (data is num) return {'number': data};
    if (data is bool) return {'boolean': data};
    
    // For complex objects, assume they have toJson method
    try {
      return (data as dynamic).toJson() as Map<String, dynamic>;
    } catch (e) {
      throw CacheException(message: 'Cannot serialize object of type ${T.toString()}');
    }
  }
}

@JsonSerializable()
class CacheEntry {
  const CacheEntry({
    required this.data,
    required this.expiresAt,
    required this.metadata,
  });

  final Map<String, dynamic> data;
  final DateTime expiresAt;
  final Map<String, dynamic> metadata;

  factory CacheEntry.fromJson(Map<String, dynamic> json) => _$CacheEntryFromJson(json);
  Map<String, dynamic> toJson() => _$CacheEntryToJson(this);
}

class CacheStats {
  const CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.hitRate,
  });

  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final double hitRate;
}
```

## Best Practices Summary

### Data Layer Guidelines

1. **Repository Pattern** - Abstract data sources behind repositories
2. **Error Handling** - Use Either pattern for consistent error handling
3. **Caching Strategy** - Implement multi-level caching (memory, disk, network)
4. **Offline Support** - Queue operations for later sync
5. **Data Validation** - Validate data at model level
6. **Performance** - Use pagination and lazy loading
7. **Security** - Encrypt sensitive cached data
8. **Testing** - Mock all external dependencies

### API Integration Best Practices

- Use consistent error handling across all endpoints
- Implement proper timeout and retry mechanisms
- Add request/response logging for debugging
- Use interceptors for common functionality (auth, logging)
- Implement proper authentication token refresh
- Support file upload with progress tracking
- Handle network connectivity changes gracefully

### Caching Best Practices

- Set appropriate TTL for different data types
- Implement cache invalidation strategies
- Monitor cache hit rates and performance
- Use compression for large cached objects
- Implement cache warming for critical data
- Provide cache statistics for monitoring
