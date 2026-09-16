import '../../../catalog/domain/entities/character.dart';

class UserCollections {
  const UserCollections({required this.favorites, required this.watched});

  const UserCollections.empty()
    : favorites = const <Character>[],
      watched = const <Character>[];

  final List<Character> favorites;
  final List<Character> watched;
}
