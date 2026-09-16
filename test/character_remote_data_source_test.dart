import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:portal_multiversal/core/errors/app_exception.dart';
import 'package:portal_multiversal/features/catalog/data/datasources/character_remote_data_source.dart';

void main() {
  const String characterJson = '''
    {"id":1,"name":"Rick Sanchez","status":"Alive","species":"Human",
    "type":"","gender":"Male","origin":{"name":"Earth"},
    "location":{"name":"Citadel"},"image":"image.jpg","episode":["1"]}
  ''';

  test('interpreta página e presença de próxima página', () async {
    final CharacterRemoteDataSource source = CharacterRemoteDataSource(
      MockClient(
        (_) async => http.Response(
          '{"info":{"next":"page2"},"results":[$characterJson]}',
          200,
        ),
      ),
    );

    final RemoteCharacterPage page = await source.getPage(1);
    expect(page.characters.single.name, 'Rick Sanchez');
    expect(page.hasNextPage, isTrue);
  });

  test('converte 404 em falha de item inexistente', () async {
    final CharacterRemoteDataSource source = CharacterRemoteDataSource(
      MockClient((_) async => http.Response('{"error":"missing"}', 404)),
    );

    expect(
      source.searchByName('ninguém'),
      throwsA(
        isA<AppException>().having(
          (AppException error) => error.type,
          'type',
          AppFailureType.notFound,
        ),
      ),
    );
  });

  test('converte erro de servidor em falha de rede', () async {
    final CharacterRemoteDataSource source = CharacterRemoteDataSource(
      MockClient((_) async => http.Response('erro', 500)),
    );

    expect(source.getPage(1), throwsA(isA<AppException>()));
  });

  test('rejeita corpo JSON inválido', () async {
    final CharacterRemoteDataSource source = CharacterRemoteDataSource(
      MockClient((_) async => http.Response('não é json', 200)),
    );

    expect(
      source.getById(1),
      throwsA(
        isA<AppException>().having(
          (AppException error) => error.type,
          'type',
          AppFailureType.invalidData,
        ),
      ),
    );
  });
}
