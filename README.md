# 📚 Smart Attendance Management System

A comprehensive Flutter-based attendance management system designed for educational institutions, featuring role-based access, QR code attendance, analytics, and multi-modal attendance tracking.

## 🚀 Features

### 👥 Multi-Role Support
- **Students**: QR scanning, attendance history, exception requests
- **Teachers**: Session management, analytics, roster management
- **Administrators**: User management, system oversight, reports
- **Counsellors**: Student support, attendance monitoring

### 📱 Core Functionality

#### 🎯 QR Code Attendance System
- **Dynamic QR Generation**: Teachers generate rotating QR codes every 30 seconds
- **Secure Scanning**: Students scan live QR codes for attendance
- **Location Verification**: GPS-based attendance validation
- **Multi-Modal Options**: QR, NFC, Bluetooth, and manual attendance

#### 📊 Analytics & Reporting
- Real-time attendance analytics
- Student performance tracking
- Attendance trend analysis
- CSV export functionality
- Risk assessment for at-risk students

#### 🔐 Security Features
- Role-based authentication
- Location-based attendance validation
- WiFi network verification
- QR code rotation for security
- Session-based attendance tracking

## 🏗️ Architecture

### 📁 Project Structure
```
management_app/
├── lib/
│   ├── core/                 # Core functionality
│   │   ├── router.dart       # App navigation
│   │   └── constants.dart    # App constants
│   ├── models/              # Data models
│   │   ├── user.dart
│   │   ├── attendance_record.dart
│   │   └── session.dart
│   ├── services/            # Business logic
│   │   ├── firebase_service.dart
│   │   ├── analytics_service.dart
│   │   ├── qr_service.dart
│   │   └── location_security_service.dart
│   ├── providers/           # State management
│   │   └── auth_provider.dart
│   ├── screens/            # UI screens
│   │   ├── student/
│   │   ├── teacher/
│   │   ├── admin/
│   │   └── counsellor/
│   └── widgets/            # Reusable components
└── README.md
```

### 🔧 Tech Stack
- **Framework**: Flutter 3.35.2
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Firebase (Firestore, Auth)
- **Local Storage**: SharedPreferences
- **QR Generation**: QR Flutter
- **Location**: Geolocator
- **Charts**: FL Chart

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35.2 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd management_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Add Android/iOS apps to Firebase
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place configuration files in respective platform folders

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 User Flows

### 👨‍🎓 Student Flow
1. **Login** → Select Student role
2. **Dashboard** → View attendance summary
3. **Scan QR** → Mark attendance for active sessions
4. **History** → View attendance records
5. **Exceptions** → Request attendance corrections

### 👨‍🏫 Teacher Flow
1. **Login** → Select Teacher role
2. **Dashboard** → View class schedule
3. **Start Session** → Generate dynamic QR codes
4. **Monitor** → Track real-time attendance
5. **Analytics** → View attendance reports
6. **Manage** → Handle attendance exceptions

### 👨‍💼 Admin Flow
1. **Login** → Select Admin role
2. **Dashboard** → System overview
3. **Users** → Manage teachers and students
4. **Reports** → Generate system-wide analytics
5. **Settings** → Configure system parameters

## 🎯 Key Features Deep Dive

### 🔄 Dynamic QR Code System

The teacher-side QR generation includes:

```dart
String _generateQRCode() {
  final random = Random();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final sessionId = widget.classData['subject']?.replaceAll(' ', '_') ?? 'session';
  final randomCode = random.nextInt(999999).toString().padLeft(6, '0');
  
  return '${sessionId}_${timestamp}_$randomCode';
}
```

**Features:**
- ✅ Rotates every 30 seconds
- ✅ Includes timestamp and session info
- ✅ Visual rotation indicator
- ✅ Prevents screenshot abuse
- ✅ Secure random components

### 📍 Location-Based Validation

```dart
static Future<LocationValidationResult> validateLocation({
  required double targetLatitude,
  required double targetLongitude,
  required double allowedRadius,
}) async {
  final currentLocation = await getCurrentLocation();
  final distance = calculateDistance(/*...*/);
  return LocationValidationResult(isValid: distance <= allowedRadius);
}
```

### 📊 Analytics Engine

- **Real-time Metrics**: Live attendance tracking
- **Trend Analysis**: Historical attendance patterns
- **Risk Assessment**: Identify at-risk students
- **Export Options**: CSV reports for external analysis

## 🔧 Configuration

### Environment Setup
Create `.env` file in project root:
```env
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key
DEFAULT_LOCATION_RADIUS=50.0
QR_ROTATION_INTERVAL=30
```

### Firebase Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Demo Mode
The app includes demo services for testing without Firebase:
- `FirebaseAttendanceServiceDemo`
- `SimpleStorageService`
- Mock location and QR services

## 📦 Build & Deploy

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

### Web Build
```bash
flutter build web --release
```

## 🔍 Troubleshooting

### Common Issues

1. **Firebase Connection Issues**
   - Verify `google-services.json` placement
   - Check Firebase project configuration
   - Ensure internet connectivity

2. **Location Permission Denied**
   - Add location permissions to `AndroidManifest.xml`
   - Request runtime permissions
   - Check device location settings

3. **QR Scanner Not Working**
   - Verify camera permissions
   - Check device camera functionality
   - Ensure adequate lighting

### Debug Commands
```bash
# Check Flutter doctor
flutter doctor

# Clean build
flutter clean && flutter pub get

# Verbose logging
flutter run --verbose
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- QR Flutter package contributors
- Open source community

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Check existing documentation
- Review troubleshooting guide

---

**Built with ❤️ using Flutter**

*Smart Attendance Management System - Making attendance tracking simple, secure, and efficient.*