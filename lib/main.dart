import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/env.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/repository_providers.dart';
import 'repositories/firebase/firebase_academics_repository.dart';
import 'repositories/firebase/firebase_announcement_repository.dart';
import 'repositories/firebase/firebase_attendance_repository.dart';
import 'repositories/firebase/firebase_auth_repository.dart';
import 'repositories/firebase/firebase_exception_repository.dart';
import 'repositories/firebase/firebase_academic_admin_repository.dart';
import 'repositories/firebase/firebase_notification_repository.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() {
  // Catch any synchronous errors before Firebase is ready.
  runZonedGuarded(_bootstrap, _onUncaughtError);
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppEnv.useFirebase) {
    runApp(const ProviderScope(child: SmartStudyApp()));
    return;
  }

  // ── Firebase core ──────────────────────────────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Emulator connections (dev only, when USE_EMULATOR=true) ───────────
  if (AppEnv.useEmulator) {
    await _connectEmulators();
  }

  // ── Crashlytics ────────────────────────────────────────────────────────
  const crashlyticsEnabled = !kDebugMode; // disabled in debug builds
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    crashlyticsEnabled,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // ── App Check (attestation-only; enforcement added once keys are live) ─
  if (!kIsWeb || AppEnv.recaptchaEnterpriseSiteKey.isNotEmpty) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AppEnv.isDev
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: AppEnv.isDev
          ? AppleProvider.debug
          : AppleProvider.deviceCheck,
      webProvider: kIsWeb
          ? ReCaptchaEnterpriseProvider(AppEnv.recaptchaEnterpriseSiteKey)
          : null,
    );
  }

  // ── Firebase repository implementations ────────────────────────────────
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final functions = FirebaseFunctions.instance;

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FirebaseAuthRepository(auth: firebaseAuth, firestore: firestore),
        ),
        attendanceRepositoryProvider.overrideWithValue(
          FirebaseAttendanceRepository(firestore: firestore),
        ),
        academicsRepositoryProvider.overrideWithValue(
          FirebaseAcademicsRepository(firestore: firestore),
        ),
        exceptionRepositoryProvider.overrideWithValue(
          FirebaseExceptionRepository(
            firestore: firestore,
            functions: functions,
          ),
        ),
        announcementRepositoryProvider.overrideWithValue(
          FirebaseAnnouncementRepository(firestore: firestore),
        ),
        academicAdminRepositoryProvider.overrideWithValue(
          FirebaseAcademicAdminRepository(firestore: firestore),
        ),
        notificationRepositoryProvider.overrideWithValue(
          FirebaseNotificationRepository(firestore: firestore),
        ),
      ],
      child: const SmartStudyApp(),
    ),
  );
}

/// Connects to local Firebase emulators for development/testing.
Future<void> _connectEmulators() async {
  const host = 'localhost';
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  debugPrint('🔥 Connected to Firebase emulators ($host)');
}

/// Top-level uncaught error handler — routes non-Flutter errors to Crashlytics.
void _onUncaughtError(Object error, StackTrace stack) {
  if (Firebase.apps.isNotEmpty) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  } else {
    debugPrint('Uncaught error: $error\n$stack');
  }
}

// ---------------------------------------------------------------------------
// Root widget
// ---------------------------------------------------------------------------

class SmartStudyApp extends ConsumerWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'SmartStudy+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
