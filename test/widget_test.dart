import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/core/router.dart';
import 'package:management_app/main.dart';
import 'package:management_app/providers/repository_providers.dart';
import 'package:management_app/repositories/in_memory/in_memory_auth_repository.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(InMemoryAuthRepository()),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SmartStudyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('app starts on onboarding and opens supported role selection', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Welcome to SmartStudy+'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('I am a...'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Teacher'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Counselor'), findsNothing);
  });

  testWidgets('protected student route redirects an unauthenticated user', (
    tester,
  ) async {
    await pumpApp(tester);
    container.read(routerProvider).go('/student');
    await tester.pumpAndSettle();

    expect(find.text('Welcome to SmartStudy+'), findsOneWidget);
  });
}
