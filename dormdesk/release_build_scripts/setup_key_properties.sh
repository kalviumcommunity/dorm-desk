#!/bin/bash

# Flutter Release Build - Key Properties Setup Script
# This script creates and configures the key.properties file for secure keystore credentials

set -e

echo "🔐 Flutter Release Build - Key Properties Setup"
echo "==============================================="

# Check if we're in Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in a Flutter project directory. Please run from project root."
    exit 1
fi

# Check if keystore exists
KEYSTORE_PATH="android/app/app-release-key.jks"
if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Error: Keystore not found at $KEYSTORE_PATH"
    echo "   Please run generate_keystore.sh first."
    exit 1
fi

# Key properties file path
KEY_PROPERTIES_PATH="android/key.properties"

# Check if key.properties already exists
if [ -f "$KEY_PROPERTIES_PATH" ]; then
    echo "⚠️  Warning: key.properties already exists at $KEY_PROPERTIES_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled."
        exit 1
    fi
fi

# Create android directory if it doesn't exist
mkdir -p android

echo "📝 Please enter keystore credentials:"
echo "=================================="

# Securely get store password
echo -n "Enter keystore store password: "
read -s STORE_PASS
echo

echo -n "Enter keystore key password: "
read -s KEY_PASS
echo

# Validate passwords
if [ -z "$STORE_PASS" ] || [ -z "$KEY_PASS" ]; then
    echo "❌ Error: Passwords cannot be empty"
    exit 1
fi

# Create key.properties file
echo "🔧 Creating key.properties file..."
echo "================================="

cat > "$KEY_PROPERTIES_PATH" << EOF
# Keystore Configuration
# This file contains sensitive information and should NOT be committed to version control
storePassword=$STORE_PASS
keyPassword=$KEY_PASS
keyAlias=upload
storeFile=app-release-key.jks
EOF

# Set file permissions
chmod 600 "$KEY_PROPERTIES_PATH"

echo "✅ key.properties created successfully!"
echo "📍 Location: $KEY_PROPERTIES_PATH"
echo ""

# Test keystore access
echo "🔑 Testing keystore access..."
echo "============================"

if keytool -list -keystore "$KEYSTORE_PATH" -alias upload -storepass "$STORE_PASS" -keypass "$KEY_PASS" > /dev/null 2>&1; then
    echo "✅ Keystore access verified successfully!"
else
    echo "❌ Error: Keystore access failed. Please check your passwords."
    rm "$KEY_PROPERTIES_PATH"
    exit 1
fi

echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Update .gitignore to exclude keystore files"
echo "2. Update android/app/build.gradle with signing configuration"
echo "3. Test release build with: flutter build apk --release"
echo ""

# Update .gitignore automatically
echo "🔒 Updating .gitignore..."
echo "======================"

GITIGNORE_FILE=".gitignore"

# Add keystore files to .gitignore if not already present
if ! grep -q "android/key.properties" "$GITIGNORE_FILE" 2>/dev/null; then
    echo "" >> "$GITIGNORE_FILE"
    echo "# Keystore files (NEVER commit these)" >> "$GITIGNORE_FILE"
    echo "android/key.properties" >> "$GITIGNORE_FILE"
    echo "android/app/app-release-key.jks" >> "$GITIGNORE_FILE"
    echo "✅ Added keystore files to .gitignore"
else
    echo "✅ Keystore files already in .gitignore"
fi

echo ""
echo "🔒 Security Reminder:"
echo "===================="
echo "• key.properties contains sensitive passwords"
echo "• This file should NEVER be committed to version control"
echo "• Store a backup of your keystore file in a secure location"
echo "• Use different passwords for production and development"
