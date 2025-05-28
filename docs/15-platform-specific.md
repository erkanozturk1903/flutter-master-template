
# 15. Platform-Specific Guidelines

> **Flutter Cross-Platform Excellence** - iOS, Android, Web, Desktop adaptations with native platform integration and optimization.

## 🎯 Platform-Specific Philosophy

### Core Concepts
```yaml
Platform Strategy:
  - Write once, adapt everywhere approach
  - Native platform conventions respect
  - Performance optimization per platform
  - UI/UX consistency with platform standards
  - Feature parity across platforms

Key Principles:
  - Platform detection and adaptation
  - Native API integration
  - Platform-specific UI patterns
  - Performance considerations per platform
  - App store compliance and guidelines
```

## 📱 iOS Platform Guidelines

### iOS-Specific Configurations
```yaml
# ios/Runner/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
        <key>NSAllowsLocalNetworking</key>
        <true/>
    </dict>
    
    <!-- Privacy Permissions -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to capture and share photos</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs photo library access to select and share images</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to provide location-based features</string>
    
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access for voice recording features</string>
    
    <key>NSContactsUsageDescription</key>
    <string>This app needs contacts access to help you connect with friends</string>
    
    <!-- Background Modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>background-processing</string>
        <string>background-fetch</string>
        <string>remote-notification</string>
    </array>
    
    <!-- Supported Interface Orientations -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <!-- iPhone Specific -->
    <key>UISupportedInterfaceOrientations~iphone</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    
    <!-- iPad Specific -->
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

### iOS UI Components & Patterns
```dart
// iOS-specific UI components with adaptive behavior
class IOSAdaptiveComponents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSLayout() : _buildMaterialLayout();
  }

  Widget _buildIOSLayout() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('iOS Native Feel'),
        backgroundColor: CupertinoColors.systemBackground,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // iOS Segmented Control
            CupertinoSegmentedControl<int>(
              children: {
                0: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Tab 1'),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Tab 2'),
                ),
                2: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Tab 3'),
                ),
              },
              onValueChanged: (value) {},
              groupValue: 0,
            ),
            
            SizedBox(height: 20),
            
            // iOS List Tiles
            CupertinoListSection.insetGrouped(
              header: Text('Settings'),
              children: [
                CupertinoListTile(
                  title: Text('Notifications'),
                  trailing: CupertinoSwitch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
                CupertinoListTile(
                  title: Text('Privacy'),
                  trailing: CupertinoListTileChevron(),
                  onTap: () {},
                ),
                CupertinoListTile(
                  title: Text('Account'),
                  trailing: CupertinoListTileChevron(),
                  onTap: () {},
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // iOS Action Sheet
            CupertinoButton(
              child: Text('Show Action Sheet'),
              onPressed: () => _showIOSActionSheet(context),
            ),
            
            SizedBox(height: 20),
            
            // iOS Text Field
            CupertinoTextField(
              placeholder: 'Enter text...',
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material Design'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Material equivalents...
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 0, label: Text('Tab 1')),
              ButtonSegment(value: 1, label: Text('Tab 2')),
              ButtonSegment(value: 2, label: Text('Tab 3')),
            ],
            selected: {0},
            onSelectionChanged: (selection) {},
          ),
          // ... rest of material components
        ],
      ),
    );
  }

  void _showIOSActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Choose an option'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('Option 1'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoActionSheetAction(
            child: Text('Option 2'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
```

### iOS SafeArea and Notch Handling
```dart
class IOSSafeAreaManager extends StatelessWidget {
  final Widget child;
  final bool maintainBottomViewPadding;

  const IOSSafeAreaManager({
    required this.child,
    this.maintainBottomViewPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return child;

    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    
    // Check for different iPhone models
    final isIPhoneX = padding.top > 44;
    final hasHomeIndicator = padding.bottom > 0;
    
    return SafeArea(
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: Container(
        // Additional padding for Dynamic Island
        padding: EdgeInsets.only(
          top: _getDynamicIslandPadding(mediaQuery),
        ),
        child: child,
      ),
    );
  }

  double _getDynamicIslandPadding(MediaQueryData mediaQuery) {
    // iPhone 14 Pro/Pro Max have larger top padding due to Dynamic Island
    if (mediaQuery.size.height >= 932 && mediaQuery.padding.top > 50) {
      return 4.0; // Additional padding for Dynamic Island
    }
    return 0.0;
  }
}

// iOS-specific keyboard handling
class IOSKeyboardHandler extends StatefulWidget {
  final Widget child;

  const IOSKeyboardHandler({required this.child});

  @override
  _IOSKeyboardHandlerState createState() => _IOSKeyboardHandlerState();
}

class _IOSKeyboardHandlerState extends State<IOSKeyboardHandler> {
  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return widget.child;

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return AnimatedPadding(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: isKeyboardVisible ? 0 : MediaQuery.of(context).viewInsets.bottom,
          ),
          child: widget.child,
        );
      },
    );
  }
}
```

### iOS Haptic Feedback
```dart
class IOSHapticFeedback {
  static void lightImpact() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    }
  }

  static void mediumImpact() {
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    }
  }

  static void heavyImpact() {
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
    }
  }

  static void selectionClick() {
    if (Platform.isIOS) {
      HapticFeedback.selectionClick();
    }
  }

  // Custom haptic patterns for iOS
  static void successFeedback() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
      Future.delayed(Duration(milliseconds: 100), () {
        HapticFeedback.lightImpact();
      });
    }
  }

  static void errorFeedback() {
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
      Future.delayed(Duration(milliseconds: 100), () {
        HapticFeedback.mediumImpact();
      });
      Future.delayed(Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
    }
  }
}

// Usage example
class HapticFeedbackExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          child: Text('Success Action'),
          onPressed: () {
            IOSHapticFeedback.successFeedback();
            // Perform success action
          },
        ),
        CupertinoButton(
          child: Text('Error Action'),
          onPressed: () {
            IOSHapticFeedback.errorFeedback();
            // Handle error
          },
        ),
      ],
    );
  }
}
```

## 🤖 Android Platform Guidelines

### Android-Specific Configurations
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.flutter_master_app">
    
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    
    <!-- Features -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.location" android:required="false" />
    <uses-feature android:name="android.hardware.microphone" android:required="false" />
    
    <application
        android:label="Flutter Master App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:networkSecurityConfig="@xml/network_security_config"
        android:usesCleartextTraffic="false"
        android:allowBackup="true"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">
        
        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <!-- Deep Link Support -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https"
                      android:host="fluttermasterapp.com" />
            </intent-filter>
            
            <!-- File associations -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="image/*" />
            </intent-filter>
        </activity>
        
        <!-- Firebase Messaging Service -->
        <service
            android:name=".FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <!-- Background Services -->
        <service
            android:name=".BackgroundSyncService"
            android:enabled="true"
            android:exported="false" />
        
        <!-- Broadcast Receivers -->
        <receiver
            android:name=".BootReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter android:priority="1000">
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.PACKAGE_REPLACED" />
                <data android:scheme="package" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

### Android Material Design 3 Implementation
```dart
// Android-specific Material Design 3 components
class AndroidMaterialComponents extends StatefulWidget {
  @override
  _AndroidMaterialComponentsState createState() => _AndroidMaterialComponentsState();
}

class _AndroidMaterialComponentsState extends State<AndroidMaterialComponents> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: Scaffold(
        // Material 3 App Bar with large title
        appBar: AppBar(
          title: Text('Material Design 3'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          scrolledUnderElevation: 4.0,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _showSearch(context),
            ),
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
            PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                PopupMenuItem(value: 'settings', child: Text('Settings')),
                PopupMenuItem(value: 'about', child: Text('About')),
                PopupMenuItem(value: 'help', child: Text('Help')),
              ],
            ),
          ],
        ),
        
        // Navigation Drawer with Material 3 styling
        drawer: NavigationDrawer(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
          },
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Flutter Master',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'master@flutter.dev',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.business_outlined),
              selectedIcon: Icon(Icons.business),
              label: Text('Projects'),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: Text('Learning'),
            ),
            Divider(),
            NavigationDrawerDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        
        // Bottom Navigation Bar with Material 3
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: [
            NavigationDestination(
              icon: Badge(
                label: Text('3'),
                child: Icon(Icons.home_outlined),
              ),
              selectedIcon: Badge(
                label: Text('3'),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        
        // Floating Action Button with Material 3
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateBottomSheet,
          icon: Icon(Icons.add),
          label: Text('Create'),
        ),
        
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material 3 Cards
          _buildMaterial3Cards(),
          
          SizedBox(height: 24),
          
          // Material 3 Text Fields
          _buildMaterial3TextFields(),
          
          SizedBox(height: 24),
          
          // Material 3 Buttons
          _buildMaterial3Buttons(),
          
          SizedBox(height: 24),
          
          // Material 3 Chips
          _buildMaterial3Chips(),
          
          SizedBox(height: 24),
          
          // Material 3 Lists
          _buildMaterial3Lists(),
        ],
      ),
    );
  }

  Widget _buildMaterial3Cards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material 3 Cards',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        
        // Elevated Card
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.article, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Elevated Card',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'This is an elevated card with Material 3 styling. It provides visual hierarchy and depth.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () {}, child: Text('Cancel')),
                    SizedBox(width: 8),
                    FilledButton(onPressed: () {}, child: Text('Continue')),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Outlined Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Outlined Card',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'This is an outlined card variant with subtle borders and no elevation.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterial3TextFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material 3 Text Fields',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        
        // Outlined TextField
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            helperText: 'We\'ll never share your email',
          ),
        ),
        
        SizedBox(height: 16),
        
        // Filled TextField
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icon(Icons.lock),
            suffixIcon: Icon(Icons.visibility),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildMaterial3Buttons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material 3 Buttons',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () {},
              child: Text('Filled'),
            ),
            FilledButton.tonal(
              onPressed: () {},
              child: Text('Filled Tonal'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Elevated'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: Text('Outlined'),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Text'),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Icon Buttons
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.favorite_border),
            ),
            IconButton.filled(
              onPressed: () {},
              icon: Icon(Icons.favorite),
            ),
            IconButton.filledTonal(
              onPressed: () {},
              icon: Icon(Icons.share),
            ),
            IconButton.outlined(
              onPressed: () {},
              icon: Icon(Icons.bookmark_border),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterial3Chips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material 3 Chips',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text('Assist Chip'),
              avatar: Icon(Icons.add),
            ),
            FilterChip(
              label: Text('Filter Chip'),
              selected: true,
              onSelected: (selected) {},
            ),
            InputChip(
              label: Text('Input Chip'),
              onDeleted: () {},
              deleteIcon: Icon(Icons.close),
            ),
            ActionChip(
              label: Text('Action Chip'),
              onPressed: () {},
              avatar: Icon(Icons.settings),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterial3Lists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material 3 Lists',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('John Doe'),
                subtitle: Text('Software Engineer'),
                trailing: Icon(Icons.more_vert),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Jane Smith'),
                subtitle: Text('UI/UX Designer'),
                trailing: Icon(Icons.more_vert),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Mike Johnson'),
                subtitle: Text('Product Manager'),
                trailing: Icon(Icons.more_vert),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: CustomSearchDelegate(),
    );
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.article),
              title: Text('Article'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Photo'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.video_call),
              title: Text('Video'),
              ```dart
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'settings':
        // Navigate to settings
        break;
      case 'about':
        // Show about dialog
        _showAboutDialog();
        break;
      case 'help':
        // Show help
        break;
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter Master App',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.flutter_dash),
      children: [
        Text('Built with Flutter and Material Design 3'),
      ],
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<String> _suggestions = [
    'Flutter',
    'Material Design',
    'Android',
    'iOS',
    'Cross Platform',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Search results for: "$query"'),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = _suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(Icons.search),
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: suggestion.substring(query.length),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          onTap: () => query = suggestion,
        );
      },
    );
  }
}
```

### Android Permissions Management
```dart
// Comprehensive Android permissions handler
class AndroidPermissionsManager {
  static Future<bool> requestSinglePermission(Permission permission) async {
    if (!Platform.isAndroid) return true;

    final status = await permission.status;
    
    if (status.isGranted) return true;
    
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      return await _showPermissionDialog(permission);
    }
    
    return false;
  }

  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    if (!Platform.isAndroid) {
      return Map.fromIterable(
        permissions,
        key: (p) => p,
        value: (p) => PermissionStatus.granted,
      );
    }

    return await permissions.request();
  }

  static Future<bool> handleLocationPermission() async {
    if (!Platform.isAndroid) return true;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationServiceDialog();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDialog(Permission.location);
      return false;
    }

    return true;
  }

  static Future<bool> handleCameraPermission() async {
    if (!Platform.isAndroid) return true;

    final cameraStatus = await Permission.camera.status;
    
    if (cameraStatus.isGranted) return true;
    
    if (cameraStatus.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    if (cameraStatus.isPermanentlyDenied) {
      return await _showPermissionDialog(Permission.camera);
    }
    
    return false;
  }

  static Future<bool> handleStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // For Android 13+ (API 33+), we need different permissions
    if (await _isAndroid13OrHigher()) {
      final photos = await Permission.photos.request();
      final videos = await Permission.videos.request();
      return photos.isGranted && videos.isGranted;
    } else {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
  }

  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  static Future<bool> _showPermissionDialog(Permission permission) async {
    // This would show a dialog explaining why permission is needed
    // and offer to open app settings
    return false; // Simplified for example
  }

  static Future<void> _showLocationServiceDialog() async {
    // Show dialog to enable location services
  }
}

// Permission request widget
class AndroidPermissionRequestWidget extends StatefulWidget {
  final List<Permission> permissions;
  final Widget child;
  final VoidCallback? onPermissionsGranted;
  final VoidCallback? onPermissionsDenied;

  const AndroidPermissionRequestWidget({
    required this.permissions,
    required this.child,
    this.onPermissionsGranted,
    this.onPermissionsDenied,
  });

  @override
  _AndroidPermissionRequestWidgetState createState() => _AndroidPermissionRequestWidgetState();
}

class _AndroidPermissionRequestWidgetState extends State<AndroidPermissionRequestWidget> {
  bool _permissionsGranted = false;
  bool _checkingPermissions = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final results = await AndroidPermissionsManager.requestMultiplePermissions(
      widget.permissions,
    );
    
    final allGranted = results.values.every((status) => status.isGranted);
    
    setState(() {
      _permissionsGranted = allGranted;
      _checkingPermissions = false;
    });

    if (allGranted) {
      widget.onPermissionsGranted?.call();
    } else {
      widget.onPermissionsDenied?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPermissions) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking permissions...'),
            ],
          ),
        ),
      );
    }

    if (!_permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 24),
                Text(
                  'Permissions Required',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'This app needs certain permissions to function properly. Please grant the required permissions.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                FilledButton(
                  onPressed: _checkPermissions,
                  child: Text('Grant Permissions'),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
```

### Android System UI Customization
```dart
// Android system UI customization
class AndroidSystemUI {
  static void setSystemUIOverlayStyle({
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Color? navigationBarColor,
    Brightness? navigationBarBrightness,
    bool? systemNavigationBarContrastEnforced,
  }) {
    if (!Platform.isAndroid) return;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarBrightness: statusBarBrightness ?? Brightness.light,
        statusBarIconBrightness: statusBarBrightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        navigationBarColor: navigationBarColor ?? Colors.white,
        navigationBarIconBrightness: navigationBarBrightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        systemNavigationBarContrastEnforced: systemNavigationBarContrastEnforced ?? true,
      ),
    );
  }

  static void enableEdgeToEdge() {
    if (!Platform.isAndroid) return;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  static void setPreferredOrientations(List<DeviceOrientation> orientations) {
    SystemChrome.setPreferredOrientations(orientations);
  }

  static void hideSystemUI() {
    if (!Platform.isAndroid) return;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
    );
  }

  static void showSystemUI() {
    if (!Platform.isAndroid) return;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
}

// Android-specific gesture handling
class AndroidGestureHandler extends StatefulWidget {
  final Widget child;

  const AndroidGestureHandler({required this.child});

  @override
  _AndroidGestureHandlerState createState() => _AndroidGestureHandlerState();
}

class _AndroidGestureHandlerState extends State<AndroidGestureHandler> {
  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return widget.child;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: widget.child,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Handle Android back button
    final navigator = Navigator.of(context);
    
    if (navigator.canPop()) {
      navigator.pop();
      return false;
    }
    
    // Show exit confirmation dialog
    return await _showExitDialog() ?? false;
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }
}
```

## 🌐 Cross-Platform Adaptive Widgets

### Adaptive UI Components
```dart
// Adaptive widgets that automatically adjust based on platform
class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const AdaptiveScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: actions?.isNotEmpty == true 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              : null,
        ),
        child: SafeArea(child: body),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const AdaptiveButton({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        color: isPrimary ? CupertinoColors.activeBlue : null,
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary 
                ? CupertinoColors.white 
                : CupertinoColors.activeBlue,
          ),
        ),
      );
    }
    
    return isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            child: Text(text),
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(text),
          );
  }
}

class AdaptiveTextField extends StatelessWidget {
  final String? placeholder;
  final String? labelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;

  const AdaptiveTextField({
    this.placeholder,
    this.labelText,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTextField(
        placeholder: placeholder,
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: placeholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AdaptiveSwitch({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      );
    }
    
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }
}

class AdaptiveSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;

  const AdaptiveSlider({
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSlider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
      );
    }
    
    return Slider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
    );
  }
}
```

### Adaptive Dialogs and Sheets
```dart
// Adaptive dialog system
class AdaptiveDialogs {
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDefaultAction: true,
              child: Text(confirmText),
            ),
          ],
        ),
      );
    }
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required String title,
    required List<ActionSheetOption<T>> options,
    bool showCancel = true,
  }) {
    if (Platform.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text(title),
          actions: options.map((option) {
            return CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(option.value),
              isDestructiveAction: option.isDestructive,
              child: Text(option.title),
            );
          }).toList(),
          cancelButton: showCancel
              ? CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(),
                  isDefaultAction: true,
                  child: Text('Cancel'),
                )
              : null,
        ),
      );
    }
    
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...options.map((option) {
            return ListTile(
              title: Text(
                option.title,
                style: TextStyle(
                  color: option.isDestructive ? Colors.red : null,
                ),
              ),
              onTap: () => Navigator.of(context).pop(option.value),
            );
          }).toList(),
          if (showCancel)
            ListTile(
              title: Text('Cancel'),
              onTap: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  static void showSnackBar({
    required BuildContext context,
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (Platform.isIOS) {
      // Use a custom iOS-style banner
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => _IOSBanner(
          message: message,
          duration: duration,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          duration: duration,
        ),
      );
    }
  }
}

class ActionSheetOption<T> {
  final String title;
  final T value;
  final bool isDestructive;

  const ActionSheetOption({
    required this.title,
    required this.value,
    this.isDestructive = false,
  });
}

class _IOSBanner extends StatefulWidget {
  final String message;
  final Duration duration;

  const _IOSBanner({
    required this.message,
    required this.duration,
  });

  @override
  __IOSBannerState createState() => __IOSBannerState();
}

class __IOSBannerState extends State<_IOSBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Timer(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                color: CupertinoColors.label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## 🔧 Platform Detection Utilities

### Platform Detection Service
```dart
// Comprehensive platform detection service
class PlatformService {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  // Device-specific detection
  static Future<bool> get isTablet async {
    if (kIsWeb) return false;
    
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.model.toLowerCase().contains('ipad');
    }
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      final size = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return size.shortestSide >= 600;
    }
    
    return false;
  }

  static Future<DeviceType> get deviceType async {
    if (kIsWeb) return DeviceType.web;
    if (await isTablet) return DeviceType.tablet;
    if (isMobile) return DeviceType.mobile;
    if (isDesktop) return DeviceType.desktop;
    return DeviceType.unknown;
  }

  // OS Version detection
  static Future<String> get osVersion async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    }
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.release;
    }
    
    return 'Unknown';
  }

  // Feature detection
  static Future<PlatformCapabilities> get capabilities async {
    return PlatformCapabilities(
      hasCamera: await _hasCamera(),
      hasBiometrics: await _hasBiometrics(),
      hasNFC: await _hasNFC(),
      hasVibration: await _hasVibration(),
      hasNotifications: await _hasNotifications(),
    );
  }

  static Future<bool> _hasCamera() async {
    if (kIsWeb) return false;
    // Implementation would check for camera availability
    return true; // Simplified
  }

  static Future<bool> _hasBiometrics() async {
    if (kIsWeb) return false;
    try {
      final localAuth = LocalAuthentication();
      return await localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _hasNFC() async {
    if (!Platform.isAndroid) return false;
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _hasVibration() async {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static Future<bool> _hasNotifications() async {
    return !kIsWeb;
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
  web,
  unknown,
}

class PlatformCapabilities {
  final bool hasCamera;
  final bool hasBiometrics;
  final bool hasNFC;
  final bool hasVibration;
  final bool hasNotifications;

  const PlatformCapabilities({
    required this.hasCamera,
    required this.hasBiometrics,
    required this.hasNFC,
    required this.hasVibration,
    required this.hasNotifications,
  });
}
```

### Responsive Layout Builder
```dart
// Responsive layout builder for different screen sizes
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? web;

  const ResponsiveLayoutBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.web,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Web layout
        if (kIsWeb && web != null) {
          return web!;
        }
        
        // Desktop layout (width > 1200)
        if (width > 1200 && desktop != null) {
          return desktop!;
        }
        
        // Tablet layout (width > 600)
        if (width > 600 && tablet != null) {
          return tablet!;
        }
        
        // Mobile layout (default)
        return mobile;
      },
    );
  }
}

// Adaptive grid system
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const AdaptiveGrid({
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns;
        
        if (width > 1200) {
          columns = desktopColumns;
        } else if (width > 600) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
```

## 📊 Platform Performance Optimization

### Platform-Specific Performance Tips
```dart
// Platform-specific performance optimizations
class PlatformPerformanceOptimizer {
  static void optimizeForPlatform() {
    if (Platform.isIOS) {
      _optimizeForIOS();
    } else if (Platform.isAndroid) {
      _optimizeForAndroid();
    }
  }

  static void _optimizeForIOS() {
    // iOS-specific optimizations
    
    // Reduce overdraw
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set appropriate blend modes for iOS
    });
    
    ```dart
    // Enable iOS-specific rendering optimizations
    RendererBinding.instance.allowFirstFrame();
    
    // Optimize for 120Hz ProMotion displays
    if (SchedulerBinding.instance.platformDispatcher.displays.isNotEmpty) {
      final display = SchedulerBinding.instance.platformDispatcher.displays.first;
      if (display.refreshRate > 60) {
        // Enable high refresh rate optimizations
        SchedulerBinding.instance.ensureVisualUpdate();
      }
    }
  }

  static void _optimizeForAndroid() {
    // Android-specific optimizations
    
    // Enable hardware acceleration
    AndroidSystemUI.enableEdgeToEdge();
    
    // Optimize for different Android versions
    _optimizeForAndroidVersion();
    
    // Memory optimization for low-end devices
    if (Platform.isAndroid) {
      _optimizeMemoryUsage();
    }
  }

  static Future<void> _optimizeForAndroidVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    // Optimize based on Android API level
    if (androidInfo.version.sdkInt >= 31) {
      // Android 12+ optimizations
      _enableAndroid12Features();
    } else if (androidInfo.version.sdkInt >= 29) {
      // Android 10+ optimizations
      _enableAndroid10Features();
    }
  }

  static void _enableAndroid12Features() {
    // Material You dynamic colors
    // Splash screen API
    // Improved haptics
  }

  static void _enableAndroid10Features() {
    // Dark theme support
    // Gesture navigation
  }

  static void _optimizeMemoryUsage() {
    // Implement memory-conscious image loading
    // Use efficient data structures
    // Clean up resources properly
  }
}

// Platform-specific image optimization
class PlatformImageOptimizer {
  static ImageProvider optimizeImageForPlatform(String imagePath) {
    if (Platform.isIOS) {
      return _optimizeForIOS(imagePath);
    } else if (Platform.isAndroid) {
      return _optimizeForAndroid(imagePath);
    }
    return AssetImage(imagePath);
  }

  static ImageProvider _optimizeForIOS(String imagePath) {
    // iOS supports HEIF format for better compression
    return ResizeImage(
      AssetImage(imagePath),
      width: _getOptimalWidth(),
      height: _getOptimalHeight(),
      policy: ResizeImagePolicy.fit,
    );
  }

  static ImageProvider _optimizeForAndroid(String imagePath) {
    // Android WebP support
    return ResizeImage(
      AssetImage(imagePath),
      width: _getOptimalWidth(),
      height: _getOptimalHeight(),
      policy: ResizeImagePolicy.exact,
    );
  }

  static int _getOptimalWidth() {
    final window = WidgetsBinding.instance.window;
    return (window.physicalSize.width / window.devicePixelRatio).round();
  }

  static int _getOptimalHeight() {
    final window = WidgetsBinding.instance.window;
    return (window.physicalSize.height / window.devicePixelRatio).round();
  }
}
```

## 🧪 Platform-Specific Testing

### Platform Testing Strategies
```dart
// Platform-specific testing utilities
class PlatformTestUtils {
  static void setupPlatformTests() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _mockPlatformChannels();
  }

  static void _mockPlatformChannels() {
    // Mock platform-specific channels for testing
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '/test/path';
      },
    );
  }

  // iOS-specific test helpers
  static Widget wrapWithCupertinoApp(Widget widget) {
    return CupertinoApp(
      home: widget,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }

  // Android-specific test helpers
  static Widget wrapWithMaterialApp(Widget widget) {
    return MaterialApp(
      home: widget,
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }

  // Cross-platform test helper
  static Widget wrapWithAdaptiveApp(Widget widget) {
    return Platform.isIOS 
        ? wrapWithCupertinoApp(widget)
        : wrapWithMaterialApp(widget);
  }
}

// Platform-specific widget tests
void main() {
  group('Platform-Specific Widget Tests', () {
    setUpAll(() {
      PlatformTestUtils.setupPlatformTests();
    });

    testWidgets('iOS Cupertino components render correctly', (tester) async {
      await tester.pumpWidget(
        PlatformTestUtils.wrapWithCupertinoApp(
          IOSAdaptiveComponents(),
        ),
      );

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(CupertinoSegmentedControl), findsOneWidget);
    });

    testWidgets('Android Material components render correctly', (tester) async {
      await tester.pumpWidget(
        PlatformTestUtils.wrapWithMaterialApp(
          AndroidMaterialComponents(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('Adaptive components choose correct platform widget', (tester) async {
      await tester.pumpWidget(
        PlatformTestUtils.wrapWithAdaptiveApp(
          AdaptiveButton(
            text: 'Test Button',
            onPressed: () {},
          ),
        ),
      );

      if (Platform.isIOS) {
        expect(find.byType(CupertinoButton), findsOneWidget);
      } else {
        expect(find.byType(ElevatedButton), findsOneWidget);
      }
    });

    group('Permission Tests', () {
      testWidgets('Permission request UI shows correctly', (tester) async {
        await tester.pumpWidget(
          PlatformTestUtils.wrapWithMaterialApp(
            AndroidPermissionRequestWidget(
              permissions: [Permission.camera],
              child: Container(),
            ),
          ),
        );

        // Verify permission UI is shown
        expect(find.text('Permissions Required'), findsOneWidget);
        expect(find.text('Grant Permissions'), findsOneWidget);
      });
    });

    group('Responsive Layout Tests', () {
      testWidgets('ResponsiveLayoutBuilder chooses correct layout', (tester) async {
        await tester.pumpWidget(
          PlatformTestUtils.wrapWithMaterialApp(
            ResponsiveLayoutBuilder(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        );

        // Test different screen sizes
        await tester.binding.setSurfaceSize(Size(400, 800)); // Mobile
        await tester.pump();
        expect(find.text('Mobile'), findsOneWidget);

        await tester.binding.setSurfaceSize(Size(800, 600)); // Tablet
        await tester.pump();
        expect(find.text('Tablet'), findsOneWidget);

        await tester.binding.setSurfaceSize(Size(1400, 900)); // Desktop
        await tester.pump();
        expect(find.text('Desktop'), findsOneWidget);
      });
    });
  });
}
```

## 📋 Platform-Specific Checklist

```yaml
iOS Implementation Checklist:
  Setup & Configuration:
    - [x] Info.plist permissions configured
    - [x] App Transport Security settings
    - [x] Background modes configuration
    - [x] Supported orientations defined
    - [x] Privacy usage descriptions added

  UI/UX Compliance:
    - [x] Cupertino design system implementation
    - [x] iOS navigation patterns
    - [x] SafeArea handling for all devices
    - [x] Dynamic Island awareness
    - [x] Haptic feedback integration
    - [x] iOS-specific gestures support

  App Store Compliance:
    - [x] Human Interface Guidelines followed
    - [x] Required app metadata
    - [x] Privacy policy implementation
    - [x] In-app purchase guidelines
    - [x] Content rating appropriateness

Android Implementation Checklist:
  Setup & Configuration:
    - [x] AndroidManifest.xml permissions
    - [x] Network security configuration
    - [x] Deep linking support
    - [x] Background services setup
    - [x] Broadcast receivers configured

  UI/UX Compliance:
    - [x] Material Design 3 implementation
    - [x] Navigation patterns compliance
    - [x] System UI customization
    - [x] Edge-to-edge layout support
    - [x] Android gesture navigation
    - [x] Adaptive icons and themes

  Google Play Compliance:
    - [x] Material Design Guidelines followed
    - [x] Target SDK version updated
    - [x] Privacy policy implementation
    - [x] Required permissions justified
    - [x] App bundle optimization

Cross-Platform Features:
  Adaptive Components:
    - [x] Platform-aware UI components
    - [x] Responsive layout system
    - [x] Adaptive navigation patterns
    - [x] Platform-specific animations
    - [x] Consistent user experience

  Performance Optimization:
    - [x] Platform-specific optimizations
    - [x] Memory management strategies
    - [x] Battery usage optimization
    - [x] Network efficiency
    - [x] Image optimization per platform

  Testing Strategy:
    - [x] Platform-specific test suites
    - [x] Device compatibility testing
    - [x] Performance benchmarking
    - [x] Accessibility testing
    - [x] Integration testing across platforms
```

## 🛠️ Advanced Platform Integration

### Native Code Integration
```dart
// Method channel for platform-specific native code
class NativePlatformBridge {
  static const MethodChannel _channel = MethodChannel('native_platform_bridge');

  // iOS-specific native calls
  static Future<Map<String, dynamic>> getIOSDeviceInfo() async {
    if (!Platform.isIOS) return {};
    
    try {
      final result = await _channel.invokeMethod('getIOSDeviceInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting iOS device info: $e');
      return {};
    }
  }

  // Android-specific native calls
  static Future<Map<String, dynamic>> getAndroidSystemInfo() async {
    if (!Platform.isAndroid) return {};
    
    try {
      final result = await _channel.invokeMethod('getAndroidSystemInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting Android system info: $e');
      return {};
    }
  }

  // Cross-platform hardware features
  static Future<bool> isFeatureAvailable(String feature) async {
    try {
      final result = await _channel.invokeMethod('isFeatureAvailable', {
        'feature': feature,
      });
      return result as bool;
    } catch (e) {
      print('Error checking feature availability: $e');
      return false;
    }
  }

  // Platform-specific security features
  static Future<bool> enablePlatformSecurity() async {
    try {
      final result = await _channel.invokeMethod('enablePlatformSecurity');
      return result as bool;
    } catch (e) {
      print('Error enabling platform security: $e');
      return false;
    }
  }
}

// Usage example
class PlatformIntegrationExample extends StatefulWidget {
  @override
  _PlatformIntegrationExampleState createState() => _PlatformIntegrationExampleState();
}

class _PlatformIntegrationExampleState extends State<PlatformIntegrationExample> {
  Map<String, dynamic> _platformInfo = {};
  bool _securityEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPlatformInfo();
    _initSecurity();
  }

  Future<void> _loadPlatformInfo() async {
    Map<String, dynamic> info = {};
    
    if (Platform.isIOS) {
      info = await NativePlatformBridge.getIOSDeviceInfo();
    } else if (Platform.isAndroid) {
      info = await NativePlatformBridge.getAndroidSystemInfo();
    }
    
    setState(() {
      _platformInfo = info;
    });
  }

  Future<void> _initSecurity() async {
    final enabled = await NativePlatformBridge.enablePlatformSecurity();
    setState(() {
      _securityEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Platform Integration',
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  ..._platformInfo.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(entry.value.toString()),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Features',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Platform Security: '),
                      Icon(
                        _securityEnabled ? Icons.check_circle : Icons.error,
                        color: _securityEnabled ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(_securityEnabled ? 'Enabled' : 'Disabled'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 Best Practices Summary

```yaml
Development Best Practices:
  Platform Detection:
    - Use Platform.isIOS/isAndroid for runtime detection
    - Implement feature detection over platform detection
    - Cache platform capabilities for performance
    - Handle edge cases gracefully

  UI/UX Consistency:
    - Follow platform-specific design guidelines
    - Use adaptive widgets for cross-platform consistency
    - Implement platform-appropriate navigation patterns
    - Respect platform conventions and user expectations

  Performance Optimization:
    - Optimize rendering for each platform
    - Use platform-specific image formats
    - Implement efficient memory management
    - Monitor performance metrics per platform

  Testing Strategy:
    - Test on real devices for each platform
    - Use platform-specific testing frameworks
    - Implement automated testing pipelines
    - Test edge cases and error scenarios

  Maintenance & Updates:
    - Keep platform SDKs updated
    - Monitor platform-specific deprecations
    - Test new OS versions early
    - Maintain platform parity in features

Code Quality Standards:
  - Use consistent naming conventions
  - Document platform-specific implementations
  - Implement proper error handling
  - Follow security best practices
  - Maintain clean architecture separation
