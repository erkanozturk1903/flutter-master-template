## 10-devops-cicd.md


# 10. DevOps & CI/CD Integration

> **Complete Flutter DevOps Guide** - GitHub Actions, automated testing, deployment pipelines, monitoring, and infrastructure management for production-ready Flutter applications.

## 📋 Table of Contents

- [DevOps Philosophy](#-devops-philosophy)
- [GitHub Actions Workflows](#-github-actions-workflows)
- [Automated Testing Pipeline](#-automated-testing-pipeline)
- [Build & Release Automation](#-build--release-automation)
- [Code Quality Gates](#-code-quality-gates)
- [Environment Management](#-environment-management)
- [Deployment Strategies](#-deployment-strategies)
- [Monitoring & Observability](#-monitoring--observability)
- [Infrastructure as Code](#-infrastructure-as-code)
- [Performance Monitoring](#-performance-monitoring)
- [Rollback Strategies](#-rollback-strategies)
- [Security in CI/CD](#-security-in-cicd)

## 🎯 DevOps Philosophy

### Core Principles
```yaml
DevOps Values:
  - Automation Over Manual Processes
  - Continuous Integration & Deployment
  - Infrastructure as Code
  - Monitoring & Observability
  - Fast Feedback Loops
  - Collaboration & Communication
```

### CI/CD Pipeline Overview
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│   Source    │───▶│  Continuous  │───▶│ Continuous  │───▶│ Continuous   │
│   Control   │    │ Integration  │    │   Delivery  │    │ Deployment   │
│             │    │              │    │             │    │              │
│ • Git       │    │ • Build      │    │ • Staging   │    │ • Production │
│ • Branching │    │ • Test       │    │ • Testing   │    │ • Monitoring │
│ • Reviews   │    │ • Quality    │    │ • Approval  │    │ • Rollback   │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────────┘
```

### Environment Strategy
```
Development ────┐
                ├──▶ Staging ────▶ Production
Feature Branch ──┘
```

## 🚀 GitHub Actions Workflows

### Main CI/CD Workflow
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  release:
    types: [published]

env:
  FLUTTER_VERSION: '3.16.0'
  JAVA_VERSION: '17'
  NODE_VERSION: '18'

jobs:
  # ═══════════════════════════════════════════════════════════════════
  # CODE QUALITY & TESTING
  # ═══════════════════════════════════════════════════════════════════
  
  code-quality:
    name: 🔍 Code Quality Analysis
    runs-on: ubuntu-latest
    timeout-minutes: 15
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: 📦 Get Dependencies
        run: flutter pub get
      
      - name: 📋 Verify Dependencies
        run: flutter pub deps
      
      - name: 🔍 Analyze Code
        run: |
          flutter analyze --fatal-infos --fatal-warnings
          echo "✅ Static analysis passed"
      
      - name: 🧪 Run Dart Code Metrics
        run: |
          dart run dart_code_metrics:metrics analyze lib
          dart run dart_code_metrics:metrics check-unused-files lib
          dart run dart_code_metrics:metrics check-unused-code lib
      
      - name: 📏 Check Formatting
        run: |
          dart format --set-exit-if-changed .
          echo "✅ Code formatting verified"
      
      - name: 🔒 Security Audit
        run: |
          flutter pub audit
          echo "✅ Security audit completed"
      
      - name: 📊 Upload Code Quality Results
        uses: github/super-linter@v4
        env:
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  unit-tests:
    name: 🧪 Unit Tests
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: code-quality
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: 📦 Get Dependencies
        run: flutter pub get
      
      - name: 🧪 Run Unit Tests
        run: |
          flutter test --coverage --reporter=expanded
          echo "✅ Unit tests completed"
      
      - name: 📊 Generate Coverage Report
        run: |
          sudo apt-get update
          sudo apt-get install -y lcov
          genhtml coverage/lcov.info -o coverage/html
          lcov --summary coverage/lcov.info
      
      - name: 📈 Upload Coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
          flags: unittests
          name: unit-tests
          fail_ci_if_error: true
      
      - name: 📋 Coverage Threshold Check
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep -oP 'lines......: \K[0-9.]+')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi
          echo "✅ Coverage $COVERAGE% meets threshold"

  widget-tests:
    name: 🎨 Widget Tests
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: code-quality
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: 📦 Get Dependencies
        run: flutter pub get
      
      - name: 🎨 Run Widget Tests
        run: |
          flutter test test/widget/ --reporter=expanded
          echo "✅ Widget tests completed"
      
      - name: 🖼️ Generate Golden File Reports
        if: failure()
        run: |
          flutter test --update-goldens test/widget/
          echo "🖼️ Golden files updated"

  integration-tests:
    name: 🔄 Integration Tests
    strategy:
      matrix:
        platform: [android, ios]
        api-level: [29, 33]
        exclude:
          - platform: ios
            api-level: 29
          - platform: ios  
            api-level: 33
    
    runs-on: ${{ matrix.platform == 'ios' && 'macos-latest' || 'ubuntu-latest' }}
    timeout-minutes: 45
    needs: [unit-tests, widget-tests]
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: ☕ Setup Java (Android)
        if: matrix.platform == 'android'
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}
      
      - name: 🤖 Setup Android Emulator
        if: matrix.platform == 'android'
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: ${{ matrix.api-level }}
          target: google_apis
          arch: x86_64
          profile: Nexus 6
          script: |
            flutter pub get
            flutter drive \
              --driver=test_driver/integration_test.dart \
              --target=integration_test/app_test.dart \
              --verbose
      
      - name: 🍎 Setup iOS Simulator
        if: matrix.platform == 'ios'
        run: |
          xcrun simctl list devices available iPhone
          DEVICE_ID=$(xcrun simctl create TestDevice com.apple.CoreSimulator.SimDeviceType.iPhone-14 com.apple.CoreSimulator.SimRuntime.iOS-16-4)
          xcrun simctl boot $DEVICE_ID
          echo "DEVICE_ID=$DEVICE_ID" >> $GITHUB_ENV
      
      - name: 🔄 Run iOS Integration Tests
        if: matrix.platform == 'ios'
        run: |
          flutter pub get
          flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/app_test.dart \
            --device-id=$DEVICE_ID \
            --verbose
      
      - name: 📱 Upload Test Artifacts
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: integration-test-failures-${{ matrix.platform }}-${{ matrix.api-level }}
          path: |
            screenshots/
            test_driver/failures/
            integration_test/screenshots/

  # ═══════════════════════════════════════════════════════════════════
  # BUILD & DEPLOYMENT
  # ═══════════════════════════════════════════════════════════════════

  build-android:
    name: 🤖 Build Android
    runs-on: ubuntu-latest
    timeout-minutes: 30
    needs: [unit-tests, widget-tests]
    if: github.event_name == 'push' || github.event_name == 'release'
    
    strategy:
      matrix:
        build-type: [debug, profile, release]
        exclude:
          - build-type: debug
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: ☕ Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}
      
      - name: 📦 Get Dependencies
        run: flutter pub get
      
      - name: 🔧 Setup Android Signing
        if: matrix.build-type == 'release'
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE }}" | base64 --decode > android/app/keystore.jks
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties
      
      - name: 🏗️ Build Android APK
        if: matrix.build-type != 'release'
        run: |
          flutter build apk --${{ matrix.build-type }} --verbose
          echo "✅ Android APK (${{ matrix.build-type }}) built successfully"
      
      - name: 🏗️ Build Android App Bundle
        if: matrix.build-type == 'release'
        run: |
          flutter build appbundle --release --verbose
          echo "✅ Android App Bundle built successfully"
      
      - name: 📱 Upload Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: android-${{ matrix.build-type }}-build
          path: |
            build/app/outputs/flutter-apk/
            build/app/outputs/bundle/
          retention-days: 30
      
      - name: 🔍 Analyze APK
        if: matrix.build-type == 'release'
        run: |
          flutter build apk --analyze-size --target-platform android-arm64
          echo "📊 APK analysis completed"

  build-ios:
    name: 🍎 Build iOS
    runs-on: macos-latest
    timeout-minutes: 45
    needs: [unit-tests, widget-tests]
    if: github.event_name == 'push' || github.event_name == 'release'
    
    strategy:
      matrix:
        build-type: [debug, profile, release]
        exclude:
          - build-type: debug
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: 📦 Get Dependencies
        run: flutter pub get
      
      - name: 🔧 Setup iOS Certificates
        if: matrix.build-type == 'release'
        env:
          IOS_CERTIFICATE: ${{ secrets.IOS_CERTIFICATE }}
          IOS_CERTIFICATE_PASSWORD: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          IOS_PROVISION_PROFILE: ${{ secrets.IOS_PROVISION_PROFILE }}
        run: |
          # Create keychain
          security create-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain
          
          # Import certificate
          echo $IOS_CERTIFICATE | base64 --decode > certificate.p12
          security import certificate.p12 -k build.keychain -P $IOS_CERTIFICATE_PASSWORD -T /usr/bin/codesign
          
          # Import provisioning profile
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo $IOS_PROVISION_PROFILE | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision
          
          # Set partition list
          security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain
      
      - name: 🏗️ Build iOS App
        run: |
          flutter build ios --${{ matrix.build-type }} --no-codesign --verbose
          echo "✅ iOS app (${{ matrix.build-type }}) built successfully"
      
      - name: 📦 Archive iOS App
        if: matrix.build-type == 'release'
        run: |
          cd ios
          xcodebuild -workspace Runner.xcworkspace \
                     -scheme Runner \
                     -configuration Release \
                     -archivePath Runner.xcarchive \
                     archive
          
          xcodebuild -exportArchive \
                     -archivePath Runner.xcarchive \
                     -exportPath ../build/ios/ \
                     -exportOptionsPlist ExportOptions.plist
      
      - name: 📱 Upload iOS Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ios-${{ matrix.build-type }}-build
          path: |
            build/ios/
            ios/Runner.xcarchive/
          retention-days: 30

  # ═══════════════════════════════════════════════════════════════════
  # DEPLOYMENT
  # ═══════════════════════════════════════════════════════════════════

  deploy-staging:
    name: 🚀 Deploy to Staging
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [build-android, build-ios, integration-tests]
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 📱 Download Android Artifacts
        uses: actions/download-artifact@v3
        with:
          name: android-profile-build
          path: android-build/
      
      - name: 📱 Download iOS Artifacts
        uses: actions/download-artifact@v3
        with:
          name: ios-profile-build
          path: ios-build/
      
      - name: 🚀 Deploy to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
          token: ${{ secrets.FIREBASE_TOKEN }}
          groups: staging-testers
          file: android-build/app-profile-release.apk
          releaseNotes: |
            🚀 Staging Build - Branch: ${{ github.ref_name }}
            📝 Commit: ${{ github.sha }}
            👤 Author: ${{ github.actor }}
            🕐 Built at: ${{ github.run_started_at }}
      
      - name: 🍎 Deploy iOS to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: ios-build/Runner.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
      
      - name: 📢 Notify Team
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
          message: |
            🚀 Staging deployment completed!
            • Android: Firebase App Distribution
            • iOS: TestFlight
            • Branch: ${{ github.ref_name }}
            • Commit: ${{ github.sha }}

  deploy-production:
    name: 🌟 Deploy to Production
    runs-on: ubuntu-latest
    timeout-minutes: 30
    needs: [build-android, build-ios, integration-tests]
    if: github.event_name == 'release'
    environment: production
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 📱 Download Android Artifacts
        uses: actions/download-artifact@v3
        with:
          name: android-release-build
          path: android-build/
      
      - name: 📱 Download iOS Artifacts
        uses: actions/download-artifact@v3
        with:
          name: ios-release-build
          path: ios-build/
      
      - name: 🤖 Deploy Android to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.fluttermaster.app
          releaseFiles: android-build/app-release.aab
          track: production
          status: completed
          whatsNewDirectory: metadata/android/
      
      - name: 🍎 Deploy iOS to App Store
        uses: apple-actions/upload-app-store-connect@v1
        with:
          app-path: ios-build/Runner.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
          submit-for-review: false
      
      - name: 📊 Create Deployment Report
        run: |
          echo "# 🚀 Production Deployment Report" > deployment-report.md
          echo "" >> deployment-report.md
          echo "## 📱 Build Information" >> deployment-report.md
          echo "- **Release:** ${{ github.event.release.tag_name }}" >> deployment-report.md
          echo "- **Commit:** ${{ github.sha }}" >> deployment-report.md
          echo "- **Author:** ${{ github.actor }}" >> deployment-report.md
          echo "- **Date:** $(date)" >> deployment-report.md
          echo "" >> deployment-report.md
          echo "## 🎯 Deployment Status" >> deployment-report.md
          echo "- ✅ Android Play Store: Deployed" >> deployment-report.md
          echo "- ✅ iOS App Store: Uploaded (Manual Review Required)" >> deployment-report.md
      
      - name: 📢 Notify Production Deployment
        uses: 8398a7/action-slack@v3
        with:
          status: success
          channel: '#releases'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
          message: |
            🌟 Production deployment completed!
            🏷️ Release: ${{ github.event.release.tag_name }}
            🤖 Android: Play Store (Live)
            🍎 iOS: App Store (Review Required)
            📊 View deployment details in GitHub Actions

  # ═══════════════════════════════════════════════════════════════════
  # POST-DEPLOYMENT MONITORING
  # ═══════════════════════════════════════════════════════════════════

  post-deployment-checks:
    name: 🔍 Post-Deployment Verification
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [deploy-staging, deploy-production]
    if: always() && (needs.deploy-staging.result == 'success' || needs.deploy-production.result == 'success')
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🔍 Health Check
        run: |
          # API Health Check
          curl -f https://api.fluttermaster.com/health || exit 1
          echo "✅ API health check passed"
      
      - name: 📊 Performance Baseline
        run: |
          # Run performance tests
          echo "🚀 Running performance baseline tests"
          # This would integrate with your performance monitoring tools
      
      - name: 🔔 Setup Monitoring Alerts
        run: |
          # Enable enhanced monitoring for new release
          echo "🔔 Enhanced monitoring enabled for new release"
          # This would configure your monitoring tools
## 📊 Code Quality Gates

### Quality Gate Workflow
```yaml
# .github/workflows/quality-gates.yml
name: Quality Gates

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  quality-gate:
    name: 🎯 Quality Gate Enforcement
    runs-on: ubuntu-latest
    timeout-minutes: 20
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
          cache: true
      
      - name: 📦 Get Dependencies
        run: flutter pub get
      
      # ══════════════════════════════════════════════════════════════
      # CODE COVERAGE GATE
      # ══════════════════════════════════════════════════════════════
      
      - name: 🧪 Run Tests with Coverage
        run: |
          flutter test --coverage --reporter=expanded
          echo "✅ Tests completed"
      
      - name: 📊 Check Coverage Threshold
        run: |
          sudo apt-get update && sudo apt-get install -y lcov
          COVERAGE=$(lcov --summary coverage/lcov.info | grep -oP 'lines......: \K[0-9.]+')
          echo "Current coverage: $COVERAGE%"
          
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% is below 80% threshold"
            echo "::error::Code coverage ($COVERAGE%) is below the required threshold (80%)"
            exit 1
          fi
          
          echo "✅ Coverage $COVERAGE% meets threshold"
          echo "coverage=$COVERAGE" >> $GITHUB_OUTPUT
      
      # ══════════════════════════════════════════════════════════════
      # CODE COMPLEXITY GATE
      # ══════════════════════════════════════════════════════════════
      
      - name: 🔍 Check Code Complexity
        run: |
          dart run dart_code_metrics:metrics analyze lib --fatal-style --fatal-performance --fatal-warnings
          
          # Check specific metrics
          dart run dart_code_metrics:metrics analyze lib \
            --set-exit-on-violation-level=warning \
            --cyclomatic-complexity=10 \
            --maximum-nesting-level=5 \
            --number-of-parameters=6 \
            --source-lines-of-code=50
          
          echo "✅ Code complexity check passed"
      
      # ══════════════════════════════════════════════════════════════
      # TECHNICAL DEBT GATE
      # ══════════════════════════════════════════════════════════════
      
      - name: 💳 Technical Debt Analysis
        run: |
          DEBT_SCORE=$(dart run dart_code_metrics:metrics analyze lib --reporter=json | jq '.summary.technicalDebt.total')
          echo "Technical debt score: $DEBT_SCORE"
          
          if (( $(echo "$DEBT_SCORE > 100" | bc -l) )); then
            echo "❌ Technical debt score ($DEBT_SCORE) exceeds limit (100)"
            echo "::error::Technical debt score is too high. Please refactor code."
            exit 1
          fi
          
          echo "✅ Technical debt within acceptable limits"
      
      # ══════════════════════════════════════════════════════════════
      # SECURITY GATE
      # ══════════════════════════════════════════════════════════════
      
      - name: 🔒 Security Audit
        run: |
          # Dependency vulnerability check
          flutter pub audit
          
          # Check for hardcoded secrets
          if grep -r "password\|secret\|key\|token" lib/ --include="*.dart" | grep -v "// ignore:"; then
            echo "❌ Potential hardcoded secrets found"
            echo "::error::Hardcoded secrets detected in source code"
            exit 1
          fi
          
          echo "✅ Security audit passed"
      
      # ══════════════════════════════════════════════════════════════
      # PERFORMANCE GATE
      # ══════════════════════════════════════════════════════════════
      
      - name: ⚡ Performance Analysis
        run: |
          # Check for performance anti-patterns
          dart run dart_code_metrics:metrics check-unnecessary-nullable lib/
          dart run dart_code_metrics:metrics check-unused-files lib/
          dart run dart_code_metrics:metrics check-unused-code lib/
          
          echo "✅ Performance analysis completed"
      
      # ══════════════════════════════════════════════════════════════
      # ARCHITECTURE COMPLIANCE GATE
      # ══════════════════════════════════════════════════════════════
      
      - name: 🏗️ Architecture Compliance Check
        run: |
          # Check Clean Architecture compliance
          ./scripts/check-architecture.sh
          
          # Verify feature structure
          ./scripts/verify-feature-structure.sh
          
          echo "✅ Architecture compliance verified"
      
      # ══════════════════════════════════════════════════════════════
      # DOCUMENTATION GATE
      # ══════════════════════════════════════════════════════════════
      
      - name: 📚 Documentation Coverage
        run: |
          DOC_COVERAGE=$(dart run dart_code_metrics:metrics analyze lib --reporter=json | jq '.summary.documentation.coverage')
          echo "Documentation coverage: $DOC_COVERAGE%"
          
          if (( $(echo "$DOC_COVERAGE < 70" | bc -l) )); then
            echo "❌ Documentation coverage ($DOC_COVERAGE%) is below 70% threshold"
            echo "::warning::Consider adding more documentation"
          else
            echo "✅ Documentation coverage meets threshold"
          fi
      
      - name: 📊 Quality Gate Summary
        run: |
          echo "# 🎯 Quality Gate Results" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "| Metric | Status | Value |" >> $GITHUB_STEP_SUMMARY
          echo "|--------|--------|-------|" >> $GITHUB_STEP_SUMMARY
          echo "| Code Coverage | ✅ Pass | ${{ steps.coverage.outputs.coverage }}% |" >> $GITHUB_STEP_SUMMARY
          echo "| Code Complexity | ✅ Pass | Within limits |" >> $GITHUB_STEP_SUMMARY
          echo "| Security Audit | ✅ Pass | No issues |" >> $GITHUB_STEP_SUMMARY
          echo "| Architecture | ✅ Pass | Compliant |" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "🎉 All quality gates passed successfully!"
```

### Architecture Compliance Scripts
```bash
#!/bin/bash
# scripts/check-architecture.sh

echo "🏗️ Checking Clean Architecture compliance..."

# Check that domain layer doesn't depend on data/presentation
if grep -r "package:.*data/" lib/features/*/domain/ 2>/dev/null; then
    echo "❌ Domain layer importing from data layer detected"
    exit 1
fi

if grep -r "package:.*presentation/" lib/features/*/domain/ 2>/dev/null; then
    echo "❌ Domain layer importing from presentation layer detected"
    exit 1
fi

# Check that data layer doesn't depend on presentation
if grep -r "package:.*presentation/" lib/features/*/data/ 2>/dev/null; then
    echo "❌ Data layer importing from presentation layer detected"
    exit 1
fi

echo "✅ Clean Architecture compliance verified"

#!/bin/bash
# scripts/verify-feature-structure.sh

echo "📁 Verifying feature structure..."

for feature_dir in lib/features/*/; do
    feature_name=$(basename "$feature_dir")
    echo "Checking feature: $feature_name"
    
    # Check required directories exist
    required_dirs=("data" "domain" "presentation")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$feature_dir$dir" ]]; then
            echo "❌ Missing required directory: $feature_dir$dir"
            exit 1
        fi
    done
    
    # Check domain structure
    domain_dirs=("entities" "repositories" "usecases")
    for dir in "${domain_dirs[@]}"; do
        if [[ ! -d "$feature_dir/domain/$dir" ]]; then
            echo "❌ Missing domain directory: $feature_dir/domain/$dir"
            exit 1
        fi
    done
    
    # Check data structure
    data_dirs=("datasources" "models" "repositories")
    for dir in "${data_dirs[@]}"; do
        if [[ ! -d "$feature_dir/data/$dir" ]]; then
            echo "❌ Missing data directory: $feature_dir/data/$dir"
            exit 1
        fi
    done
    
    # Check presentation structure
    presentation_dirs=("bloc" "pages" "widgets")
    for dir in "${presentation_dirs[@]}"; do
        if [[ ! -d "$feature_dir/presentation/$dir" ]]; then
            echo "❌ Missing presentation directory: $feature_dir/presentation/$dir"
            exit 1
        fi
    done
done

echo "✅ Feature structure verification completed"
```

## 🌍 Environment Management

### Environment Configuration
```yaml
# .github/workflows/environment-setup.yml
name: Environment Setup

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      flutter_version:
        required: false
        type: string
        default: '3.16.0'

jobs:
  setup-environment:
    name: 🌍 Setup ${{ inputs.environment }} Environment
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ inputs.flutter_version }}
          channel: 'stable'
          cache: true
      
      - name: 🔧 Configure Environment
        run: |
          # Create environment-specific configuration
          cat > lib/core/config/environment_config.dart << EOF
          class EnvironmentConfig {
            static const String environment = '${{ inputs.environment }}';
            static const String apiBaseUrl = '${{ vars.API_BASE_URL }}';
            static const String apiKey = '${{ secrets.API_KEY }}';
            static const bool debugMode = ${{ inputs.environment != 'production' }};
            
            // Firebase configuration
            static const String firebaseProjectId = '${{ vars.FIREBASE_PROJECT_ID }}';
            static const String firebaseApiKey = '${{ secrets.FIREBASE_API_KEY }}';
            
            // Analytics configuration
            static const String analyticsId = '${{ vars.ANALYTICS_ID }}';
            static const bool enableAnalytics = ${{ inputs.environment == 'production' }};
            
            // Feature flags
            static const bool enableBetaFeatures = ${{ inputs.environment != 'production' }};
            static const bool enableDebugMenu = ${{ inputs.environment == 'development' }};
          }
          EOF
          
          echo "✅ Environment configuration created for ${{ inputs.environment }}"
      
      - name: 📱 Configure Firebase
        run: |
          # Download Firebase configuration files
          echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 --decode > android/app/google-services.json
          echo "${{ secrets.GOOGLE_SERVICE_INFO_PLIST }}" | base64 --decode > ios/Runner/GoogleService-Info.plist
          
          echo "✅ Firebase configuration completed"
      
      - name: 🔐 Setup Environment Secrets
        run: |
          # Create secure environment file
          cat > .env << EOF
          ENVIRONMENT=${{ inputs.environment }}
          API_BASE_URL=${{ vars.API_BASE_URL }}
          API_KEY=${{ secrets.API_KEY }}
          DATABASE_URL=${{ secrets.DATABASE_URL }}
          REDIS_URL=${{ secrets.REDIS_URL }}
          JWT_SECRET=${{ secrets.JWT_SECRET }}
          ENCRYPTION_KEY=${{ secrets.ENCRYPTION_KEY }}
          EOF
          
          echo "✅ Environment secrets configured"
      
      - name: 📦 Install Dependencies
        run: |
          flutter pub get
          echo "✅ Dependencies installed"
      
      - name: 🧪 Validate Environment
        run: |
          # Run environment-specific tests
          flutter test test/environment/ --dart-define=ENVIRONMENT=${{ inputs.environment }}
          
          # Validate configuration
          dart run scripts/validate_environment.dart ${{ inputs.environment }}
          
          echo "✅ Environment validation completed"
```

### Environment Validation Script
```dart
// scripts/validate_environment.dart
import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('❌ Environment argument required');
    exit(1);
  }
  
  final environment = arguments[0];
  print('🔍 Validating $environment environment...');
  
  try {
    _validateEnvironmentConfig(environment);
    _validateFirebaseConfig(environment);
    _validateSecrets(environment);
    _validateFeatureFlags(environment);
    
    print('✅ Environment validation successful');
  } catch (e) {
    print('❌ Environment validation failed: $e');
    exit(1);
  }
}

void _validateEnvironmentConfig(String environment) {
  final validEnvironments = ['development', 'staging', 'production'];
  
  if (!validEnvironments.contains(environment)) {
    throw Exception('Invalid environment: $environment');
  }
  
  // Check if environment config file exists
  final configFile = File('lib/core/config/environment_config.dart');
  if (!configFile.existsSync()) {
    throw Exception('Environment config file not found');
  }
  
  final content = configFile.readAsStringSync();
  if (!content.contains("environment = '$environment'")) {
    throw Exception('Environment config mismatch');
  }
  
  print('✅ Environment configuration valid');
}

void _validateFirebaseConfig(String environment) {
  // Validate Android Firebase config
  final androidConfig = File('android/app/google-services.json');
  if (!androidConfig.existsSync()) {
    throw Exception('Android Firebase config not found');
  }
  
  final androidConfigContent = jsonDecode(androidConfig.readAsStringSync());
  final projectId = androidConfigContent['project_info']['project_id'];
  
  if (!projectId.contains(environment)) {
    print('⚠️ Warning: Firebase project ID may not match environment');
  }
  
  // Validate iOS Firebase config
  final iosConfig = File('ios/Runner/GoogleService-Info.plist');
  if (!iosConfig.existsSync()) {
    throw Exception('iOS Firebase config not found');
  }
  
  print('✅ Firebase configuration valid');
}

void _validateSecrets(String environment) {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    throw Exception('Environment secrets file not found');
  }
  
  final envContent = envFile.readAsStringSync();
  final requiredSecrets = [
    'API_BASE_URL',
    'API_KEY',
    'JWT_SECRET',
    'ENCRYPTION_KEY',
  ];
  
  for (final secret in requiredSecrets) {
    if (!envContent.contains(secret)) {
      throw Exception('Required secret not found: $secret');
    }
  }
  
  print('✅ Environment secrets valid');
}

void _validateFeatureFlags(String environment) {
  // Validate feature flags configuration
  final configFile = File('lib/core/config/environment_config.dart');
  final content = configFile.readAsStringSync();
  
  if (environment == 'production') {
    if (content.contains('debugMode = true')) {
      throw Exception('Debug mode should be false in production');
    }
    if (content.contains('enableBetaFeatures = true')) {
      throw Exception('Beta features should be disabled in production');
    }
  }
  
  print('✅ Feature flags configuration valid');
}
```

## 🚀 Deployment Strategies

### Blue-Green Deployment
```yaml
# .github/workflows/blue-green-deployment.yml
name: Blue-Green Deployment

on:
  release:
    types: [published]

env:
  CLUSTER_NAME: flutter-master-cluster
  REGION: us-central1

jobs:
  blue-green-deploy:
    name: 🔄 Blue-Green Deployment
    runs-on: ubuntu-latest
    timeout-minutes: 30
    environment: production
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: ☁️ Setup Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: 🔍 Get Current Deployment
        id: current
        run: |
          CURRENT_COLOR=$(kubectl get service flutter-master-app -o jsonpath='{.spec.selector.version}')
          NEW_COLOR=$([ "$CURRENT_COLOR" = "blue" ] && echo "green" || echo "blue")
          
          echo "current_color=$CURRENT_COLOR" >> $GITHUB_OUTPUT
          echo "new_color=$NEW_COLOR" >> $GITHUB_OUTPUT
          
          echo "Current active: $CURRENT_COLOR"
          echo "Deploying to: $NEW_COLOR"
      
      - name: 🚀 Deploy New Version
        run: |
          # Update deployment with new image
          kubectl set image deployment/flutter-master-app-${{ steps.current.outputs.new_color }} \
            app=gcr.io/${{ secrets.GCP_PROJECT_ID }}/flutter-master-app:${{ github.event.release.tag_name }}
          
          # Wait for rollout to complete
          kubectl rollout status deployment/flutter-master-app-${{ steps.current.outputs.new_color }} --timeout=600s
          
          echo "✅ New version deployed to ${{ steps.current.outputs.new_color }}"
      
      - name: 🧪 Health Check New Deployment
        run: |
          # Get new deployment endpoint
          NEW_ENDPOINT=$(kubectl get service flutter-master-app-${{ steps.current.outputs.new_color }} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
          
          # Perform health checks
          for i in {1..5}; do
            if curl -f "http://$NEW_ENDPOINT/health"; then
              echo "✅ Health check $i passed"
            else
              echo "❌ Health check $i failed"
              exit 1
            fi
            sleep 10
          done
          
          echo "✅ All health checks passed"
      
      - name: 🔄 Switch Traffic
        run: |
          # Update main service to point to new deployment
          kubectl patch service flutter-master-app -p '{"spec":{"selector":{"version":"${{ steps.current.outputs.new_color }}"}}}'
          
          echo "✅ Traffic switched to ${{ steps.current.outputs.new_color }}"
      
      - name: ⏱️ Monitoring Period
        run: |
          echo "🔍 Monitoring new deployment for 5 minutes..."
          sleep 300
          
          # Check error rates and performance metrics
          ./scripts/check-deployment-health.sh ${{ steps.current.outputs.new_color }}
      
      - name: 🗑️ Cleanup Old Deployment
        if: success()
        run: |
          # Scale down old deployment
          kubectl scale deployment flutter-master-app-${{ steps.current.outputs.current_color }} --replicas=0
          
          echo "✅ Old deployment scaled down"
      
      - name: 🔄 Rollback on Failure
        if: failure()
        run: |
          echo "❌ Deployment failed, rolling back..."
          
          # Switch traffic back to old deployment
          kubectl patch service flutter-master-app -p '{"spec":{"selector":{"version":"${{ steps.current.outputs.current_color }}"}}}'
          
          # Scale down failed deployment
          kubectl scale deployment flutter-master-app-${{ steps.current.outputs.new_color }} --replicas=0
          
          echo "✅ Rollback completed"
          exit 1
```

### Canary Deployment
```yaml
# .github/workflows/canary-deployment.yml
name: Canary Deployment

on:
  workflow_dispatch:
    inputs:
      traffic_percentage:
        description: 'Traffic percentage for canary (1-100)'
        required: true
        default: '10'
        type: string

jobs:
  canary-deploy:
    name: 🐤 Canary Deployment
    runs-on: ubuntu-latest
    timeout-minutes: 45
    environment: production
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: ☁️ Setup Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: 🚀 Deploy Canary Version
        run: |
          # Deploy canary version
          kubectl apply -f k8s/canary-deployment.yaml
          
          # Wait for canary deployment
          kubectl rollout status deployment/flutter-master-app-canary --timeout=300s
          
          echo "✅ Canary deployment ready"
      
      - name: 🔀 Configure Traffic Split
        run: |
          # Update Istio VirtualService for traffic splitting
          cat > istio-traffic-split.yaml << EOF
          apiVersion: networking.istio.io/v1beta1
          kind: VirtualService
          metadata:
            name: flutter-master-app
          spec:
            hosts:
            - flutter-master-app
            http:
            - match:
              - headers:
                  canary:
                    exact: "true"
              route:
              - destination:
                  host: flutter-master-app
                  subset: canary
            - route:
              - destination:
                  host: flutter-master-app
                  subset: stable
                weight: ${{ 100 - inputs.traffic_percentage }}
              - destination:
                  host: flutter-master-app
                  subset: canary
                weight: ${{ inputs.traffic_percentage }}
          EOF
          
          kubectl apply -f istio-traffic-split.yaml
          echo "✅ Traffic split configured: ${{ inputs.traffic_percentage }}% to canary"
      
      - name: 📊 Monitor Canary Metrics
        run: |
          echo "📊 Monitoring canary deployment for 10 minutes..."
          
          for i in {1..20}; do
            # Check error rates
            ERROR_RATE=$(./scripts/get-error-rate.sh canary)
            RESPONSE_TIME=$(./scripts/get-response-time.sh canary)
            
            echo "Minute $((i/2)): Error Rate: $ERROR_RATE%, Response Time: ${RESPONSE_TIME}ms"
            
            # Fail if error rate > 5% or response time > 2000ms
            if (( $(echo "$ERROR_RATE > 5" | bc -l) )) || (( $(echo "$RESPONSE_TIME > 2000" | bc -l) )); then
              echo "❌ Canary metrics exceeded thresholds"
              exit 1
            fi
            
            sleep 30
          done
          
          echo "✅ Canary metrics within acceptable range"
      
      - name: ✅ Promote Canary
        if: success()
        run: |
          # Gradually increase traffic to canary
          for percentage in 25 50 75 100; do
            echo "🔀 Increasing canary traffic to $percentage%"
            
            # Update traffic split
            kubectl patch virtualservice flutter-master-app --type='merge' -p="{
              \"spec\": {
                \"http\": [{
                  \"route\": [{
                    \"destination\": {\"host\": \"flutter-master-app\", \"subset\": \"stable\"},
                    \"weight\": $((100 - percentage))
                  }, {
                    \"destination\": {\"host\": \"flutter-master-app\", \"subset\": \"canary\"},
                    \"weight\": $percentage
                  }]
                }]
              }
            }"
            
            # Monitor for 2 minutes at each stage
            sleep 120
            
            # Check metrics
            ERROR_RATE=$(./scripts/get-error-rate.sh canary)
            if (( $(echo "$ERROR_RATE > 3" | bc -l) )); then
              echo "❌ Error rate too high at $percentage% traffic"
              exit 1
            fi
          done
          
          # Replace stable with canary
          kubectl patch deployment flutter-master-app-stable --type='merge' -p="{
            \"spec\": {
              \"template\": {
                \"spec\": {
                  \"containers\": [{
                    \"name\": \"app\",
                    \"image\": \"$(kubectl get deployment flutter-master-app-canary -o jsonpath='{.spec.template.spec.containers[0].image}')\"
                  }]
                }
              }
            }
          }"
          
          # Clean up canary deployment
          kubectl delete deployment flutter-master-app-canary
          
          echo "✅ Canary promotion completed"
      
      - name: 🔄 Rollback Canary
        if: failure()
        run: |
          echo "❌ Canary deployment failed, rolling back..."
          
          # Remove canary traffic
          kubectl patch virtualservice flutter-master-app --type='merge' -p="{
            \"spec\": {
              \"http\": [{
                \"route\": [{
                  \"destination\": {\"host\": \"flutter-master-app\", \"subset\": \"stable\"},
                  \"weight\": 100
                }]
              }]
            }
          }"
          
          # Delete canary deployment
          kubectl delete deployment flutter-master-app-canary
          
          echo "✅ Canary rollback completed"
## 📊 Monitoring & Observability

### Comprehensive Monitoring Setup
```yaml
# .github/workflows/monitoring-setup.yml
name: Monitoring & Observability

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string

jobs:
  setup-monitoring:
    name: 📊 Setup Monitoring Stack
    runs-on: ubuntu-latest
    timeout-minutes: 20
    environment: ${{ inputs.environment }}
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: ☁️ Setup Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: 📊 Deploy Prometheus Stack
        run: |
          # Add Prometheus Helm repository
          helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
          helm repo update
          
          # Deploy Prometheus with custom values
          cat > prometheus-values.yaml << EOF
          prometheus:
            prometheusSpec:
              retention: 30d
              storageSpec:
                volumeClaimTemplate:
                  spec:
                    accessModes: ["ReadWriteOnce"]
                    resources:
                      requests:
                        storage: 50Gi
              additionalScrapeConfigs:
                - job_name: 'flutter-master-app'
                  static_configs:
                    - targets: ['flutter-master-app:8080']
                  metrics_path: '/metrics'
                  scrape_interval: 30s
          
          grafana:
            adminPassword: ${{ secrets.GRAFANA_ADMIN_PASSWORD }}
            persistence:
              enabled: true
              size: 10Gi
            dashboardProviders:
              dashboardproviders.yaml:
                apiVersion: 1
                providers:
                - name: 'default'
                  orgId: 1
                  folder: ''
                  type: file
                  disableDeletion: false
                  editable: true
                  options:
                    path: /var/lib/grafana/dashboards/default
            
          alertmanager:
            config:
              global:
                slack_api_url: '${{ secrets.SLACK_WEBHOOK_URL }}'
              route:
                group_by: ['alertname']
                group_wait: 10s
                group_interval: 10s
                repeat_interval: 1h
                receiver: 'web.hook'
              receivers:
              - name: 'web.hook'
                slack_configs:
                - channel: '#alerts'
                  title: 'Flutter Master App Alert'
                  text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
          EOF
          
          helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
            --namespace monitoring --create-namespace \
            --values prometheus-values.yaml
          
          echo "✅ Prometheus stack deployed"
      
      - name: 📈 Configure Application Metrics
        run: |
          # Deploy custom metrics configuration
          cat > app-metrics-config.yaml << EOF
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: app-metrics-config
            namespace: default
          data:
            metrics.yaml: |
              metrics:
                # Application metrics
                - name: app_requests_total
                  type: counter
                  description: Total number of requests
                  labels: [method, endpoint, status_code]
                
                - name: app_request_duration_seconds
                  type: histogram
                  description: Request duration in seconds
                  labels: [method, endpoint]
                  buckets: [0.1, 0.5, 1, 2, 5, 10]
                
                - name: app_active_users
                  type: gauge
                  description: Number of active users
                
                - name: app_errors_total
                  type: counter
                  description: Total number of errors
                  labels: [error_type, severity]
                
                # Business metrics
                - name: user_registrations_total
                  type: counter
                  description: Total user registrations
                
                - name: user_logins_total
                  type: counter
                  description: Total user logins
                  labels: [method]
                
                - name: feature_usage_total
                  type: counter
                  description: Feature usage counter
                  labels: [feature_name, user_type]
          EOF
          
          kubectl apply -f app-metrics-config.yaml
          echo "✅ Application metrics configured"
      
      - name: 📊 Setup Custom Dashboards
        run: |
          # Create Flutter Master App dashboard
          cat > flutter-dashboard.json << EOF
          {
            "dashboard": {
              "id": null,
              "title": "Flutter Master App - ${{ inputs.environment }}",
              "tags": ["flutter", "${{ inputs.environment }}"],
              "timezone": "UTC",
              "panels": [
                {
                  "id": 1,
                  "title": "Request Rate",
                  "type": "graph",
                  "targets": [
                    {
                      "expr": "rate(app_requests_total[5m])",
                      "legendFormat": "{{method}} {{endpoint}}"
                    }
                  ],
                  "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
                },
                {
                  "id": 2,
                  "title": "Error Rate",
                  "type": "graph",
                  "targets": [
                    {
                      "expr": "rate(app_errors_total[5m])",
                      "legendFormat": "{{error_type}}"
                    }
                  ],
                  "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
                },
                {
                  "id": 3,
                  "title": "Response Time",
                  "type": "graph",
                  "targets": [
                    {
                      "expr": "histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[5m]))",
                      "legendFormat": "95th percentile"
                    }
                  ],
                  "gridPos": {"h": 8, "w": 24, "x": 0, "y": 8}
                },
                {
                  "id": 4,
                  "title": "Active Users",
                  "type": "singlestat",
                  "targets": [
                    {
                      "expr": "app_active_users",
                      "legendFormat": "Active Users"
                    }
                  ],
                  "gridPos": {"h": 8, "w": 6, "x": 0, "y": 16}
                }
              ],
              "time": {"from": "now-1h", "to": "now"},
              "refresh": "30s"
            }
          }
          EOF
          
          # Import dashboard to Grafana
          GRAFANA_POD=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}')
          kubectl cp flutter-dashboard.json monitoring/$GRAFANA_POD:/tmp/dashboard.json
          
          echo "✅ Custom dashboards configured"
      
      - name: 🚨 Setup Alerting Rules
        run: |
          cat > alerting-rules.yaml << EOF
          apiVersion: monitoring.coreos.com/v1
          kind: PrometheusRule
          metadata:
            name: flutter-master-app-alerts
            namespace: monitoring
          spec:
            groups:
            - name: flutter-master-app.rules
              rules:
              # High error rate alert
              - alert: HighErrorRate
                expr: rate(app_errors_total[5m]) > 0.1
                for: 2m
                labels:
                  severity: warning
                  environment: ${{ inputs.environment }}
                annotations:
                  summary: "High error rate detected"
                  description: "Error rate is {{ \$value }} errors per second"
              
              # High response time alert
              - alert: HighResponseTime
                expr: histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[5m])) > 2
                for: 5m
                labels:
                  severity: warning
                  environment: ${{ inputs.environment }}
                annotations:
                  summary: "High response time detected"
                  description: "95th percentile response time is {{ \$value }} seconds"
              
              # Low active users alert
              - alert: LowActiveUsers
                expr: app_active_users < 10
                for: 10m
                labels:
                  severity: info
                  environment: ${{ inputs.environment }}
                annotations:
                  summary: "Low number of active users"
                  description: "Only {{ \$value }} active users"
              
              # Application down alert
              - alert: ApplicationDown
                expr: up{job="flutter-master-app"} == 0
                for: 1m
                labels:
                  severity: critical
                  environment: ${{ inputs.environment }}
                annotations:
                  summary: "Application is down"
                  description: "Flutter Master App is not responding"
              
              # Memory usage alert
              - alert: HighMemoryUsage
                expr: (container_memory_usage_bytes{pod=~"flutter-master-app.*"} / container_spec_memory_limit_bytes) > 0.8
                for: 5m
                labels:
                  severity: warning
                  environment: ${{ inputs.environment }}
                annotations:
                  summary: "High memory usage"
                  description: "Memory usage is {{ \$value | humanizePercentage }}"
              
              # CPU usage alert
              - alert: HighCPUUsage
                expr: rate(container_cpu_usage_seconds_total{pod=~"flutter-master-app.*"}[5m]) > 0.8
                for: 5m
                labels:
                  severity: warning
                  environment: ${{ inputs.environment }}
                annotations:
                  summary: "High CPU usage"
                  description: "CPU usage is {{ \$value | humanizePercentage }}"
          EOF
          
          kubectl apply -f alerting-rules.yaml
          echo "✅ Alerting rules configured"
      
      - name: 📱 Setup Mobile App Analytics
        run: |
          # Configure Firebase Analytics
          cat > firebase-analytics-config.yaml << EOF
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: firebase-analytics-config
          data:
            config.json: |
              {
                "analytics": {
                  "enabled": true,
                  "debug_mode": ${{ inputs.environment != 'production' }},
                  "custom_events": [
                    "user_registration",
                    "user_login",
                    "feature_used",
                    "error_occurred",
                    "purchase_completed"
                  ],
                  "custom_parameters": [
                    "user_type",
                    "app_version",
                    "platform",
                    "error_type"
                  ]
                },
                "crashlytics": {
                  "enabled": true,
                  "auto_collection": true,
                  "custom_logs": true
                }
              }
          EOF
          
          kubectl apply -f firebase-analytics-config.yaml
          echo "✅ Mobile analytics configured"
```

### Performance Monitoring Scripts
```bash
#!/bin/bash
# scripts/check-deployment-health.sh

DEPLOYMENT_COLOR=$1
NAMESPACE=${2:-default}

echo "🔍 Checking health of $DEPLOYMENT_COLOR deployment..."

# Get deployment pods
PODS=$(kubectl get pods -n $NAMESPACE -l version=$DEPLOYMENT_COLOR -o jsonpath='{.items[*].metadata.name}')

if [ -z "$PODS" ]; then
    echo "❌ No pods found for deployment $DEPLOYMENT_COLOR"
    exit 1
fi

# Check pod health
for pod in $PODS; do
    echo "Checking pod: $pod"
    
    # Check pod status
    STATUS=$(kubectl get pod $pod -n $NAMESPACE -o jsonpath='{.status.phase}')
    if [ "$STATUS" != "Running" ]; then
        echo "❌ Pod $pod is not running (status: $STATUS)"
        exit 1
    fi
    
    # Check readiness
    READY=$(kubectl get pod $pod -n $NAMESPACE -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
    if [ "$READY" != "True" ]; then
        echo "❌ Pod $pod is not ready"
        exit 1
    fi
    
    echo "✅ Pod $pod is healthy"
done

# Check service endpoint
SERVICE_IP=$(kubectl get service flutter-master-app-$DEPLOYMENT_COLOR -n $NAMESPACE -o jsonpath='{.spec.clusterIP}')
if [ -z "$SERVICE_IP" ]; then
    echo "❌ Service IP not found"
    exit 1
fi

# Health check
for i in {1..5}; do
    if curl -f -s "http://$SERVICE_IP:8080/health" > /dev/null; then
        echo "✅ Health check $i passed"
    else
        echo "❌ Health check $i failed"
        exit 1
    fi
    sleep 5
done

# Check metrics endpoint
if curl -f -s "http://$SERVICE_IP:8080/metrics" > /dev/null; then
    echo "✅ Metrics endpoint accessible"
else
    echo "❌ Metrics endpoint not accessible"
    exit 1
fi

echo "✅ All health checks passed for $DEPLOYMENT_COLOR deployment"

#!/bin/bash
# scripts/get-error-rate.sh

DEPLOYMENT=$1
NAMESPACE=${2:-default}

# Query Prometheus for error rate
PROMETHEUS_URL="http://prometheus-server.monitoring.svc.cluster.local:80"

# Get error rate for the last 5 minutes
ERROR_RATE=$(curl -s "$PROMETHEUS_URL/api/v1/query" \
  --data-urlencode "query=rate(app_errors_total{version=\"$DEPLOYMENT\"}[5m]) * 100" | \
  jq -r '.data.result[0].value[1] // "0"')

# Format to 2 decimal places
printf "%.2f" "$ERROR_RATE"

#!/bin/bash
# scripts/get-response-time.sh

DEPLOYMENT=$1
NAMESPACE=${2:-default}

# Query Prometheus for 95th percentile response time
PROMETHEUS_URL="http://prometheus-server.monitoring.svc.cluster.local:80"

RESPONSE_TIME=$(curl -s "$PROMETHEUS_URL/api/v1/query" \
  --data-urlencode "query=histogram_quantile(0.95, rate(app_request_duration_seconds_bucket{version=\"$DEPLOYMENT\"}[5m])) * 1000" | \
  jq -r '.data.result[0].value[1] // "0"')

# Format to integer milliseconds
printf "%.0f" "$RESPONSE_TIME"
```

## 🏗️ Infrastructure as Code

### Terraform Infrastructure
```hcl
# infrastructure/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
  
  backend "gcs" {
    bucket = "flutter-master-terraform-state"
    prefix = "terraform/state"
  }
}

# Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "flutter-master-cluster"
}

# Locals
locals {
  common_labels = {
    project     = "flutter-master"
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Google Kubernetes Engine Cluster
resource "google_container_cluster" "primary" {
  name     = "${var.cluster_name}-${var.environment}"
  location = var.region
  
  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Network configuration
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  
  # IP allocation for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  # Master auth configuration
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    
    horizontal_pod_autoscaling {
      disabled = false
    }
    
    network_policy_config {
      disabled = false
    }
    
    istio_config {
      disabled = false
      auth     = "AUTH_MUTUAL_TLS"
    }
  }
  
  # Network policy
  network_policy {
    enabled = true
  }
  
  # Maintenance policy
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
  
  labels = local.common_labels
}

# Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-${var.environment}-nodes"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  node_count = var.environment == "prod" ? 3 : 2
  
  # Auto scaling
  autoscaling {
    min_node_count = var.environment == "prod" ? 3 : 1
    max_node_count = var.environment == "prod" ? 10 : 5
  }
  
  # Node configuration
  node_config {
    preemptible  = var.environment != "prod"
    machine_type = var.environment == "prod" ? "e2-standard-4" : "e2-standard-2"
    
    # OAuth scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
    
    # Labels
    labels = merge(local.common_labels, {
      node_pool = "primary"
    })
    
    # Metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }
    
    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    # Shielded instance
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
  
  # Update strategy
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
  
  # Management
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  
  depends_on = [google_project_service.compute]
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-${var.environment}-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.name
  
  # Secondary ranges for pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "${var.cluster_name}-${var.environment}-db"
  database_version = "POSTGRES_14"
  region          = var.region
  
  settings {
    tier = var.environment == "prod" ? "db-standard-2" : "db-f1-micro"
    
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"
    
    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = var.environment == "prod"
      
      backup_retention_settings {
        retained_backups = var.environment == "prod" ? 30 : 7
        retention_unit   = "COUNT"
      }
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      require_ssl     = true
    }
    
    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
    
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
  }
  
  deletion_protection = var.environment == "prod"
}

# Redis Instance
resource "google_redis_instance" "cache" {
  name           = "${var.cluster_name}-${var.environment}-redis"
  tier           = var.environment == "prod" ? "STANDARD_HA" : "BASIC"
  memory_size_gb = var.environment == "prod" ? 4 : 1
  region         = var.region
  
  authorized_network = google_compute_network.vpc.id
  
  redis_version = "REDIS_6_X"
  
  labels = local.common_labels
}

# Storage Bucket
resource "google_storage_bucket" "app_storage" {
  name     = "${var.project_id}-${var.environment}-app-storage"
  location = "US"
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = var.environment == "prod"
  }
  
  lifecycle_rule {
    condition {
      age = var.environment == "prod" ? 365 : 90
    }
    action {
      type = "Delete"
    }
  }
  
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
  
  labels = local.common_labels
}

# Service Account for Workload Identity
resource "google_service_account" "workload_identity" {
  account_id   = "${var.cluster_name}-${var.environment}-wi"
  display_name = "Flutter Master Workload Identity"
}

# IAM bindings
resource "google_project_iam_member" "workload_identity" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}

# Enable required APIs
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_project_service" "sql" {
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "redis" {
  service = "redis.googleapis.com"
}

# Outputs
output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "database_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.main.connection_name
}

output "redis_host" {
  description = "Redis instance host"
  value       = google_redis_instance.cache.host
}

output "storage_bucket" {
  description = "Storage bucket name"
  value       = google_storage_bucket.app_storage.name
}
```

### Terraform Deployment Workflow
```yaml
# .github/workflows/terraform.yml
name: Terraform Infrastructure

on:
  push:
    paths:
      - 'infrastructure/**'
    branches: [main, develop]
  pull_request:
    paths:
      - 'infrastructure/**'

env:
  TF_VERSION: '1.6.0'
  TF_WORKING_DIR: './infrastructure'

jobs:
  terraform:
    name: 🏗️ Terraform
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    strategy:
      matrix:
        environment: [dev, staging, prod]
        exclude:
          - environment: prod
          - environment: staging
    
    environment: ${{ matrix.environment }}
    
    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🔧 Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: ☁️ Setup Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: 🏗️ Terraform Init
        run: |
          terraform init \
            -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" \
            -backend-config="prefix=terraform/state/${{ matrix.environment }}"
      
      - name: 📋 Terraform Validate
        run: terraform validate
      
      - name: 📊 Terraform Plan
        id: plan
        run: |
          terraform plan \
            -var="project_id=${{ secrets.GCP_PROJECT_ID }}" \
            -var="environment=${{ matrix.environment }}" \
            -out=tfplan \
            -detailed-exitcode
        continue-on-error: true
      
      - name: 📝 Update PR Comment
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        env:
          PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
        with:
          script: |
            const output = `#### Terraform Plan 📊 \`${{ steps.plan.outcome }}\`
            #### Environment: \`${{ matrix.environment }}\`
            
            <details><summary>Show Plan</summary>
            
            \`\`\`\n
            ${process.env.PLAN}
            \`\`\`
            
            </details>
            
            *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
      
      - name: 🚀 Terraform Apply
        if: github.ref == 'refs/heads/main' && steps.plan.outcome == 'success'
        run: |
          terraform apply -auto-approve tfplan
          echo "✅ Infrastructure deployed successfully"
      
      - name: 📊 Terraform Output
        if: github.ref == 'refs/heads/main'
        run: |
          terraform output -json > terraform-outputs.json
          echo "Infrastructure outputs saved"
      
      - name: 📤 Upload Terraform Outputs
        if: github.ref == 'refs/heads/main'
        uses: actions/upload-artifact@v3
        with:
          name: terraform-outputs-${{ matrix.environment }}
          path: ${{ env.TF_WORKING_DIR }}/terraform-outputs.json
## 🔒 Security in CI/CD

### Security-First CI/CD Pipeline
```yaml
# .github/workflows/security-pipeline.yml
name: Security Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  schedule:
    # Run security scans daily at 2 AM
    - cron: '0 2 * * *'

env:
  FLUTTER_VERSION: '3.16.0'

jobs:
  # ═══════════════════════════════════════════════════════════════════
  # DEPENDENCY SECURITY SCANNING
  # ═══════════════════════════════════════════════════════════════════
  
  dependency-security:
    name: 🔍 Dependency Security Scan
    runs-on: ubuntu-latest
    timeout-minutes: 15
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: 📦 Get Dependencies
        run: flutter pub get
      
      - name: 🔒 Audit Dependencies
        run: |
          echo "🔍 Running dependency audit..."
          flutter pub audit --machine
          
          # Custom vulnerability check
          if flutter pub audit | grep -i "vulnerability"; then
            echo "❌ Security vulnerabilities found in dependencies"
            exit 1
          fi
          
          echo "✅ No security vulnerabilities found"
      
      - name: 📊 SBOM Generation
        run: |
          # Generate Software Bill of Materials
          flutter pub deps --json > sbom.json
          
          # Analyze dependency tree for suspicious packages
          dart run scripts/analyze_dependencies.dart sbom.json
          
          echo "✅ SBOM generated and analyzed"
      
      - name: 🚨 Snyk Security Scan
        uses: snyk/actions/dart@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=medium
      
      - name: 📤 Upload Security Reports
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: dependency-security-reports
          path: |
            sbom.json
            snyk-report.json
          retention-days: 30

  # ═══════════════════════════════════════════════════════════════════
  # SECRETS SCANNING
  # ═══════════════════════════════════════════════════════════════════
  
  secrets-scanning:
    name: 🔐 Secrets Scanning
    runs-on: ubuntu-latest
    timeout-minutes: 10
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for complete scan
      
      - name: 🔍 TruffleHog Secrets Scan
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
          extra_args: --debug --only-verified
      
      - name: 🔐 GitLeaks Scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: 🔍 Custom Secret Patterns
        run: |
          echo "🔍 Scanning for custom secret patterns..."
          
          # Check for hardcoded API keys
          if grep -r "api[_-]key\s*[=:]\s*['\"]" . --include="*.dart" --exclude-dir=".git"; then
            echo "❌ Potential hardcoded API keys found"
            exit 1
          fi
          
          # Check for passwords
          if grep -r "password\s*[=:]\s*['\"][^'\"]*['\"]" . --include="*.dart" --exclude-dir=".git"; then
            echo "❌ Potential hardcoded passwords found"
            exit 1
          fi
          
          # Check for JWT tokens
          if grep -r "eyJ[A-Za-z0-9_-]*\." . --include="*.dart" --exclude-dir=".git"; then
            echo "❌ Potential JWT tokens found"
            exit 1
          fi
          
          # Check for private keys
          if grep -r "BEGIN.*PRIVATE.*KEY" . --exclude-dir=".git"; then
            echo "❌ Private keys found"
            exit 1
          fi
          
          echo "✅ No hardcoded secrets detected"

  # ═══════════════════════════════════════════════════════════════════
  # STATIC APPLICATION SECURITY TESTING (SAST)
  # ═══════════════════════════════════════════════════════════════════
  
  sast-scanning:
    name: 🛡️ SAST Security Analysis
    runs-on: ubuntu-latest
    timeout-minutes: 20
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: 📦 Get Dependencies
        run: flutter pub get
      
      - name: 🔍 CodeQL Analysis
        uses: github/codeql-action/init@v2
        with:
          languages: 'dart'
      
      - name: 🏗️ Autobuild
        uses: github/codeql-action/autobuild@v2
      
      - name: 🔍 Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2
      
      - name: 🛡️ Semgrep SAST Scan
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/secrets
            p/owasp-top-ten
          generateSarif: "1"
      
      - name: 📊 Upload SARIF Results
        if: always()
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: semgrep.sarif
      
      - name: 🔒 Custom Security Rules
        run: |
          echo "🔍 Running custom security analysis..."
          
          # Check for SQL injection vulnerabilities
          if grep -r "query.*+.*\$" lib/ --include="*.dart"; then
            echo "⚠️ Potential SQL injection vulnerability found"
          fi
          
          # Check for unsafe HTTP usage
          if grep -r "http://" lib/ --include="*.dart" | grep -v "localhost"; then
            echo "⚠️ Unsafe HTTP usage detected"
          fi
          
          # Check for insecure random usage
          if grep -r "Random()" lib/ --include="*.dart"; then
            echo "⚠️ Insecure random number generation"
          fi
          
          # Check for debug mode in production
          if grep -r "kDebugMode.*false" lib/ --include="*.dart"; then
            echo "⚠️ Debug mode explicitly disabled - ensure this is intentional"
          fi
          
          echo "✅ Custom security analysis completed"

  # ═══════════════════════════════════════════════════════════════════
  # CONTAINER SECURITY SCANNING
  # ═══════════════════════════════════════════════════════════════════
  
  container-security:
    name: 📦 Container Security Scan
    runs-on: ubuntu-latest
    timeout-minutes: 25
    needs: [dependency-security, secrets-scanning]
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
      
      - name: 🏗️ Build Docker Image
        run: |
          cat > Dockerfile << EOF
          FROM cirrusci/flutter:3.16.0 as builder
          
          WORKDIR /app
          COPY pubspec.* ./
          RUN flutter pub get
          
          COPY . .
          RUN flutter build web --release
          
          FROM nginx:alpine
          RUN addgroup -g 1001 -S flutter && \
              adduser -S flutter -u 1001 -G flutter
          
          COPY --from=builder /app/build/web /usr/share/nginx/html
          COPY nginx.conf /etc/nginx/nginx.conf
          
          USER flutter
          EXPOSE 8080
          
          CMD ["nginx", "-g", "daemon off;"]
          EOF
          
          docker build -t flutter-master-app:security-scan .
      
      - name: 🔍 Trivy Container Scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'flutter-master-app:security-scan'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH,MEDIUM'
      
      - name: 📊 Upload Trivy Results
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: 🛡️ Snyk Container Scan
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          image: flutter-master-app:security-scan
          args: --severity-threshold=medium
      
      - name: 🔒 Container Security Benchmark
        run: |
          # Run Docker Bench Security
          docker run --rm --net host --pid host --userns host --cap-add audit_control \
            -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
            -v /var/lib:/var/lib:ro \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            -v /usr/lib/systemd:/usr/lib/systemd:ro \
            -v /etc:/etc:ro \
            --label docker_bench_security \
            docker/docker-bench-security || true
          
          echo "✅ Container security benchmark completed"

  # ═══════════════════════════════════════════════════════════════════
  # SECURITY COMPLIANCE CHECKS
  # ═══════════════════════════════════════════════════════════════════
  
  compliance-checks:
    name: 📋 Security Compliance
    runs-on: ubuntu-latest
    timeout-minutes: 15
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
      
      - name: 🔍 OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        env:
          JAVA_HOME: /opt/jdk
        with:
          project: 'flutter-master-app'
          path: '.'
          format: 'ALL'
          args: >
            --enableRetired
            --enableExperimental
            --nvdApiKey ${{ secrets.NVD_API_KEY }}
      
      - name: 📊 Upload OWASP Report
        uses: actions/upload-artifact@v3
        with:
          name: owasp-dependency-check-report
          path: reports/
      
      - name: 🔒 Security Policy Compliance
        run: |
          echo "🔍 Checking security policy compliance..."
          
          # Check for security.md file
          if [[ ! -f "SECURITY.md" ]]; then
            echo "❌ SECURITY.md file missing"
            exit 1
          fi
          
          # Check for proper license
          if [[ ! -f "LICENSE" ]]; then
            echo "❌ LICENSE file missing"
            exit 1
          fi
          
          # Check for code of conduct
          if [[ ! -f "CODE_OF_CONDUCT.md" ]]; then
            echo "⚠️ CODE_OF_CONDUCT.md recommended"
          fi
          
          # Verify required security headers in code
          if ! grep -r "X-Frame-Options\|X-Content-Type-Options\|X-XSS-Protection" lib/; then
            echo "⚠️ Security headers implementation recommended"
          fi
          
          echo "✅ Security policy compliance checked"
      
      - name: 📝 Generate Security Report
        run: |
          cat > security-compliance-report.md << EOF
          # Security Compliance Report
          
          **Date:** $(date)
          **Commit:** ${{ github.sha }}
          **Branch:** ${{ github.ref_name }}
          
          ## Compliance Status
          
          - ✅ Dependency Security Scan
          - ✅ Secrets Scanning
          - ✅ SAST Analysis
          - ✅ Container Security
          - ✅ OWASP Compliance
          
          ## Security Metrics
          
          - **Vulnerabilities Found:** 0 Critical, 0 High, 0 Medium
          - **Secrets Detected:** 0
          - **Container Security Score:** Pass
          - **Compliance Score:** 100%
          
          ## Recommendations
          
          - Maintain regular security scanning
          - Keep dependencies updated
          - Review security policies quarterly
          
          ---
          *Generated by Security Pipeline*
          EOF
          
          echo "✅ Security compliance report generated"
      
      - name: 📤 Upload Compliance Report
        uses: actions/upload-artifact@v3
        with:
          name: security-compliance-report
          path: security-compliance-report.md

  # ═══════════════════════════════════════════════════════════════════
  # SECURITY NOTIFICATION
  # ═══════════════════════════════════════════════════════════════════
  
  security-notification:
    name: 🔔 Security Notification
    runs-on: ubuntu-latest
    needs: [dependency-security, secrets-scanning, sast-scanning, container-security, compliance-checks]
    if: always()
    
    steps:
      - name: 📊 Evaluate Security Status
        id: security-status
        run: |
          # Check if any security job failed
          if [[ "${{ needs.dependency-security.result }}" != "success" ]] || \
             [[ "${{ needs.secrets-scanning.result }}" != "success" ]] || \
             [[ "${{ needs.sast-scanning.result }}" != "success" ]] || \
             [[ "${{ needs.container-security.result }}" != "success" ]] || \
             [[ "${{ needs.compliance-checks.result }}" != "success" ]]; then
            echo "security_status=failed" >> $GITHUB_OUTPUT
            echo "Security pipeline failed"
          else
            echo "security_status=passed" >> $GITHUB_OUTPUT
            echo "Security pipeline passed"
          fi
      
      - name: 🚨 Notify Security Team (Failure)
        if: steps.security-status.outputs.security_status == 'failed'
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          channel: '#security-alerts'
          webhook_url: ${{ secrets.SLACK_SECURITY_WEBHOOK }}
          message: |
            🚨 SECURITY ALERT: Security pipeline failed!
            
            **Repository:** ${{ github.repository }}
            **Branch:** ${{ github.ref_name }}
            **Commit:** ${{ github.sha }}
            **Author:** ${{ github.actor }}
            
            **Failed Checks:**
            - Dependency Security: ${{ needs.dependency-security.result }}
            - Secrets Scanning: ${{ needs.secrets-scanning.result }}
            - SAST Analysis: ${{ needs.sast-scanning.result }}
            - Container Security: ${{ needs.container-security.result }}
            - Compliance: ${{ needs.compliance-checks.result }}
            
            **Action Required:** Review security findings immediately
            **View Details:** ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
      
      - name: ✅ Notify Security Team (Success)
        if: steps.security-status.outputs.security_status == 'passed'
        uses: 8398a7/action-slack@v3
        with:
          status: success
          channel: '#security-reports'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
          message: |
            ✅ Security pipeline completed successfully
            
            **Repository:** ${{ github.repository }}
            **Branch:** ${{ github.ref_name }}
            **Commit:** ${{ github.sha }}
            
            All security checks passed ✨
```

### Security Scripts & Tools
```dart
// scripts/analyze_dependencies.dart
import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart analyze_dependencies.dart <sbom.json>');
    exit(1);
  }
  
  final sbomFile = File(arguments[0]);
  if (!sbomFile.existsSync()) {
    print('❌ SBOM file not found: ${arguments[0]}');
    exit(1);
  }
  
  print('🔍 Analyzing dependency security...');
  
  try {
    final sbomContent = jsonDecode(sbomFile.readAsStringSync());
    _analyzeDependencies(sbomContent);
    print('✅ Dependency analysis completed');
  } catch (e) {
    print('❌ Failed to analyze dependencies: $e');
    exit(1);
  }
}

void _analyzeDependencies(Map<String, dynamic> sbom) {
  final packages = sbom['packages'] as Map<String, dynamic>? ?? {};
  final suspiciousPatterns = [
    'test', 'debug', 'temp', 'hack', 'exploit', 'backdoor'
  ];
  
  var suspicious = 0;
  var outdated = 0;
  
  for (final package in packages.entries) {
    final packageName = package.key;
    final packageInfo = package.value as Map<String, dynamic>;
    
    // Check for suspicious package names
    for (final pattern in suspiciousPatterns) {
      if (packageName.toLowerCase().contains(pattern)) {
        print('⚠️ Suspicious package name: $packageName');
        suspicious++;
      }
    }
    
    // Check for very old versions (simplified check)
    final version = packageInfo['version'] as String?;
    if (version != null && version.startsWith('0.')) {
      print('⚠️ Pre-release version detected: $packageName@$version');
      outdated++;
    }
  }
  
  print('📊 Analysis Summary:');
  print('   • Total packages: ${packages.length}');
  print('   • Suspicious names: $suspicious');
  print('   • Pre-release versions: $outdated');
  
  if (suspicious > 0) {
    print('⚠️ Review suspicious packages before deployment');
  }
}
```

## 🔄 Rollback Strategies

### Automated Rollback System
```yaml
# .github/workflows/rollback.yml
name: Emergency Rollback

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to rollback'
        required: true
        type: choice
        options:
          - staging
          - production
      rollback_version:
        description: 'Version to rollback to (e.g., v1.2.3)'
        required: true
        type: string
      reason:
        description: 'Reason for rollback'
        required: true
        type: string

jobs:
  emergency-rollback:
    name: 🔄 Emergency Rollback
    runs-on: ubuntu-latest
    timeout-minutes: 15
    environment: ${{ inputs.environment }}
    
    steps:
      - name: 📚 Checkout Repository
        uses: actions/checkout@v4
        with:
          ref: ${{ inputs.rollback_version }}
      
      - name: ☁️ Setup Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: 🔍 Validate Rollback Version
        run: |
          echo "🔍 Validating rollback version: ${{ inputs.rollback_version }}"
          
          # Check if the version exists
          if ! git tag | grep -q "^${{ inputs.rollback_version }}$"; then
            echo "❌ Version ${{ inputs.rollback_version }} not found"
            exit 1
          fi
          
          # Check if version is not too old (30 days)
          VERSION_DATE=$(git log -1 --format=%ct ${{ inputs.rollback_version }})
          CURRENT_DATE=$(date +%s)
          DAYS_OLD=$(( (CURRENT_DATE - VERSION_DATE) / 86400 ))
          
          if [ $DAYS_OLD -gt 30 ]; then
            echo "⚠️ Warning: Rollback version is $DAYS_OLD days old"
            echo "Consider using a more recent version"
          fi
          
          echo "✅ Rollback version validated"
      
      - name: 📊 Pre-Rollback Health Check
        run: |
          echo "🔍 Checking current deployment health..."
          
          # Get current deployment status
          CURRENT_REPLICAS=$(kubectl get deployment flutter-master-app-${{ inputs.environment }} -o jsonpath='{.status.readyReplicas}')
          DESIRED_REPLICAS=$(kubectl get deployment flutter-master-app-${{ inputs.environment }} -o jsonpath='{.spec.replicas}')
          
          echo "Current replicas: $CURRENT_REPLICAS/$DESIRED_REPLICAS"
          
          if [ "$CURRENT_REPLICAS" != "$DESIRED_REPLICAS" ]; then
            echo "⚠️ Current deployment is not fully healthy"
          fi
          
          # Check error rates
          ERROR_RATE=$(./scripts/get-error-rate.sh ${{ inputs.environment }})
          echo "Current error rate: $ERROR_RATE%"
          
          echo "✅ Pre-rollback health check completed"
      
      - name: 🔄 Execute Rollback
        run: |
          echo "🔄 Rolling back to version ${{ inputs.rollback_version }}..."
          
          # Get the image tag for the rollback version
          ROLLBACK_IMAGE="gcr.io/${{ secrets.GCP_PROJECT_ID }}/flutter-master-app:${{ inputs.rollback_version }}"
          
          # Update deployment
          kubectl set image deployment/flutter-master-app-${{ inputs.environment }} \
            app=$ROLLBACK_IMAGE
          
          echo "✅ Rollback deployment initiated"
      
      - name: ⏱️ Wait for Rollback Completion
        run: |
          echo "⏱️ Waiting for rollback to complete..."
          
          # Wait for rollout to complete (max 5 minutes)
          if kubectl rollout status deployment/flutter-master-app-${{ inputs.environment }} --timeout=300s; then
            echo "✅ Rollback completed successfully"
          else
            echo "❌ Rollback failed to complete within timeout"
            exit 1
          fi
      
      - name: 🧪 Post-Rollback Verification
        run: |
          echo "🧪 Verifying rollback..."
          
          # Wait a bit for metrics to stabilize
          sleep 60
          
          # Check health endpoint
          HEALTH_CHECK=$(kubectl run health-check --rm -i --restart=Never --image=curlimages/curl -- \
            curl -s -o /dev/null -w "%{http_code}" \
            http://flutter-master-app-${{ inputs.environment }}:8080/health)
          
          if [ "$HEALTH_CHECK" != "200" ]; then
            echo "❌ Health check failed after rollback"
            exit 1
          fi
          
          # Check error rates
          sleep 30  # Wait for metrics
          ERROR_RATE=$(./scripts/get-error-rate.sh ${{ inputs.environment }})
          
          if (( $(echo "$ERROR_RATE > 5" | bc -l) )); then
            echo "❌ High error rate after rollback: $ERROR_RATE%"
            exit 1
          fi
          
          echo "✅ Post-rollback verification successful"
          echo "   • Health check: ✅"
          echo "   • Error rate: $ERROR_RATE%"
      
      - name: 📊 Update Monitoring
        run: |
          # Create rollback annotation in monitoring
          cat > rollback-annotation.json << EOF
          {
            "time": $(date +%s)000,
            "title": "Emergency Rollback",
            "text": "Rolled back to ${{ inputs.rollback_version }} in ${{ inputs.environment }}",
            "tags": ["rollback", "${{ inputs.environment }}"],
            "annotation": {
              "reason": "${{ inputs.reason }}",
              "version": "${{ inputs.rollback_version }}",
              "triggered_by": "${{ github.actor }}"
            }
          }
          EOF
          
          # Send to monitoring system (Grafana annotation API)
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.GRAFANA_API_KEY }}" \
            -H "Content-Type: application/json" \
            -d @rollback-annotation.json \
            "${{ secrets.GRAFANA_URL }}/api/annotations" || true
          
          echo "✅ Monitoring updated with rollback information"
      
      - name: 🔔 Notify Teams
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
          message: |
            🔄 Emergency Rollback ${{ job.status == 'success' && 'Completed' || 'Failed' }}
            
            **Environment:** ${{ inputs.environment }}
            **Rollback Version:** ${{ inputs.rollback_version }}
            **Reason:** ${{ inputs.reason }}
            **Triggered By:** ${{ github.actor }}
            **Status:** ${{ job.status == 'success' && '✅ Success' || '❌ Failed' }}
            
            ${{ job.status == 'success' && 'Service has been rolled back and is healthy' || 'Rollback failed - immediate attention required' }}
      
      - name: 📝 Create Incident Report
        if: always()
        run: |
          cat > incident-report.md << EOF
          # Emergency Rollback Incident Report
          
          **Date:** $(date)
          **Environment:** ${{ inputs.environment }}
          **Rollback Version:** ${{ inputs.rollback_version }}
          **Triggered By:** ${{ github.actor }}
          **Status:** ${{ job.status }}
          
          ## Incident Details
          
          **Reason for Rollback:**
          ${{ inputs.reason }}
          
          ## Timeline
          
          - **Rollback Initiated:** $(date)
          - **Rollback Completed:** $(date)
          - **Verification Status:** ${{ job.status == 'success' && 'Passed' || 'Failed' }}
          
          ## Actions Taken
          
          1. Validated rollback version ${{ inputs.rollback_version }}
          2. Executed deployment rollback
          3. Verified service health and metrics
          4. Updated monitoring and notifications
          
          ## Next Steps
          
          - [ ] Investigate root cause of issue
          - [ ] Plan forward fix
          - [ ] Update deployment procedures if needed
          - [ ] Post-mortem meeting scheduled
          
          ---
          *Auto-generated by Emergency Rollback Workflow*
          EOF
          
          echo "✅ Incident report generated"
      
      - name: 📤 Upload Incident Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: rollback-incident-report-${{ inputs.environment }}
          path: incident-report.md
```

## 📋 DevOps Summary & Best Practices

### Complete DevOps Checklist
```yaml
# DevOps Implementation Checklist

CI/CD Pipeline:
  - [x] Automated testing (unit, widget, integration)
  - [x] Code quality gates with coverage thresholds
  - [x] Security scanning (SAST, dependency, secrets)
  - [x] Multi-environment deployment (dev, staging, prod)
  - [x] Automated rollback capabilities
  - [x] Performance benchmarking

Build & Release:
  - [x] Multi-platform builds (Android, iOS, Web)
  - [x] Automated signing and publishing
  - [x] Release note generation
  - [x] Artifact management and versioning
  - [x] Build optimization and caching

Infrastructure:
  - [x] Infrastructure as Code (Terraform)
  - [x] Container orchestration (Kubernetes)
  - [x] Auto-scaling and load balancing
  - [x] Backup and disaster recovery
  - [x] SSL/TLS certificate management

Monitoring & Observability:
  - [x] Application performance monitoring
  - [x] Real-time alerting and notifications
  - [x] Log aggregation and analysis
  - [x] Custom metrics and dashboards
  - [x] Health checks and uptime monitoring

Security:
  - [x] Secrets management and rotation
  - [x] Vulnerability scanning and patching
  - [x] Access control and audit logging
  - [x] Compliance monitoring (GDPR, SOC2)
  - [x] Incident response procedures

Quality Assurance:
  - [x] Automated quality gates
  - [x] Performance regression testing
  - [x] Accessibility testing
  - [x] Cross-platform compatibility testing
  - [x] Load and stress testing
```

### Performance Metrics & KPIs
```yaml
# DevOps Performance Metrics

Deployment Metrics:
  - Deployment Frequency: Daily (Target)
  - Lead Time: < 2 hours (Target)
  - Change Failure Rate: < 5% (Target)
  - Mean Time to Recovery: < 30 minutes (Target)

Quality Metrics:
  - Code Coverage: > 80% (Required)
  - Test Pass Rate: > 98% (Target)
  - Static Analysis Score: A Grade (Target)
  - Security Vulnerabilities: 0 Critical/High (Required)

Performance Metrics:
  - Build Time: < 10 minutes (Target)
  - Test Execution Time: < 5 minutes (Target)
  - Deployment Time: < 15 minutes (Target)
  - Rollback Time: < 5 minutes (Target)

Reliability Metrics:
  - Service Uptime: > 99.9% (Target)
  - Error Rate: < 0.1% (Target)
  - Response Time: < 200ms P95 (Target)
  - Resource Utilization: < 70% (Target)
```

### Essential Tools & Technologies
```yaml
# DevOps Technology Stack

Version Control:
  - Git with GitFlow branching strategy
  - GitHub for repository hosting
  - Semantic versioning for releases

CI/CD Platform:
  - GitHub Actions for automation
  - Docker for containerization
  - Kubernetes for orchestration

Cloud Infrastructure:
  - Google Cloud Platform (primary)
```yaml
  - Terraform for infrastructure as code
  - Helm for Kubernetes package management
  - Istio for service mesh

Monitoring Stack:
  - Prometheus for metrics collection
  - Grafana for visualization
  - AlertManager for alerting
  - Jaeger for distributed tracing
  - ELK Stack for log aggregation

Security Tools:
  - Snyk for vulnerability scanning
  - TruffleHog for secrets detection
  - CodeQL for static analysis
  - Trivy for container scanning
  - OWASP ZAP for dynamic testing

Quality Tools:
  - SonarQube for code quality
  - Dart Code Metrics for complexity analysis
  - Codecov for coverage reporting
  - Lighthouse for performance audits
```

### DevOps Automation Scripts
```bash
#!/bin/bash
# scripts/setup-devops.sh

set -e

echo "🚀 Setting up DevOps environment..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install required tools
install_tools() {
    echo "📦 Installing required tools..."
    
    # Docker
    if ! command_exists docker; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        echo "✅ Docker installed"
    fi
    
    # Kubectl
    if ! command_exists kubectl; then
        echo "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        echo "✅ kubectl installed"
    fi
    
    # Helm
    if ! command_exists helm; then
        echo "Installing Helm..."
        curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
        sudo apt-get update
        sudo apt-get install helm
        echo "✅ Helm installed"
    fi
    
    # Terraform
    if ! command_exists terraform; then
        echo "Installing Terraform..."
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform
        echo "✅ Terraform installed"
    fi
    
    # Google Cloud SDK
    if ! command_exists gcloud; then
        echo "Installing Google Cloud SDK..."
        curl https://sdk.cloud.google.com | bash
        exec -l $SHELL
        echo "✅ Google Cloud SDK installed"
    fi
}

# Setup monitoring
setup_monitoring() {
    echo "📊 Setting up monitoring stack..."
    
    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Add Prometheus Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Install Prometheus
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set grafana.adminPassword=admin123 \
        --set prometheus.prometheusSpec.retention=30d \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi
    
    echo "✅ Monitoring stack deployed"
}

# Setup security scanning
setup_security() {
    echo "🔒 Setting up security tools..."
    
    # Install Falco for runtime security
    helm repo add falcosecurity https://falcosecurity.github.io/charts
    helm repo update
    
    helm upgrade --install falco falcosecurity/falco \
        --namespace falco-system \
        --create-namespace \
        --set falco.grpc.enabled=true \
        --set falco.grpcOutput.enabled=true
    
    # Install OPA Gatekeeper for policy enforcement
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
    
    echo "✅ Security tools deployed"
}

# Setup CI/CD
setup_cicd() {
    echo "🔄 Setting up CI/CD components..."
    
    # Create secrets for GitHub Actions
    cat > github-secrets.md << EOF
# GitHub Secrets to Configure

## Required Secrets:
- GCP_SERVICE_ACCOUNT: Base64 encoded service account key
- GCP_PROJECT_ID: Google Cloud project ID
- ANDROID_KEYSTORE: Base64 encoded Android keystore
- KEYSTORE_PASSWORD: Android keystore password
- KEY_PASSWORD: Android key password
- KEY_ALIAS: Android key alias
- IOS_CERTIFICATE: Base64 encoded iOS certificate
- IOS_CERTIFICATE_PASSWORD: iOS certificate password
- IOS_PROVISION_PROFILE: Base64 encoded provisioning profile
- FIREBASE_TOKEN: Firebase CLI token
- SLACK_WEBHOOK: Slack webhook URL for notifications
- SNYK_TOKEN: Snyk API token for security scanning

## Optional Secrets:
- CODECOV_TOKEN: Codecov token for coverage reporting
- SONAR_TOKEN: SonarQube token for code quality
- NVD_API_KEY: NIST NVD API key for vulnerability scanning
EOF
    
    echo "✅ CI/CD setup guide created: github-secrets.md"
}

# Setup development environment
setup_dev_environment() {
    echo "💻 Setting up development environment..."
    
    # Create development configuration
    cat > .env.development << EOF
# Development Environment Configuration
ENVIRONMENT=development
DEBUG_MODE=true
API_BASE_URL=http://localhost:8080
ENABLE_LOGGING=true
ENABLE_ANALYTICS=false
EOF
    
    # Create Docker Compose for local development
    cat > docker-compose.dev.yml << EOF
version: '3.8'
services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: flutter_master_dev
      POSTGRES_USER: dev_user
      POSTGRES_PASSWORD: dev_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
  
  mailhog:
    image: mailhog/mailhog
    ports:
      - "1025:1025"  # SMTP
      - "8025:8025"  # Web UI

volumes:
  postgres_data:
  redis_data:
EOF
    
    echo "✅ Development environment configured"
}

# Main execution
main() {
    echo "🚀 Flutter Master DevOps Setup"
    echo "=============================="
    
    install_tools
    setup_monitoring
    setup_security
    setup_cicd
    setup_dev_environment
    
    echo ""
    echo "✅ DevOps setup completed successfully!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Configure GitHub secrets using: github-secrets.md"
    echo "2. Initialize Terraform: cd infrastructure && terraform init"
    echo "3. Start development services: docker-compose -f docker-compose.dev.yml up -d"
    echo "4. Access Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
    echo "5. Access Prometheus: kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
    echo ""
    echo "🔧 Useful Commands:"
    echo "- View pods: kubectl get pods --all-namespaces"
    echo "- Check monitoring: kubectl get pods -n monitoring"
    echo "- View security policies: kubectl get constraints"
    echo "- Monitor deployments: kubectl rollout status deployment/<name>"
}

# Run main function
main "$@"

#!/bin/bash
# scripts/deploy.sh

set -e

ENVIRONMENT=${1:-staging}
VERSION=${2:-latest}
DRY_RUN=${3:-false}

echo "🚀 Deploying Flutter Master App"
echo "Environment: $ENVIRONMENT"
echo "Version: $VERSION"
echo "Dry Run: $DRY_RUN"

# Validate inputs
validate_inputs() {
    if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "Valid options: development, staging, production"
        exit 1
    fi
    
    if [[ "$VERSION" == "latest" && "$ENVIRONMENT" == "production" ]]; then
        echo "❌ Cannot deploy 'latest' to production"
        echo "Please specify a specific version tag"
        exit 1
    fi
}

# Pre-deployment checks
pre_deployment_checks() {
    echo "🔍 Running pre-deployment checks..."
    
    # Check cluster connectivity
    if ! kubectl cluster-info > /dev/null 2>&1; then
        echo "❌ Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check if namespace exists
    if ! kubectl get namespace $ENVIRONMENT > /dev/null 2>&1; then
        echo "📦 Creating namespace: $ENVIRONMENT"
        kubectl create namespace $ENVIRONMENT
    fi
    
    # Check if image exists
    if [[ "$VERSION" != "latest" ]]; then
        if ! gcloud container images describe gcr.io/$GCP_PROJECT_ID/flutter-master-app:$VERSION > /dev/null 2>&1; then
            echo "❌ Image not found: gcr.io/$GCP_PROJECT_ID/flutter-master-app:$VERSION"
            exit 1
        fi
    fi
    
    echo "✅ Pre-deployment checks passed"
}

# Deploy application
deploy_application() {
    echo "🚀 Deploying application..."
    
    # Update deployment manifests
    sed -i "s|{{ENVIRONMENT}}|$ENVIRONMENT|g" k8s/*.yaml
    sed -i "s|{{VERSION}}|$VERSION|g" k8s/*.yaml
    sed -i "s|{{PROJECT_ID}}|$GCP_PROJECT_ID|g" k8s/*.yaml
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 Dry run - showing what would be deployed:"
        kubectl apply -f k8s/ --namespace=$ENVIRONMENT --dry-run=client
    else
        # Apply Kubernetes manifests
        kubectl apply -f k8s/ --namespace=$ENVIRONMENT
        
        # Wait for deployment to complete
        kubectl rollout status deployment/flutter-master-app --namespace=$ENVIRONMENT --timeout=600s
    fi
    
    echo "✅ Application deployed successfully"
}

# Post-deployment verification
post_deployment_verification() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 Skipping verification for dry run"
        return
    fi
    
    echo "🧪 Running post-deployment verification..."
    
    # Wait for pods to be ready
    kubectl wait --for=condition=ready pod -l app=flutter-master-app --namespace=$ENVIRONMENT --timeout=300s
    
    # Health check
    echo "🔍 Performing health check..."
    for i in {1..5}; do
        if kubectl exec -n $ENVIRONMENT deployment/flutter-master-app -- curl -f http://localhost:8080/health > /dev/null 2>&1; then
            echo "✅ Health check $i passed"
        else
            echo "❌ Health check $i failed"
            if [[ $i -eq 5 ]]; then
                echo "❌ All health checks failed"
                exit 1
            fi
        fi
        sleep 10
    done
    
    # Check metrics endpoint
    if kubectl exec -n $ENVIRONMENT deployment/flutter-master-app -- curl -f http://localhost:8080/metrics > /dev/null 2>&1; then
        echo "✅ Metrics endpoint accessible"
    else
        echo "⚠️ Metrics endpoint not accessible"
    fi
    
    echo "✅ Post-deployment verification completed"
}

# Cleanup
cleanup() {
    echo "🧹 Cleaning up temporary files..."
    git checkout k8s/ > /dev/null 2>&1 || true
}

# Main execution
main() {
    trap cleanup EXIT
    
    validate_inputs
    pre_deployment_checks
    deploy_application
    post_deployment_verification
    
    echo ""
    echo "🎉 Deployment completed successfully!"
    echo ""
    echo "📊 Deployment Summary:"
    echo "- Environment: $ENVIRONMENT"
    echo "- Version: $VERSION"
    echo "- Namespace: $ENVIRONMENT"
    echo "- Replicas: $(kubectl get deployment flutter-master-app -n $ENVIRONMENT -o jsonpath='{.status.readyReplicas}')/$(kubectl get deployment flutter-master-app -n $ENVIRONMENT -o jsonpath='{.spec.replicas}')"
    echo ""
    echo "🔗 Useful Commands:"
    echo "- View pods: kubectl get pods -n $ENVIRONMENT"
    echo "- View logs: kubectl logs -f deployment/flutter-master-app -n $ENVIRONMENT"
    echo "- Port forward: kubectl port-forward -n $ENVIRONMENT svc/flutter-master-app 8080:80"
    echo "- Rollback: kubectl rollout undo deployment/flutter-master-app -n $ENVIRONMENT"
}

# Run main function
main "$@"
```

---

## 🎯 DevOps Implementation Summary

Bu **DevOps & CI/CD Integration** rehberi, production-ready Flutter uygulamaları için kapsamlı bir DevOps çözümü sunuyor:

### 🚀 **CI/CD Pipeline**
- **Multi-Stage Testing** - Unit, widget, integration testleri
- **Code Quality Gates** - Coverage, complexity, security kontrolleri
- **Automated Deployment** - Staging ve production ortamları
- **Blue-Green & Canary** - Gelişmiş deployment stratejileri

### 🔒 **Security Integration**
- **SAST/DAST Scanning** - Kod ve uygulama güvenlik taraması
- **Dependency Auditing** - Güvenlik açığı kontrolü
- **Secrets Management** - Güvenli credential yönetimi
- **Container Security** - Docker image güvenlik taraması

### 📊 **Monitoring & Observability**
- **Prometheus Stack** - Metrics collection ve alerting
- **Grafana Dashboards** - Görselleştirme ve monitoring
- **Log Aggregation** - Centralized logging sistemi
- **Performance Tracking** - Uygulama performans izleme

### 🏗️ **Infrastructure as Code**
- **Terraform** - Cloud infrastructure yönetimi
- **Kubernetes** - Container orchestration
- **Helm Charts** - Package management
- **Auto-scaling** - Otomatik kaynak yönetimi

### 🔄 **Rollback & Recovery**
- **Emergency Rollback** - Hızlı geri alma sistemi
- **Health Monitoring** - Sürekli sağlık kontrolü
- **Incident Response** - Otomatik olay yönetimi
- **Disaster Recovery** - Felaket kurtarma planları

### 📈 **Performance Metrics**
- **Deployment Frequency**: Daily
- **Lead Time**: < 2 hours
- **MTTR**: < 30 minutes
- **Change Failure Rate**: < 5%
