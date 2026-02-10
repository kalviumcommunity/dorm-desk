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


