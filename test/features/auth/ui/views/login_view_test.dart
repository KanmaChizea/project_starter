import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_starter/core/session/session_service.dart';
import 'package:project_starter/features/auth/data/repositories/auth_repository.dart';
import 'package:project_starter/features/auth/data/services/auth_service.dart';
import 'package:project_starter/features/auth/ui/views/login_view.dart';

void main() {
  testWidgets('signs in and shows a confirmation', (tester) async {
    final authService = AuthService(
      FakeAuthRepository(delay: Duration.zero),
      SessionService(),
    );

    await tester.pumpWidget(
      RepositoryProvider.value(
        value: authService,
        child: const MaterialApp(home: LoginView()),
      ),
    );

    final signIn = find.widgetWithText(FilledButton, 'Sign in');
    expect(tester.widget<FilledButton>(signIn).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'jane@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'secret123',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(signIn).onPressed, isNotNull);

    await tester.tap(signIn);
    await tester.pumpAndSettle();

    expect(find.text('Signed in as jane@example.com'), findsOneWidget);
  });
}
