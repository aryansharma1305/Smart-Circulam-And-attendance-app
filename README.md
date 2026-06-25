# Smart Circulam and Attendance App

A Flutter + Firebase attendance management app for educational institutions.
The project focuses on role-based attendance workflows, secure QR attendance,
academic administration, exception review, announcements, and student-facing
notifications.

The app is currently in active development. Local/demo flows work without
Firebase through in-memory repositories, while Firebase-backed dev and staging
environments are partially configured.

## Current status

- Flutter app architecture has been moved toward repository-driven state.
- Firebase dev and staging project configuration has been generated.
- Firestore rules and indexes are deployed to dev and staging.
- Cloud Functions source compiles locally, but deployment requires Firebase
  Blaze billing.
- Firebase Storage rules are present locally, but Storage must be initialized in
  the Firebase Console before deployment.
- Production Firebase configuration is intentionally not completed yet.

See [PROJECT_ROADMAP.md](PROJECT_ROADMAP.md) for the phase-by-phase plan and
deployment status.

## Features

### Roles

- Student: attendance history, QR attendance, exception requests, notifications.
- Teacher: schedule, sessions, live attendance, announcements, exception review.
- Admin: user management, academic catalog setup, audit visibility, compliance.
- Counselor/parent-oriented models are present for future expansion.

### Attendance

- Session-based attendance records.
- QR attendance token model with signed payload support.
- Duplicate attendance prevention.
- Student enrollment validation path for secure QR submission.
- Attendance exception requests for legitimate corrections.

### Academics

- Departments, terms, subjects, sections, rooms, teaching assignments, and
  timetable foundations.
- Admin-facing academic management screen.
- Firebase and in-memory repository implementations.

### Security and compliance

- Role and institution scoping through Firebase custom claims.
- Firestore rules for users, sessions, attendance, exceptions, announcements,
  notifications, audit logs, and academic catalog data.
- Cloud Function source for transactional attendance exception approval.
- Audit events for sensitive backend actions.
- Protected Storage rules for exception evidence and announcement attachments.

### Notifications

- In-app notification model and repository.
- Firebase and in-memory inbox implementations.
- Student notification screen backed by repository data.
- FCM is not wired yet; the roadmap keeps push delivery as a future production
  hardening step.

## Tech stack

- Flutter / Dart
- Riverpod
- GoRouter
- Firebase Auth
- Cloud Firestore
- Cloud Functions for Firebase
- Firebase Storage
- Firebase App Check
- Firebase Crashlytics
- Jest + Firebase Rules Unit Testing for Firestore rules

## Repository structure

```text
.
├── lib/
│   ├── controllers/          # Riverpod state controllers
│   ├── core/                 # Routing, environment, guards, common state
│   ├── models/               # Domain models
│   ├── providers/            # Repository/provider wiring
│   ├── repositories/         # Contracts plus Firebase/in-memory implementations
│   ├── screens/              # Admin, auth, student, teacher, common UI
│   ├── services/             # QR, secure attendance, storage/demo helpers
│   └── widgets/              # Reusable Flutter widgets
├── functions/
│   ├── src/                  # Callable/backend Firebase Functions
│   └── tests/                # Firestore rules tests
├── test/                     # Dart unit/widget tests
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── firebase.json
└── PROJECT_ROADMAP.md
```

## Getting started

### Prerequisites

- Flutter SDK installed.
- Node.js and npm for Firebase Functions.
- Firebase CLI for emulator/rules deployment.
- FlutterFire CLI if regenerating Firebase options.

### Install dependencies

```bash
flutter pub get
npm --prefix functions install
```

### Run locally without Firebase

By default, the app can run with in-memory repositories:

```bash
flutter run
```

### Run with Firebase

Use the environment flags defined in `lib/core/env.dart`.

Examples:

```bash
flutter run --dart-define=APP_ENV=dev --dart-define=USE_FIREBASE=true
flutter run --dart-define=APP_ENV=staging --dart-define=USE_FIREBASE=true
```

For local emulators:

```bash
firebase emulators:start
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=USE_FIREBASE=true \
  --dart-define=USE_EMULATOR=true
```

## Firebase projects

Configured aliases:

- `dev`: `smart-circulam-dev`
- `staging`: `smart-circulam-staging`

Production configuration is not active yet because the originally requested
project ID was unavailable/quota-limited during setup.

## Useful commands

### Flutter

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

Focused tests used during development:

```bash
flutter test \
  test/services/secure_qr_service_test.dart \
  test/services/attendance_qr_submission_service_test.dart \
  test/repositories/in_memory_attendance_test.dart \
  test/repositories/in_memory_notification_repository_test.dart \
  test/widget_test.dart
```

### Firebase Functions

```bash
npm --prefix functions run build
```

### Firestore rules tests

```bash
firebase emulators:exec --only firestore \
  "npm --prefix functions test -- --runInBand" \
  --project smart-app-test
```

### Deploy Firestore rules and indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes --project smart-circulam-dev
firebase deploy --only firestore:rules,firestore:indexes --project smart-circulam-staging
```

### Deploy Storage rules

Storage must first be initialized in the Firebase Console for each project.

```bash
firebase deploy --only storage --project smart-circulam-dev
firebase deploy --only storage --project smart-circulam-staging
```

### Deploy Functions

Cloud Functions deployment requires Firebase Blaze billing:

```bash
firebase deploy --only functions --project smart-circulam-dev
firebase deploy --only functions --project smart-circulam-staging
```

## Cost and deployment notes

- Firestore has a no-cost quota and is already usable for dev/staging.
- Cloud Functions require Blaze, although low development usage can remain
  within Firebase's no-cost quota.
- Firebase Storage also requires project Storage initialization before rules can
  be deployed.
- Use Firebase budget alerts if enabling Blaze.

## Roadmap

The active implementation plan is maintained in
[PROJECT_ROADMAP.md](PROJECT_ROADMAP.md). Completed local foundations include:

1. Repository architecture and testable in-memory implementations.
2. Firebase project setup for dev/staging.
3. Firestore rules, indexes, Functions source, and emulator tests.
4. Academic catalog management foundation.
5. Secure QR attendance foundation.
6. Exception review, audit, announcements, and in-app notifications foundation.

Next planned area: reports and compliance.

## Contributing

1. Create a feature branch.
2. Keep commits small and meaningful.
3. Run relevant Flutter tests and Firebase rules tests.
4. Update the roadmap/docs when changing architecture or deployment status.
5. Open a pull request for review.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
