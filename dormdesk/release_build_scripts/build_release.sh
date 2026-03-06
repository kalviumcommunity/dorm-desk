#!/bin/bash

# Flutter Release Build - Automated Build Script
# This script handles the complete release build process for Flutter Android apps

set -e

echo "🚀 Flutter Release Build - Automated Build Process"
echo "================================================="

# Check if we're in Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in a Flutter project directory. Please run from project root."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter not found. Please install Flutter SDK"
    exit 1
fi

# Check if keystore and key.properties exist
KEYSTORE_PATH="android/app/app-release-key.jks"
KEY_PROPERTIES_PATH="android/key.properties"

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Error: Keystore not found at $KEYSTORE_PATH"
    echo "   Please run generate_keystore.sh first."
    exit 1
fi

if [ ! -f "$KEY_PROPERTIES_PATH" ]; then
    echo "❌ Error: key.properties not found at $KEY_PROPERTIES_PATH"
    echo "   Please run setup_key_properties.sh first."
    exit 1
fi

# Parse command line arguments
BUILD_TYPE="apk"
CLEAN_BUILD=false
INCREMENT_VERSION=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --apk)
            BUILD_TYPE="apk"
            shift
            ;;
        --aab)
            BUILD_TYPE="aab"
            shift
            ;;
        --both)
            BUILD_TYPE="both"
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        --increment-version)
            INCREMENT_VERSION=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --apk              Build APK (default)"
            echo "  --aab              Build AAB (Android App Bundle)"
            echo "  --both             Build both APK and AAB"
            echo "  --clean            Clean build directory before building"
            echo "  --increment-version Increment version number"
            echo "  --help             Show this help message"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for available options"
            exit 1
            ;;
    esac
done

# Display build configuration
echo "📋 Build Configuration:"
echo "====================="
echo "Build Type: $BUILD_TYPE"
echo "Clean Build: $CLEAN_BUILD"
echo "Increment Version: $INCREMENT_VERSION"
echo ""

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2)
echo "📱 Current Version: $CURRENT_VERSION"

# Increment version if requested
if [ "$INCREMENT_VERSION" = true ]; then
    echo "🔄 Incrementing version..."
    
    # Extract version number and build number
    VERSION_PART=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
    BUILD_PART=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)
    
    # Increment build number
    NEW_BUILD=$((BUILD_PART + 1))
    NEW_VERSION="$VERSION_PART+$NEW_BUILD"
    
    echo "📝 New Version: $NEW_VERSION"
    
    # Update pubspec.yaml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    else
        # Linux
        sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    fi
    
    echo "✅ Version updated in pubspec.yaml"
fi

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo "🧹 Cleaning build directory..."
    flutter clean
    echo "✅ Build directory cleaned"
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo "✅ Dependencies updated"

# Check build configuration
echo "🔍 Verifying build configuration..."
echo "=================================="

# Check if build.gradle has signing configuration
BUILD_GRADLE="android/app/build.gradle"
if ! grep -q "signingConfigs" "$BUILD_GRADLE"; then
    echo "⚠️  Warning: signingConfigs not found in build.gradle"
    echo "   Please ensure build.gradle is properly configured for release signing"
fi

# Test keystore access
echo "🔑 Testing keystore access..."
if keytool -list -keystore "$KEYSTORE_PATH" -alias upload > /dev/null 2>&1; then
    echo "✅ Keystore access verified"
else
    echo "❌ Error: Keystore access failed. Please check key.properties"
    exit 1
fi

# Build function
build_release() {
    local build_type=$1
    echo ""
    echo "🔨 Building $build_type..."
    echo "========================="
    
    case $build_type in
        "apk")
            flutter build apk --release
            APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
            if [ -f "$APK_PATH" ]; then
                APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
                echo "✅ APK built successfully!"
                echo "📍 Location: $APK_PATH"
                echo "📏 Size: $APK_SIZE"
                
                # Get SHA keys for reference
                echo ""
                echo "🔑 SHA Keys (for Firebase):"
                echo "=========================="
                echo "SHA-1:"
                keytool -list -v -keystore "$KEYSTORE_PATH" -alias upload | grep "SHA-1:" | cut -d' ' -f3
                echo ""
                echo "SHA-256:"
                keytool -list -v -keystore "$KEYSTORE_PATH" -alias upload | grep "SHA-256:" | cut -d' ' -f3
            else
                echo "❌ APK build failed"
                exit 1
            fi
            ;;
        "aab")
            flutter build appbundle --release
            AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
            if [ -f "$AAB_PATH" ]; then
                AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
                echo "✅ AAB built successfully!"
                echo "📍 Location: $AAB_PATH"
                echo "📏 Size: $AAB_SIZE"
                
                # Get SHA keys for reference
                echo ""
                echo "🔑 SHA Keys (for Firebase):"
                echo "=========================="
                echo "SHA-1:"
                keytool -list -v -keystore "$KEYSTORE_PATH" -alias upload | grep "SHA-1:" | cut -d' ' -f3
                echo ""
                echo "SHA-256:"
                keytool -list -v -keystore "$KEYSTORE_PATH" -alias upload | grep "SHA-256:" | cut -d' ' -f3
            else
                echo "❌ AAB build failed"
                exit 1
            fi
            ;;
    esac
}

# Execute build based on type
case $BUILD_TYPE in
    "apk")
        build_release "apk"
        ;;
    "aab")
        build_release "aab"
        ;;
    "both")
        build_release "apk"
        echo ""
        build_release "aab"
        ;;
esac

echo ""
echo "🎉 Build process completed successfully!"
echo "====================================="

# Display final information
echo "📋 Build Summary:"
echo "================"
echo "Build Type: $BUILD_TYPE"
echo "Version: $(grep '^version:' pubspec.yaml | cut -d' ' -f2)"

if [ "$BUILD_TYPE" = "apk" ] || [ "$BUILD_TYPE" = "both" ]; then
    echo "APK Path: build/app/outputs/flutter-apk/app-release.apk"
fi

if [ "$BUILD_TYPE" = "aab" ] || [ "$BUILD_TYPE" = "both" ]; then
    echo "AAB Path: build/app/outputs/bundle/release/app-release.aab"
fi

echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Test the build on a physical device:"
if [ "$BUILD_TYPE" = "apk" ] || [ "$BUILD_TYPE" = "both" ]; then
    echo "   adb install build/app/outputs/flutter-apk/app-release.apk"
fi
echo ""
echo "2. Upload to Google Play Console (for AAB):"
if [ "$BUILD_TYPE" = "aab" ] || [ "$BUILD_TYPE" = "both" ]; then
    echo "   Upload build/app/outputs/bundle/release/app-release.aab"
fi
echo ""
echo "3. Add SHA keys to Firebase Console if not already done"
echo "4. Test all functionality in release mode"
echo "5. Monitor crash reports after release"

echo ""
echo "🔒 Security Reminder:"
echo "===================="
echo "• Keep your keystore file (.jks) secure and backed up"
echo "• Never commit keystore files to version control"
echo "• Store passwords in a secure location"
echo "• Consider using Google Play App Signing for production"
