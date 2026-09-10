import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';

enum CatalogStatus { initial, loading, success, error }

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repository);

  final CharacterRepository _repository;
  final List<Character> _characters = <Character>[];

  CatalogStatus status = CatalogStatus.initial;
  int _currentPage = 0;
  bool hasNextPage = true;
  bool isLoadingMore = false;
  bool isSearching = false;
  String? errorMessage;
  String? paginationError;
  String? searchError;

  List<Character> get characters => List<Character>.unmodifiable(_characters);

  Future<void> loadInitial({bool force = false}) async {
    if (_characters.isNotEmpty && !force) return;
    status = CatalogStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final CharacterPage page = await _repository.getPage(1);
      _characters
        ..clear()
        ..addAll(page.characters);
      _currentPage = page.currentPage;
      hasNextPage = page.hasNextPage;
      status = CatalogStatus.success;
    } on AppException catch (error) {
      errorMessage = error.message;
      status = CatalogStatus.error;
    } on Object catch (_) {
      errorMessage = 'Não foi possível carregar o catálogo.';
      status = CatalogStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage) return;
    isLoadingMore = true;
    paginationError = null;
    notifyListeners();
    try {
      final CharacterPage page = await _repository.getPage(_currentPage + 1);
      final Set<int> existingIds = _characters
          .map((Character item) => item.id)
          .toSet();
      _characters.addAll(
        page.characters.where((Character item) => existingIds.add(item.id)),
      );
      _currentPage = page.currentPage;
      hasNextPage = page.hasNextPage;
    } on AppException catch (error) {
      paginationError = error.message;
    } on Object catch (_) {
      paginationError = 'Não foi possível carregar mais personagens.';
    }
    isLoadingMore = false;
    notifyListeners();
  }

  Future<Character?> search(String query) async {
    final String normalized = query.trim();
    searchError = null;
    if (normalized.isEmpty) {
      searchError = 'Digite o nome de um personagem.';
      notifyListeners();
      return null;
    }
    isSearching = true;
    notifyListeners();
    try {
      final List<Character> results = await _repository.searchByName(
        normalized,
      );
      final String target = normalized.toLowerCase();
      final Character selected = results.firstWhere(
        (Character item) => item.name.toLowerCase() == target,
        orElse: () => results.first,
      );
      return selected;
    } on AppException catch (error) {
      searchError = error.message;
      return null;
    } on Object catch (_) {
      searchError = 'Não foi possível realizar a busca.';
      return null;
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }
}
