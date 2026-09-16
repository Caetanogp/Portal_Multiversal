import 'package:flutter_test/flutter_test.dart';
import 'package:portal_multiversal/core/errors/app_exception.dart';
import 'package:portal_multiversal/features/catalog/data/models/character_model.dart';

void main() {
  test('converte JSON completo em entidade', () {
    final CharacterModel model = CharacterModel.fromJson(<String, Object?>{
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'type': '',
      'gender': 'Male',
      'origin': <String, Object?>{'name': 'Earth'},
      'location': <String, Object?>{'name': 'Citadel'},
      'image': 'https://example.com/rick.jpg',
      'episode': <Object?>['one', 'two'],
    });

    expect(model.toEntity().name, 'Rick Sanchez');
    expect(model.toEntity().episodeCount, 2);
  });

  test('snapshot persiste e restaura a quantidade de episódios', () {
    final CharacterModel original = CharacterModel.fromJson(<String, Object?>{
      'id': 1,
      'name': 'Rick',
      'origin': <String, Object?>{'name': 'Earth'},
      'location': <String, Object?>{'name': 'Mars'},
      'episodeCount': 8,
    });

    final CharacterModel restored = CharacterModel.fromJson(original.toJson());
    expect(restored.episodeCount, 8);
  });

  test('rejeita JSON sem campos essenciais', () {
    expect(
      () => CharacterModel.fromJson(<String, Object?>{'name': 'Sem id'}),
      throwsA(isA<AppException>()),
    );
  });
}
