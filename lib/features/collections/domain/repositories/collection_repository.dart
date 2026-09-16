import '../../../catalog/domain/entities/character.dart';
import '../entities/user_collections.dart';

abstract interface class CollectionRepository {
  Future<UserCollections> load(String userId);

  Future<void> saveFavorites(String userId, List<Character> characters);

  Future<void> saveWatched(String userId, List<Character> characters);
}
