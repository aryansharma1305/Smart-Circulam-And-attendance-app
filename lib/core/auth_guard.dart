import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final String? redirectPath;

  const AuthGuard({super.key, required this.child, this.redirectPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        // If user is null, redirect to onboarding
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/onboarding');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user exists, show the child widget
        return child;
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/onboarding'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A secondary defense-in-depth guard that ensures the authenticated user
/// has the required role before rendering the child.
///
/// If the user lacks the role, it shows an access denied message.
/// Note: The primary access control happens in [GoRouter.redirect].
class RoleGuard extends ConsumerWidget {
  final Widget child;
  final UserRole requiredRole;

  const RoleGuard({super.key, required this.child, required this.requiredRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/onboarding');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user.role != requiredRole && user.role != UserRole.admin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Access Denied')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('You must be a ${requiredRole.name} to view this page.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (user.role == UserRole.student) {
                        context.go('/student');
                      } else if (user.role == UserRole.teacher) {
                        context.go('/teacher');
                      } else {
                        context.go('/onboarding');
                      }
                    },
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          );
        }

        return child;
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
