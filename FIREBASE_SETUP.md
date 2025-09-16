# Firebase Setup Guide for SmartStudy+

This guide will help you set up Firebase for the SmartStudy+ app to enable real-time database functionality.

## Prerequisites

1. A Google account
2. Flutter development environment set up
3. Android Studio or VS Code with Flutter extensions

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `smartstudy-plus` (or your preferred name)
4. Enable Google Analytics (optional but recommended)
5. Click "Create project"

## Step 2: Add Android App

1. In the Firebase Console, click "Add app" and select Android
2. Enter your package name: `com.example.management_app` (or your actual package name)
3. Enter app nickname: `SmartStudy+ Android`
4. Click "Register app"
5. Download the `google-services.json` file
6. Place it in `android/app/` directory

## Step 3: Add iOS App (if needed)

1. Click "Add app" and select iOS
2. Enter your bundle ID: `com.example.managementApp` (or your actual bundle ID)
3. Enter app nickname: `SmartStudy+ iOS`
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place it in `ios/Runner/` directory

## Step 4: Enable Authentication

1. In Firebase Console, go to "Authentication" > "Sign-in method"
2. Enable the following providers:
   - **Email/Password**: For basic authentication
   - **Google**: For Google sign-in (optional)
   - **Phone**: For OTP-based login (optional)

## Step 5: Set up Firestore Database

1. Go to "Firestore Database" in the Firebase Console
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

### Firestore Security Rules

Replace the default rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Attendance records - users can only access their own
    match /attendance_records/{recordId} {
      allow read, write: if request.auth != null && 
        (resource.data.student_id == request.auth.uid || 
         resource.data.teacher_id == request.auth.uid);
    }
    
    // Sessions - teachers can create/update, students can read
    match /sessions/{sessionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        resource.data.teacher_id == request.auth.uid;
    }
    
    // Classes - authenticated users can read
    match /classes/{classId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Timetables - authenticated users can read
    match /timetables/{timetableId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 6: Configure Firebase Options

1. In Firebase Console, go to Project Settings (gear icon)
2. Scroll down to "Your apps" section
3. Click on your Android app
4. Copy the configuration values
5. Update `lib/firebase_options.dart` with your actual values:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-api-key',
  appId: 'your-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  storageBucket: 'your-storage-bucket',
);
```

## Step 7: Test Firebase Connection

1. Run the app: `flutter run`
2. Check the console for any Firebase connection errors
3. Try creating a session as a teacher
4. Try scanning QR code as a student

## Step 8: Set up Cloud Functions (Optional)

For advanced features like push notifications and automated reports:

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize functions: `firebase init functions`
4. Deploy: `firebase deploy --only functions`

## Troubleshooting

### Common Issues

1. **"No Firebase App '[DEFAULT]' has been created"**
   - Make sure Firebase is initialized in `main.dart`
   - Check that `firebase_options.dart` has correct configuration

2. **"Permission denied" errors**
   - Check Firestore security rules
   - Ensure user is authenticated

3. **"Network request failed"**
   - Check internet connection
   - Verify Firebase project is active
   - Check if Firestore is enabled

4. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check that `google-services.json` is in the correct location
   - Verify package name matches Firebase configuration

### Testing Authentication

```dart
// Test authentication
try {
  final user = await FirebaseAuth.instance.signInAnonymously();
  print('User signed in: ${user.user?.uid}');
} catch (e) {
  print('Sign in failed: $e');
}
```

### Testing Firestore

```dart
// Test Firestore write
try {
  await FirebaseFirestore.instance
      .collection('test')
      .add({'message': 'Hello Firebase!'});
  print('Data written successfully');
} catch (e) {
  print('Write failed: $e');
}
```

## Production Considerations

1. **Security Rules**: Update Firestore rules for production
2. **Authentication**: Implement proper user management
3. **Data Validation**: Add server-side validation
4. **Monitoring**: Set up Firebase Performance and Crashlytics
5. **Backup**: Configure automated backups
6. **Scaling**: Monitor usage and upgrade plan if needed

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

## Next Steps

1. Set up user authentication flow
2. Implement real-time updates
3. Add push notifications
4. Set up analytics and monitoring
5. Deploy to production
