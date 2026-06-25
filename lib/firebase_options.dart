// Firebase environment routing shim.
//
// Generate/update environment-specific files with:
//   flutterfire configure --project=<project-id> --out=lib/firebase_options_<env>.dart
//
// Production is intentionally not wired until the Firebase project exists.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import 'core/env.dart';
import 'firebase_options_dev.dart' as dev;
import 'firebase_options_staging.dart' as staging;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (AppEnv.current) {
      case Env.dev:
        return dev.DefaultFirebaseOptions.currentPlatform;
      case Env.staging:
        return staging.DefaultFirebaseOptions.currentPlatform;
      case Env.prod:
        throw UnsupportedError(
          'Firebase production options are not configured. '
          'Create/select a production Firebase project and generate '
          'lib/firebase_options_prod.dart.',
        );
    }
  }
}
