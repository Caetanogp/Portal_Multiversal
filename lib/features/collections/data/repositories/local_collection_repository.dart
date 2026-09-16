import 'dart:convert';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../../catalog/data/models/character_model.dart';
import '../../../catalog/domain/entities/character.dart';
import '../../domain/entities/user_collections.dart';
import '../../domain/repositories/collection_repository.dart';

class LocalCollectionRepository implements CollectionRepository {
  const LocalCollectionRepository(this._store);

  final KeyValueStore _store;

  @override
  Future<UserCollections> load(String userId) async {
    try {
      return UserCollections(
        favorites: await _read(_key(userId, 'favorites')),
        watched: await _read(_key(userId, 'watched')),
      );
    } on AppException {
      rethrow;
    } on Object catch (_) {
      throw const AppException(
        'Não foi possível ler suas listas salvas.',
        type: AppFailureType.storage,
      );
    }
  }

  @override
  Future<void> saveFavorites(String userId, List<Character> characters) =>
      _write(_key(userId, 'favorites'), characters);

  @override
  Future<void> saveWatched(String userId, List<Character> characters) =>
      _write(_key(userId, 'watched'), characters);

  Future<List<Character>> _read(String key) async {
    final String? raw = await _store.getString(key);
    if (raw == null || raw.isEmpty) return <Character>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List<Object?>) throw const FormatException();
      return decoded
          .map(
            (Object? item) => CharacterModel.fromJson(
              Map<String, Object?>.from(item! as Map<Object?, Object?>),
            ).toEntity(),
          )
          .toList(growable: false);
    } on Object catch (_) {
      throw const AppException(
        'Uma lista local está corrompida.',
        type: AppFailureType.storage,
      );
    }
  }

  Future<void> _write(String key, List<Character> characters) async {
    try {
      final String raw = jsonEncode(
        characters
            .map((Character item) => CharacterModel.fromEntity(item).toJson())
            .toList(growable: false),
      );
      await _store.setString(key, raw);
    } on Object catch (_) {
      throw const AppException(
        'Não foi possível salvar sua lista.',
        type: AppFailureType.storage,
      );
    }
  }

  static String _key(String userId, String collection) =>
      'collections.$userId.$collection.v1';
}
