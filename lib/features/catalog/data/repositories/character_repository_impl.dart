import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/character_remote_data_source.dart';
import '../models/character_model.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  const CharacterRepositoryImpl(this._remoteDataSource);

  final CharacterRemoteDataSource _remoteDataSource;

  @override
  Future<Character> getById(int id) async =>
      (await _remoteDataSource.getById(id)).toEntity();

  @override
  Future<CharacterPage> getPage(int page) async {
    final RemoteCharacterPage result = await _remoteDataSource.getPage(page);
    return CharacterPage(
      characters: result.characters
          .map((CharacterModel model) => model.toEntity())
          .toList(growable: false),
      currentPage: page,
      hasNextPage: result.hasNextPage,
    );
  }

  @override
  Future<List<Character>> searchByName(String name) async =>
      (await _remoteDataSource.searchByName(name))
          .map((CharacterModel model) => model.toEntity())
          .toList(growable: false);
}
