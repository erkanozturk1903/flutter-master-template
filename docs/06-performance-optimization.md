⚡ Performance & Optimization

## Overview

Performance is critical for user experience and app success. This guide establishes comprehensive standards for monitoring, optimizing, and maintaining high-performance Flutter applications through proactive performance management, memory optimization, and efficient rendering techniques.

## Performance Monitoring & Analytics

### Performance Monitor Service

```dart
// core/performance/performance_monitor.dart
class PerformanceMonitor {
  static const String _tag = 'PerformanceMonitor';
  static final Map<String, Stopwatch> _activeTraces = {};
  static final List<PerformanceMetric> _metrics = [];

  /// Initialize performance monitoring
  static Future<void> initialize() async {
    // Initialize Firebase Performance
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    
    // Set up custom performance tracking
    _setupFrameMetricsCallback();
    _setupMemoryMonitoring();
    
    if (kDebugMode) {
      debugPrint('[$_tag] Performance monitoring initialized');
    }
  }

  /// Start a custom trace
  static Trace startTrace(String traceName) {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    trace.start();
    
    _activeTraces[traceName] = Stopwatch()..start();
    
    if (kDebugMode) {
      debugPrint('[$_tag] Started trace: $traceName');
    }
    
    return trace;
  }

  /// Stop a custom trace
  static void stopTrace(String traceName) {
    final stopwatch = _activeTraces.remove(traceName);
    if (stopwatch != null) {
      stopwatch.stop();
      
      final metric = PerformanceMetric(
        name: traceName,
        duration: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
      
      _metrics.add(metric);
      
      if (kDebugMode) {
        debugPrint('[$_tag] Stopped trace: $traceName (${stopwatch.elapsedMilliseconds}ms)');
      }
    }

    // Stop Firebase trace
    final trace = FirebasePerformance.instance.newTrace(traceName);
    trace.stop();
  }

  /// Record custom metric
  static void recordCustomMetric(String name, int value) {
    FirebaseAnalytics.instance.logEvent(
      name: 'performance_metric',
      parameters: {
        'metric_name': name,
        'metric_value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    if (kDebugMode) {
      debugPrint('[$_tag] Recorded metric: $name = $value');
    }
  }

  /// Track screen rendering performance
  static void trackScreenPerformance(String screenName) {
    FirebaseAnalytics.instance.logScreenView(screenName: screenName);
    
    // Start trace for screen load time
    startTrace('screen_$screenName');
  }

  /// Measure function execution time
  static Future<T> measureAsync<T>(String operationName, Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      recordCustomMetric('${operationName}_duration', stopwatch.elapsedMilliseconds);
      
      if (kDebugMode) {
        debugPrint('[$_tag] $operationName took ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      recordCustomMetric('${operationName}_error', stopwatch.elapsedMilliseconds);
      rethrow;
    }
  }

  /// Measure synchronous function execution time
  static T measureSync<T>(String operationName, T Function() operation) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      recordCustomMetric('${operationName}_duration', stopwatch.elapsedMilliseconds);
      
      if (kDebugMode) {
        debugPrint('[$_tag] $operationName took ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      recordCustomMetric('${operationName}_error', stopwatch.elapsedMilliseconds);
      rethrow;
    }
  }

  /// Setup frame metrics callback
  static void _setupFrameMetricsCallback() {
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      final frameMetrics = WidgetsBinding.instance.window.render.frameMetrics;
      if (frameMetrics != null) {
        _analyzeFrameMetrics(frameMetrics);
      }
    });
  }

  /// Analyze frame rendering metrics
  static void _analyzeFrameMetrics(FrameMetrics frameMetrics) {
    final frameDuration = frameMetrics.totalSpan.inMilliseconds;
    final buildDuration = frameMetrics.buildDuration.inMilliseconds;
    final rasterDuration = frameMetrics.rasterDuration.inMilliseconds;

    // Record frame metrics
    recordCustomMetric('frame_total_duration', frameDuration);
    recordCustomMetric('frame_build_duration', buildDuration);
    recordCustomMetric('frame_raster_duration', rasterDuration);

    // Detect janky frames (>16ms for 60fps)
    if (frameDuration > 16) {
      recordCustomMetric('janky_frame_count', 1);
      
      if (kDebugMode) {
        debugPrint('[$_tag] Janky frame detected: ${frameDuration}ms');
      }
    }
  }

  /// Setup memory monitoring
  static void _setupMemoryMonitoring() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkMemoryUsage();
    });
  }

  /// Check current memory usage
  static void _checkMemoryUsage() {
    // Platform-specific memory monitoring would go here
    // For now, we'll use a placeholder
    if (kDebugMode) {
      debugPrint('[$_tag] Memory check completed');
    }
  }

  /// Get performance metrics summary
  static PerformanceSummary getPerformanceSummary() {
    if (_metrics.isEmpty) {
      return PerformanceSummary.empty();
    }

    final durations = _metrics.map((m) => m.duration).toList();
    durations.sort();

    return PerformanceSummary(
      totalMetrics: _metrics.length,
      averageDuration: durations.fold<int>(0, (a, b) => a + b) / durations.length,
      medianDuration: durations[durations.length ~/ 2].toDouble(),
      p95Duration: durations[(durations.length * 0.95).round() - 1].toDouble(),
      slowestOperation: _metrics.reduce((a, b) => a.duration > b.duration ? a : b),
    );
  }

  /// Clear performance metrics
  static void clearMetrics() {
    _metrics.clear();
    _activeTraces.clear();
  }
}

class PerformanceMetric {
  const PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
  });

  final String name;
  final int duration;
  final DateTime timestamp;
}

class PerformanceSummary {
  const PerformanceSummary({
    required this.totalMetrics,
    required this.averageDuration,
    required this.medianDuration,
    required this.p95Duration,
    required this.slowestOperation,
  });

  final int totalMetrics;
  final double averageDuration;
  final double medianDuration;
  final double p95Duration;
  final PerformanceMetric slowestOperation;

  factory PerformanceSummary.empty() {
    return PerformanceSummary(
      totalMetrics: 0,
      averageDuration: 0,
      medianDuration: 0,
      p95Duration: 0,
      slowestOperation: PerformanceMetric(
        name: 'none',
        duration: 0,
        timestamp: DateTime.now(),
      ),
    );
  }
}
```

### Performance-Aware Widgets

```dart
// shared/widgets/performance/performance_widget.dart
abstract class PerformanceAwareWidget extends StatefulWidget {
  const PerformanceAwareWidget({super.key});

  String get performanceId;
}

abstract class PerformanceAwareState<T extends PerformanceAwareWidget> 
    extends State<T> with TickerProviderStateMixin {
  
  late final Stopwatch _buildStopwatch;
  late final Stopwatch _initStopwatch;
  int _buildCount = 0;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _buildStopwatch = Stopwatch();
    _initStopwatch = Stopwatch()..start();
    
    PerformanceMonitor.trackScreenPerformance(widget.performanceId);
    
    // Track init performance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initStopwatch.stop();
      PerformanceMonitor.recordCustomMetric(
        '${widget.performanceId}_init_time',
        _initStopwatch.elapsedMilliseconds,
      );
      
      if (_isFirstBuild) {
        PerformanceMonitor.stopTrace('screen_${widget.performanceId}');
        _isFirstBuild = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildStopwatch.start();
    
    final widget = buildWidget(context);
    
    _buildStopwatch.stop();
    _buildCount++;
    
    // Record build performance
    PerformanceMonitor.recordCustomMetric(
      '${this.widget.performanceId}_build_time',
      _buildStopwatch.elapsedMilliseconds,
    );
    
    if (kDebugMode && _buildStopwatch.elapsedMilliseconds > 16) {
      debugPrint(
        'Performance Warning: ${this.widget.performanceId} build #$_buildCount '
        'took ${_buildStopwatch.elapsedMilliseconds}ms (>16ms threshold)',
      );
    }
    
    _buildStopwatch.reset();
    return widget;
  }

  Widget buildWidget(BuildContext context);

  @override
  void dispose() {
    PerformanceMonitor.recordCustomMetric(
      '${widget.performanceId}_total_builds',
      _buildCount,
    );
    super.dispose();
  }
}

// Example usage
class HomeScreen extends PerformanceAwareWidget {
  const HomeScreen({super.key});

  @override
  String get performanceId => 'home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends PerformanceAwareState<HomeScreen> {
  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const HomeContent(),
    );
  }
}
```

## Memory Management & Optimization

### Memory Monitor

```dart
// core/performance/memory_monitor.dart
class MemoryMonitor {
  static Timer? _monitoringTimer;
  static final List<MemorySnapshot> _snapshots = [];

  /// Start memory monitoring
  static void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(interval, (_) => _takeSnapshot());
    
    if (kDebugMode) {
      debugPrint('MemoryMonitor: Started monitoring with ${interval.inSeconds}s interval');
    }
  }

  /// Stop memory monitoring
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    if (kDebugMode) {
      debugPrint('MemoryMonitor: Stopped monitoring');
    }
  }

  /// Take memory snapshot
  static void _takeSnapshot() {
    // In a real implementation, you would use platform channels
    // to get actual memory usage from the platform
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      heapUsage: _getHeapUsage(),
      totalMemory: _getTotalMemory(),
    );

    _snapshots.add(snapshot);

    // Keep only last 100 snapshots
    if (_snapshots.length > 100) {
      _snapshots.removeAt(0);
    }

    // Check for memory leaks
    _checkForMemoryLeaks(snapshot);
  }

  /// Get current heap usage (placeholder)
  static int _getHeapUsage() {
    // Platform-specific implementation would go here
    return 0;
  }

  /// Get total memory usage (placeholder)
  static int _getTotalMemory() {
    // Platform-specific implementation would go here
    return 0;
  }

  /// Check for potential memory leaks
  static void _checkForMemoryLeaks(MemorySnapshot snapshot) {
    if (_snapshots.length < 10) return;

    final recent = _snapshots.skip(_snapshots.length - 10).toList();
    final growthRate = (recent.last.heapUsage - recent.first.heapUsage) / 10;

    if (growthRate > 1024 * 1024) { // 1MB per snapshot
      PerformanceMonitor.recordCustomMetric('memory_leak_warning', 1);
      
      if (kDebugMode) {
        debugPrint('MemoryMonitor: Potential memory leak detected (growth: ${growthRate / 1024 / 1024:.2f}MB)');
      }
    }
  }

  /// Get memory statistics
  static MemoryStats getMemoryStats() {
    if (_snapshots.isEmpty) {
      return MemoryStats.empty();
    }

    final heapUsages = _snapshots.map((s) => s.heapUsage).toList();
    final totalMemories = _snapshots.map((s) => s.totalMemory).toList();

    return MemoryStats(
      currentHeapUsage: heapUsages.last,
      currentTotalMemory: totalMemories.last,
      averageHeapUsage: heapUsages.fold<int>(0, (a, b) => a + b) / heapUsages.length,
      peakHeapUsage: heapUsages.reduce((a, b) => a > b ? a : b),
      snapshotCount: _snapshots.length,
    );
  }

  /// Clear memory snapshots
  static void clearSnapshots() {
    _snapshots.clear();
  }
}

class MemorySnapshot {
  const MemorySnapshot({
    required this.timestamp,
    required this.heapUsage,
    required this.totalMemory,
  });

  final DateTime timestamp;
  final int heapUsage;
  final int totalMemory;
}

class MemoryStats {
  const MemoryStats({
    required this.currentHeapUsage,
    required this.currentTotalMemory,
    required this.averageHeapUsage,
    required this.peakHeapUsage,
    required this.snapshotCount,
  });

  final int currentHeapUsage;
  final int currentTotalMemory;
  final double averageHeapUsage;
  final int peakHeapUsage;
  final int snapshotCount;

  factory MemoryStats.empty() {
    return const MemoryStats(
      currentHeapUsage: 0,
      currentTotalMemory: 0,
      averageHeapUsage: 0,
      peakHeapUsage: 0,
      snapshotCount: 0,
    );
  }
}
```

### Memory-Efficient Widgets

```dart
// shared/widgets/performance/memory_efficient_widgets.dart

/// Efficient list widget with recycling
class PerformantListView<T> extends StatefulWidget {
  const PerformantListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.cacheExtent,
    this.itemExtent,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final double? cacheExtent;
  final double? itemExtent;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  State<PerformantListView<T>> createState() => _PerformantListViewState<T>();
}

class _PerformantListViewState<T> extends State<PerformantListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore != null &&
        !_isLoadingMore &&
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget listView;

    if (widget.separatorBuilder != null) {
      listView = ListView.separated(
        controller: _scrollController,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        cacheExtent: widget.cacheExtent,
        itemCount: widget.items.length,
        itemBuilder: (context, index) => _buildItem(context, index),
        separatorBuilder: widget.separatorBuilder!,
      );
    } else {
      listView = ListView.builder(
        controller: _scrollController,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        cacheExtent: widget.cacheExtent,
        itemExtent: widget.itemExtent,
        itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildItem(context, index);
        },
      );
    }

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildItem(BuildContext context, int index) {
    return AutomaticKeepAliveClientMixin.wantKeepAlive
        ? KeepAliveItem(
            key: ValueKey(widget.items[index]),
            child: widget.itemBuilder(context, widget.items[index], index),
          )
        : widget.itemBuilder(context, widget.items[index], index);
  }
}

/// Keep alive wrapper for list items
class KeepAliveItem extends StatefulWidget {
  const KeepAliveItem({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<KeepAliveItem> createState() => _KeepAliveItemState();
}

class _KeepAliveItemState extends State<KeepAliveItem>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Memory-efficient image widget
class PerformantImage extends StatefulWidget {
  const PerformantImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  @override
  State<PerformantImage> createState() => _PerformantImageState();
}

class _PerformantImageState extends State<PerformantImage> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      
      // Memory optimization
      memCacheWidth: widget.memCacheWidth ?? widget.width?.toInt(),
      memCacheHeight: widget.memCacheHeight ?? widget.height?.toInt(),
      maxWidthDiskCache: widget.maxWidthDiskCache ?? 1000,
      maxHeightDiskCache: widget.maxHeightDiskCache ?? 1000,
      
      // Performance settings
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      
      placeholder: (context, url) {
        return widget.placeholder ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
      },
      
      errorWidget: (context, url, error) {
        return widget.errorWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Theme.of(context).colorScheme.errorContainer,
              child: Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            );
      },
    );
  }
}
```

## Widget Optimization Patterns

### Efficient Widget Building

```dart
// shared/widgets/performance/optimized_builders.dart

/// Optimized builder that prevents unnecessary rebuilds
class OptimizedBuilder<T> extends StatefulWidget {
  const OptimizedBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.initialData,
    this.buildWhen,
  });

  final Stream<T> stream;
  final Widget Function(BuildContext context, T data) builder;
  final T? initialData;
  final bool Function(T previous, T current)? buildWhen;

  @override
  State<OptimizedBuilder<T>> createState() => _OptimizedBuilderState<T>();
}

class _OptimizedBuilderState<T> extends State<OptimizedBuilder<T>> {
  late StreamSubscription<T> _subscription;
  T? _currentData;
  T? _previousData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
    _subscription = widget.stream.listen(_onData);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onData(T data) {
    if (widget.buildWhen != null) {
      if (_currentData != null && !widget.buildWhen!(_currentData as T, data)) {
        _currentData = data;
        return; // Don't rebuild
      }
    }

    setState(() {
      _previousData = _currentData;
      _currentData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentData == null) {
      return const SizedBox.shrink();
    }

    return widget.builder(context, _currentData as T);
  }
}

/// Widget that only rebuilds when specific conditions are met
class ConditionalBuilder extends StatefulWidget {
  const ConditionalBuilder({
    super.key,
    required this.condition,
    required this.builder,
    this.fallback,
  });

  final bool Function() condition;
  final Widget Function(BuildContext context) builder;
  final Widget? fallback;

  @override
  State<ConditionalBuilder> createState() => _ConditionalBuilderState();
}

class _ConditionalBuilderState extends State<ConditionalBuilder> {
  Widget? _cachedWidget;
  bool? _lastCondition;

  @override
  Widget build(BuildContext context) {
    final currentCondition = widget.condition();

    if (_lastCondition != currentCondition || _cachedWidget == null) {
      _lastCondition = currentCondition;
      _cachedWidget = currentCondition 
          ? widget.builder(context)
          : widget.fallback ?? const SizedBox.shrink();
    }

    return _cachedWidget!;
  }
}

/// Lazy loading widget that builds content only when visible
class LazyBuilder extends StatefulWidget {
  const LazyBuilder({
    super.key,
    required this.builder,
    this.placeholder,
    this.threshold = 100.0,
  });

  final Widget Function(BuildContext context) builder;
  final Widget? placeholder;
  final double threshold;

  @override
  State<LazyBuilder> createState() => _LazyBuilderState();
}

class _LazyBuilderState extends State<LazyBuilder> {
  bool _isVisible = false;
  Widget? _builtWidget;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0 && !_isVisible) {
          setState(() {
            _isVisible = true;
            _builtWidget = widget.builder(context);
          });
        }
      },
      child: _isVisible && _builtWidget != null
          ? _builtWidget!
          : widget.placeholder ?? const SizedBox.shrink(),
    );
  }
}
```

### Performance-Optimized Form

```dart
// shared/widgets/performance/optimized_form.dart
class OptimizedForm extends StatefulWidget {
  const OptimizedForm({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.initialValues,
    this.validationMode = AutovalidateMode.onUserInteraction,
  });

  final List<FormFieldConfig> fields;
  final void Function(Map<String, dynamic> values) onSubmit;
  final Map<String, dynamic>? initialValues;
  final AutovalidateMode validationMode;

  @override
  State<OptimizedForm> createState() => _OptimizedFormState();
}

class _OptimizedFormState extends State<OptimizedForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, ValueNotifier<String?>> _errorNotifiers = {};

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _disposeFields();
    super.dispose();
  }

  void _initializeFields() {
    for (final field in widget.fields) {
      _controllers[field.key] = TextEditingController(
        text: widget.initialValues?[field.key]?.toString() ?? '',
      );
      _focusNodes[field.key] = FocusNode();
      _errorNotifiers[field.key] = ValueNotifier<String?>(null);

      // Add listeners for real-time validation
      _controllers[field.key]!.addListener(() {
        if (widget.validationMode == AutovalidateMode.onUserInteraction) {
          _validateField(field);
        }
      });
    }
  }

  void _disposeFields() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    for (final notifier in _errorNotifiers.values) {
      notifier.dispose();
    }
  }

  void _validateField(FormFieldConfig field) {
    final value = _controllers[field.key]!.text;
    final error = field.validator?.call(value);
    _errorNotifiers[field.key]!.value = error;
  }

  void _handleSubmit() {
    bool isValid = true;
    
    // Validate all fields
    for (final field in widget.fields) {
      _validateField(field);
      if (_errorNotifiers[field.key]!.value != null) {
        isValid = false;
      }
    }

    if (isValid) {
      final values = <String, dynamic>{};
      for (final field in widget.fields) {
        values[field.key] = _controllers[field.key]!.text;
      }
      widget.onSubmit(values);
    } else {
      // Focus first field with error
      for (final field in widget.fields) {
        if (_errorNotifiers[field.key]!.value != null) {
          _focusNodes[field.key]!.requestFocus();
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled, // Handle manually for better performance
      child: Column(
        children: [
          ...widget.fields.map((field) => _buildField(field)),
          const SizedBox(height: 24),
          AppButton(
            onPressed: _handleSubmit,
            isFullWidth: true,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ValueListenableBuilder<String?>(
        ```dart
        valueListenable: _errorNotifiers[field.key]!,
        builder: (context, error, child) {
          return AppTextField(
            controller: _controllers[field.key],
            focusNode: _focusNodes[field.key],
            label: field.label,
            hint: field.hint,
            errorText: error,
            keyboardType: field.keyboardType,
            obscureText: field.obscureText,
            textInputAction: field == widget.fields.last 
                ? TextInputAction.done 
                : TextInputAction.next,
            onSubmitted: (_) {
              if (field != widget.fields.last) {
                final nextFieldIndex = widget.fields.indexOf(field) + 1;
                final nextField = widget.fields[nextFieldIndex];
                _focusNodes[nextField.key]!.requestFocus();
              } else {
                _handleSubmit();
              }
            },
          );
        },
      ),
    );
  }
}

class FormFieldConfig {
  const FormFieldConfig({
    required this.key,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  final String key;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
}
```

## Image & Asset Optimization

### Optimized Image Loading

```dart
// core/performance/image_optimization.dart
class ImageOptimizer {
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxCacheObjects = 1000;

  /// Preload critical images
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    final futures = imageUrls.map((url) => precacheImage(
      CachedNetworkImageProvider(url),
      context,
    ));

    await Future.wait(futures);
  }

  /// Optimize image for display
  static Widget optimizedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableMemoryCache = true,
    bool enableDiskCache = true,
  }) {
    // Calculate optimal cache dimensions
    final memWidth = (width * MediaQuery.of(navigatorKey.currentContext!).devicePixelRatio).toInt();
    final memHeight = (height * MediaQuery.of(navigatorKey.currentContext!).devicePixelRatio).toInt();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: enableMemoryCache ? memWidth : null,
      memCacheHeight: enableMemoryCache ? memHeight : null,
      maxWidthDiskCache: enableDiskCache ? 1200 : null,
      maxHeightDiskCache: enableDiskCache ? 1200 : null,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(width, height),
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(width, height),
      cacheManager: _getOptimizedCacheManager(),
    );
  }

  static Widget _defaultPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  static Widget _defaultErrorWidget(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.error_outline, color: Colors.grey),
    );
  }

  static CacheManager _getOptimizedCacheManager() {
    return CacheManager(
      Config(
        'optimized_images',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: maxCacheObjects,
        repo: JsonCacheInfoRepository(databaseName: 'optimized_images'),
        fileService: HttpFileService(),
      ),
    );
  }

  /// Clean up image cache
  static Future<void> clearImageCache() async {
    await _getOptimizedCacheManager().emptyCache();
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Get cache statistics
  static Future<ImageCacheStats> getCacheStats() async {
    final cacheManager = _getOptimizedCacheManager();
    final cacheObjects = await cacheManager.store.getAllObjects();
    
    int totalSize = 0;
    for (final obj in cacheObjects) {
      totalSize += obj.length ?? 0;
    }

    return ImageCacheStats(
      objectCount: cacheObjects.length,
      totalSize: totalSize,
      memoryImageCount: imageCache.currentSize,
      memoryImageBytes: imageCache.currentSizeBytes,
    );
  }
}

class ImageCacheStats {
  const ImageCacheStats({
    required this.objectCount,
    required this.totalSize,
    required this.memoryImageCount,
    required this.memoryImageBytes,
  });

  final int objectCount;
  final int totalSize;
  final int memoryImageCount;
  final int memoryImageBytes;

  String get formattedDiskSize => '${(totalSize / 1024 / 1024).toStringAsFixed(1)} MB';
  String get formattedMemorySize => '${(memoryImageBytes / 1024 / 1024).toStringAsFixed(1)} MB';
}
```

### Asset Bundling Optimization

```dart
// core/assets/asset_optimizer.dart
class AssetOptimizer {
  static const Map<String, String> _assetPaths = {
    'logo': 'assets/images/logo.webp',
    'placeholder': 'assets/images/placeholder.webp',
    'error': 'assets/images/error.webp',
    'splash': 'assets/images/splash.webp',
  };

  /// Preload critical assets
  static Future<void> preloadCriticalAssets(BuildContext context) async {
    final criticalAssets = ['logo', 'placeholder', 'error'];
    
    final futures = criticalAssets.map((assetKey) {
      final assetPath = _assetPaths[assetKey];
      if (assetPath != null) {
        return precacheImage(AssetImage(assetPath), context);
      }
      return Future.value();
    });

    await Future.wait(futures);
  }

  /// Get optimized asset image
  static Widget getAssetImage(
    String assetKey, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    final assetPath = _assetPaths[assetKey];
    if (assetPath == null) {
      return Icon(Icons.error, size: width ?? height ?? 24);
    }

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error, size: width ?? height ?? 24);
      },
    );
  }

  /// Load asset as bytes for processing
  static Future<Uint8List> loadAssetBytes(String assetKey) async {
    final assetPath = _assetPaths[assetKey];
    if (assetPath == null) {
      throw ArgumentError('Asset not found: $assetKey');
    }

    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }
}
```

## Network Performance Optimization

### Request Optimization

```dart
// core/network/network_optimizer.dart
class NetworkOptimizer {
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxConcurrentRequests = 10;
  static final Semaphore _requestSemaphore = Semaphore(maxConcurrentRequests);

  /// Optimize API request with throttling and caching
  static Future<T> optimizedRequest<T>(
    String cacheKey,
    Future<T> Function() request, {
    Duration cacheDuration = const Duration(minutes: 5),
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = await _getCachedResponse<T>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // Throttle concurrent requests
    await _requestSemaphore.acquire();
    
    try {
      final startTime = DateTime.now();
      
      // Make request with timeout
      final result = await request().timeout(requestTimeout);
      
      final duration = DateTime.now().difference(startTime);
      PerformanceMonitor.recordCustomMetric(
        'network_request_duration',
        duration.inMilliseconds,
      );

      // Cache successful response
      await _cacheResponse(cacheKey, result, cacheDuration);
      
      return result;
    } catch (e) {
      PerformanceMonitor.recordCustomMetric('network_request_error', 1);
      rethrow;
    } finally {
      _requestSemaphore.release();
    }
  }

  /// Batch multiple requests
  static Future<List<T>> batchRequests<T>(
    List<Future<T> Function()> requests, {
    int? concurrency,
  }) async {
    final semaphore = Semaphore(concurrency ?? maxConcurrentRequests);
    
    final futures = requests.map((request) async {
      await semaphore.acquire();
      try {
        return await request();
      } finally {
        semaphore.release();
      }
    });

    return Future.wait(futures);
  }

  /// Debounce rapid requests
  static Future<T> debouncedRequest<T>(
    String debounceKey,
    Future<T> Function() request, {
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    final completer = Completer<T>();
    
    _debouncedRequests[debounceKey]?.cancel();
    
    _debouncedRequests[debounceKey] = Timer(delay, () async {
      try {
        final result = await request();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      } finally {
        _debouncedRequests.remove(debounceKey);
      }
    });

    return completer.future;
  }

  static final Map<String, Timer> _debouncedRequests = {};

  static Future<T?> _getCachedResponse<T>(String key) async {
    // Implementation would use CacheManager
    return null;
  }

  static Future<void> _cacheResponse<T>(String key, T response, Duration duration) async {
    // Implementation would use CacheManager
  }
}

class Semaphore {
  Semaphore(this.maxCount) : _currentCount = maxCount;

  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}
```

## Build Performance Optimization

### Build Time Optimization

```dart
// shared/widgets/performance/build_optimizer.dart

/// Mixin to optimize widget builds
mixin BuildOptimizationMixin<T extends StatefulWidget> on State<T> {
  bool _debugBuildOptimization = kDebugMode;
  int _buildCount = 0;
  Stopwatch? _buildTimer;

  @override
  Widget build(BuildContext context) {
    if (_debugBuildOptimization) {
      _buildTimer = Stopwatch()..start();
      _buildCount++;
    }

    final widget = buildOptimized(context);

    if (_debugBuildOptimization) {
      _buildTimer!.stop();
      final buildTime = _buildTimer!.elapsedMilliseconds;
      
      if (buildTime > 16) { // Slower than 60fps
        debugPrint(
          'Performance Warning: ${T.toString()} build #$_buildCount '
          'took ${buildTime}ms (>16ms threshold)',
        );
      }

      PerformanceMonitor.recordCustomMetric(
        '${T.toString().toLowerCase()}_build_time',
        buildTime,
      );
    }

    return widget;
  }

  Widget buildOptimized(BuildContext context);

  @override
  void dispose() {
    if (_debugBuildOptimization) {
      PerformanceMonitor.recordCustomMetric(
        '${T.toString().toLowerCase()}_total_builds',
        _buildCount,
      );
    }
    super.dispose();
  }
}

/// Widget that caches its build result
class CachedBuilder extends StatefulWidget {
  const CachedBuilder({
    super.key,
    required this.builder,
    this.cacheKey,
    this.shouldRebuild,
  });

  final Widget Function(BuildContext context) builder;
  final String? cacheKey;
  final bool Function()? shouldRebuild;

  @override
  State<CachedBuilder> createState() => _CachedBuilderState();
}

class _CachedBuilderState extends State<CachedBuilder> {
  Widget? _cachedWidget;
  String? _lastCacheKey;

  @override
  Widget build(BuildContext context) {
    final currentCacheKey = widget.cacheKey ?? widget.hashCode.toString();
    final shouldRebuild = widget.shouldRebuild?.call() ?? false;

    if (_cachedWidget == null || 
        _lastCacheKey != currentCacheKey || 
        shouldRebuild) {
      
      _cachedWidget = widget.builder(context);
      _lastCacheKey = currentCacheKey;
    }

    return _cachedWidget!;
  }
}

/// Widget that prevents unnecessary rebuilds
class StableBuilder extends StatefulWidget {
  const StableBuilder({
    super.key,
    required this.builder,
    this.dependencies,
  });

  final Widget Function(BuildContext context) builder;
  final List<Object?>? dependencies;

  @override
  State<StableBuilder> createState() => _StableBuilderState();
}

class _StableBuilderState extends State<StableBuilder> {
  Widget? _cachedWidget;
  List<Object?>? _lastDependencies;

  @override
  Widget build(BuildContext context) {
    final currentDependencies = widget.dependencies;
    
    if (_cachedWidget == null || 
        !_dependenciesEqual(_lastDependencies, currentDependencies)) {
      
      _cachedWidget = widget.builder(context);
      _lastDependencies = currentDependencies?.toList();
    }

    return _cachedWidget!;
  }

  bool _dependenciesEqual(List<Object?>? a, List<Object?>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    
    return true;
  }
}
```

## Performance Testing & Monitoring

### Performance Test Suite

```dart
// test/performance/performance_test.dart
void main() {
  group('Performance Tests', () {
    testWidgets('Widget build performance', (WidgetTester tester) async {
      const iterations = 100;
      final buildTimes = <int>[];

      for (int i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(data: 'Test data $i'),
          ),
        );
        
        stopwatch.stop();
        buildTimes.add(stopwatch.elapsedMilliseconds);
        
        await tester.pumpAndSettle();
      }

      final averageBuildTime = buildTimes.fold<int>(0, (a, b) => a + b) / buildTimes.length;
      final maxBuildTime = buildTimes.reduce((a, b) => a > b ? a : b);

      // Performance assertions
      expect(averageBuildTime, lessThan(5), reason: 'Average build time should be under 5ms');
      expect(maxBuildTime, lessThan(16), reason: 'Max build time should be under 16ms (60fps)');
      
      print('Average build time: ${averageBuildTime.toStringAsFixed(2)}ms');
      print('Max build time: ${maxBuildTime}ms');
    });

    testWidgets('Memory usage test', (WidgetTester tester) async {
      // Baseline memory measurement
      final initialMemory = _getMemoryUsage();
      
      // Create many widgets
      for (int i = 0; i < 1000; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(data: 'Memory test $i'),
          ),
        );
      }
      
      // Force garbage collection
      await tester.binding.delayed(const Duration(milliseconds: 100));
      
      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      // Memory assertions
      expect(memoryIncrease, lessThan(50 * 1024 * 1024), 
             reason: 'Memory increase should be less than 50MB');
      
      print('Memory increase: ${(memoryIncrease / 1024 / 1024).toStringAsFixed(2)}MB');
    });

    test('Network request performance', () async {
      const requestCount = 100;
      final requestTimes = <int>[];

      for (int i = 0; i < requestCount; i++) {
        final stopwatch = Stopwatch()..start();
        
        try {
          await NetworkOptimizer.optimizedRequest(
            'test_request_$i',
            () => _simulateNetworkRequest(),
          );
        } catch (e) {
          // Ignore errors for performance testing
        }
        
        stopwatch.stop();
        requestTimes.add(stopwatch.elapsedMilliseconds);
      }

      final averageRequestTime = requestTimes.fold<int>(0, (a, b) => a + b) / requestTimes.length;
      final maxRequestTime = requestTimes.reduce((a, b) => a > b ? a : b);

      expect(averageRequestTime, lessThan(100), reason: 'Average request time should be under 100ms');
      expect(maxRequestTime, lessThan(1000), reason: 'Max request time should be under 1000ms');
      
      print('Average request time: ${averageRequestTime.toStringAsFixed(2)}ms');
      print('Max request time: ${maxRequestTime}ms');
    });
  });
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key, required this.data});
  
  final String data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: List.generate(100, (index) => Text('$data - Item $index')),
      ),
    );
  }
}

int _getMemoryUsage() {
  // Platform-specific memory measurement would go here
  return 0;
}

Future<String> _simulateNetworkRequest() async {
  await Future.delayed(const Duration(milliseconds: 50));
  return 'Mock response';
}
```

## Best Practices Summary

### Performance Guidelines

1. **Monitor Performance** - Use built-in performance monitoring
2. **Optimize Builds** - Prevent unnecessary widget rebuilds
3. **Manage Memory** - Dispose resources properly and monitor usage
4. **Cache Strategically** - Implement multi-level caching
5. **Optimize Images** - Use appropriate sizes and formats
6. **Batch Operations** - Group related operations together
7. **Test Performance** - Include performance tests in CI/CD
8. **Profile Regularly** - Use Flutter DevTools for profiling

### Common Performance Anti-Patterns

❌ **Avoid:**
- Building widgets in loops without proper keys
- Not disposing controllers and streams
- Loading large images without optimization
- Making network requests in build methods
- Creating objects in build methods
- Using setState for global state changes
- Ignoring memory leaks

✅ **Follow:**
- Use const constructors everywhere possible
- Implement proper disposal patterns
- Optimize images for display size
- Cache frequently accessed data
- Use efficient list builders
- Monitor and measure performance
- Profile before optimizing

### Performance Metrics to Track

- **Frame rendering time** (target: <16ms for 60fps)
- **Memory usage** (heap size, growth rate)
- **Network request latency** (API response times)
- **Widget build times** (especially in lists)
- **Image loading times** (first paint, full load)
- **App startup time** (cold start, warm start)
- **Battery usage** (CPU, network, rendering)


