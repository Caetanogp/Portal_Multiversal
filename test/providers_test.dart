import 'package:flutter_test/flutter_test.dart';
import 'package:portal_multiversal/features/catalog/domain/entities/character.dart';
import 'package:portal_multiversal/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:portal_multiversal/features/collections/presentation/providers/collection_provider.dart';

import 'helpers/test_doubles.dart';

void main() {
  test('CatalogProvider acumula páginas e remove IDs duplicados', () async {
    final FakeCharacterRepository repository = FakeCharacterRepository(
      pages: <int, CharacterPage>{
        1: const CharacterPage(
          characters: <Character>[sampleCharacter],
          currentPage: 1,
          hasNextPage: true,
        ),
        2: const CharacterPage(
          characters: <Character>[sampleCharacter, secondCharacter],
          currentPage: 2,
          hasNextPage: false,
        ),
      },
    );
    final CatalogProvider provider = CatalogProvider(repository);

    await provider.loadInitial();
    await provider.loadMore();

    expect(provider.characters.map((item) => item.id), <int>[1, 2]);
    expect(provider.hasNextPage, isFalse);
  });

  test('busca prioriza nome exato sem diferenciar maiúsculas', () async {
    final CatalogProvider provider = CatalogProvider(
      FakeCharacterRepository(
        searchResults: const <Character>[secondCharacter, sampleCharacter],
      ),
    );

    expect((await provider.search('RICK SANCHEZ'))?.id, 1);
  });

  test(
    'CollectionProvider alterna, persiste e restaura após recarregar',
    () async {
      final InMemoryCollectionRepository repository =
          InMemoryCollectionRepository();
      final CollectionProvider provider = CollectionProvider(repository);
      await provider.loadForUser('rick');

      expect(await provider.toggleFavorite(sampleCharacter), isNull);
      expect(await provider.toggleWatched(sampleCharacter), isNull);
      final CollectionProvider restored = CollectionProvider(repository);
      await restored.loadForUser('rick');

      expect(restored.isFavorite(1), isTrue);
      expect(restored.isWatched(1), isTrue);
    },
  );

  test('CollectionProvider desfaz alteração quando a gravação falha', () async {
    final InMemoryCollectionRepository repository =
        InMemoryCollectionRepository()..failWrites = true;
    final CollectionProvider provider = CollectionProvider(repository);
    await provider.loadForUser('rick');

    expect(await provider.toggleFavorite(sampleCharacter), isNotNull);
    expect(provider.favorites, isEmpty);
  });
}
