# Flutter Project Folder Structure — DormDesk

## Introduction

A Flutter project follows a structured folder layout that separates application logic, platform-specific configuration, assets, and tests. Understanding this structure helps maintain clean code organization, improves scalability, and supports team collaboration.

This document explains the purpose of the major folders and files in the DormDesk Flutter project.

---

## Core Folder Overview

### lib/

Main source code folder of the Flutter app.

Contains all Dart code including UI screens, widgets, models, and business logic.

Key file:

* **main.dart** — entry point of the Flutter application

Project organization example:

```
lib/
 ┣ main.dart
 ┣ screens/
 ┣ widgets/
 ┣ services/
 ┗ models/
```

---

### android/

Contains Android-specific build configuration and native setup.

Used when Flutter builds the Android version of the app.

Important files:

* android/app/build.gradle — Android build configuration
* AndroidManifest.xml — permissions and app metadata

---

### ios/

Contains iOS-specific build configuration for Xcode.

Used when building the iOS version of the app.

Important file:

* ios/Runner/Info.plist — iOS app permissions and metadata

---

### assets/

Developer-created folder for static resources.

Stores:

* images
* icons
* fonts
* JSON files

Assets must be declared in **pubspec.yaml** to be used by Flutter.

---

### test/

Contains automated test files.

Default file:

* widget_test.dart — sample widget test

Used for unit and widget testing.

---

## Important Root Files

### pubspec.yaml

Main configuration file of a Flutter project.

Used for:

* dependency management
* asset registration
* fonts
* environment constraints
* package metadata

---

### README.md

Project documentation file.

Contains:

* setup steps
* feature overview
* sprint documentation
* usage instructions

---

### .gitignore

Defines which files Git should ignore.

Prevents committing:

* build outputs
* IDE configs
* temporary files

---

## Generated Folders (Do Not Edit)

### build/

Contains compiled build outputs.
Auto-generated during builds.

---

### .dart_tool/

Dart and Flutter internal tooling data.

---

### .idea / .vscode

IDE configuration folders.

---

## Why This Structure Matters

* Separates platform code from Flutter code
* Keeps UI and logic organized
* Makes features modular
* Helps teams work on different layers safely
* Supports scaling large apps
* Reduces merge conflicts

A clean structure allows multiple developers to work on screens, services, and features without interfering with each other.

---

## Conclusion

Understanding the Flutter folder structure makes development faster, cleaner, and more maintainable. It provides a predictable layout for adding features, assets, and platform configurations as the DormDesk app grows.
