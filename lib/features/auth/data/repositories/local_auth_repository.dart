import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._store, {Random? secureRandom})
    : _random = secureRandom ?? Random.secure();

  static const String _usersKey = 'auth.users.v1';
  static const String _sessionKey = 'auth.session.v1';

  final KeyValueStore _store;
  final Random _random;

  @override
  Future<AuthUser> register({
    required String username,
    required String password,
  }) async {
    final String displayName = username.trim();
    final String id = _normalize(displayName);
    _validate(displayName, password);
    final Map<String, Object?> users = await _readUsers();
    if (users.containsKey(id)) {
      throw const AppException(
        'Esse usuário já está cadastrado.',
        type: AppFailureType.validation,
      );
    }
    final String salt = List<int>.generate(
      16,
      (_) => _random.nextInt(256),
    ).map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    users[id] = <String, Object?>{
      'displayName': displayName,
      'salt': salt,
      'passwordHash': _hash(password, salt),
    };
    try {
      await _store.setString(_usersKey, jsonEncode(users));
      await _store.setString(_sessionKey, id);
    } on Object catch (_) {
      throw const AppException(
        'Não foi possível salvar o cadastro neste dispositivo.',
        type: AppFailureType.storage,
      );
    }
    return AuthUser(id: id, displayName: displayName);
  }

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final String id = _normalize(username);
    if (id.isEmpty || password.isEmpty) {
      throw const AppException(
        'Informe usuário e senha.',
        type: AppFailureType.validation,
      );
    }
    final Map<String, Object?> users = await _readUsers();
    final Object? rawRecord = users[id];
    if (rawRecord is! Map<String, Object?>) {
      throw const AppException(
        'Usuário ou senha inválidos.',
        type: AppFailureType.validation,
      );
    }
    final String salt = rawRecord['salt'] as String? ?? '';
    final String expected = rawRecord['passwordHash'] as String? ?? '';
    if (expected.isEmpty || _hash(password, salt) != expected) {
      throw const AppException(
        'Usuário ou senha inválidos.',
        type: AppFailureType.validation,
      );
    }
    await _store.setString(_sessionKey, id);
    return AuthUser(
      id: id,
      displayName: rawRecord['displayName'] as String? ?? username.trim(),
    );
  }

  @override
  Future<void> logout() => _store.remove(_sessionKey);

  @override
  Future<AuthUser?> restoreSession() async {
    final String? id = await _store.getString(_sessionKey);
    if (id == null) return null;
    final Map<String, Object?> users = await _readUsers();
    final Object? rawRecord = users[id];
    if (rawRecord is! Map<String, Object?>) {
      await _store.remove(_sessionKey);
      return null;
    }
    return AuthUser(
      id: id,
      displayName: rawRecord['displayName'] as String? ?? id,
    );
  }

  Future<Map<String, Object?>> _readUsers() async {
    try {
      final String? raw = await _store.getString(_usersKey);
      if (raw == null || raw.isEmpty) return <String, Object?>{};
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<Object?, Object?>) throw const FormatException();
      return decoded.map(
        (Object? key, Object? value) => MapEntry(
          key.toString(),
          value is Map<Object?, Object?>
              ? value.map(
                  (Object? nestedKey, Object? nestedValue) =>
                      MapEntry(nestedKey.toString(), nestedValue),
                )
              : value,
        ),
      );
    } on AppException {
      rethrow;
    } on Object catch (_) {
      throw const AppException(
        'Os dados locais de acesso estão inválidos.',
        type: AppFailureType.storage,
      );
    }
  }

  static String _normalize(String value) => value.trim().toLowerCase();

  static String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  static void _validate(String username, String password) {
    if (username.length < 3) {
      throw const AppException(
        'O usuário deve ter pelo menos 3 caracteres.',
        type: AppFailureType.validation,
      );
    }
    if (password.length < 4) {
      throw const AppException(
        'A senha deve ter pelo menos 4 caracteres.',
        type: AppFailureType.validation,
      );
    }
  }
}
