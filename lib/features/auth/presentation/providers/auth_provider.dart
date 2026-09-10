import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus {
  bootstrapping,
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;
  AuthStatus status = AuthStatus.bootstrapping;
  AuthUser? user;
  String? errorMessage;

  Future<void> restoreSession() async {
    try {
      user = await _repository.restoreSession();
      status = user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } on AppException catch (error) {
      errorMessage = error.message;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String username, required String password}) =>
      _authenticate(
        () => _repository.login(username: username, password: password),
      );

  Future<bool> register({required String username, required String password}) =>
      _authenticate(
        () => _repository.register(username: username, password: password),
      );

  Future<bool> _authenticate(Future<AuthUser> Function() action) async {
    errorMessage = null;
    status = AuthStatus.authenticating;
    notifyListeners();
    try {
      user = await action();
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
    } on Object catch (_) {
      errorMessage = 'Não foi possível concluir o acesso.';
    }
    status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _repository.logout();
    user = null;
    errorMessage = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }
}
