
# 12. Error Handling & Logging

> **Comprehensive Error Management & Logging Guide** - Global error handling, structured logging, crash reporting, and monitoring for production-ready Flutter applications.

## 📋 Table of Contents

- [Error Handling Philosophy](#-error-handling-philosophy)
- [Global Error Handling](#-global-error-handling)
- [Custom Exception Classes](#-custom-exception-classes)
- [Structured Logging System](#-structured-logging-system)
- [Crash Reporting](#-crash-reporting)
- [Error Recovery Strategies](#-error-recovery-strategies)
- [Network Error Handling](#-network-error-handling)
- [State Management Error Handling](#-state-management-error-handling)
- [User-Friendly Error Messages](#-user-friendly-error-messages)
- [Logging Best Practices](#-logging-best-practices)
- [Performance Monitoring](#-performance-monitoring)
- [Error Analytics](#-error-analytics)

## 🎯 Error Handling Philosophy

### Core Principles
```yaml
Error Handling Strategy:
  - Fail Fast: Detect errors early
  - Fail Safe: Graceful degradation
  - User First: Clear, actionable messages
  - Developer Friendly: Detailed debugging info
  - Context Aware: Preserve error context
  - Recovery Focus: Provide recovery options
```

### Error Classification
```yaml
Error Types:
  Critical: Application crashes, data corruption
  High: Feature unusable, security issues
  Medium: Feature degraded, performance issues
  Low: Cosmetic issues, minor UX problems
  Info: Expected behavior, user actions

Error Sources:
  - Network failures
  - API responses
  - Local storage issues
  - Authentication problems
  - Validation errors
  - System limitations
```

## 🌐 Global Error Handling

### Application-Wide Error Handler
```dart
// lib/core/error/global_error_handler.dart
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalErrorHandler {
  static bool _isInitialized = false;
  static late ErrorReporter _errorReporter;
  static late Logger _logger;

  /// Initialize global error handling
  static Future<void> initialize({
    required ErrorReporter errorReporter,
    required Logger logger,
  }) async {
    if (_isInitialized) return;

    _errorReporter = errorReporter;
    _logger = logger;

    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Handle errors outside Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // Handle isolate errors
    Isolate.current.addErrorListener(
      RawReceivePort((dynamic pair) {
        final List<dynamic> errorAndStacktrace = pair as List<dynamic>;
        _handleIsolateError(
          errorAndStacktrace.first,
          errorAndStacktrace.last as StackTrace?,
        );
      }).sendPort,
    );

    // Handle unhandled async errors
    runZonedGuarded(
      () {
        // Your app initialization code
      },
      (error, stack) {
        _handleZoneError(error, stack);
      },
    );

    _isInitialized = true;
    _logger.info('Global error handler initialized');
  }

  /// Handle Flutter framework errors
  static void _handleFlutterError(FlutterErrorDetails details) {
    final errorInfo = ErrorInfo(
      error: details.exception,
      stackTrace: details.stack,
      context: details.context?.toString(),
      library: details.library,
      errorType: ErrorType.flutter,
      severity: _determineSeverity(details.exception),
      timestamp: DateTime.now(),
      userInfo: _getCurrentUserInfo(),
      deviceInfo: _getDeviceInfo(),
    );

    _processError(errorInfo);

    // In debug mode, also print to console
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Handle platform-level errors
  static bool _handlePlatformError(Object error, StackTrace? stack) {
    final errorInfo = ErrorInfo(
      error: error,
      stackTrace: stack,
      errorType: ErrorType.platform,
      severity: ErrorSeverity.high,
      timestamp: DateTime.now(),
      userInfo: _getCurrentUserInfo(),
      deviceInfo: _getDeviceInfo(),
    );

    _processError(errorInfo);
    return true;
  }

  /// Handle isolate errors
  static void _handleIsolateError(dynamic error, StackTrace? stack) {
    final errorInfo = ErrorInfo(
      error: error,
      stackTrace: stack,
      errorType: ErrorType.isolate,
      severity: ErrorSeverity.high,
      timestamp: DateTime.now(),
      userInfo: _getCurrentUserInfo(),
      deviceInfo: _getDeviceInfo(),
    );

    _processError(errorInfo);
  }

  /// Handle zone errors (async errors)
  static void _handleZoneError(Object error, StackTrace stack) {
    final errorInfo = ErrorInfo(
      error: error,
      stackTrace: stack,
      errorType: ErrorType.async,
      severity: _determineSeverity(error),
      timestamp: DateTime.now(),
      userInfo: _getCurrentUserInfo(),
      deviceInfo: _getDeviceInfo(),
    );

    _processError(errorInfo);
  }

  /// Process error through the pipeline
  static void _processError(ErrorInfo errorInfo) {
    try {
      // Log the error
      _logger.error(
        'Global error captured',
        error: errorInfo.error,
        stackTrace: errorInfo.stackTrace,
        extra: errorInfo.toMap(),
      );

      // Report to crash analytics
      _errorReporter.reportError(errorInfo);

      // Handle critical errors
      if (errorInfo.severity == ErrorSeverity.critical) {
        _handleCriticalError(errorInfo);
      }

      // Show user notification if needed
      if (_shouldShowUserNotification(errorInfo)) {
        _showErrorNotification(errorInfo);
      }

    } catch (e, s) {
      // Fallback logging if error handling fails
      debugPrint('Error in error handler: $e\n$s');
    }
  }

  /// Determine error severity
  static ErrorSeverity _determineSeverity(Object error) {
    if (error is OutOfMemoryError) return ErrorSeverity.critical;
    if (error is NetworkException) return ErrorSeverity.medium;
    if (error is ValidationException) return ErrorSeverity.low;
    if (error is AuthenticationException) return ErrorSeverity.high;
    if (error is DataException) return ErrorSeverity.high;
    
    // Default severity based on error type
    if (error is AssertionError) return ErrorSeverity.high;
    if (error is StateError) return ErrorSeverity.medium;
    if (error is ArgumentError) return ErrorSeverity.medium;
    if (error is RangeError) return ErrorSeverity.medium;
    if (error is FormatException) return ErrorSeverity.low;
    
    return ErrorSeverity.medium;
  }

  /// Handle critical errors that might crash the app
  static void _handleCriticalError(ErrorInfo errorInfo) {
    // Save app state
    _saveAppState();
    
    // Clear memory if possible
    _clearNonEssentialMemory();
    
    // Navigate to error screen
    _navigateToErrorScreen(errorInfo);
  }

  /// Check if error should show user notification
  static bool _shouldShowUserNotification(ErrorInfo errorInfo) {
    // Don't show notifications for low severity errors
    if (errorInfo.severity == ErrorSeverity.low) return false;
    
    // Don't show notifications in debug mode
    if (kDebugMode) return false;
    
    // Don't spam notifications
    if (_recentNotifications.length >= 3) return false;
    
    return true;
  }

  /// Show user-friendly error notification
  static void _showErrorNotification(ErrorInfo errorInfo) {
    // Implementation depends on your app's navigation/notification system
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      ErrorNotificationService.show(
        context: context,
        errorInfo: errorInfo,
      );
    }
  }

  // Helper methods
  static Map<String, dynamic> _getCurrentUserInfo() {
    return UserService.getCurrentUserInfo() ?? {};
  }

  static Map<String, dynamic> _getDeviceInfo() {
    return DeviceInfoService.getDeviceInfo() ?? {};
  }

  static void _saveAppState() {
    // Save current app state for recovery
    AppStateService.saveCurrentState();
  }

  static void _clearNonEssentialMemory() {
    // Clear caches and non-essential data
    ImageCache().clear();
  }

  static void _navigateToErrorScreen(ErrorInfo errorInfo) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CriticalErrorScreen(errorInfo: errorInfo),
        ),
        (route) => false,
      );
    }
  }

  static final List<DateTime> _recentNotifications = [];
}

/// Error information container
class ErrorInfo {
  final Object error;
  final StackTrace? stackTrace;
  final String? context;
  final String? library;
  final ErrorType errorType;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> customData;

  ErrorInfo({
    required this.error,
    this.stackTrace,
    this.context,
    this.library,
    required this.errorType,
    required this.severity,
    required this.timestamp,
    this.userInfo = const {},
    this.deviceInfo = const {},
    this.customData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
      'library': library,
      'errorType': errorType.name,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'userInfo': userInfo,
      'deviceInfo': deviceInfo,
      'customData': customData,
    };
  }
}

enum ErrorType {
  flutter,
  platform,
  isolate,
  async,
  network,
  data,
  authentication,
  validation,
  business,
}

enum ErrorSeverity {
  critical,
  high,
  medium,
  low,
  info,
}
```

## 🚨 Custom Exception Classes

### Base Exception Framework
```dart
// lib/core/error/exceptions.dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic> context;
  final DateTime timestamp;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.context = const {},
  }) : timestamp = null; // Will be set in constructor body

  AppException._internal({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.context = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// User-friendly error message
  String get userMessage => message;

  /// Developer-friendly error message
  String get debugMessage => toString();

  /// Error severity level
  ErrorSeverity get severity;

  /// Whether error should be reported to analytics
  bool get shouldReport => severity != ErrorSeverity.low;

  /// Whether error should show user notification
  bool get shouldNotifyUser => severity == ErrorSeverity.high || severity == ErrorSeverity.critical;

  /// Convert to map for logging
  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'code': code,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'originalError': originalError?.toString(),
      'stackTrace': stackTrace?.toString(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('${runtimeType}: $message');
    if (code != null) buffer.write(' (Code: $code)');
    if (context.isNotEmpty) buffer.write(' Context: $context');
    return buffer.toString();
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  final int? statusCode;
  final String? endpoint;
  final String? method;

  const NetworkException({
    required String message,
    String? code,
    this.statusCode,
    this.endpoint,
    this.method,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic> context = const {},
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
          context: context,
        );

  @override
  ErrorSeverity get severity {
    if (statusCode != null) {
      if (statusCode! >= 500) return ErrorSeverity.high;
      if (statusCode! >= 400) return ErrorSeverity.medium;
    }
    return ErrorSeverity.medium;
  }

  @override
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication required. Please log in.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Requested resource not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Network error. Please check your connection.';
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'statusCode': statusCode,
      'endpoint': endpoint,
      'method': method,
    };
  }
}

/// Authentication and authorization exceptions
class AuthenticationException extends AppException {
  final AuthErrorType errorType;

  const AuthenticationException({
    required String message,
    required this.errorType,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic> context = const {},
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
          context: context,
        );

  @override
  ErrorSeverity get severity => ErrorSeverity.high;

  @override
  String get userMessage {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid email or password. Please try again.';
      case AuthErrorType.accountLocked:
        return 'Account is temporarily locked. Please try again later.';
      case AuthErrorType.accountDisabled:
        return 'Account has been disabled. Please contact support.';
      case AuthErrorType.tokenExpired:
        return 'Session expired. Please log in again.';
      case AuthErrorType.biometricNotAvailable:
        return 'Biometric authentication is not available.';
      case AuthErrorType.biometricFailed:
        return 'Biometric authentication failed. Please try again.';
      case AuthErrorType.permissionDenied:
        return 'Access denied. Insufficient permissions.';
      default:
        return 'Authentication error. Please try again.';
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'errorType': errorType.name,
    };
  }
}

enum AuthErrorType {
  invalidCredentials,
  accountLocked,
  accountDisabled,
  tokenExpired,
  biometricNotAvailable,
  biometricFailed,
  permissionDenied,
}

/// Data-related exceptions
class DataException extends AppException {
  final DataErrorType errorType;
  final String? tableName;
  final String? fieldName;

  const DataException({
    required String message,
    required this.errorType,
    this.tableName,
    this.fieldName,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic> context = const {},
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
          context: context,
        );

  @override
  ErrorSeverity get severity {
    switch (errorType) {
      case DataErrorType.corruption:
        return ErrorSeverity.critical;
      case DataErrorType.notFound:
        return ErrorSeverity.medium;
      case DataErrorType.constraint:
        return ErrorSeverity.medium;
      case DataErrorType.permission:
        return ErrorSeverity.high;
      default:
        return ErrorSeverity.medium;
    }
  }

  @override
  String get userMessage {
    switch (errorType) {
      case DataErrorType.notFound:
        return 'Requested data not found.';
      case DataErrorType.corruption:
        return 'Data corruption detected. Please restart the app.';
      case DataErrorType.constraint:
        return 'Data validation failed. Please check your input.';
      case DataErrorType.permission:
        return 'Permission denied for data access.';
      case DataErrorType.storage:
        return 'Storage error. Please check available space.';
      case DataErrorType.sync:
        return 'Data synchronization failed. Will retry automatically.';
      default:
        return 'Data error occurred. Please try again.';
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'errorType': errorType.name,
      'tableName': tableName,
      'fieldName': fieldName,
    };
  }
}

enum DataErrorType {
  notFound,
  corruption,
  constraint,
  permission,
  storage,
  sync,
}

/// Business logic exceptions
class BusinessException extends AppException {
  final BusinessErrorType errorType;

  const BusinessException({
    required String message,
    required this.errorType,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic> context = const {},
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
          context: context,
        );

  @override
  ErrorSeverity get severity => ErrorSeverity.medium;

  @override
  String get userMessage => message; // Business messages are usually user-friendly

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'errorType': errorType.name,
    };
  }
}

enum BusinessErrorType {
  validation,
  workflow,
  rule,
  state,
}

/// Validation exceptions
class ValidationException extends AppException {
  final List<ValidationError> errors;

  const ValidationException({
    required String message,
    required this.errors,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic> context = const {},
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
          context: context,
        );

  @override
  ErrorSeverity get severity => ErrorSeverity.low;

  @override
  String get userMessage {
    if (errors.length == 1) {
      return errors.first.message;
    }
    return 'Please correct the following errors:\n${errors.map((e) => '• ${e.message}').join('\n')}';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'validationErrors': errors.map((e) => e.toMap()).toList(),
    };
  }
}

class ValidationError {
  final String field;
  final String message;
  final dynamic value;
  final String? code;

  const ValidationError({
    required this.field,
    required this.message,
    this.value,
    this.code,
  });

  Map<String, dynamic> toMap() {
    return {
      'field': field,
      'message': message,
      'value': value,
      'code': code,
    };
  }
}
```

## 📊 Structured Logging System

### Advanced Logger Implementation
```dart
// lib/core/logging/logger.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  final List<LogOutput> _outputs = [];
  LogLevel _minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  final Map<String, dynamic> _globalContext = {};

  /// Initialize logger with outputs
  void initialize({
    required List<LogOutput> outputs,
    LogLevel minimumLevel = LogLevel.info,
    Map<String, dynamic> globalContext = const {},
  }) {
    _outputs.clear();
    _outputs.addAll(outputs);
    _minimumLevel = minimumLevel;
    _globalContext.addAll(globalContext);
  }

  /// Add global context that will be included in all logs
  void addGlobalContext(String key, dynamic value) {
    _globalContext[key] = value;
  }

  /// Log debug message
  void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(LogLevel.debug, message, error, stackTrace, extra);
  }

  /// Log info message
  void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(LogLevel.info, message, error, stackTrace, extra);
  }

  /// Log warning message
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(LogLevel.warning, message, error, stackTrace, extra);
  }

  /// Log error message
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(LogLevel.error, message, error, stackTrace, extra);
  }

  /// Log critical message
  void critical(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(LogLevel.critical, message, error, stackTrace, extra);
  }

  /// Log network request
  void logNetworkRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    int? statusCode,
    Duration? duration,
    String? error,
  }) {
    final requestData = {
      'type': 'network_request',
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
      'statusCode': statusCode,
      'duration_ms': duration?.inMilliseconds,
      'error': error,
    };

    if (error != null) {
      warning('Network request failed', extra: requestData);
    } else {
      info('Network request completed', extra: requestData);
    }
  }

  /// Log user action
  void logUserAction({
    required String action,
    String? screen,
    Map<String, dynamic>? parameters,
  }) {
    info('User action', extra: {
      'type': 'user_action',
      'action': action,
      'screen': screen,
      'parameters': parameters,
    });
  }

  /// Log performance metric
  void logPerformance({
    required String metric,
    required Duration duration,
    Map<String, dynamic>? extra,
  }) {
    info('Performance metric', extra: {
      'type': 'performance',
      'metric': metric,
      'duration_ms': duration.inMilliseconds,
      ...?extra,
    });
  }

  /// Log business event
  void logBusinessEvent({
    required String event,
    Map<String, dynamic>? data,
  }) {
    info('Business event', extra: {
      'type': 'business_event',
      'event': event,
      'data': data,
    });
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  ) {
    if (level.index < _minimumLevel.index) return;

    final logEntry = LogEntry(
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: {
        ..._globalContext,
        ...?extra,
      },
    );

    // Send to all configured outputs
    for (final output in _outputs) {
      try {
        output.write(logEntry);
      } catch (e) {
        // Fallback logging if output fails
        developer.log(
          'Failed to write log to ${output.runtimeType}: $e',
          level: 1000, // Error level
        );
      }
    }
  }
}

/// Log entry data structure
class LogEntry {
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  LogEntry({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    required this.timestamp,
    this.context = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }

  String toJson() => jsonEncode(toMap());

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${level.name.toUpperCase()}] ');
    buffer.write('${timestamp.toIso8601String()} - ');
    buffer.write(message);
    
    if (context.isNotEmpty) {
      buffer.write(' | Context: ${jsonEncode(context)}');
    }
    
    if (error != null) {
      buffer.write(' | Error: $error');
    }
    
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    
    return buffer.toString();
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Abstract log output interface
abstract class LogOutput {
  void write(LogEntry entry);
  Future<void> flush() async {}
  Future<void> close() async {}
}

/// Console log output
class ConsoleLogOutput implements LogOutput {
  final bool colorized;
  
  ConsoleLogOutput({this.colorized = true});

  @override
  void write(LogEntry entry) {
    final message = colorized ? _colorize(entry) : entry.toString();
    
    if (kDebugMode) {
      developer.log(
        message,
        name: 'AppLogger',
        level: _getLogLevel(entry.level),
        error: entry.error,
        stackTrace: entry.stackTrace,
      );
    } else {
      print(message);
    }
  }

  String _colorize(LogEntry entry) {
    const reset = '\x1B[0m';
    String color;
    
    switch (entry.level) {
      case LogLevel.debug:
        color = '\x1B[37m'; // White
        break;
      case LogLevel.info:
        color = '\x1B[32m'; // Green
        break;
      case LogLevel.warning:
        color = '\x1B[33m'; // Yellow
        break;
      case LogLevel.error:
        color = '\x1B[31m'; // Red
        break;
      case LogLevel.critical:
        color = '\x1B[35m'; // Magenta
        break;
    }
    
    return '$color${entry.toString()}$reset';
  }

  int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }
}

/// File log output
class FileLogOutput implements LogOutput {
  final String filePath;
  final int maxFileSize;
  final int maxFiles;
  final bool compress;
  
  late final File _file;
  int _currentSize = 0;

  FileLogOutput({
    required this.filePath,
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxFiles = 5,
    this.compress = true,
  }) {
    _file = File(filePath);
    _ensureFileExists();
    _currentSize = _file.existsSync() ? _file.lengthSync() : 0;
  }

  @override
  void write(LogEntry entry) {
    final line = '${entry.toJson()}\n';
    
    // Check if rotation is needed
    if (_currentSize + line.length > maxFileSize) {
      _rotateFiles();
    }
    
    _file.writeAsStringSync(line, mode: FileMode.append);
    _currentSize += line.length;
  }

  void _ensureFileExists() {
    if (!_file.existsSync()) {
      _file.createSync(recursive: true);
    }
  }

  void _rotateFiles() {
    // Rotate log files
    for (int i = maxFiles - 1; i >= 1; i--) {
      final currentFile = File('$filePath.$i');
      final nextFile = File('$filePath.${i + 1}');
      
      if (currentFile.existsSync()) {
        if (nextFile.existsSync()) {
          nextFile.deleteSync();
        }
        currentFile.renameSync(nextFile.path);
      }
    }
    
    // Move current file to .1
    if (_file.existsSync()) {
      _file.renameSync('$filePath.1');
    }
    
    // Create new file
    _file.createSync();
    _currentSize = 0;
  }

  @override
  Future<void> flush() async {
    await _file.writeAsString('', mode: FileMode.append, flush: true);
  }
}

/// Remote log output (sends logs to server)
class RemoteLogOutput implements LogOutput {
  final String endpoint;
  final String apiKey;
  final Duration batchInterval;
  final int maxBatchSize;
  
  final List<LogEntry> _buffer = [];
```dart
  Timer? _batchTimer;
  final Dio _dio;

  RemoteLogOutput({
    required this.endpoint,
    required this.apiKey,
    this.batchInterval = const Duration(seconds: 30),
    this.maxBatchSize = 100,
  }) : _dio = Dio() {
    _setupBatchTimer();
  }

  @override
  void write(LogEntry entry) {
    _buffer.add(entry);
    
    // Send immediately for critical errors
    if (entry.level == LogLevel.critical) {
      _sendBatch();
    } else if (_buffer.length >= maxBatchSize) {
      _sendBatch();
    }
  }

  void _setupBatchTimer() {
    _batchTimer = Timer.periodic(batchInterval, (_) {
      if (_buffer.isNotEmpty) {
        _sendBatch();
      }
    });
  }

  Future<void> _sendBatch() async {
    if (_buffer.isEmpty) return;

    final batch = List<LogEntry>.from(_buffer);
    _buffer.clear();

    try {
      await _dio.post(
        endpoint,
        data: {
          'logs': batch.map((e) => e.toMap()).toList(),
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'flutter_app',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
    } catch (e) {
      // Log failed to send, add back to buffer
      _buffer.insertAll(0, batch);
      
      // Prevent infinite growth
      if (_buffer.length > maxBatchSize * 2) {
        _buffer.removeRange(maxBatchSize, _buffer.length);
      }
    }
  }

  @override
  Future<void> flush() async {
    await _sendBatch();
  }

  @override
  Future<void> close() async {
    _batchTimer?.cancel();
    await flush();
    _dio.close();
  }
}
```

## 📱 Crash Reporting

### Firebase Crashlytics Integration
```dart
// lib/core/error/crash_reporter.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReporter implements ErrorReporter {
  static final CrashReporter _instance = CrashReporter._internal();
  factory CrashReporter() => _instance;
  CrashReporter._internal();

  late FirebaseCrashlytics _crashlytics;
  bool _isInitialized = false;

  /// Initialize crash reporting
  Future<void> initialize() async {
    if (_isInitialized) return;

    _crashlytics = FirebaseCrashlytics.instance;

    // Set crashlytics collection enabled based on debug mode
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Set custom keys for better debugging
    await _setDefaultCustomKeys();

    _isInitialized = true;
  }

  @override
  void reportError(ErrorInfo errorInfo) {
    if (!_isInitialized) return;

    try {
      // Set custom keys for this error
      _setErrorCustomKeys(errorInfo);

      // Record error
      _crashlytics.recordError(
        errorInfo.error,
        errorInfo.stackTrace,
        fatal: errorInfo.severity == ErrorSeverity.critical,
        information: [
          DiagnosticsProperty('errorType', errorInfo.errorType.name),
          DiagnosticsProperty('severity', errorInfo.severity.name),
          DiagnosticsProperty('timestamp', errorInfo.timestamp.toIso8601String()),
          DiagnosticsProperty('context', errorInfo.context),
          DiagnosticsProperty('userInfo', errorInfo.userInfo),
          DiagnosticsProperty('deviceInfo', errorInfo.deviceInfo),
        ],
      );

      // Log custom event for analytics
      _crashlytics.log('Error reported: ${errorInfo.error.runtimeType}');

    } catch (e) {
      // Fallback logging if crash reporting fails
      debugPrint('Failed to report error to Crashlytics: $e');
    }
  }

  /// Set user information for crash reports
  Future<void> setUserInfo({
    required String userId,
    String? email,
    String? name,
    Map<String, String>? customAttributes,
  }) async {
    if (!_isInitialized) return;

    try {
      await _crashlytics.setUserIdentifier(userId);
      
      if (email != null) {
        await _crashlytics.setCustomKey('user_email', email);
      }
      
      if (name != null) {
        await _crashlytics.setCustomKey('user_name', name);
      }

      if (customAttributes != null) {
        for (final entry in customAttributes.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }
    } catch (e) {
      debugPrint('Failed to set user info in Crashlytics: $e');
    }
  }

  /// Record a custom log message
  void log(String message) {
    if (!_isInitialized) return;
    _crashlytics.log(message);
  }

  /// Record a breadcrumb for debugging
  void recordBreadcrumb({
    required String message,
    String? category,
    Map<String, String>? data,
  }) {
    if (!_isInitialized) return;

    final breadcrumb = StringBuffer();
    breadcrumb.write(message);
    
    if (category != null) {
      breadcrumb.write(' [Category: $category]');
    }
    
    if (data != null && data.isNotEmpty) {
      breadcrumb.write(' Data: $data');
    }

    _crashlytics.log(breadcrumb.toString());
  }

  /// Force a crash for testing
  void testCrash() {
    if (kDebugMode) {
      _crashlytics.crash();
    }
  }

  /// Set default custom keys
  Future<void> _setDefaultCustomKeys() async {
    await _crashlytics.setCustomKey('app_version', await _getAppVersion());
    await _crashlytics.setCustomKey('flutter_version', _getFlutterVersion());
    await _crashlytics.setCustomKey('platform', defaultTargetPlatform.name);
    await _crashlytics.setCustomKey('debug_mode', kDebugMode);
  }

  /// Set error-specific custom keys
  Future<void> _setErrorCustomKeys(ErrorInfo errorInfo) async {
    await _crashlytics.setCustomKey('error_type', errorInfo.errorType.name);
    await _crashlytics.setCustomKey('error_severity', errorInfo.severity.name);
    
    // Add context as custom keys
    for (final entry in errorInfo.context.entries) {
      if (entry.value is String || entry.value is num || entry.value is bool) {
        await _crashlytics.setCustomKey('ctx_${entry.key}', entry.value.toString());
      }
    }
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  String _getFlutterVersion() {
    // This would need to be set at build time
    return 'Unknown'; // Replace with actual Flutter version
  }
}

/// Error reporter interface
abstract class ErrorReporter {
  void reportError(ErrorInfo errorInfo);
}
```

## 🔄 Error Recovery Strategies

### Automatic Recovery System
```dart
// lib/core/error/error_recovery.dart
class ErrorRecoveryService {
  static final ErrorRecoveryService _instance = ErrorRecoveryService._internal();
  factory ErrorRecoveryService() => _instance;
  ErrorRecoveryService._internal();

  final Map<Type, List<RecoveryStrategy>> _strategies = {};
  final Logger _logger = Logger();

  /// Register recovery strategy for specific error type
  void registerStrategy<T extends Exception>(RecoveryStrategy strategy) {
    _strategies.putIfAbsent(T, () => []).add(strategy);
  }

  /// Attempt to recover from error
  Future<RecoveryResult> attemptRecovery(Exception error) async {
    final errorType = error.runtimeType;
    final strategies = _strategies[errorType] ?? [];

    _logger.info('Attempting recovery for ${errorType.toString()}');

    for (final strategy in strategies) {
      try {
        final result = await strategy.recover(error);
        
        if (result.success) {
          _logger.info('Recovery successful using ${strategy.runtimeType}');
          return result;
        } else {
          _logger.warning('Recovery attempt failed: ${result.message}');
        }
      } catch (e, s) {
        _logger.error(
          'Recovery strategy failed',
          error: e,
          stackTrace: s,
          extra: {'strategy': strategy.runtimeType.toString()},
        );
      }
    }

    _logger.error('All recovery attempts failed for ${errorType.toString()}');
    return RecoveryResult.failed('No recovery strategy succeeded');
  }

  /// Initialize default recovery strategies
  void initializeDefaultStrategies() {
    // Network error recovery
    registerStrategy<NetworkException>(NetworkRecoveryStrategy());
    
    // Authentication error recovery
    registerStrategy<AuthenticationException>(AuthRecoveryStrategy());
    
    // Data error recovery
    registerStrategy<DataException>(DataRecoveryStrategy());
    
    // Storage error recovery
    registerStrategy<StorageException>(StorageRecoveryStrategy());
  }
}

/// Base recovery strategy interface
abstract class RecoveryStrategy {
  Future<RecoveryResult> recover(Exception error);
}

/// Recovery result
class RecoveryResult {
  final bool success;
  final String message;
  final Map<String, dynamic> data;

  RecoveryResult._({
    required this.success,
    required this.message,
    this.data = const {},
  });

  factory RecoveryResult.success({
    String message = 'Recovery successful',
    Map<String, dynamic> data = const {},
  }) {
    return RecoveryResult._(
      success: true,
      message: message,
      data: data,
    );
  }

  factory RecoveryResult.failed(String message) {
    return RecoveryResult._(
      success: false,
      message: message,
    );
  }
}

/// Network error recovery strategy
class NetworkRecoveryStrategy implements RecoveryStrategy {
  final int maxRetries;
  final Duration retryDelay;

  NetworkRecoveryStrategy({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  Future<RecoveryResult> recover(Exception error) async {
    if (error is! NetworkException) {
      return RecoveryResult.failed('Invalid error type for network recovery');
    }

    // Check network connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return RecoveryResult.failed('No network connectivity');
    }

    // Attempt retry with exponential backoff
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      await Future.delayed(retryDelay * attempt);

      try {
        // Retry the original request
        final success = await _retryNetworkRequest(error);
        if (success) {
          return RecoveryResult.success(
            message: 'Network request succeeded on retry $attempt',
            data: {'attempts': attempt},
          );
        }
      } catch (e) {
        if (attempt == maxRetries) {
          return RecoveryResult.failed('Network recovery failed after $maxRetries attempts');
        }
      }
    }

    return RecoveryResult.failed('Network recovery failed');
  }

  Future<bool> _retryNetworkRequest(NetworkException error) async {
    // This would retry the original network request
    // Implementation depends on your network layer
    return false; // Placeholder
  }
}

/// Authentication error recovery strategy
class AuthRecoveryStrategy implements RecoveryStrategy {
  @override
  Future<RecoveryResult> recover(Exception error) async {
    if (error is! AuthenticationException) {
      return RecoveryResult.failed('Invalid error type for auth recovery');
    }

    switch (error.errorType) {
      case AuthErrorType.tokenExpired:
        return await _refreshToken();
      case AuthErrorType.biometricFailed:
        return await _fallbackToPasswordAuth();
      default:
        return RecoveryResult.failed('No recovery available for ${error.errorType}');
    }
  }

  Future<RecoveryResult> _refreshToken() async {
    try {
      final authService = GetIt.instance<AuthService>();
      final refreshed = await authService.refreshToken();
      
      if (refreshed) {
        return RecoveryResult.success(message: 'Token refreshed successfully');
      } else {
        return RecoveryResult.failed('Token refresh failed');
      }
    } catch (e) {
      return RecoveryResult.failed('Token refresh error: $e');
    }
  }

  Future<RecoveryResult> _fallbackToPasswordAuth() async {
    // Prompt user for password authentication
    return RecoveryResult.success(
      message: 'Fallback to password authentication',
      data: {'action': 'prompt_password'},
    );
  }
}

/// Data error recovery strategy
class DataRecoveryStrategy implements RecoveryStrategy {
  @override
  Future<RecoveryResult> recover(Exception error) async {
    if (error is! DataException) {
      return RecoveryResult.failed('Invalid error type for data recovery');
    }

    switch (error.errorType) {
      case DataErrorType.corruption:
        return await _recoverFromCorruption();
      case DataErrorType.sync:
        return await _resyncData();
      case DataErrorType.storage:
        return await _clearCache();
      default:
        return RecoveryResult.failed('No recovery available for ${error.errorType}');
    }
  }

  Future<RecoveryResult> _recoverFromCorruption() async {
    try {
      // Clear corrupted data and reload from server
      final dataService = GetIt.instance<DataService>();
      await dataService.clearLocalData();
      await dataService.syncFromServer();
      
      return RecoveryResult.success(message: 'Data recovered from server');
    } catch (e) {
      return RecoveryResult.failed('Data recovery failed: $e');
    }
  }

  Future<RecoveryResult> _resyncData() async {
    try {
      final dataService = GetIt.instance<DataService>();
      await dataService.forceSyncFromServer();
      
      return RecoveryResult.success(message: 'Data resynced successfully');
    } catch (e) {
      return RecoveryResult.failed('Data resync failed: $e');
    }
  }

  Future<RecoveryResult> _clearCache() async {
    try {
      final cacheService = GetIt.instance<CacheService>();
      await cacheService.clearAll();
      
      return RecoveryResult.success(message: 'Cache cleared successfully');
    } catch (e) {
      return RecoveryResult.failed('Cache clear failed: $e');
    }
  }
}

/// Storage error recovery strategy
class StorageRecoveryStrategy implements RecoveryStrategy {
  @override
  Future<RecoveryResult> recover(Exception error) async {
    try {
      // Check available storage
      final storageInfo = await _getStorageInfo();
      
      if (storageInfo.freeSpace < 100 * 1024 * 1024) { // Less than 100MB
        // Try to free up space
        await _freeUpSpace();
        
        return RecoveryResult.success(
          message: 'Storage space freed up',
          data: {'freed_space': storageInfo.freeSpace},
        );
      }
      
      return RecoveryResult.failed('Sufficient storage available, error may be elsewhere');
    } catch (e) {
      return RecoveryResult.failed('Storage recovery failed: $e');
    }
  }

  Future<StorageInfo> _getStorageInfo() async {
    // Get storage information
    return StorageInfo(freeSpace: 0, totalSpace: 0); // Placeholder
  }

  Future<void> _freeUpSpace() async {
    // Clear caches, temporary files, etc.
    final cacheService = GetIt.instance<CacheService>();
    await cacheService.clearExpiredItems();
  }
}

class StorageInfo {
  final int freeSpace;
  final int totalSpace;
  
  StorageInfo({required this.freeSpace, required this.totalSpace});
}
```

## 🌐 Network Error Handling

### Comprehensive Network Error Management
```dart
// lib/core/error/network_error_handler.dart
class NetworkErrorHandler {
  static final NetworkErrorHandler _instance = NetworkErrorHandler._internal();
  factory NetworkErrorHandler() => _instance;
  NetworkErrorHandler._internal();

  final Logger _logger = Logger();
  final ErrorRecoveryService _recoveryService = ErrorRecoveryService();

  /// Handle network errors with automatic recovery
  Future<T> handleNetworkCall<T>(
    Future<T> Function() networkCall, {
    String? operation,
    Map<String, dynamic>? context,
    bool autoRetry = true,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    Exception? lastError;

    while (attempt < maxRetries) {
      attempt++;

      try {
        _logger.debug('Executing network call', extra: {
          'operation': operation,
          'attempt': attempt,
          'context': context,
        });

        final result = await networkCall();
        
        if (attempt > 1) {
          _logger.info('Network call succeeded after retry', extra: {
            'operation': operation,
            'attempts': attempt,
          });
        }

        return result;

      } on DioException catch (e) {
        lastError = _convertDioException(e);
        
        _logger.warning('Network call failed', extra: {
          'operation': operation,
          'attempt': attempt,
          'error': lastError.toString(),
          'statusCode': e.response?.statusCode,
        });

        // Don't retry certain errors
        if (!_shouldRetry(e) || !autoRetry) {
          break;
        }

        // Wait before retry (exponential backoff)
        if (attempt < maxRetries) {
          final delay = Duration(seconds: (2 * attempt).clamp(1, 10));
          await Future.delayed(delay);
        }

      } catch (e) {
        lastError = NetworkException(
          message: 'Unexpected network error: ${e.toString()}',
          originalError: e,
        );
        
        _logger.error('Unexpected network error', error: e, extra: {
          'operation': operation,
          'attempt': attempt,
        });
        
        break; // Don't retry unexpected errors
      }
    }

    // All retries failed, attempt recovery
    if (lastError != null && autoRetry) {
      final recoveryResult = await _recoveryService.attemptRecovery(lastError);
      if (recoveryResult.success) {
        // Recovery succeeded, try one more time
        try {
          return await networkCall();
        } catch (e) {
          // Recovery didn't help, throw original error
        }
      }
    }

    throw lastError ?? NetworkException(message: 'Network call failed');
  }

  /// Convert Dio exceptions to custom network exceptions
  NetworkException _convertDioException(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final endpoint = e.requestOptions.path;
    final method = e.requestOptions.method;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          message: 'Connection timeout',
          code: 'CONNECTION_TIMEOUT',
          statusCode: statusCode,
          endpoint: endpoint,
          method: method,
          originalError: e,
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Send timeout',
          code: 'SEND_TIMEOUT',
          statusCode: statusCode,
          endpoint: endpoint,
          method: method,
          originalError: e,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Receive timeout',
          code: 'RECEIVE_TIMEOUT',
          statusCode: statusCode,
          endpoint: endpoint,
          method: method,
          originalError: e,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(e);

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          code: 'REQUEST_CANCELLED',
          statusCode: statusCode,
          endpoint: endpoint,
          method: method,
          originalError: e,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Connection error - please check your internet connection',
          code: 'CONNECTION_ERROR',
          statusCode: statusCode,
          endpoint: endpoint,
          method: method,
          originalError: e,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'SSL certificate error',
          code: 'SSL_ERROR',
          statusCode: statusCode,
          endpoint: endpoint,
          method: method,
          originalError: e,
        );

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: 'Unknown network error: ${e.message}',
          code: 'UNKNOWN_ERROR',
          statusCode: statusCode,
          endpoint: endpoint,
          method: method,
          originalError: e,
        );
    }
  }

  /// Handle bad HTTP response
  NetworkException _handleBadResponse(DioException e) {
    final response = e.response!;
    final statusCode = response.statusCode!;
    final endpoint = e.requestOptions.path;
    final method = e.requestOptions.method;

    String message;
    String code;

    if (statusCode >= 400 && statusCode < 500) {
      // Client errors
      switch (statusCode) {
        case 400:
          message = 'Bad request - invalid data sent';
          code = 'BAD_REQUEST';
          break;
        case 401:
          message = 'Authentication required';
          code = 'UNAUTHORIZED';
          break;
        case 403:
          message = 'Access forbidden';
          code = 'FORBIDDEN';
          break;
        case 404:
          message = 'Resource not found';
          code = 'NOT_FOUND';
          break;
        case 409:
          message = 'Conflict - resource already exists';
          code = 'CONFLICT';
          break;
        case 422:
          message = 'Validation error';
          code = 'VALIDATION_ERROR';
          break;
        case 429:
          message = 'Too many requests - please try again later';
          code = 'RATE_LIMIT';
          break;
        default:
          message = 'Client error (${statusCode})';
          code = 'CLIENT_ERROR';
      }
    } else if (statusCode >= 500) {
      // Server errors
      switch (statusCode) {
        case 500:
          message = 'Internal server error';
          code = 'INTERNAL_SERVER_ERROR';
          break;
        case 502:
          message = 'Bad gateway';
          code = 'BAD_GATEWAY';
          break;
        case 503:
          message = 'Service unavailable';
          code = 'SERVICE_UNAVAILABLE';
          break;
        case 504:
          message = 'Gateway timeout';
          code = 'GATEWAY_TIMEOUT';
          break;
        default:
          message = 'Server error (${statusCode})';
          code = 'SERVER_ERROR';
      }
    } else {
      message = 'HTTP error (${statusCode})';
      code = 'HTTP_ERROR';
    }

    // Try to extract error message from response
    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final errorMessage = responseData['message'] ?? 
                          responseData['error'] ?? 
                          responseData['detail'];
      if (errorMessage != null) {
        message = '$message: $errorMessage';
      }
    }

    return NetworkException(
      message: message,
      code: code,
      statusCode: statusCode,
      endpoint: endpoint,
      method: method,
      originalError: e,
      context: {'responseData': responseData},
    );
  }

  /// Check if error should be retried
  bool _shouldRetry(DioException e) {
    // Don't retry client errors (4xx) except for specific cases
    if (e.response?.statusCode != null) {
      final statusCode = e.response!.statusCode!;
      
      // Retry server errors (5xx)
      if (statusCode >= 500) return true;
      
      // Retry rate limiting (429)
      if (statusCode == 429) return true;
      
      // Retry request timeout (408)
      if (statusCode == 408) return true;
      
      // Don't retry other client errors
      if (statusCode >= 400) return false;
    }

    // Retry timeout errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // Retry connection errors
    if (e.type == DioExceptionType.connectionError) {
      return true;
    }

    // Don't retry cancelled requests
    if (e.type == DioExceptionType.cancel) {
      return false;
    }

    // Don't retry certificate errors
    if (e.type == DioExceptionType.badCertificate) {
      return false;
    }

    return false;
  }
}
## 🔄 State Management Error Handling

### BLoC Error Handling Pattern
```dart
// lib/core/error/bloc_error_mixin.dart
import 'package:flutter_bloc/flutter_bloc.dart';

mixin BlocErrorHandlerMixin<Event, State> on Bloc<Event, State> {
  final Logger _logger = Logger();
  final ErrorRecoveryService _recoveryService = ErrorRecoveryService();

  /// Handle errors in bloc operations
  Future<T> handleBlocError<T>({
    required Future<T> Function() operation,
    required T Function(Exception error) onError,
    String? operationName,
    Map<String, dynamic>? context,
    bool attemptRecovery = true,
  }) async {
    try {
      _logger.debug('Executing bloc operation: ${operationName ?? 'unknown'}');
      
      final result = await operation();
      
      _logger.debug('Bloc operation completed successfully: ${operationName ?? 'unknown'}');
      return result;
      
    } catch (e, stackTrace) {
      final exception = e is Exception ? e : Exception(e.toString());
      
      _logger.error(
        'Bloc operation failed: ${operationName ?? 'unknown'}',
        error: e,
        stackTrace: stackTrace,
        extra: {
          'bloc': runtimeType.toString(),
          'operation': operationName,
          'context': context,
        },
      );

      // Attempt recovery if enabled
      if (attemptRecovery && exception is AppException) {
        try {
          final recoveryResult = await _recoveryService.attemptRecovery(exception);
          if (recoveryResult.success) {
            _logger.info('Recovery successful, retrying operation');
            return await operation();
          }
        } catch (recoveryError) {
          _logger.warning('Recovery attempt failed', error: recoveryError);
        }
      }

      // Create error info for reporting
      final errorInfo = ErrorInfo(
        error: exception,
        stackTrace: stackTrace,
        errorType: _getErrorType(exception),
        severity: _getErrorSeverity(exception),
        timestamp: DateTime.now(),
        context: {
          'bloc': runtimeType.toString(),
          'operation': operationName,
          ...?context,
        },
      );

      // Report error
      GlobalErrorHandler.reportError(errorInfo);

      return onError(exception);
    }
  }

  ErrorType _getErrorType(Exception exception) {
    if (exception is NetworkException) return ErrorType.network;
    if (exception is DataException) return ErrorType.data;
    if (exception is AuthenticationException) return ErrorType.authentication;
    if (exception is ValidationException) return ErrorType.validation;
    if (exception is BusinessException) return ErrorType.business;
    return ErrorType.platform;
  }

  ErrorSeverity _getErrorSeverity(Exception exception) {
    if (exception is AppException) {
      return exception.severity;
    }
    return ErrorSeverity.medium;
  }
}

/// Base error state for BLoCs
abstract class ErrorState {
  final Exception error;
  final String message;
  final bool isRecoverable;
  final Map<String, dynamic> context;

  const ErrorState({
    required this.error,
    required this.message,
    this.isRecoverable = false,
    this.context = const {},
  });
}

/// Generic error state implementation
class GenericErrorState extends ErrorState {
  const GenericErrorState({
    required Exception error,
    required String message,
    bool isRecoverable = false,
    Map<String, dynamic> context = const {},
  }) : super(
          error: error,
          message: message,
          isRecoverable: isRecoverable,
          context: context,
        );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenericErrorState &&
        other.error.runtimeType == error.runtimeType &&
        other.message == message;
  }

  @override
  int get hashCode => error.runtimeType.hashCode ^ message.hashCode;
}
```

### Example BLoC with Error Handling
```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> with BlocErrorHandlerMixin {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthErrorRecoveryRequested>(_onErrorRecoveryRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    await handleBlocError<void>(
      operation: () async {
        final result = await _loginUseCase(LoginParams(
          email: event.email,
          password: event.password,
        ));

        result.fold(
          (failure) => throw _convertFailureToException(failure),
          (user) => emit(AuthAuthenticated(user: user)),
        );
      },
      onError: (exception) {
        emit(AuthError(
          error: exception,
          message: _getErrorMessage(exception),
          isRecoverable: _isRecoverable(exception),
          canRetry: _canRetry(exception),
        ));
      },
      operationName: 'login',
      context: {'email': event.email},
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await handleBlocError<void>(
      operation: () async {
        final result = await _logoutUseCase(NoParams());
        result.fold(
          (failure) => throw _convertFailureToException(failure),
          (_) => emit(AuthUnauthenticated()),
        );
      },
      onError: (exception) {
        // For logout, we still want to clear the state even if logout fails
        emit(AuthUnauthenticated());
        
        // But log the error
        Logger().warning('Logout failed but state cleared', error: exception);
      },
      operationName: 'logout',
      attemptRecovery: false, // Don't attempt recovery for logout
    );
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    await handleBlocError<void>(
      operation: () async {
        final result = await _getCurrentUserUseCase(NoParams());
        result.fold(
          (failure) => throw _convertFailureToException(failure),
          (user) => emit(user != null 
              ? AuthAuthenticated(user: user) 
              : AuthUnauthenticated()),
        );
      },
      onError: (exception) {
        // For auth check, default to unauthenticated on error
        emit(AuthUnauthenticated());
      },
      operationName: 'checkAuth',
      attemptRecovery: false,
    );
  }

  Future<void> _onErrorRecoveryRequested(
    AuthErrorRecoveryRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthError) return;

    final errorState = state as AuthError;
    if (!errorState.canRetry) return;

    emit(AuthLoading());

    // Retry the original operation based on the last attempted action
    switch (event.retryAction) {
      case AuthRetryAction.login:
        add(AuthLoginRequested(
          email: event.email!,
          password: event.password!,
        ));
        break;
      case AuthRetryAction.logout:
        add(AuthLogoutRequested());
        break;
      case AuthRetryAction.checkAuth:
        add(AuthCheckRequested());
        break;
    }
  }

  Exception _convertFailureToException(Failure failure) {
    if (failure is NetworkFailure) {
      return NetworkException(
        message: failure.message,
        code: failure.code,
      );
    } else if (failure is AuthFailure) {
      return AuthenticationException(
        message: failure.message,
        errorType: _getAuthErrorType(failure),
        code: failure.code,
      );
    } else if (failure is ValidationFailure) {
      return ValidationException(
        message: failure.message,
        errors: failure.errors.map((e) => ValidationError(
          field: e.field,
          message: e.message,
          code: e.code,
        )).toList(),
      );
    }
    
    return Exception(failure.message);
  }

  AuthErrorType _getAuthErrorType(AuthFailure failure) {
    switch (failure.type) {
      case AuthFailureType.invalidCredentials:
        return AuthErrorType.invalidCredentials;
      case AuthFailureType.accountLocked:
        return AuthErrorType.accountLocked;
      case AuthFailureType.tokenExpired:
        return AuthErrorType.tokenExpired;
      default:
        return AuthErrorType.invalidCredentials;
    }
  }

  String _getErrorMessage(Exception exception) {
    if (exception is AppException) {
      return exception.userMessage;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  bool _isRecoverable(Exception exception) {
    if (exception is NetworkException) {
      // Network errors are usually recoverable
      return true;
    }
    if (exception is AuthenticationException) {
      // Some auth errors are recoverable
      return exception.errorType == AuthErrorType.tokenExpired;
    }
    return false;
  }

  bool _canRetry(Exception exception) {
    if (exception is NetworkException) return true;
    if (exception is AuthenticationException) {
      return exception.errorType != AuthErrorType.invalidCredentials;
    }
    return false;
  }
}

/// Auth-specific error state
class AuthError extends AuthState implements ErrorState {
  final Exception error;
  final String message;
  final bool isRecoverable;
  final bool canRetry;
  final Map<String, dynamic> context;

  const AuthError({
    required this.error,
    required this.message,
    this.isRecoverable = false,
    this.canRetry = false,
    this.context = const {},
  });

  @override
  List<Object?> get props => [error, message, isRecoverable, canRetry];
}

/// Error recovery event
class AuthErrorRecoveryRequested extends AuthEvent {
  final AuthRetryAction retryAction;
  final String? email;
  final String? password;

  const AuthErrorRecoveryRequested({
    required this.retryAction,
    this.email,
    this.password,
  });

  @override
  List<Object?> get props => [retryAction, email, password];
}

enum AuthRetryAction {
  login,
  logout,
  checkAuth,
}
```

## 💬 User-Friendly Error Messages

### Error Message Service
```dart
// lib/core/error/error_message_service.dart
class ErrorMessageService {
  static final ErrorMessageService _instance = ErrorMessageService._internal();
  factory ErrorMessageService() => _instance;
  ErrorMessageService._internal();

  final Map<String, String> _customMessages = {};
  late Locale _currentLocale;

  /// Initialize with locale
  void initialize(Locale locale) {
    _currentLocale = locale;
    _loadCustomMessages();
  }

  /// Get user-friendly error message
  String getUserMessage(Exception error, {BuildContext? context}) {
    // Try custom message first
    final customMessage = _getCustomMessage(error);
    if (customMessage != null) return customMessage;

    // Get localized message
    if (context != null) {
      final localizedMessage = _getLocalizedMessage(error, context);
      if (localizedMessage != null) return localizedMessage;
    }

    // Get default message from exception
    if (error is AppException) {
      return error.userMessage;
    }

    // Fallback message
    return _getDefaultMessage(error);
  }

  /// Get error title for dialogs
  String getErrorTitle(Exception error, {BuildContext? context}) {
    if (error is NetworkException) {
      return _localize(context, 'error_network_title') ?? 'Connection Error';
    } else if (error is AuthenticationException) {
      return _localize(context, 'error_auth_title') ?? 'Authentication Error';
    } else if (error is ValidationException) {
      return _localize(context, 'error_validation_title') ?? 'Validation Error';
    } else if (error is DataException) {
      return _localize(context, 'error_data_title') ?? 'Data Error';
    }
    
    return _localize(context, 'error_generic_title') ?? 'Error';
  }

  /// Get error icon for UI
  IconData getErrorIcon(Exception error) {
    if (error is NetworkException) {
      return Icons.wifi_off;
    } else if (error is AuthenticationException) {
      return Icons.lock_outline;
    } else if (error is ValidationException) {
      return Icons.warning_outlined;
    } else if (error is DataException) {
      return Icons.storage_outlined;
    }
    
    return Icons.error_outline;
  }

  /// Get error color
  Color getErrorColor(Exception error, {required ColorScheme colorScheme}) {
    final severity = _getErrorSeverity(error);
    
    switch (severity) {
      case ErrorSeverity.critical:
        return colorScheme.error;
      case ErrorSeverity.high:
        return colorScheme.error;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.low:
        return Colors.amber;
      case ErrorSeverity.info:
        return colorScheme.primary;
    }
  }

  /// Get suggested actions for error
  List<ErrorAction> getSuggestedActions(Exception error, {BuildContext? context}) {
    final actions = <ErrorAction>[];

    if (error is NetworkException) {
      actions.addAll([
        ErrorAction(
          label: _localize(context, 'action_retry') ?? 'Retry',
          icon: Icons.refresh,
          action: ErrorActionType.retry,
        ),
        ErrorAction(
          label: _localize(context, 'action_check_connection') ?? 'Check Connection',
          icon: Icons.settings,
          action: ErrorActionType.settings,
        ),
      ]);
    } else if (error is AuthenticationException) {
      if (error.errorType == AuthErrorType.tokenExpired) {
        actions.add(ErrorAction(
          label: _localize(context, 'action_sign_in') ?? 'Sign In Again',
          icon: Icons.login,
          action: ErrorActionType.signIn,
        ));
      } else {
        actions.add(ErrorAction(
          label: _localize(context, 'action_try_again') ?? 'Try Again',
          icon: Icons.refresh,
          action: ErrorActionType.retry,
        ));
      }
    } else if (error is ValidationException) {
      actions.add(ErrorAction(
        label: _localize(context, 'action_fix_errors') ?? 'Fix Errors',
        icon: Icons.edit,
        action: ErrorActionType.edit,
      ));
    } else if (error is DataException && error.errorType == DataErrorType.storage) {
      actions.add(ErrorAction(
        label: _localize(context, 'action_free_space') ?? 'Free Up Space',
        icon: Icons.cleaning_services,
        action: ErrorActionType.cleanup,
      ));
    }

    // Common actions
    actions.add(ErrorAction(
      label: _localize(context, 'action_contact_support') ?? 'Contact Support',
      icon: Icons.support_agent,
      action: ErrorActionType.support,
    ));

    return actions;
  }

  /// Register custom error message
  void registerCustomMessage(String errorCode, String message) {
    _customMessages[errorCode] = message;
  }

  String? _getCustomMessage(Exception error) {
    if (error is AppException && error.code != null) {
      return _customMessages[error.code!];
    }
    return null;
  }

  String? _getLocalizedMessage(Exception error, BuildContext context) {
    // Implementation would use your localization system
    // This is a simplified example
    
    if (error is NetworkException) {
      final statusCode = error.statusCode;
      if (statusCode != null) {
        return _localize(context, 'network_error_$statusCode');
      }
      return _localize(context, 'network_error_generic');
    }
    
    return null;
  }

  String _getDefaultMessage(Exception error) {
    if (error is NetworkException) {
      return 'Please check your internet connection and try again.';
    } else if (error is AuthenticationException) {
      return 'Authentication failed. Please try again.';
    } else if (error is ValidationException) {
      return 'Please check your input and try again.';
    } else if (error is DataException) {
      return 'Data error occurred. Please try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  ErrorSeverity _getErrorSeverity(Exception error) {
    if (error is AppException) {
      return error.severity;
    }
    return ErrorSeverity.medium;
  }

  String? _localize(BuildContext? context, String key) {
    if (context == null) return null;
    // Use your localization system here
    // return AppLocalizations.of(context)?.translate(key);
    return null; // Placeholder
  }

  void _loadCustomMessages() {
    // Load custom messages based on locale
    // This could be from a JSON file or remote configuration
  }
}

/// Error action data class
class ErrorAction {
  final String label;
  final IconData icon;
  final ErrorActionType action;
  final Map<String, dynamic> parameters;

  const ErrorAction({
    required this.label,
    required this.icon,
    required this.action,
    this.parameters = const {},
  });
}

enum ErrorActionType {
  retry,
  signIn,
  settings,
  edit,
  cleanup,
  support,
  dismiss,
}
```

### Error UI Components
```dart
// lib/shared/widgets/error_widgets.dart
class ErrorStateWidget extends StatelessWidget {
  final Exception error;
  final VoidCallback? onRetry;
  final VoidCallback? onSupport;
  final String? customMessage;
  final bool showDetails;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onSupport,
    this.customMessage,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorMessageService = ErrorMessageService();
    
    final title = errorMessageService.getErrorTitle(error, context: context);
    final message = customMessage ?? errorMessageService.getUserMessage(error, context: context);
    final icon = errorMessageService.getErrorIcon(error);
    final color = errorMessageService.getErrorColor(error, colorScheme: theme.colorScheme);
    final actions = errorMessageService.getSuggestedActions(error, context: context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            
            const SizedBox(height: 24.0),
            
            // Error Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12.0),
            
            // Error Message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32.0),
            
            // Action Buttons
            ...actions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: _buildActionButton(context, action),
              ),
            )),
            
            // Show Details Button
            if (showDetails) ...[
              const SizedBox(height: 16.0),
              TextButton.icon(
                onPressed: () => _showErrorDetails(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('Show Details'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ErrorAction action) {
    switch (action.action) {
      case ErrorActionType.retry:
        return ElevatedButton.icon(
          onPressed: onRetry,
          icon: Icon(action.icon),
          label: Text(action.label),
        );
      
      case ErrorActionType.support:
        return OutlinedButton.icon(
          onPressed: onSupport ?? () => _contactSupport(context),
          icon: Icon(action.icon),
          label: Text(action.label),
        );
      
      case ErrorActionType.settings:
        return OutlinedButton.icon(
          onPressed: () => _openSettings(context),
          icon: Icon(action.icon),
          label: Text(action.label),
        );
      
      default:
        return OutlinedButton.icon(
          onPressed: () => _handleAction(context, action),
          icon: Icon(action.icon),
          label: Text(action.label),
        );
    }
  }

  void _showErrorDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ErrorDetailsDialog(error: error),
    );
  }

  void _contactSupport(BuildContext context) {
    // Implementation for contacting support
    final supportService = GetIt.instance<SupportService>();
    supportService.contactSupport(
      error: error,
      context: context,
    );
  }

  void _openSettings(BuildContext context) {
    // Implementation for opening settings
    Navigator.of(context).pushNamed('/settings');
  }

  void _handleAction(BuildContext context, ErrorAction action) {
    // Handle other action types
    switch (action.action) {
      case ErrorActionType.signIn:
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        break;
      case ErrorActionType.edit:
        Navigator.of(context).pop();
        break;
      case ErrorActionType.cleanup:
        _showCleanupDialog(context);
        break;
      case ErrorActionType.dismiss:
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  void _showCleanupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StorageCleanupDialog(),
    );
  }
}

/// Error snackbar widget
class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    super.key,
    required Exception error,
    VoidCallback? onRetry,
    BuildContext? context,
  }) : super(
          content: _ErrorSnackBarContent(
            error: error,
            context: context,
          ),
          backgroundColor: _getBackgroundColor(error, context),
          behavior: SnackBarBehavior.floating,
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Retry',
                  onPressed: onRetry,
                  textColor: Colors.white,
                )
              : null,
          duration: _getDuration(error),
        );

  static Color _getBackgroundColor(Exception error, BuildContext? context) {
    if (context == null) return Colors.red;
    
    final errorMessageService = ErrorMessageService();
    final colorScheme = Theme.of(context).colorScheme;
    return errorMessageService.getErrorColor(error, colorScheme: colorScheme);
  }

  static Duration _getDuration(Exception error) {
    if (error is AppException) {
      switch (error.severity) {
        case ErrorSeverity.critical:
          return const Duration(seconds: 8);
        case ErrorSeverity.high:
          return const Duration(seconds: 6);
        case ErrorSeverity.medium:
          return const Duration(seconds: 4);
        case ErrorSeverity.low:
        case ErrorSeverity.info:
          return const Duration(seconds: 3);
      }
    }
    return const Duration(seconds: 4);
  }
}

class _ErrorSnackBarContent extends StatelessWidget {
  final Exception error;
  final BuildContext? context;

  const _ErrorSnackBarContent({
    required this.error,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessageService = ErrorMessageService();
    final icon = errorMessageService.getErrorIcon(error);
    final message = errorMessageService.getUserMessage(error, context: context);

    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Error details dialog
class ErrorDetailsDialog extends StatelessWidget {
  final Exception error;

  const ErrorDetailsDialog({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Type:', error.runtimeType.toString()),
            if (error is AppException) ...[
              _buildDetailRow('Message:', error.message),
              if (error.code != null)
                _buildDetailRow('Code:', error.code!),
              _buildDetailRow('Severity:', error.severity.name),
              _buildDetailRow('Timestamp:', error.timestamp.toString()),
              if (error.context.isNotEmpty)
                _buildDetailRow('Context:', error.context.toString()),
            ],
            if (error is NetworkException) ...[
              if (error.statusCode != null)
                _buildDetailRow('Status Code:', error.statusCode.toString()),
              if (error.endpoint != null)
                _buildDetailRow('Endpoint:', error.endpoint!),
              if (error.method != null)
                _buildDetailRow('Method:', error.method!),
            ],
            const SizedBox(height: 16.0),
            const Text(
              'Stack Trace:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SelectableText(
                _getStackTrace(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _copyToClipboard(context),
          child: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  String _getStackTrace() {
    if (error is AppException && error.stackTrace != null) {
      return error.stackTrace.toString();
    }
    return 'No stack trace available';
  }

  void _copyToClipboard(BuildContext context) {
    final details = _buildErrorDetails();
    Clipboard.setData(ClipboardData(text: details));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error details copied to clipboard')),
    );
  }

  String _buildErrorDetails() {
    final buffer = StringBuffer();
    buffer.writeln('Error Details');
    buffer.writeln('=============');
    buffer.writeln('Type: ${error.runtimeType}');
    
    if (error is AppException) {
      buffer.writeln('Message: ${error.message}');
      if (error.code != null) buffer.writeln('Code: ${error.code}');
      buffer.writeln('Severity: ${error.severity.name}');
      buffer.writeln('Timestamp: ${error.timestamp}');
      if (error.context.isNotEmpty) buffer.writeln('Context: ${error.context}');
    }
    
    buffer.writeln('\nStack Trace:');
    buffer.writeln(_getStackTrace());
    
    return buffer.toString();
  }
}
Evet kral, son kısımları da yazayım. Bunlar production'da çok kritik! 💪

## 📈 Logging Best Practices

### Production Logging Configuration
```dart
// lib/core/logging/production_logger.dart
class ProductionLogger {
  static final ProductionLogger _instance = ProductionLogger._internal();
  factory ProductionLogger() => _instance;
  ProductionLogger._internal();

  late Logger _logger;
  final Map<String, LogBuffer> _buffers = {};
  Timer? _flushTimer;
  bool _isInitialized = false;

  /// Initialize production logging
  Future<void> initialize({
    required String environment,
    required String apiEndpoint,
    required String apiKey,
  }) async {
    if (_isInitialized) return;

    final outputs = <LogOutput>[
      // Console output for debugging
      if (kDebugMode) ConsoleLogOutput(colorized: true),
      
      // File output for local logging
      FileLogOutput(
        filePath: await _getLogFilePath(),
        maxFileSize: 5 * 1024 * 1024, // 5MB
        maxFiles: 3,
      ),
      
      // Remote output for production
      if (!kDebugMode) RemoteLogOutput(
        endpoint: '$apiEndpoint/logs',
        apiKey: apiKey,
        batchInterval: const Duration(seconds: 30),
        maxBatchSize: 50,
      ),
    ];

    _logger = Logger();
    _logger.initialize(
      outputs: outputs,
      minimumLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
      globalContext: {
        'environment': environment,
        'app_version': await _getAppVersion(),
        'platform': Platform.operatingSystem,
        'device_id': await _getDeviceId(),
      },
    );

    // Setup periodic log analysis
    _setupLogAnalysis();
    
    _isInitialized = true;
    _logger.info('Production logging initialized');
  }

  /// Setup log analysis and metrics
  void _setupLogAnalysis() {
    // Analyze logs every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (_) {
      _analyzeRecentLogs();
    });

    // Generate daily reports
    Timer.periodic(const Duration(hours: 24), (_) {
      _generateDailyReport();
    });
  }

  /// Analyze recent logs for patterns
  void _analyzeRecentLogs() {
    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
    
    // Get recent logs from buffer
    final recentLogs = _getLogsInTimeRange(fiveMinutesAgo, now);
    
    // Analyze error patterns
    final errorCount = recentLogs.where((log) => 
        log.level == LogLevel.error || log.level == LogLevel.critical).length;
    
    if (errorCount > 10) {
      _logger.warning('High error rate detected', extra: {
        'error_count': errorCount,
        'time_window': '5_minutes',
      });
    }

    // Analyze performance patterns
    final performanceLogs = recentLogs.where((log) => 
        log.context['type'] == 'performance').toList();
    
    if (performanceLogs.isNotEmpty) {
      final avgDuration = performanceLogs
          .map((log) => log.context['duration_ms'] as int? ?? 0)
          .reduce((a, b) => a + b) / performanceLogs.length;
      
      if (avgDuration > 5000) { // > 5 seconds
        _logger.warning('Performance degradation detected', extra: {
          'avg_duration_ms': avgDuration,
          'sample_count': performanceLogs.length,
        });
      }
    }
  }

  /// Generate daily report
  void _generateDailyReport() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    final dailyLogs = _getLogsInTimeRange(yesterday, now);
    
    final report = {
      'date': yesterday.toIso8601String().split('T')[0],
      'total_logs': dailyLogs.length,
      'errors': dailyLogs.where((log) => log.level == LogLevel.error).length,
      'warnings': dailyLogs.where((log) => log.level == LogLevel.warning).length,
      'performance_issues': dailyLogs.where((log) => 
          log.context['type'] == 'performance' && 
          (log.context['duration_ms'] as int? ?? 0) > 3000).length,
      'top_errors': _getTopErrors(dailyLogs),
    };

    _logger.info('Daily logging report', extra: report);
  }

  List<LogEntry> _getLogsInTimeRange(DateTime start, DateTime end) {
    // Implementation would retrieve logs from buffer or storage
    return []; // Placeholder
  }

  Map<String, int> _getTopErrors(List<LogEntry> logs) {
    final errorCounts = <String, int>{};
    
    for (final log in logs) {
      if (log.level == LogLevel.error && log.error != null) {
        final errorType = log.error.runtimeType.toString();
        errorCounts[errorType] = (errorCounts[errorType] ?? 0) + 1;
      }
    }
    
    // Sort by count and return top 5
    final sorted = errorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(5));
  }

  Future<String> _getLogFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/logs/app.log';
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  Future<String> _getDeviceId() async {
    return await PlatformDeviceId.getDeviceId ?? 'unknown';
  }
}

/// Log buffer for analysis
class LogBuffer {
  final int maxSize;
  final List<LogEntry> _entries = [];

  LogBuffer({this.maxSize = 1000});

  void add(LogEntry entry) {
    _entries.add(entry);
    if (_entries.length > maxSize) {
      _entries.removeAt(0);
    }
  }

  List<LogEntry> getEntries({
    DateTime? since,
    LogLevel? minimumLevel,
  }) {
    return _entries.where((entry) {
      if (since != null && entry.timestamp.isBefore(since)) return false;
      if (minimumLevel != null && entry.level.index < minimumLevel.index) return false;
      return true;
    }).toList();
  }
}
```

## 📊 Performance Monitoring

### Performance Tracking System
```dart
// lib/core/monitoring/performance_monitor.dart
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Logger _logger = Logger();
  final Map<String, PerformanceMetric> _metrics = {};
  final List<PerformanceSnapshot> _snapshots = [];
  Timer? _monitoringTimer;

  /// Initialize performance monitoring
  void initialize() {
    // Start monitoring every 30 seconds
    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _capturePerformanceSnapshot();
    });

    _logger.info('Performance monitoring initialized');
  }

  /// Track method execution time
  Future<T> trackExecution<T>({
    required String operation,
    required Future<T> Function() function,
    Map<String, dynamic>? context,
    Duration? warningThreshold,
  }) async {
    final stopwatch = Stopwatch()..start();
    final startTime = DateTime.now();

    try {
      final result = await function();
      stopwatch.stop();

      final duration = stopwatch.elapsed;
      _recordMetric(operation, duration, success: true, context: context);

      // Log warning if execution time exceeds threshold
      if (warningThreshold != null && duration > warningThreshold) {
        _logger.warning('Slow operation detected', extra: {
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
          'threshold_ms': warningThreshold.inMilliseconds,
          'context': context,
        });
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      _recordMetric(operation, stopwatch.elapsed, success: false, context: context);
      rethrow;
    }
  }

  /// Track widget build performance
  void trackWidgetBuild(String widgetName, Duration buildTime) {
    _recordMetric('widget_build_$widgetName', buildTime, success: true);

    if (buildTime.inMilliseconds > 16) { // > 16ms (60fps threshold)
      _logger.warning('Slow widget build', extra: {
        'widget': widgetName,
        'build_time_ms': buildTime.inMilliseconds,
        'fps_impact': true,
      });
    }
  }

  /// Track memory usage
  void trackMemoryUsage() {
    // Implementation would use platform-specific memory APIs
    final memoryInfo = _getMemoryInfo();
    
    _logger.info('Memory usage', extra: {
      'type': 'memory',
      'used_mb': memoryInfo.usedMemoryMB,
      'available_mb': memoryInfo.availableMemoryMB,
      'usage_percentage': memoryInfo.usagePercentage,
    });

    if (memoryInfo.usagePercentage > 80) {
      _logger.warning('High memory usage detected', extra: {
        'usage_percentage': memoryInfo.usagePercentage,
        'used_mb': memoryInfo.usedMemoryMB,
      });
    }
  }

  /// Track frame rendering performance
  void trackFramePerformance() {
    final binding = WidgetsBinding.instance;
    
    binding.addPostFrameCallback((_) {
      final frameTime = binding.currentSystemFrameTimeStamp;
      // Calculate frame duration and log if slow
    });
  }

  /// Get performance summary
  PerformanceSummary getPerformanceSummary({Duration? period}) {
    final cutoff = period != null 
        ? DateTime.now().subtract(period)
        : DateTime.now().subtract(const Duration(hours: 1));

    final recentMetrics = _metrics.values
        .where((metric) => metric.lastUpdated.isAfter(cutoff))
        .toList();

    final slowOperations = recentMetrics
        .where((metric) => metric.averageDuration.inMilliseconds > 1000)
        .toList();

    return PerformanceSummary(
      totalOperations: recentMetrics.fold(0, (sum, metric) => sum + metric.callCount),
      averageResponseTime: _calculateAverageResponseTime(recentMetrics),
      slowOperations: slowOperations.map((m) => m.name).toList(),
      errorRate: _calculateErrorRate(recentMetrics),
      memoryUsageTrend: _getMemoryTrend(),
    );
  }

  void _recordMetric(
    String operation, 
    Duration duration, {
    required bool success,
    Map<String, dynamic>? context,
  }) {
    final metric = _metrics.putIfAbsent(operation, () => PerformanceMetric(name: operation));
    metric.addMeasurement(duration, success: success);

    _logger.logPerformance(
      metric: operation,
      duration: duration,
      extra: {
        'success': success,
        'call_count': metric.callCount,
        'avg_duration_ms': metric.averageDuration.inMilliseconds,
        ...?context,
      },
    );
  }

  void _capturePerformanceSnapshot() {
    final snapshot = PerformanceSnapshot(
      timestamp: DateTime.now(),
      memoryInfo: _getMemoryInfo(),
      cpuUsage: _getCPUUsage(),
      activeOperations: _metrics.length,
      averageResponseTime: _calculateAverageResponseTime(_metrics.values.toList()),
    );

    _snapshots.add(snapshot);

    // Keep only last 100 snapshots
    if (_snapshots.length > 100) {
      _snapshots.removeAt(0);
    }

    // Log snapshot
    _logger.info('Performance snapshot', extra: snapshot.toMap());
  }

  MemoryInfo _getMemoryInfo() {
    // Platform-specific implementation
    return MemoryInfo(
      usedMemoryMB: 150, // Placeholder
      availableMemoryMB: 350, // Placeholder
    );
  }

  double _getCPUUsage() {
    // Platform-specific implementation
    return 25.0; // Placeholder
  }

  Duration _calculateAverageResponseTime(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return Duration.zero;
    
    final totalMs = metrics.fold(0, (sum, metric) => sum + metric.averageDuration.inMilliseconds);
    return Duration(milliseconds: (totalMs / metrics.length).round());
  }

  double _calculateErrorRate(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    
    final totalCalls = metrics.fold(0, (sum, metric) => sum + metric.callCount);
    final totalErrors = metrics.fold(0, (sum, metric) => sum + metric.errorCount);
    
    return totalCalls > 0 ? (totalErrors / totalCalls) * 100 : 0.0;
  }

  List<double> _getMemoryTrend() {
    return _snapshots.map((s) => s.memoryInfo.usagePercentage).toList();
  }

  void dispose() {
    _monitoringTimer?.cancel();
  }
}

/// Performance metric data
class PerformanceMetric {
  final String name;
  final List<Duration> _durations = [];
  int _errorCount = 0;
  DateTime _lastUpdated = DateTime.now();

  PerformanceMetric({required this.name});

  void addMeasurement(Duration duration, {required bool success}) {
    _durations.add(duration);
    if (!success) _errorCount++;
    _lastUpdated = DateTime.now();

    // Keep only last 100 measurements
    if (_durations.length > 100) {
      _durations.removeAt(0);
    }
  }

  int get callCount => _durations.length;
  int get errorCount => _errorCount;
  DateTime get lastUpdated => _lastUpdated;

  Duration get averageDuration {
    if (_durations.isEmpty) return Duration.zero;
    final totalMs = _durations.fold(0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: (totalMs / _durations.length).round());
  }

  Duration get maxDuration => _durations.isEmpty ? Duration.zero : _durations.reduce((a, b) => a > b ? a : b);
  Duration get minDuration => _durations.isEmpty ? Duration.zero : _durations.reduce((a, b) => a < b ? a : b);
}

/// Performance snapshot data
class PerformanceSnapshot {
  final DateTime timestamp;
  final MemoryInfo memoryInfo;
  final double cpuUsage;
  final int activeOperations;
  final Duration averageResponseTime;

  PerformanceSnapshot({
    required this.timestamp,
    required this.memoryInfo,
    required this.cpuUsage,
    required this.activeOperations,
    required this.averageResponseTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'memory_used_mb': memoryInfo.usedMemoryMB,
      'memory_usage_percent': memoryInfo.usagePercentage,
      'cpu_usage_percent': cpuUsage,
      'active_operations': activeOperations,
      'avg_response_time_ms': averageResponseTime.inMilliseconds,
    };
  }
}

/// Memory information
class MemoryInfo {
  final int usedMemoryMB;
  final int availableMemoryMB;

  MemoryInfo({
    required this.usedMemoryMB,
    required this.availableMemoryMB,
  });

  int get totalMemoryMB => usedMemoryMB + availableMemoryMB;
  double get usagePercentage => (usedMemoryMB / totalMemoryMB) * 100;
}

/// Performance summary
class PerformanceSummary {
  final int totalOperations;
  final Duration averageResponseTime;
  final List<String> slowOperations;
  final double errorRate;
  final List<double> memoryUsageTrend;

  PerformanceSummary({
    required this.totalOperations,
    required this.averageResponseTime,
    required this.slowOperations,
    required this.errorRate,
    required this.memoryUsageTrend,
  });
}
```

## 📈 Error Analytics

### Error Analytics Dashboard
```dart
// lib/core/analytics/error_analytics.dart
class ErrorAnalytics {
  static final ErrorAnalytics _instance = ErrorAnalytics._internal();
  factory ErrorAnalytics() => _instance;
  ErrorAnalytics._internal();

  final Logger _logger = Logger();
  final Map<String, ErrorPattern> _patterns = {};
  final List<ErrorTrend> _trends = [];

  /// Track error for analytics
  void trackError(ErrorInfo errorInfo) {
    final pattern = _patterns.putIfAbsent(
      errorInfo.error.runtimeType.toString(),
      () => ErrorPattern(errorType: errorInfo.error.runtimeType.toString()),
    );

    pattern.addOccurrence(errorInfo);

    // Update trends
    _updateTrends(errorInfo);

    // Check for critical patterns
    _checkCriticalPatterns(pattern);

    // Log analytics event
    _logger.info('Error tracked for analytics', extra: {
      'error_type': errorInfo.error.runtimeType.toString(),
      'severity': errorInfo.severity.name,
      'pattern_count': pattern.occurrences,
      'trend_direction': _getTrendDirection(errorInfo.error.runtimeType.toString()),
    });
  }

  /// Get error analytics report
  ErrorAnalyticsReport generateReport({Duration? period}) {
    final cutoff = period != null 
        ? DateTime.now().subtract(period)
        : DateTime.now().subtract(const Duration(days: 7));

    final recentPatterns = _patterns.values
        .where((pattern) => pattern.lastOccurrence.isAfter(cutoff))
        .toList();

    final topErrors = recentPatterns
        .where((pattern) => pattern.occurrences >= 5)
        .toList()
        ..sort((a, b) => b.occurrences.compareTo(a.occurrences));

    final criticalErrors = recentPatterns
        .where((pattern) => pattern.severity == ErrorSeverity.critical)
        .toList();

    final userImpactingErrors = recentPatterns
        .where((pattern) => pattern.severity == ErrorSeverity.high && pattern.occurrences >= 10)
        .toList();

    return ErrorAnalyticsReport(
      period: period ?? const Duration(days: 7),
      totalErrors: recentPatterns.fold(0, (sum, pattern) => sum + pattern.occurrences),
      uniqueErrorTypes: recentPatterns.length,
      topErrors: topErrors.take(10).toList(),
      criticalErrors: criticalErrors,
      userImpactingErrors: userImpactingErrors,
      errorTrends: _getTrendAnalysis(),
      recommendations: _generateRecommendations(recentPatterns),
    );
  }

  void _updateTrends(ErrorInfo errorInfo) {
    final hour = DateTime.now().hour;
    final today = DateTime.now().day;
    
    final trend = _trends.firstWhere(
      (t) => t.errorType == errorInfo.error.runtimeType.toString() && 
             t.date.day == today && 
             t.hour == hour,
      orElse: () {
        final newTrend = ErrorTrend(
          errorType: errorInfo.error.runtimeType.toString(),
          date: DateTime.now(),
          hour: hour,
        );
        _trends.add(newTrend);
        return newTrend;
      },
    );

    trend.increment();

    // Keep only last 7 days of trends
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    _trends.removeWhere((trend) => trend.date.isBefore(weekAgo));
  }

  void _checkCriticalPatterns(ErrorPattern pattern) {
    // Check for error spikes
    if (pattern.occurrences >= 50 && pattern.isRecentSpike()) {
      _logger.critical('Error spike detected', extra: {
        'error_type': pattern.errorType,
        'occurrences': pattern.occurrences,
        'time_window': '1_hour',
      });
    }

    // Check for critical error frequency
    if (pattern.severity == ErrorSeverity.critical && pattern.occurrences >= 5) {
      _logger.critical('Multiple critical errors detected', extra: {
        'error_type': pattern.errorType,
        'occurrences': pattern.occurrences,
      });
    }

    // Check for user impact
    if (pattern.affectedUsers.length >= 100) {
      _logger.warning('High user impact error', extra: {
        'error_type': pattern.errorType,
        'affected_users': pattern.affectedUsers.length,
      });
    }
  }

  String _getTrendDirection(String errorType) {
    final recentTrends = _trends
        .where((t) => t.errorType == errorType)
        .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

    if (recentTrends.length < 2) return 'stable';

    final recent = recentTrends.takeLast(6).fold(0, (sum, trend) => sum + trend.count);
    final previous = recentTrends.take(recentTrends.length - 6).fold(0, (sum, trend) => sum + trend.count);

    if (recent > previous * 1.5) return 'increasing';
    if (recent < previous * 0.5) return 'decreasing';
    return 'stable';
  }

  Map<String, TrendAnalysis> _getTrendAnalysis() {
    final analysis = <String, TrendAnalysis>{};

    for (final pattern in _patterns.values) {
      final trends = _trends.where((t) => t.errorType == pattern.errorType).toList();
      
      if (trends.isEmpty) continue;

      final totalCount = trends.fold(0, (sum, trend) => sum + trend.count);
      final avgPerHour = totalCount / trends.length;
      final peakHour = trends.reduce((a, b) => a.count > b.count ? a : b).hour;

      analysis[pattern.errorType] = TrendAnalysis(
        direction: _getTrendDirection(pattern.errorType),
        averagePerHour: avgPerHour,
        peakHour: peakHour,
        totalOccurrences: totalCount,
      );
    }

    return analysis;
  }

  List<String> _generateRecommendations(List<ErrorPattern> patterns) {
    final recommendations = <String>[];

    // Network error recommendations
    final networkErrors = patterns.where((p) => p.errorType.contains('Network')).toList();
    if (networkErrors.isNotEmpty) {
      final totalNetworkErrors = networkErrors.fold(0, (sum, p) => sum + p.occurrences);
      if (totalNetworkErrors > 100) {
        recommendations.add('High network error rate detected. Consider implementing better retry logic and offline capabilities.');
      }
    }

    // Authentication error recommendations
    final authErrors = patterns.where((p) => p.errorType.contains('Authentication')).toList();
    if (authErrors.isNotEmpty) {
      recommendations.add('Authentication errors detected. Review token refresh logic and session management.');
    }

    // Memory error recommendations
    final memoryErrors = patterns.where((p) => p.errorType.contains('Memory')).toList();
    if (memoryErrors.isNotEmpty) {
      recommendations.add('Memory-related errors detected. Consider optimizing memory usage and implementing proper disposal.');
    }

    // Validation error recommendations
    final validationErrors = patterns.where((p) => p.errorType.contains('Validation')).toList();
    if (validationErrors.isNotEmpty && validationErrors.first.occurrences > 50) {
      recommendations.add('High validation error rate. Review input validation and user experience.');
    }

    return recommendations;
  }
}

/// Error pattern tracking
class ErrorPattern {
  final String errorType;
  int _occurrences = 0;
  DateTime _firstOccurrence = DateTime.now();
  DateTime _lastOccurrence = DateTime.now();
  ErrorSeverity _severity = ErrorSeverity.medium;
  final Set<String> _affectedUsers = {};
  final List<DateTime> _hourlyOccurrences = [];

  ErrorPattern({required this.errorType});

  void addOccurrence(ErrorInfo errorInfo) {
    _occurrences++;
    _lastOccurrence = DateTime.now();
    _hourlyOccurrences.add(DateTime.now());
    
    if (errorInfo.severity.index > _severity.index) {
      _severity = errorInfo.severity;
    }

    // Track affected users
    final userId = errorInfo.userInfo['user_id'] as String?;
    if (userId != null) {
      _affectedUsers.add(userId);
    }

    // Keep only last hour of occurrences for spike detection
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    _hourlyOccurrences.removeWhere((time) => time.isBefore(oneHourAgo));
  }

  int get occurrences => _occurrences;
  DateTime get firstOccurrence => _firstOccurrence;
  DateTime get lastOccurrence => _lastOccurrence;
  ErrorSeverity get severity => _severity;
  Set<String> get affectedUsers => _affectedUsers;

  bool isRecentSpike() {
    return _hourlyOccurrences.length >= 10; // 10+ errors in last hour
  }
}

/// Error trend data
class ErrorTrend {
  final String errorType;
  final DateTime date;
  final int hour;
  int _count = 0;

  ErrorTrend({
    required this.errorType,
    required this.date,
    required this.hour,
  });

  void increment() => _count++;
  int get count => _count;
}

/// Trend analysis
class TrendAnalysis {
  final String direction;
  final double averagePerHour;
  final int peakHour;
  final int totalOccurrences;

  TrendAnalysis({
    required this.direction,
    required this.averagePerHour,
    required this.peakHour,
    required this.totalOccurrences,
  });
}

/// Error analytics report
class ErrorAnalyticsReport {
  final Duration period;
  final int totalErrors;
  final int uniqueErrorTypes;
  final List<ErrorPattern> topErrors;
  final List<ErrorPattern> criticalErrors;
  final List<ErrorPattern> userImpactingErrors;
  final Map<String, TrendAnalysis> errorTrends;
  final List<String> recommendations;

  ErrorAnalyticsReport({
    required this.period,
    required this.totalErrors,
    required this.uniqueErrorTypes,
    required this.topErrors,
    required this.criticalErrors,
    required this.userImpactingErrors,
    required this.errorTrends,
    required this.recommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'period_days': period.inDays,
      'total_errors': totalErrors,
      'unique_error_types': uniqueErrorTypes,
      'top_errors': topErrors.map((e) => {
        'type': e.errorType,
        'count': e.occurrences,
        'severity': e.severity.name,
        'affected_users': e.affectedUsers.length,
      }).toList(),
      'critical_errors_count': criticalErrors.length,
      'user_impacting_errors_count': userImpactingErrors.length,
      'recommendations': recommendations,
    };
  }
}
```

---

## 🎯 Error Handling & Logging Summary

Bu **Error Handling & Logging** rehberi, production-ready Flutter uygulamaları için kapsamlı hata yönetimi ve loglama çözümü sunuyor:

### 🌐 **Global Error Management**
- **Unified Error Handling** - Tüm hata türleri için merkezi yönetim
- **Custom Exception Framework** - Uygulama-spesifik hata sınıfları
- **Automatic Recovery** - Otomatik hata kurtarma stratejileri
- **Context Preservation** - Hata bağlamının korunması

### 📊 **Advanced Logging System**
- **Structured Logging** - JSON formatında organize loglar
- **Multiple Outputs** - Console, file, remote endpoint desteği
- **Log Levels** - Debug, info, warning, error, critical
- **Performance Tracking** - İşlem sürelerinin izlenmesi

### 🔄 **State Management Integration**
- **BLoC Error Patterns** - State management için hata yönetimi
- **Error States** - Kullanıcı dostu hata durumları
- **Recovery Actions** - Otomatik ve manuel kurtarma seçenekleri
- **Context Awareness** - Hata durumuna uygun aksiyon önerileri

### 💬 **User Experience Focus**
- **Friendly Messages** - Kullanıcı dostu hata mesajları
- **Actionable UI** - Çözüm odaklı arayüz elemanları
- **Progressive Disclosure** - Detay seviyesine göre bilgi sunumu
- **Recovery Guidance** - Kullanıcıya rehberlik eden aksiyonlar

### 📈 **Production Monitoring**
- **Error Analytics** - Hata pattern analizi ve trend izleme
- **Performance Metrics** - Uygulama performans göstergeleri
- **Crash Reporting** - Firebase Crashlytics entegrasyonu
- **Real-time Alerts** - Kritik durumlar için anlık bildirimler

### 🔧 **Developer Tools**
- **Debug Information** - Geliştirici dostu hata detayları
- **Error Details Dialog** - Kapsamlı hata bilgisi ekranı
- **Log Analysis** - Pattern detection ve anomaly detection
- **Performance Profiling** - Memory ve CPU kullanım izleme
