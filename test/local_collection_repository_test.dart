import 'package:flutter_test/flutter_test.dart';
import 'package:portal_multiversal/features/collections/data/repositories/local_collection_repository.dart';

import 'helpers/test_doubles.dart';

void main() {
  test('persiste snapshots e isola coleções por usuário', () async {
    final InMemoryStore store = InMemoryStore();
    final LocalCollectionRepository repository = LocalCollectionRepository(
      store,
    );

    await repository.saveFavorites('rick', const [sampleCharacter]);
    await repository.saveWatched('morty', const [secondCharacter]);

    final rick = await repository.load('rick');
    final morty = await repository.load('morty');
    expect(rick.favorites.single.name, 'Rick Sanchez');
    expect(rick.watched, isEmpty);
    expect(morty.favorites, isEmpty);
    expect(morty.watched.single.name, 'Morty Smith');
  });
}
