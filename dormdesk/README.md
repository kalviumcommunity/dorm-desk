# dormdesk - Firebase Authentication (Email & Password)

A Flutter project demonstrating comprehensive Firebase Authentication implementation with email and password signup, login, and session management for secure user authentication.

## Learning Objectives Demonstrated

### 1. Understanding Firebase Authentication

#### What is Firebase Authentication?
Firebase Authentication handles user identity for mobile and web apps with secure APIs. It provides enterprise-grade security without building your own authentication backend.

#### Supported Authentication Methods:
- **Email & Password**: Traditional authentication with email credentials
- **Google Sign-In**: OAuth2 integration with Google accounts
- **Phone Number**: SMS-based authentication
- **Social Providers**: Apple, GitHub, Facebook, Twitter
- **Anonymous**: Temporary user sessions
- **Custom**: Build your own authentication system

#### Why Firebase Authentication?
- **Security**: Enterprise-grade security with built-in protection
- **Scalability**: Handles millions of users automatically
- **Cross-Platform**: Works on iOS, Android, Web, and more
- **Real-time**: Instant authentication state synchronization
- **Compliance**: GDPR, CCPA, and other regulations compliant

### 2. Firebase Console Setup

#### Enable Email/Password Authentication
1. **Open Firebase Console**: https://console.firebase.google.com
2. **Navigate to Authentication**: Click "Authentication" in left sidebar
3. **Sign-in Method Tab**: Click "Sign-in method" tab
4. **Enable Email/Password**: Toggle the switch and click "Save"
5. **Configure Settings**: Set password requirements and email templates

#### Key Configuration Options:
- **Password Requirements**: Minimum length, complexity rules
- **Email Templates**: Verification, password reset, welcome emails
- **Rate Limiting**: Prevent brute force attacks
- **Session Management**: Configure session timeout and refresh tokens

### 3. Project Dependencies

#### pubspec.yaml Configuration
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0      # Firebase SDK core
  firebase_auth: ^5.0.0      # Authentication services
  cloud_firestore: ^5.0.0    # Database for user profiles
  cupertino_icons: ^1.0.8     # iOS-style icons
```

#### Dependency Installation
```bash
# Install dependencies
flutter pub get

# Clean and rebuild if needed
flutter clean
flutter pub get
```

### 4. Firebase Initialization

#### main.dart Setup
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/responsive_home.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DormDesk - Firebase Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      home: StreamBuilder<User?>(
        // Listen to authentication state changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // If user is authenticated, show home screen
          if (snapshot.hasData && snapshot.data != null) {
            return const ResponsiveHome();
          }
          
          // If user is not authenticated, show auth screen
          return const AuthScreen();
        },
      ),
    );
  }
}
```

### 5. Authentication Screen Implementation

#### Complete Auth Screen Features
```dart
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  // State variables
  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Authentication submission
  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential;
      
      if (isLogin) {
        // Login existing user
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Create new user
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save user profile to Firestore
        await userCredential.user?.updateDisplayName(_nameController.text.trim());
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      // Show success message and navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLogin ? 'Login Successful!' : 'Account Created Successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResponsiveHome()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      String errorMessage = 'Authentication Error';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please choose a stronger password.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Try again later.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during authentication.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
```

### 6. User State Management

#### Authentication State Listening
```dart
// Stream-based authentication state management
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return const CircularProgressIndicator();
      case ConnectionState.active:
        final user = snapshot.data;
        if (user != null) {
          return HomeScreen(user: user);
        } else {
          return AuthScreen();
        }
      case ConnectionState.none:
        return const AuthScreen();
    }
  },
)
```

#### Current User Access
```dart
// Get current authenticated user
User? currentUser = FirebaseAuth.instance.currentUser;

// Check if user is logged in
if (currentUser != null) {
  print('User is logged in: ${currentUser.email}');
  print('User ID: ${currentUser.uid}');
  print('Display Name: ${currentUser.displayName}');
} else {
  print('No user is currently logged in');
}
```

### 7. User Profile Management

#### Firestore User Profile Storage
```dart
// Save user profile during signup
await _firestore.collection('users').doc(userCredential.user!.uid).set({
  'uid': userCredential.user!.uid,
  'email': _emailController.text.trim(),
  'name': _nameController.text.trim(),
  'createdAt': FieldValue.serverTimestamp(),
  'lastLogin': FieldValue.serverTimestamp(),
  'profilePicture': '', // Optional profile picture URL
  'phone': '', // Optional phone number
  'room': '', // Dorm room assignment
});

// Update user profile
await _firestore.collection('users').doc(currentUser.uid).update({
  'lastLogin': FieldValue.serverTimestamp(),
  'profilePicture': newProfilePictureUrl,
});

// Retrieve user profile
DocumentSnapshot userDoc = await _firestore
    .collection('users')
    .doc(currentUser.uid)
    .get();

if (userDoc.exists) {
  Map<String, dynamic> userData = userDoc.data()!;
  String userName = userData['name'] ?? 'User';
  String userEmail = userData['email'] ?? '';
}
```

### 8. Logout Implementation

#### Secure Logout Process
```dart
Future<void> _logout() async {
  try {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    // Navigation will be handled by StreamBuilder in main.dart
  } catch (e) {
    // Handle logout errors
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

#### Logout Button in UI
```dart
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    // Show confirmation dialog
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirmLogout == true) {
      await _logout();
    }
  },
  tooltip: 'Logout',
)
```

### 9. Error Handling & Validation

#### Common Firebase Auth Errors
```dart
// Comprehensive error handling
switch (e.code) {
  case 'user-not-found':
    // User doesn't exist
    errorMessage = 'No account found with this email address.';
    break;
  case 'wrong-password':
    // Incorrect password
    errorMessage = 'The password is incorrect. Please try again.';
    break;
  case 'email-already-in-use':
    // Email already registered
    errorMessage = 'An account with this email already exists.';
    break;
  case 'weak-password':
    // Password too weak
    errorMessage = 'Password should be at least 6 characters long.';
    break;
  case 'invalid-email':
    // Invalid email format
    errorMessage = 'Please enter a valid email address.';
    break;
  case 'too-many-requests':
    // Rate limiting
    errorMessage = 'Too many failed attempts. Please try again later.';
    break;
  case 'operation-not-allowed':
    // Operation disabled
    errorMessage = 'This operation is not allowed. Please contact support.';
    break;
  case 'user-disabled':
    // Account disabled
    errorMessage = 'This account has been disabled. Please contact support.';
    break;
  default:
    // Unknown error
    errorMessage = e.message ?? 'An authentication error occurred.';
}
```

#### Form Validation Examples
```dart
// Email validation with regex
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  
  // Basic email format validation
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  
  return null;
}

// Password validation
String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  
  // Optional: Add complexity requirements
  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$').hasMatch(value)) {
    return 'Password should contain letters and numbers';
  }
  
  return null;
}
```

### 10. Security Best Practices

#### Password Security
```dart
// Enforce strong passwords
bool _isPasswordStrong(String password) {
  // Minimum 8 characters
  if (password.length < 8) return false;
  
  // Contains uppercase letter
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  
  // Contains lowercase letter
  if (!password.contains(RegExp(r'[a-z]'))) return false;
  
  // Contains number
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  
  // Contains special character
  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
  
  return true;
}
```

#### Session Management
```dart
// Handle user session persistence
await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

// Check current persistence setting
Persistence persistence = await FirebaseAuth.instance.getPersistence();

// Clear user session (for testing)
await FirebaseAuth.instance.signOut();
```

#### Rate Limiting
```dart
// Implement rate limiting for failed attempts
int _failedAttempts = 0;
DateTime? _lastAttemptTime;

bool _isRateLimited() {
  if (_lastAttemptTime != null) {
    final timeSinceLastAttempt = DateTime.now().difference(_lastAttemptTime!);
    if (timeSinceLastAttempt.inMinutes < 5 && _failedAttempts >= 5) {
      return true; // Rate limited
    }
  }
  return false;
}
```

### 11. Testing & Verification

#### Authentication Testing Checklist
- [ ] User can create new account with valid email/password
- [ ] User can login with existing credentials
- [ ] Invalid email shows appropriate error message
- [ ] Invalid password shows appropriate error message
- [ ] Duplicate email registration is prevented
- [ ] User profile is saved to Firestore
- [ ] Authentication state persists across app restarts
- [ ] Logout functionality works correctly
- [ ] Loading states show during authentication
- [ ] Error messages are user-friendly

#### Firebase Console Verification
1. **Navigate to Firebase Console**: https://console.firebase.google.com
2. **Go to Authentication**: Click "Authentication" in sidebar
3. **Check Users Tab**: View registered users list
4. **Verify User Data**: Confirm user profiles are stored correctly
5. **Monitor Usage**: Check authentication metrics and errors

#### Test Scenarios
```dart
// Test case examples
void _runAuthenticationTests() {
  // Test valid signup
  test('Valid user signup', () async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
    );
    expect(result.user, isNotNull);
  });

  // Test invalid login
  test('Invalid login attempt', () async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: 'invalid@example.com',
        password: 'wrongpassword',
      );
      fail('Should have thrown an exception');
    } on FirebaseAuthException catch (e) {
      expect(e.code, equals('user-not-found'));
    }
  });

  // Test password strength
  test('Password validation', () {
    expect(_validatePassword('123'), isNotNull); // Too short
    expect(_validatePassword('strongpassword'), isNull); // Valid
  });
}
```

## App Features Demonstrating Firebase Authentication

### 1. **Complete Authentication Flow**
- **User Registration**: Email/password signup with validation
- **User Login**: Secure authentication with error handling
- **Session Management**: Persistent authentication state
- **User Profiles**: Firestore integration for user data
- **Logout Functionality**: Secure sign-out with confirmation

### 2. **Professional UI/UX**
- **Form Validation**: Real-time validation feedback
- **Loading States**: Visual indicators during operations
- **Error Messages**: User-friendly error descriptions
- **Responsive Design**: Works on all screen sizes
- **Material Design 3**: Modern, consistent theming

### 3. **Security Features**
- **Password Requirements**: Enforced minimum strength
- **Email Validation**: Proper format checking
- **Rate Limiting**: Prevent brute force attacks
- **Secure Storage**: Encrypted data transmission
- **Session Management**: Proper token handling

### 4. **Error Handling**
- **Comprehensive Coverage**: All Firebase auth errors handled
- **User-Friendly Messages**: Clear, actionable error text
- **Graceful Failures**: App continues working during errors
- **Logging**: Proper error tracking and debugging

## Authentication Flow Examples

### Before Firebase Auth (Basic Form)
```dart
// Basic form without authentication
Scaffold(
  body: Column(
    children: [
      TextField(decoration: InputDecoration(labelText: 'Email')),
      TextField(decoration: InputDecoration(labelText: 'Password')),
      ElevatedButton(
        onPressed: () => print('Login clicked'),
        child: Text('Login'),
      ),
    ],
  ),
)
```

### After Firebase Auth (Complete System)
```dart
// Complete authentication system
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      return ResponsiveHome(); // Authenticated user
    }
    return AuthScreen(); // Unauthenticated user
  },
)
```

## Video Explanation

*[Link to your 1-2 minute Firebase Authentication video here]*

## Getting Started

This project demonstrates comprehensive Firebase Authentication implementation in Flutter applications.

For help getting started with Firebase Authentication:
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Flutter Firebase Auth Guide](https://firebase.google.com/docs/auth/flutter/start)
- [Firebase Console Setup](https://console.firebase.google.com)

## Key Learnings

### How Firebase Simplifies Authentication Management
- **No Backend Required**: Firebase handles all authentication infrastructure
- **Security Built-in**: Enterprise-grade security without implementation effort
- **Scalable Architecture**: Handles millions of users automatically
- **Cross-Platform Support**: Same code works on iOS, Android, Web
- **Real-time State**: Instant authentication state synchronization across devices

### Security Features Better Than Custom Systems
- **Encryption**: All data transmission uses industry-standard encryption
- **Compliance**: GDPR, CCPA, and other regulations automatically handled
- **Rate Limiting**: Built-in protection against brute force attacks
- **Token Management**: Secure JWT token handling and refresh
- **Audit Logs**: Comprehensive authentication event logging
- **Multi-Factor Support**: Easy integration with 2FA systems

### Challenges Faced During Implementation
1. **Firebase Configuration**: Initial setup required careful console configuration
2. **Error Handling**: Comprehensive coverage of all Firebase auth error codes
3. **State Management**: Proper StreamBuilder implementation for auth state
4. **Form Validation**: Client-side validation before Firebase calls
5. **User Experience**: Loading states and error messages for better UX
6. **Testing**: End-to-end testing of complete authentication flow

### Best Practices for Production
- **Input Validation**: Always validate on client-side before Firebase calls
- **Error Messages**: Provide clear, actionable error descriptions
- **Loading States**: Show visual feedback during authentication operations
- **Security**: Enforce strong password requirements and rate limiting
- **User Profiles**: Store additional user data in Firestore for personalization
- **Testing**: Comprehensive testing of all authentication scenarios
- **Documentation**: Clear setup instructions and API documentation
