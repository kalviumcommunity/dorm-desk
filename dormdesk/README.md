# dormdesk - Complete Authentication Flow

A Flutter project demonstrating complete Firebase Authentication flow with sign up, login, and logout functionality using StreamBuilder for real-time navigation.

## Authentication Flow Overview

### Complete Flow Implementation
1. **User Signs Up** → Account created in Firebase Auth + Firestore profile
2. **User Logs In** → Firebase returns authenticated session
3. **App Listens to Auth State** → StreamBuilder determines screen to show
4. **User Logs Out** → Session cleared → Auto-redirect to login screen

### Key Components
- **StreamBuilder**: Real-time auth state listening in main.dart
- **AuthScreen**: Toggle between signup/login modes
- **HomeScreen**: Authenticated user dashboard with logout
- **Firebase Auth**: Session management and user operations
- **Firestore**: User profile storage and metadata

## Implementation Details

### 1. StreamBuilder Navigation (main.dart)
```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    
    if (snapshot.hasData && snapshot.data != null) {
      return HomeScreen(user: snapshot.data!);
    }
    
    return const AuthScreen();
  },
)
```

### 2. Sign Up Logic
```dart
// Create user account
userCredential = await _auth.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Save profile to Firestore
await _firestore.collection('users').doc(userCredential.user!.uid).set({
  'uid': userCredential.user!.uid,
  'email': email,
  'name': name,
  'createdAt': FieldValue.serverTimestamp(),
  'lastLogin': FieldValue.serverTimestamp(),
});
```

### 3. Login Logic
```dart
// Authenticate existing user
userCredential = await _auth.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Update last login timestamp
await _firestore.collection('users').doc(userCredential.user!.uid).update({
  'lastLogin': FieldValue.serverTimestamp(),
});
```

### 4. Logout Logic
```dart
// Clear Firebase session
await FirebaseAuth.instance.signOut();

// StreamBuilder automatically redirects to AuthScreen
```

## Features Implemented

### AuthScreen Features
- **Toggle Mode**: Switch between signup and login
- **Form Validation**: Real-time email/password validation
- **Error Handling**: Comprehensive Firebase error coverage
- **Loading States**: Visual feedback during operations
- **Password Reset**: Email-based password recovery
- **Remember Me**: Checkbox for user convenience

### HomeScreen Features
- **User Display**: Show email and user ID
- **Profile Details**: Dialog with complete user info
- **Logout Button**: Secure session termination
- **Success Feedback**: Confirmation messages

### Error Handling
- **user-not-found**: No account with this email
- **wrong-password**: Incorrect password
- **email-already-in-use**: Account exists
- **weak-password**: Password too short
- **invalid-email**: Bad email format
- **too-many-requests**: Rate limiting active

## Testing Checklist

### End-to-End Flow
- [ ] User can create new account
- [ ] User appears in Firebase Console
- [ ] App navigates to HomeScreen on signup
- [ ] User can login with existing credentials
- [ ] Logout returns to AuthScreen
- [ ] Session persists across app restart
- [ ] Error messages display correctly
- [ ] Form validation works properly

### Firebase Console Verification
1. Navigate to Firebase Console → Authentication → Users
2. Verify new users appear after signup
3. Check user profile data in Firestore
4. Monitor authentication metrics

## Screenshots Required

### AuthScreen UI
- Show signup mode with name field
- Show login mode without name field
- Display validation errors
- Show loading state

### HomeScreen UI
- Show welcome message with user email
- Display user profile dialog
- Show logout button

### Firebase Console
- Users table with registered accounts
- User profile data in Firestore

## Reflection Questions

### What was the hardest part of building the flow?
- **StreamBuilder Integration**: Managing auth state changes and automatic navigation
- **Error Handling**: Comprehensive coverage of all Firebase error codes
- **Form Validation**: Real-time validation with proper user feedback
- **Session Management**: Ensuring proper cleanup and persistence

### How does StreamBuilder simplify navigation?
- **Automatic Detection**: No manual routing checks needed
- **Real-time Updates**: Instant UI updates on auth changes
- **Clean Architecture**: Single source of truth for navigation
- **State Management**: Eliminates manual state tracking

### Why is logout essential for session security?
- **Data Protection**: Clears sensitive user data from device
- **Session Termination**: Prevents unauthorized access
- **Resource Cleanup**: Frees up Firebase connections
- **User Privacy**: Ensures complete sign-out on shared devices
- **Security Best Practice**: Follows authentication security standards

## Getting Started

1. **Enable Email/Password Auth** in Firebase Console
2. **Install Dependencies**: `flutter pub get`
3. **Run App**: `flutter run`
4. **Test Flow**: Complete signup → login → logout cycle

## Key Learnings

### Authentication Architecture
- **Stream-based Navigation**: Real-time auth state management
- **Separation of Concerns**: Clear screen responsibilities
- **Error Recovery**: Graceful handling of all failure cases
- **User Experience**: Smooth transitions and feedback

### Firebase Integration
- **Auth SDK**: Complete authentication operations
- **Firestore Integration**: User profile management
- **Error Codes**: Proper error handling and user feedback
- **Session Management**: Automatic state persistence
