import 'package:portal_multiversal/core/errors/app_exception.dart';
import 'package:portal_multiversal/core/storage/key_value_store.dart';
import 'package:portal_multiversal/features/auth/domain/entities/auth_user.dart';
import 'package:portal_multiversal/features/auth/domain/repositories/auth_repository.dart';
import 'package:portal_multiversal/features/catalog/domain/entities/character.dart';
import 'package:portal_multiversal/features/catalog/domain/repositories/character_repository.dart';
import 'package:portal_multiversal/features/collections/domain/entities/user_collections.dart';
import 'package:portal_multiversal/features/collections/domain/repositories/collection_repository.dart';

const Character sampleCharacter = Character(
  id: 1,
  name: 'Rick Sanchez',
  status: 'Alive',
  species: 'Human',
  type: '',
  gender: 'Male',
  origin: 'Earth (C-137)',
  location: 'Citadel of Ricks',
  imageUrl: '',
  episodeCount: 51,
);

const Character secondCharacter = Character(
  id: 2,
  name: 'Morty Smith',
  status: 'Alive',
  species: 'Human',
  type: '',
  gender: 'Male',
  origin: 'unknown',
  location: 'Earth',
  imageUrl: '',
  episodeCount: 20,
);

class InMemoryStore implements KeyValueStore {
  final Map<String, String> values = <String, String>{};
  bool failWrites = false;

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    if (failWrites) throw StateError('write failed');
    values[key] = value;
  }
}

class FakeCharacterRepository implements CharacterRepository {
  FakeCharacterRepository({
    this.pages,
    this.searchResults = const <Character>[sampleCharacter],
    this.detail = sampleCharacter,
    this.failure,
  });

  final Map<int, CharacterPage>? pages;
  final List<Character> searchResults;
  final Character detail;
  final AppException? failure;
  Future<void>? pageDelay;
  int detailCalls = 0;
  int pageCalls = 0;

  @override
  Future<Character> getById(int id) async {
    detailCalls++;
    if (failure != null) throw failure!;
    return detail;
  }

  @override
  Future<CharacterPage> getPage(int page) async {
    pageCalls++;
    if (pageDelay != null) await pageDelay;
    if (failure != null) throw failure!;
    return pages?[page] ??
        CharacterPage(
          characters: const <Character>[sampleCharacter],
          currentPage: page,
          hasNextPage: false,
        );
  }

  @override
  Future<List<Character>> searchByName(String name) async {
    if (failure != null) throw failure!;
    return searchResults;
  }
}

class FakeAuthRepository implements AuthRepository {
  AuthUser? currentUser;

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    if (currentUser == null) {
      throw const AppException(
        'Usuário ou senha inválidos.',
        type: AppFailureType.validation,
      );
    }
    return currentUser!;
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }

  @override
  Future<AuthUser> register({
    required String username,
    required String password,
  }) async {
    currentUser = AuthUser(id: username.toLowerCase(), displayName: username);
    return currentUser!;
  }

  @override
  Future<AuthUser?> restoreSession() async => currentUser;
}

class InMemoryCollectionRepository implements CollectionRepository {
  final Map<String, UserCollections> values = <String, UserCollections>{};
  bool failWrites = false;

  @override
  Future<UserCollections> load(String userId) async =>
      values[userId] ?? const UserCollections.empty();

  @override
  Future<void> saveFavorites(String userId, List<Character> characters) async {
    if (failWrites) {
      throw const AppException(
        'Falha ao salvar.',
        type: AppFailureType.storage,
      );
    }
    final UserCollections current =
        values[userId] ?? const UserCollections.empty();
    values[userId] = UserCollections(
      favorites: List<Character>.of(characters),
      watched: current.watched,
    );
  }

  @override
  Future<void> saveWatched(String userId, List<Character> characters) async {
    if (failWrites) {
      throw const AppException(
        'Falha ao salvar.',
        type: AppFailureType.storage,
      );
    }
    final UserCollections current =
        values[userId] ?? const UserCollections.empty();
    values[userId] = UserCollections(
      favorites: current.favorites,
      watched: List<Character>.of(characters),
    );
  }
}
