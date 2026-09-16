import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:portal_multiversal/app.dart';

import '../test/helpers/test_doubles.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cadastro, catálogo, detalhe, favoritos e vistos', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository authRepository = FakeAuthRepository();
    final FakeCharacterRepository characterRepository =
        FakeCharacterRepository();
    final InMemoryCollectionRepository collectionRepository =
        InMemoryCollectionRepository();

    await tester.pumpWidget(
      PortalMultiversalApp(
        authRepository: authRepository,
        characterRepository: characterRepository,
        collectionRepository: collectionRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('toggle-auth-mode')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey<String>('username-field')),
      'Rick',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('password-field')),
      '1234',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('confirmation-field')),
      '1234',
    );
    await tester.tap(find.byKey(const ValueKey<String>('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Catálogo Multiversal'), findsOneWidget);
    await tester.tap(find.text('Rick Sanchez'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('favorite-button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('watched-button')));
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Rick Sanchez'), findsOneWidget);
    await tester.tap(find.text('Vistos'));
    await tester.pumpAndSettle();
    expect(find.text('Rick Sanchez'), findsOneWidget);
  });
}
