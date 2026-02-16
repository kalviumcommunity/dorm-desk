# dormdesk - Flutter Authentication App

A Flutter project demonstrating core architecture concepts including widget tree, reactive rendering, and Dart language fundamentals.

## Learning Objectives Demonstrated

### 1. Flutter's Architecture
This app demonstrates Flutter's three-layer architecture:
- **Framework Layer**: Written in Dart, using Material widgets and rendering libraries
- **Engine Layer**: C++ Skia engine for pixel-perfect rendering across platforms  
- **Embedder Layer**: Platform integration for Android/iOS deployment

### 2. Widget Tree Implementation

#### StatelessWidget vs StatefulWidget

**StatelessWidget** - Used for static UI components:
```dart
class LoginScreen extends StatelessWidget {
  // Static UI that doesn't change based on user interaction
  // Email/password fields, buttons, etc.
}
```

**StatefulWidget** - Used for dynamic UI that updates:
```dart
class HomeScreen extends StatefulWidget {
  // Dynamic UI with state changes
  // Notes list, user interactions, etc.
}
```

### 3. Dart Language Essentials Demonstrated

#### Classes & Objects
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Object-oriented design for authentication
}
```

#### Async/Await
```dart
Future<User?> login(String email, String password) async {
  final cred = await _auth.signInWithEmailAndPassword(
    email: email, password: password,
  );
  return cred.user;
}
```

#### Null Safety
```dart
if (user != null && context.mounted) {
  Navigator.pushReplacement(context, MaterialPageRoute(...));
}
```

#### Type Inference
```dart
final user = await auth.login(email, password);
// Dart infers User? type automatically
```

### 4. Reactive UI Implementation

The app demonstrates Flutter's reactive pattern through:

**setState() Pattern**: When user data changes, the UI automatically re-renders
```dart
onPressed: () async {
  final user = await auth.login(email, password);
  if (user != null && context.mounted) {
    Navigator.pushReplacement(...); // Triggers UI rebuild
  }
}
```

**StreamBuilder**: Real-time updates from Firestore
```dart
StreamBuilder(
  stream: firestore.getNotes(uid),
  builder: (context, snapshot) {
    // UI automatically updates when data changes
  },
)
```

## Why Dart is Ideal for Flutter

1. **Compiled to Native ARM/x86**: Fast performance
2. **Strong Typing with Type Inference**: Safety + productivity
3. **Async/Await Support**: Perfect for mobile app operations
4. **Null Safety**: Prevents runtime crashes
5. **JIT & AOT Compilation**: Fast development + fast deployment

## App Features Demonstrating Concepts

1. **Authentication Flow**: Shows state management and async operations
2. **Real-time Data**: StreamBuilder demonstrates reactive updates
3. **Navigation**: Widget tree transitions between screens
4. **Form Handling**: User input with validation
5. **Firebase Integration**: Platform channel communication

## Screenshots

*Add screenshots of your app running on Android/iOS here*

## Video Explanation

*[Link to your 3-5 minute video explanation here]*

## Getting Started

This project is a starting point for understanding Flutter's core concepts.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
