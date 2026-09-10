class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.imageUrl,
    required this.episodeCount,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String origin;
  final String location;
  final String imageUrl;
  final int episodeCount;

  @override
  bool operator ==(Object other) => other is Character && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class CharacterPage {
  const CharacterPage({
    required this.characters,
    required this.currentPage,
    required this.hasNextPage,
  });

  final List<Character> characters;
  final int currentPage;
  final bool hasNextPage;
}
