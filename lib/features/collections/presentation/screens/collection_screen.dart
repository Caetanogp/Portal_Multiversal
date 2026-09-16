import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_message.dart';
import '../../../catalog/domain/entities/character.dart';
import '../../../catalog/presentation/screens/detail_screen.dart';
import '../../../catalog/presentation/widgets/character_grid.dart';
import '../providers/collection_provider.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({required this.showWatched, super.key});

  final bool showWatched;

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionProvider>(
      builder: (BuildContext context, CollectionProvider state, _) {
        if (state.isLoading) {
          return Center(
            child: Semantics(
              label: 'Carregando listas salvas',
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (state.errorMessage != null) {
          return AsyncMessage(
            icon: Icons.storage_outlined,
            title: 'Listas indisponíveis',
            message: state.errorMessage!,
          );
        }
        final List<Character> characters = showWatched
            ? state.watched
            : state.favorites;
        if (characters.isEmpty) {
          return AsyncMessage(
            icon: showWatched ? Icons.visibility_outlined : Icons.star_border,
            title: showWatched ? 'Nenhum personagem visto' : 'Nenhum favorito',
            message: showWatched
                ? 'Marque personagens como vistos na tela de detalhes.'
                : 'Favorite personagens na tela de detalhes.',
          );
        }
        return CharacterGrid(
          characters: characters,
          onCharacterTap: (Character character) {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => DetailScreen(characterId: character.id),
              ),
            );
          },
        );
      },
    );
  }
}
