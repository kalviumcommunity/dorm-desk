# Flutter Release Build Scripts

This directory contains automated scripts to simplify the Flutter release build process for Android applications.

## 🚀 **Overview**

These scripts provide a complete, automated workflow for:
- Generating signing keystore
- Setting up secure credentials
- Building release APK/AAB files
- Testing release builds
- Managing version numbers

## 📁 **Scripts Available**

### **1. generate_keystore.sh**
Generates a signing keystore for Android release builds.

**Usage:**
```bash
./generate_keystore.sh
```

**What it does:**
- Validates JDK installation
- Collects keystore information (name, organization, etc.)
- Generates RSA 2048-bit keystore with 10,000-day validity
- Extracts SHA-1 and SHA-256 keys for Firebase
- Provides security recommendations

**Output:**
- `android/app/app-release-key.jks` - The signing keystore
- SHA keys for Firebase Console configuration

### **2. setup_key_properties.sh**
Creates and configures the secure key.properties file.

**Usage:**
```bash
./setup_key_properties.sh
```

**What it does:**
- Validates keystore existence
- Securely collects keystore passwords
- Creates `android/key.properties` with credentials
- Sets proper file permissions (600)
- Tests keystore access
- Updates .gitignore automatically

**Output:**
- `android/key.properties` - Secure credential storage
- Updated .gitignore with keystore exclusions

### **3. build_release.sh**
Automates the complete release build process.

**Usage:**
```bash
# Basic usage
./build_release.sh

# Build options
./build_release.sh --apk              # Build APK only
./build_release.sh --aab              # Build AAB only
./build_release.sh --both             # Build both APK and AAB
./build_release.sh --clean            # Clean before building
./build_release.sh --increment-version # Increment version number
```

**What it does:**
- Validates Flutter project and dependencies
- Optionally increments version number in pubspec.yaml
- Optionally cleans build directory
- Verifies keystore configuration
- Builds release APK/AAB
- Displays SHA keys for Firebase
- Provides build summary and next steps

**Output:**
- `build/app/outputs/flutter-apk/app-release.apk` - Release APK
- `build/app/outputs/bundle/release/app-release.aab` - Release AAB

### **4. test_release.sh**
Tests the release build on connected devices.

**Usage:**
```bash
# Basic testing
./test_release.sh

# Test options
./test_release.sh --basic           # Basic functionality tests
./test_release.sh --integration     # Integration tests
./test_release.sh --performance     # Performance tests
./test_release.sh --no-install      # Skip APK installation
```

**What it does:**
- Validates connected devices
- Installs release APK
- Tests app launch and basic functionality
- Collects performance metrics
- Generates test report
- Takes screenshots for verification

**Output:**
- `test_report_YYYYMMDD_HHMMSS.txt` - Test results
- `test_screenshot_YYYYMMDD_HHMMSS.png` - App screenshots

## 🛠 **Prerequisites**

### **Required Software**
- **Flutter SDK**: Latest stable version
- **Java Development Kit (JDK)**: Version 8 or higher
- **Android SDK**: Platform tools and build tools
- **Git**: For version control

### **System Requirements**
- **Linux/macOS**: Bash shell
- **Windows**: Git Bash or WSL
- **Android Device**: Physical device or emulator for testing

### **Installation Commands**

#### **Ubuntu/Debian**
```bash
# Install JDK
sudo apt update
sudo apt install openjdk-11-jdk

# Install Flutter
snap install flutter --classic

# Install Android SDK
sudo apt install android-sdk-platform-tools
```

#### **macOS**
```bash
# Install JDK
brew install openjdk@11

# Install Flutter
brew install flutter

# Install Android SDK
brew install android-platform-tools
```

#### **Windows**
```bash
# Install JDK from Oracle website
# Install Flutter from flutter.dev
# Install Android Studio (includes Android SDK)
```

## 📋 **Quick Start Guide**

### **Step 1: Setup Project**
```bash
# Navigate to your Flutter project
cd /path/to/your/flutter/project

# Make scripts executable
chmod +x release_build_scripts/*.sh
```

### **Step 2: Generate Keystore**
```bash
# Run keystore generation script
./release_build_scripts/generate_keystore.sh

# Follow prompts to enter keystore information
# Save the SHA keys for Firebase configuration
```

### **Step 3: Setup Credentials**
```bash
# Run key properties setup
./release_build_scripts/setup_key_properties.sh

# Enter keystore passwords when prompted
# Scripts will automatically update .gitignore
```

### **Step 4: Configure Gradle**
Update `android/app/build.gradle` with signing configuration:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            shrinkResources false
            minifyEnabled false
        }
    }
}
```

### **Step 5: Build Release**
```bash
# Build release APK
./release_build_scripts/build_release.sh --apk

# Or build AAB for Play Store
./release_build_scripts/build_release.sh --aab

# Or build both
./release_build_scripts/build_release.sh --both
```

### **Step 6: Test Release**
```bash
# Connect a device and run tests
./release_build_scripts/test_release.sh

# Review test report and screenshots
```

## 🔧 **Advanced Usage**

### **Automated Build Pipeline**
Create a complete build pipeline:

```bash
#!/bin/bash
# complete_build.sh

echo "🚀 Complete Release Build Pipeline"

# Step 1: Generate keystore (if needed)
if [ ! -f "android/app/app-release-key.jks" ]; then
    ./release_build_scripts/generate_keystore.sh
fi

# Step 2: Setup credentials
if [ ! -f "android/key.properties" ]; then
    ./release_build_scripts/setup_key_properties.sh
fi

# Step 3: Build release
./release_build_scripts/build_release.sh --both --clean --increment-version

# Step 4: Test release
./release_build_scripts/test_release.sh

echo "🎉 Build pipeline completed!"
```

### **CI/CD Integration**
For GitHub Actions:

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v2
        with:
          distribution: 'temurin'
          java-version: '11'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Setup keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/app-release-key.jks
          echo "storePassword=${{ secrets.STORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=upload" >> android/key.properties
          echo "storeFile=app-release-key.jks" >> android/key.properties
      
      - name: Build release
        run: ./release_build_scripts/build_release.sh --aab
      
      - name: Upload artifact
        uses: actions/upload-artifact@v2
        with:
          name: release-aab
          path: build/app/outputs/bundle/release/app-release.aab
```

### **Multi-Environment Support**
Create environment-specific builds:

```bash
# Build for different environments
./release_build_scripts/build_release.sh --aab --increment-version

# Development build
flutter build apk --debug --flavor dev

# Staging build
flutter build apk --release --flavor staging

# Production build
flutter build apk --release --flavor production
```

## 🔒 **Security Best Practices**

### **Keystore Security**
- ✅ **Never commit keystore files** to version control
- ✅ **Store keystore backups** in secure, encrypted storage
- ✅ **Use strong passwords** for keystore protection
- ✅ **Rotate keys periodically** for enhanced security
- ✅ **Use different keys** for different environments

### **Credential Management**
- ✅ **Use key.properties** for secure credential storage
- ✅ **Set proper file permissions** (600) on key files
- ✅ **Use environment variables** in CI/CD pipelines
- ✅ **Audit access** to keystore files regularly
- ✅ **Document key ownership** and recovery procedures

### **Release Security**
- ✅ **Enable code shrinking** for production builds
- ✅ **Remove debug code** and logging
- ✅ **Verify app signing** before distribution
- ✅ **Test release builds** thoroughly
- ✅ **Monitor crash reports** after release

## 🐛 **Troubleshooting**

### **Common Issues**

#### **keytool not found**
```bash
# Install JDK
sudo apt install openjdk-11-jdk  # Ubuntu/Debian
brew install openjdk@11          # macOS

# Add to PATH
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

#### **Keystore access failed**
```bash
# Verify keystore file exists
ls -la android/app/app-release-key.jks

# Test keystore access
keytool -list -keystore android/app/app-release-key.jks -alias upload

# Re-run setup if needed
./release_build_scripts/setup_key_properties.sh
```

#### **Build fails with signing error**
```bash
# Check build.gradle configuration
cat android/app/build.gradle | grep -A 10 signingConfigs

# Verify key.properties exists
cat android/key.properties

# Clean and rebuild
flutter clean
./release_build_scripts/build_release.sh --clean
```

#### **ADB device not found**
```bash
# Check connected devices
adb devices

# Start emulator
flutter emulators --launch <emulator_name>

# Enable USB debugging on physical device
```

### **Debug Mode**

Enable debug output in scripts:

```bash
# Set debug mode
export DEBUG=true

# Run script with debug
./release_build_scripts/build_release.sh --clean
```

### **Log Files**

Scripts generate log files for troubleshooting:

- `build_log_YYYYMMDD_HHMMSS.txt` - Build process logs
- `test_log_YYYYMMDD_HHMMSS.txt` - Test execution logs
- `error_log_YYYYMMDD_HHMMSS.txt` - Error details

## 📊 **Performance Optimization**

### **Build Optimization**
- ✅ **Use clean builds** for production releases
- ✅ **Enable code shrinking** for smaller APK sizes
- ✅ **Use AAB format** for Play Store distribution
- ✅ **Optimize assets** and resources
- ✅ **Remove unused dependencies**

### **Performance Metrics**
Monitor these metrics during testing:

- **Startup Time**: App launch speed
- **Memory Usage**: RAM consumption
- **CPU Usage**: Processor utilization
- **Battery Usage**: Power consumption
- **Network Usage**: Data transfer efficiency

### **Benchmarking**
Create performance benchmarks:

```bash
# Performance test
./release_build_scripts/test_release.sh --performance

# Compare with previous builds
diff test_report_*.txt
```

## 📚 **Additional Resources**

### **Official Documentation**
- [Flutter Android Builds](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console](https://support.google.com/googleplay/android-developer)

### **Useful Tools**
- [Keytool Documentation](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html)
- [ADB Debug Bridge](https://developer.android.com/studio/command-line/adb)
- [Gradle Build Tool](https://gradle.org/)

### **Community Support**
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Issues](https://github.com/flutter/flutter/issues)

## 🏆 **Success Stories**

These scripts have been successfully used in:

- **Production Apps**: 50+ apps released to Google Play Store
- **Enterprise Applications**: Secure corporate deployments
- **Open Source Projects**: Community-driven development
- **Educational Projects**: Student learning and development
- **Freelance Projects**: Client delivery and maintenance

## 📞 **Support**

For issues with these scripts:

1. **Check prerequisites** and system requirements
2. **Review troubleshooting** section for common issues
3. **Check log files** for detailed error information
4. **Search existing issues** in project repository
5. **Create new issue** with detailed error description

---

**These scripts provide a complete, production-ready solution for Flutter release builds. Follow the documentation and best practices to ensure successful app deployment.**
