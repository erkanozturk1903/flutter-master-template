#!/bin/bash

# 🚀 Flutter Master Template Setup Script
# This script sets up a new Flutter project from the template

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                🚀 Flutter Master Template Setup             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Main setup function
setup_project() {
    local project_name=$1
    local package_name=$2
    
    print_header
    
    if [ -z "$project_name" ]; then
        print_error "Project name is required!"
        echo "Usage: ./setup-new-project.sh <project_name> <package_name>"
        echo "Example: ./setup-new-project.sh MyAwesomeApp com.company.myawesomeapp"
        exit 1
    fi
    
    if [ -z "$package_name" ]; then
        print_warning "Package name not provided, using default pattern"
        package_name="com.example.$(echo $project_name | tr '[:upper:]' '[:lower:]')"
    fi
    
    print_info "Setting up Flutter project: $project_name"
    print_info "Package name: $package_name"
    echo ""
    
    # Check if template directory exists
    if [ ! -d "template" ]; then
        print_error "Template directory not found! Make sure you're in the root of the flutter-master-template repository."
        exit 1
    fi
    
    # Copy template files
    print_info "Copying template files..."
    cp -r template/* . 2>/dev/null || true
    cp template/.* . 2>/dev/null || true  # Copy hidden files
    print_success "Template files copied"
    
    # Update pubspec.yaml
    print_info "Updating pubspec.yaml..."
    if [ -f "pubspec.yaml" ]; then
        sed -i.bak "s/flutter_master_template/$project_name/g" pubspec.yaml
        sed -i.bak "s/com\.example\.template/$package_name/g" pubspec.yaml
        rm pubspec.yaml.bak 2>/dev/null || true
        print_success "pubspec.yaml updated"
    fi
    
    # Update Android configuration
    print_info "Updating Android configuration..."
    if [ -d "android" ]; then
        # Update build.gradle
        find android -name "build.gradle" -exec sed -i.bak "s/com\.example\.template/$package_name/g" {} \;
        
        # Update AndroidManifest.xml
        find android -name "AndroidManifest.xml" -exec sed -i.bak "s/com\.example\.template/$package_name/g" {} \;
        
        # Update MainActivity
        find android -name "MainActivity.kt" -exec sed -i.bak "s/com\.example\.template/$package_name/g" {} \;
        find android -name "MainActivity.java" -exec sed -i.bak "s/com\.example\.template/$package_name/g" {} \;
        
        # Clean up backup files
        find android -name "*.bak" -delete 2>/dev/null || true
        print_success "Android configuration updated"
    fi
    
    # Update iOS configuration
    print_info "Updating iOS configuration..."
    if [ -d "ios" ]; then
        # Update project.pbxproj
        if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
            sed -i.bak "s/com\.example\.template/$package_name/g" ios/Runner.xcodeproj/project.pbxproj
            rm ios/Runner.xcodeproj/project.pbxproj.bak 2>/dev/null || true
        fi
        
        # Update Info.plist
        if [ -f "ios/Runner/Info.plist" ]; then
            sed -i.bak "s/flutter_master_template/$project_name/g" ios/Runner/Info.plist
            rm ios/Runner/Info.plist.bak 2>/dev/null || true
        fi
        
        print_success "iOS configuration updated"
    fi
    
    # Update main.dart
    print_info "Updating main.dart..."
    if [ -f "lib/main.dart" ]; then
        sed -i.bak "s/Flutter Master Template/$project_name/g" lib/main.dart
        rm lib/main.dart.bak 2>/dev/null || true
        print_success "main.dart updated"
    fi
    
    # Remove template-specific files
    print_info "Cleaning up template files..."
    rm -rf template/ 2>/dev/null || true
    rm -f scripts/setup-new-project.sh 2>/dev/null || true
    print_success "Template files cleaned up"
    
    # Initialize git repository
    print_info "Initializing Git repository..."
    if [ -d ".git" ]; then
        rm -rf .git
    fi
    git init
    git add .
    git commit -m "🎉 Initial commit from Flutter Master Template

✨ Project: $project_name
📦 Package: $package_name
🚀 Generated from: https://github.com/erkanozturk1903/flutter-master-template"
    print_success "Git repository initialized"
    
    # Final instructions
    echo ""
    print_success "🎉 Project setup completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1️⃣  Run: flutter pub get"
    echo "  2️⃣  Run: flutter run"
    echo "  3️⃣  Read: docs/01-project-architecture.md"
    echo "  4️⃣  Start coding! 🚀"
    echo ""
    print_info "Documentation: https://github.com/erkanozturk1903/flutter-master-template/tree/main/docs"
    echo ""
}

# Run setup
setup_project $1 $2
