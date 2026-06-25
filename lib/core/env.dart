/// Application environment selector.
///
/// The active environment is determined at compile time via the `--dart-define`
/// flag:
///   flutter run --dart-define=ENV=dev
///   flutter run --dart-define=ENV=staging
///   flutter run --dart-define=ENV=prod
///
/// Defaults to [Env.dev] when the flag is absent (local development).
enum Env { dev, staging, prod }

class AppEnv {
  AppEnv._();

  static const _raw = String.fromEnvironment('ENV', defaultValue: 'dev');

  static Env get current {
    switch (_raw) {
      case 'staging':
        return Env.staging;
      case 'prod':
        return Env.prod;
      default:
        return Env.dev;
    }
  }

  static bool get isDev => current == Env.dev;
  static bool get isStaging => current == Env.staging;
  static bool get isProd => current == Env.prod;

  /// Whether to connect to Firebase emulators instead of the live project.
  ///
  /// Set to true by passing `--dart-define=USE_EMULATOR=true`.
  static const useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: false,
  );

  /// Firebase is opt-in until real per-environment configuration is supplied.
  /// Emulator mode always enables the Firebase adapters.
  static const useFirebase =
      bool.fromEnvironment('USE_FIREBASE', defaultValue: false) || useEmulator;

  static const recaptchaEnterpriseSiteKey = String.fromEnvironment(
    'RECAPTCHA_ENTERPRISE_SITE_KEY',
  );
}
