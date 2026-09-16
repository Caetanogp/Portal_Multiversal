import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:portal_multiversal/core/errors/app_exception.dart';
import 'package:portal_multiversal/features/auth/data/repositories/local_auth_repository.dart';

import 'helpers/test_doubles.dart';

void main() {
  late InMemoryStore store;
  late LocalAuthRepository repository;

  setUp(() {
    store = InMemoryStore();
    repository = LocalAuthRepository(store, secureRandom: Random(7));
  });

  test('cadastra, normaliza usuário e restaura sessão', () async {
    final user = await repository.register(
      username: '  PortalUser  ',
      password: 'segredo',
    );

    expect(user.id, 'portaluser');
    expect((await repository.restoreSession())?.displayName, 'PortalUser');
    expect(store.values.toString(), isNot(contains('segredo')));
  });

  test('login é case-insensitive e logout encerra sessão', () async {
    await repository.register(username: 'Rick', password: '1234');
    await repository.logout();
    expect(await repository.restoreSession(), isNull);

    final user = await repository.login(username: 'RICK', password: '1234');
    expect(user.id, 'rick');
  });

  test('rejeita senha inválida e conta duplicada', () async {
    await repository.register(username: 'Morty', password: '1234');

    expect(
      repository.login(username: 'Morty', password: 'errada'),
      throwsA(isA<AppException>()),
    );
    expect(
      repository.register(username: 'MORTY', password: '5678'),
      throwsA(isA<AppException>()),
    );
  });

  test('informa falha de persistência no cadastro', () async {
    store.failWrites = true;
    expect(
      repository.register(username: 'Summer', password: '1234'),
      throwsA(isA<AppException>()),
    );
  });
}
