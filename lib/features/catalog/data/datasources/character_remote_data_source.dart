import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../models/character_model.dart';

class RemoteCharacterPage {
  const RemoteCharacterPage({
    required this.characters,
    required this.hasNextPage,
  });

  final List<CharacterModel> characters;
  final bool hasNextPage;
}

class CharacterRemoteDataSource {
  CharacterRemoteDataSource(
    this._client, {
    this.baseUrl = 'https://rickandmortyapi.com/api',
    this.timeout = const Duration(seconds: 12),
  });

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<RemoteCharacterPage> getPage(int page) async {
    final Map<String, Object?> json = await _getObject(
      Uri.parse('$baseUrl/character')
          .replace(queryParameters: <String, String>{'page': page.toString()}),
    );
    final Map<String, Object?> info = _asMap(json['info']);
    return RemoteCharacterPage(
      characters: _parseCharacters(json['results']),
      hasNextPage: info['next'] != null,
    );
  }

  Future<CharacterModel> getById(int id) async {
    final Map<String, Object?> json = await _getObject(
      Uri.parse('$baseUrl/character/$id'),
    );
    return CharacterModel.fromJson(json);
  }

  Future<List<CharacterModel>> searchByName(String name) async {
    final Map<String, Object?> json = await _getObject(
      Uri.parse('$baseUrl/character')
          .replace(queryParameters: <String, String>{'name': name}),
    );
    return _parseCharacters(json['results']);
  }

  Future<Map<String, Object?>> _getObject(Uri uri) async {
    try {
      final http.Response response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 404) {
        throw const AppException(
          'Nenhum personagem foi encontrado.',
          type: AppFailureType.notFound,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const AppException(
          'O portal está indisponível. Tente novamente em instantes.',
          type: AppFailureType.network,
        );
      }
      return _asMap(jsonDecode(response.body));
    } on AppException {
      rethrow;
    } on TimeoutException catch (_) {
      throw const AppException(
        'A conexão demorou demais. Verifique sua internet e tente novamente.',
        type: AppFailureType.network,
      );
    } on http.ClientException catch (_) {
      throw const AppException(
        'Não foi possível acessar a internet.',
        type: AppFailureType.network,
      );
    } on FormatException catch (_) {
      throw const AppException(
        'A API retornou uma resposta inválida.',
        type: AppFailureType.invalidData,
      );
    }
  }

  static List<CharacterModel> _parseCharacters(Object? value) {
    if (value is! List<Object?>) {
      throw const AppException(
        'A lista de personagens recebida é inválida.',
        type: AppFailureType.invalidData,
      );
    }
    return value
        .map((Object? item) => CharacterModel.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  static Map<String, Object?> _asMap(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map<Object?, Object?>) {
      return value.map(
        (Object? key, Object? item) => MapEntry(key.toString(), item),
      );
    }
    throw const AppException(
      'A API retornou uma resposta inválida.',
      type: AppFailureType.invalidData,
    );
  }
}
