import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/character.dart';

class CharacterModel {
  const CharacterModel({
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

  factory CharacterModel.fromJson(Map<String, Object?> json) {
    try {
      final Map<String, Object?> origin = _map(json['origin']);
      final Map<String, Object?> location = _map(json['location']);
      final Object? episodes = json['episode'];
      return CharacterModel(
        id: json['id'] as int,
        name: json['name'] as String,
        status: (json['status'] as String?) ?? 'unknown',
        species: (json['species'] as String?) ?? 'unknown',
        type: (json['type'] as String?) ?? '',
        gender: (json['gender'] as String?) ?? 'unknown',
        origin: (origin['name'] as String?) ?? 'unknown',
        location: (location['name'] as String?) ?? 'unknown',
        imageUrl: (json['image'] as String?) ?? '',
        episodeCount: episodes is List<Object?>
            ? episodes.length
            : (json['episodeCount'] as int?) ?? 0,
      );
    } on Object catch (_) {
      throw const AppException(
        'A API retornou dados de personagem inválidos.',
        type: AppFailureType.invalidData,
      );
    }
  }

  factory CharacterModel.fromEntity(Character character) => CharacterModel(
    id: character.id,
    name: character.name,
    status: character.status,
    species: character.species,
    type: character.type,
    gender: character.gender,
    origin: character.origin,
    location: character.location,
    imageUrl: character.imageUrl,
    episodeCount: character.episodeCount,
  );

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

  Character toEntity() => Character(
    id: id,
    name: name,
    status: status,
    species: species,
    type: type,
    gender: gender,
    origin: origin,
    location: location,
    imageUrl: imageUrl,
    episodeCount: episodeCount,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'type': type,
    'gender': gender,
    'origin': <String, Object?>{'name': origin},
    'location': <String, Object?>{'name': location},
    'image': imageUrl,
    'episodeCount': episodeCount,
  };

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map<Object?, Object?>) {
      return value.map(
        (Object? key, Object? item) => MapEntry(key.toString(), item),
      );
    }
    return <String, Object?>{};
  }
}
