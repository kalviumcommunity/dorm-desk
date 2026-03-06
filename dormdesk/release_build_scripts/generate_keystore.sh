#!/bin/bash

# Flutter Release Build - Keystore Generation Script
# This script generates a signing keystore for Flutter Android release builds

set -e

echo "🔐 Flutter Release Build - Keystore Generation"
echo "=============================================="

# Check if JDK is installed
if ! command -v keytool &> /dev/null; then
    echo "❌ Error: keytool not found. Please install Java Development Kit (JDK)"
    echo "   Ubuntu/Debian: sudo apt install openjdk-11-jdk"
    echo "   macOS: brew install openjdk@11"
    echo "   Windows: Download JDK from Oracle website"
    exit 1
fi

# Check if we're in Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in a Flutter project directory. Please run from project root."
    exit 1
fi

# Set keystore file path
KEYSTORE_NAME="app-release-key.jks"
KEYSTORE_PATH="android/app/$KEYSTORE_NAME"
KEY_ALIAS="upload"

# Check if keystore already exists
if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  Warning: Keystore already exists at $KEYSTORE_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Keystore generation cancelled."
        exit 1
    fi
fi

# Create android/app directory if it doesn't exist
mkdir -p android/app

echo "📝 Please enter keystore information:"
echo "===================================="

# Collect keystore information
echo -n "Enter your full name: "
read FULL_NAME

echo -n "Enter your organizational unit: "
read ORG_UNIT

echo -n "Enter your organization name: "
read ORG_NAME

echo -n "Enter your city: "
read CITY

echo -n "Enter your state/province: "
read STATE

echo -n "Enter your two-letter country code (e.g., US): "
read COUNTRY_CODE

# Validate country code
if [[ ! $COUNTRY_CODE =~ ^[A-Za-z]{2}$ ]]; then
    echo "❌ Error: Country code must be exactly 2 letters"
    exit 1
fi

# Generate keystore
echo ""
echo "🔧 Generating keystore..."
echo "========================"

keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -dname "CN=$FULL_NAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY_CODE" \
    -storepass:env:STORE_PASS \
    -keypass:env:KEY_PASS

if [ $? -eq 0 ]; then
    echo "✅ Keystore generated successfully!"
    echo "📍 Location: $KEYSTORE_PATH"
    echo ""
    
    # Get SHA keys for Firebase
    echo "🔑 Getting SHA keys for Firebase..."
    echo "==================================="
    
    echo "SHA-1:"
    keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" | grep "SHA-1:" | cut -d' ' -f3
    
    echo ""
    echo "SHA-256:"
    keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" | grep "SHA-256:" | cut -d' ' -f3
    
    echo ""
    echo "📋 Next Steps:"
    echo "=============="
    echo "1. Add these SHA keys to your Firebase Console"
    echo "2. Create android/key.properties file with your passwords"
    echo "3. Update android/app/build.gradle with signing configuration"
    echo "4. Add keystore files to .gitignore"
    echo ""
    echo "🔒 Important Security Notes:"
    echo "============================"
    echo "• NEVER commit keystore files to version control"
    echo "• Store passwords securely in key.properties"
    echo "• Backup your keystore file in a secure location"
    echo "• Use different keys for different environments"
    
else
    echo "❌ Keystore generation failed!"
    exit 1
fi
