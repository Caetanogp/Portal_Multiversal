import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../catalog/domain/entities/character.dart';
import '../../domain/entities/user_collections.dart';
import '../../domain/repositories/collection_repository.dart';

class CollectionProvider extends ChangeNotifier {
  CollectionProvider(this._repository);

  final CollectionRepository _repository;
  String? _userId;
  List<Character> _favorites = <Character>[];
  List<Character> _watched = <Character>[];

  bool isLoading = false;
  String? errorMessage;

  List<Character> get favorites => List<Character>.unmodifiable(_favorites);
  List<Character> get watched => List<Character>.unmodifiable(_watched);

  bool isFavorite(int characterId) =>
      _favorites.any((Character item) => item.id == characterId);

  bool isWatched(int characterId) =>
      _watched.any((Character item) => item.id == characterId);

  Future<void> loadForUser(String userId) async {
    if (_userId == userId && !isLoading) return;
    _userId = userId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final UserCollections collections = await _repository.load(userId);
      _favorites = List<Character>.of(collections.favorites);
      _watched = List<Character>.of(collections.watched);
    } on AppException catch (error) {
      errorMessage = error.message;
      _favorites = <Character>[];
      _watched = <Character>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> toggleFavorite(Character character) async {
    final String? userId = _userId;
    if (userId == null) return 'Faça login para alterar favoritos.';
    final List<Character> before = List<Character>.of(_favorites);
    _toggle(_favorites, character);
    notifyListeners();
    try {
      await _repository.saveFavorites(userId, _favorites);
      return null;
    } on AppException catch (error) {
      _favorites = before;
      notifyListeners();
      return error.message;
    }
  }

  Future<String?> toggleWatched(Character character) async {
    final String? userId = _userId;
    if (userId == null) return 'Faça login para alterar itens vistos.';
    final List<Character> before = List<Character>.of(_watched);
    _toggle(_watched, character);
    notifyListeners();
    try {
      await _repository.saveWatched(userId, _watched);
      return null;
    } on AppException catch (error) {
      _watched = before;
      notifyListeners();
      return error.message;
    }
  }

  void clear() {
    _userId = null;
    _favorites = <Character>[];
    _watched = <Character>[];
    errorMessage = null;
    notifyListeners();
  }

  static void _toggle(List<Character> values, Character character) {
    final int index = values.indexWhere(
      (Character item) => item.id == character.id,
    );
    if (index >= 0) {
      values.removeAt(index);
    } else {
      values.add(character);
    }
  }
}
