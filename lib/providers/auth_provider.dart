/// Backward-compatibility shim for auth_provider.dart.
///
/// All provider definitions and the [AuthNotifier] class have been moved to
/// `lib/controllers/auth_controller.dart`. This file re-exports them so that
/// any existing import of `auth_provider.dart` continues to resolve without
/// changes.
///
/// New code should import from `auth_controller.dart` directly.
export '../controllers/auth_controller.dart'
    show
        AuthController,
        authProvider,
        currentUserProvider,
        isAuthenticatedProvider;

// Legacy type alias so any code that references `AuthNotifier` still compiles.
import '../controllers/auth_controller.dart';
typedef AuthNotifier = AuthController;
