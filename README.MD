```
# 🏨 DormDesk – Hostel Issue Management System

DormDesk is a Flutter-based mobile application designed to digitize and streamline
hostel issue reporting, tracking, and resolution. It replaces manual complaint
registers with a transparent, role-based, and scalable system for students,
staff, wardens, and administrators.

Repository:
https://github.com/kalviumcommunity/dorm-desk.git

---

## 📌 Problem Statement

College hostel residents face frequent delays when reporting mess issues,
maintenance problems, or facility complaints due to outdated manual systems.
These systems lack transparency, tracking, accountability, and analytics.

---

## 🎯 Solution

DormDesk provides a centralized digital platform where:
- Students can raise and track complaints
- Staff can receive and resolve assigned tasks
- Wardens can monitor, assign, and escalate issues
- Admins can manage rules, announcements, and analytics

---

## ✨ Key Features

### 👤 User Management
- Role-based access (Student, Staff, Warden, Admin)
- Secure authentication
- Profile management

### 🛠 Issue Management
- Raise hostel-related issues
- Category-based complaints
- Priority and status tracking
- Auto/manual assignment
- SLA-based escalation

### 📣 Announcements & Notice Board
- Laundry arrival time notices
- Water shutdown alerts
- Mess updates
- Emergency announcements

### 🍽 Mess & Food Management
- Food feedback and ratings
- Cleanliness reviews
- Food suggestions and improvements

### 📜 Rules & Policies
- Hostel rules
- Mess rules
- Disciplinary guidelines

### 📝 Feedback System
- Post-resolution feedback
- Staff performance ratings
- Anonymous feedback support

### 🔔 Notifications
- Real-time push notifications
- In-app alerts

### 📊 Analytics & Reporting
- Issue resolution metrics
- Staff performance tracking
- Hostel-wise statistics

---

## 🧱 System Architecture

DormDesk follows Clean Architecture with MVVM pattern for scalability and
maintainability.

Presentation Layer (Flutter UI)
        ↓
ViewModel (State Management)
        ↓
Domain Layer (Business Logic)
        ↓
Data Layer (Repositories & Data Sources)

---

## 🗂 Project Structure

lib/
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   ├── errors/
│   └── network/
│
├── features/
│   ├── auth/
│   ├── profile/
│   ├── issues/
│   ├── mess/
│   ├── announcements/
│   ├── rules/
│   ├── feedback/
│   └── notifications/
│
├── routes/
├── app.dart
└── main.dart

---

## 🧑‍💻 Tech Stack

Framework        : Flutter  
Language         : Dart  
State Management : Riverpod  
Backend          : REST APIs  
Local Storage    : Hive / SQLite  
Authentication   : JWT  
Notifications    : Firebase Cloud Messaging  

---

## 📱 Supported Issue Categories

- Room Cleaning
- Plumbing
- Electrical (Fan, Light, AC)
- Furniture Repair (Table, Chair, Cupboard, Bureau)
- Painting & Room Maintenance
- Common Toilet Issues
- Bathroom Issues
- Drainage Problems
- Drinking Water
- Bathing Water
- Laundry Arrival Time
- Mess & Food Complaints
- Improvement Suggestions
- Complaints on Students
- Complaints on Staff
- Complaints on Wardens

---

## 🔐 Security

- JWT-based authentication
- Role-based access control (RBAC)
- Secure local storage
- Input validation
- Audit logging

---

## 📶 Offline Support

- Offline issue creation
- Local caching of issues
- Auto-sync when network is restored

---

## 🚀 Future Enhancements

- Image upload for issues
- QR-based room issue reporting
- AI-based issue categorization
- WhatsApp chatbot integration
- Web admin dashboard
- Multi-hostel support

---

## 🛠 Installation & Setup

git clone https://github.com/kalviumcommunity/dorm-desk.git
cd dorm-desk
flutter pub get
flutter run

---



## 📄 License

This project is licensed under the MIT License.

---

## Multi-Screen Navigation — Sprint 3.16

DormDesk uses Flutter’s Navigator and named routes to enable navigation between Welcome, Login, Signup, and Home screens.

### Routes Setup

Routes are defined in `main.dart`:

```dart
MaterialApp(
  initialRoute: '/welcome',
  routes: {
    '/welcome': (context) => WelcomeScreen(),
    '/login': (context) => LoginScreen(),
    '/signup': (context) => SignupScreen(),
  },
  onGenerateRoute: (settings) {
    if (settings.name == '/home') {
      final uid = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => HomeScreen(uid),
      );
    }
    return null;
  },
);
```

### Navigation Flow

```
WelcomeScreen → LoginScreen → HomeScreen
SignupScreen → HomeScreen
Logout → LoginScreen
```

### Navigator Methods Used

* `Navigator.pushNamed()` – Navigate to another screen
* `Navigator.pushReplacementNamed()` – Replace current screen
* `Navigator.pop()` – Go back
* `onGenerateRoute` – Pass UID to HomeScreen

### Argument Passing Example

```dart
Navigator.pushReplacementNamed(
  context,
  '/home',
  arguments: user.uid,
);
```

### Reflection

Using named routes makes navigation clean, scalable, and easier to manage in larger applications like DormDesk. It also allows safe data transfer between screens.

---

## Responsive Layout Design — Sprint 3.17

A responsive layout was implemented in DormDesk using Flutter’s core layout widgets: Container, Row, and Column. The layout adapts dynamically to different screen sizes, ensuring a consistent user experience across mobile and tablet devices.

---

### Layout Structure

The layout consists of three main sections:

* Header Section — Displays DormDesk title
* Main Content Area — Shows panels using Row (tablet) or Column (mobile)
* Footer / Bottom Panel — Additional UI section

---

### Key Widgets Used

**Container**
Used to define structure, spacing, colors, and alignment.

```dart
Container(
  width: double.infinity,
  height: 120,
  color: Colors.blue,
  child: Center(child: Text("DormDesk Header")),
);
```

**Column**
Used for vertical layout on mobile devices.

```dart
Column(
  children: [
    Container(color: Colors.orange),
    Container(color: Colors.green),
  ],
);
```

**Row**
Used for horizontal layout on larger screens.

```dart
Row(
  children: [
    Expanded(child: Container(color: Colors.orange)),
    Expanded(child: Container(color: Colors.green)),
  ],
);
```

---

### Responsive Logic Using MediaQuery

Screen width is detected and layout adjusts automatically:

```dart
double width = MediaQuery.of(context).size.width;
bool isTablet = width > 600;
```

Mobile → Column layout
Tablet → Row layout

---

### Navigation Integration

The responsive layout is accessible via named route:

```dart
Navigator.pushNamed(context, '/responsive');
```

---

### Screenshots

(Add screenshots here)

* Mobile layout (Column)
* Tablet layout (Row)
* Responsive layout transition

---

### Reflection

Responsive design ensures the application works across multiple screen sizes without layout issues. Using Row, Column, Container, and MediaQuery makes the UI flexible, scalable, and adaptable for real-world deployment.

---
## Scrollable Views with ListView & GridView — Sprint 3.18

This feature demonstrates scrollable layouts in DormDesk using Flutter’s ListView and GridView widgets. These widgets allow efficient display of dynamic and large datasets while maintaining smooth UI performance.

---

### ListView Implementation

ListView.builder is used to display a horizontal scrollable list of hostel-related items.

```dart
SizedBox(
  height: 200,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 10,
    itemBuilder: (context, index) {
      return Container(
        width: 150,
        margin: EdgeInsets.all(8),
        color: Colors.blue,
        child: Center(child: Text("Item $index")),
      );
    },
  ),
)
```

This allows efficient rendering by loading only visible elements.

---

### GridView Implementation

GridView.builder is used to display structured hostel service tiles in a grid layout.

```dart
GridView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemCount: 6,
  itemBuilder: (context, index) {
    return Container(
      margin: EdgeInsets.all(8),
      color: Colors.green,
      child: Center(child: Text("Tile $index")),
    );
  },
)
```

This provides an organized and scalable UI.

---

### Navigation

Scrollable views are integrated using named routes:

```dart
Navigator.pushNamed(context, '/scrollable');
```

---

### Benefits

• Efficient rendering using builder constructors
• Smooth scrolling performance
• Scalable for large datasets
• Organized UI layout
• Improved user experience

---

### Reflection

ListView and GridView improve UI efficiency by rendering only visible items, reducing memory usage and improving performance. Builder constructors are recommended for large datasets because they dynamically generate widgets as needed instead of loading everything at once.

This implementation prepares DormDesk for displaying dynamic hostel issues, notifications, and service dashboards efficiently.
---
## Responsive Design using MediaQuery and LayoutBuilder — Sprint 3.23

Implemented adaptive UI using MediaQuery and LayoutBuilder.

MediaQuery was used to detect screen width and height.

LayoutBuilder was used to switch between mobile and tablet layouts.

Mobile layout uses Column structure.

Tablet layout uses Row structure.

This ensures DormDesk UI adapts smoothly across all screen sizes.

---

## Firebase SDK Integration (FlutterFire CLI)

Firebase was integrated using FlutterFire CLI to enable authentication and Firestore.

Steps performed:

• Installed Firebase CLI and FlutterFire CLI  
• Logged into Firebase  
• Ran flutterfire configure  
• Generated firebase_options.dart  
• Initialized Firebase in main.dart  

Firebase.initializeApp(
 options: DefaultFirebaseOptions.currentPlatform,
);

Result:

Firebase authentication and Firestore services are fully functional in DormDesk.

Benefits:

• Automated configuration  
• Multi-platform support  
• Reduced manual setup errors  

---

## Persistent Login using Firebase Auth

Implemented automatic user session handling using FirebaseAuth.authStateChanges().

AuthGate widget listens to authentication state changes and routes users automatically.

If user is logged in → HomeScreen  
If user is logged out → LoginScreen  

Firebase handles session persistence automatically across app restarts.

No manual storage required.

This ensures seamless and secure user experience.

---