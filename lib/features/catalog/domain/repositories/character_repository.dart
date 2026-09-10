import '../entities/character.dart';

abstract interface class CharacterRepository {
  Future<CharacterPage> getPage(int page);

  Future<Character> getById(int id);

  Future<List<Character>> searchByName(String name);
}
