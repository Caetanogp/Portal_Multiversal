import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:portal_multiversal/core/theme/app_theme.dart';
import 'package:portal_multiversal/features/auth/presentation/providers/auth_provider.dart';
import 'package:portal_multiversal/features/auth/presentation/screens/auth_screen.dart';
import 'package:portal_multiversal/features/catalog/domain/repositories/character_repository.dart';
import 'package:portal_multiversal/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:portal_multiversal/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:portal_multiversal/features/collections/presentation/providers/collection_provider.dart';

import 'helpers/test_doubles.dart';

void main() {
  testWidgets('login alterna para cadastro e valida confirmação de senha', (
    WidgetTester tester,
  ) async {
    final AuthProvider provider = AuthProvider(FakeAuthRepository())
      ..status = AuthStatus.unauthenticated;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: provider,
        child: MaterialApp(theme: AppTheme.dark, home: const AuthScreen()),
      ),
    );

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
      '9999',
    );
    await tester.tap(find.byKey(const ValueKey<String>('auth-submit-button')));
    await tester.pump();

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
  });

  testWidgets('catálogo exibe GridView, paginação e abre detalhe pela busca', (
    WidgetTester tester,
  ) async {
    final FakeCharacterRepository repository = FakeCharacterRepository();
    final CatalogProvider catalog = CatalogProvider(repository);
    final CollectionProvider collections = CollectionProvider(
      InMemoryCollectionRepository(),
    );
    await catalog.loadInitial();
    await collections.loadForUser('rick');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<CharacterRepository>.value(value: repository),
          ChangeNotifierProvider<CatalogProvider>.value(value: catalog),
          ChangeNotifierProvider<CollectionProvider>.value(value: collections),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: CatalogScreen()),
        ),
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Carregar Mais'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('load-more-button')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('search-field')),
      'Rick Sanchez',
    );
    await tester.tap(find.byKey(const ValueKey<String>('search-button')));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do personagem'), findsOneWidget);
    expect(repository.detailCalls, 1);
  });

  testWidgets('botão atualiza o catálogo usando o Provider', (
    WidgetTester tester,
  ) async {
    final FakeCharacterRepository repository = FakeCharacterRepository();
    final CatalogProvider catalog = CatalogProvider(repository);
    await catalog.loadInitial();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<CharacterRepository>.value(value: repository),
          ChangeNotifierProvider<CatalogProvider>.value(value: catalog),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: CatalogScreen()),
        ),
      ),
    );

    expect(repository.pageCalls, 1);
    expect(
      find.byKey(const ValueKey<String>('refresh-catalog-button')),
      findsOneWidget,
    );
    expect(find.byTooltip('Atualizar catálogo'), findsOneWidget);
    final Completer<void> refreshCompleter = Completer<void>();
    repository.pageDelay = refreshCompleter.future;

    await tester.tap(
      find.byKey(const ValueKey<String>('refresh-catalog-button')),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('refresh-catalog-progress')),
      findsOneWidget,
    );
    expect(find.byTooltip('Atualizando catálogo'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey<String>('refresh-catalog-button')),
          )
          .onPressed,
      isNull,
    );

    refreshCompleter.complete();
    await tester.pumpAndSettle();

    expect(repository.pageCalls, 2);
  });

  testWidgets(
    'tela de autenticação atende diretrizes básicas de acessibilidade',
    (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final AuthProvider provider = AuthProvider(FakeAuthRepository())
        ..status = AuthStatus.unauthenticated;
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: provider,
          child: MaterialApp(theme: AppTheme.dark, home: const AuthScreen()),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    },
  );

  testWidgets('fonte 2x em tela estreita não causa overflow', (
    WidgetTester tester,
  ) async {
    final AuthProvider provider = AuthProvider(FakeAuthRepository())
      ..status = AuthStatus.unauthenticated;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(2),
        ),
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: provider,
          child: MaterialApp(theme: AppTheme.dark, home: const AuthScreen()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
