import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_message.dart';
import '../../../collections/presentation/providers/collection_provider.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../widgets/character_image.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.characterId, super.key});

  final int characterId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Character> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CharacterRepository>().getById(widget.characterId);
  }

  void _retry() {
    setState(() {
      _future = context.read<CharacterRepository>().getById(widget.characterId);
    });
  }

  Future<void> _toggleFavorite(Character character) async {
    final String? error = await context
        .read<CollectionProvider>()
        .toggleFavorite(character);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _toggleWatched(Character character) async {
    final String? error = await context
        .read<CollectionProvider>()
        .toggleWatched(character);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do personagem')),
      body: FutureBuilder<Character>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<Character> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: Semantics(
                label: 'Carregando detalhes do personagem',
                child: const CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return AsyncMessage(
              icon: Icons.cloud_off,
              title: 'Detalhes indisponíveis',
              message: snapshot.error?.toString() ?? 'Tente novamente.',
              actionLabel: 'Tentar novamente',
              onAction: _retry,
            );
          }
          return _DetailContent(
            character: snapshot.requireData,
            onToggleFavorite: _toggleFavorite,
            onToggleWatched: _toggleWatched,
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.character,
    required this.onToggleFavorite,
    required this.onToggleWatched,
  });

  final Character character;
  final ValueChanged<Character> onToggleFavorite;
  final ValueChanged<Character> onToggleWatched;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 11,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: CharacterImage(
                    imageUrl: character.imageUrl,
                    characterName: character.name,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                character.name,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Consumer<CollectionProvider>(
                builder: (BuildContext context, CollectionProvider state, _) {
                  final bool favorite = state.isFavorite(character.id);
                  final bool watched = state.isWatched(character.id);
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      ElevatedButton.icon(
                        key: const ValueKey<String>('favorite-button'),
                        onPressed: () => onToggleFavorite(character),
                        icon: Icon(favorite ? Icons.star : Icons.star_border),
                        label: Text(
                          favorite ? 'Remover dos favoritos' : 'Favoritar',
                        ),
                      ),
                      ElevatedButton.icon(
                        key: const ValueKey<String>('watched-button'),
                        onPressed: () => onToggleWatched(character),
                        icon: Icon(
                          watched
                              ? Icons.visibility
                              : Icons.visibility_outlined,
                        ),
                        label: Text(
                          watched
                              ? 'Marcar como não visto'
                              : 'Marcar como visto',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: <Widget>[
                      _Attribute(
                        label: 'Status',
                        value: _translate(character.status),
                      ),
                      _Attribute(label: 'Espécie', value: character.species),
                      _Attribute(
                        label: 'Tipo',
                        value: character.type.isEmpty
                            ? 'Não informado'
                            : character.type,
                      ),
                      _Attribute(
                        label: 'Gênero',
                        value: _translate(character.gender),
                      ),
                      _Attribute(label: 'Origem', value: character.origin),
                      _Attribute(
                        label: 'Última localização',
                        value: character.location,
                      ),
                      _Attribute(
                        label: 'Episódios',
                        value: character.episodeCount.toString(),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _translate(String value) => switch (value.toLowerCase()) {
    'alive' => 'Vivo',
    'dead' => 'Morto',
    'male' => 'Masculino',
    'female' => 'Feminino',
    'genderless' => 'Sem gênero',
    'unknown' => 'Desconhecido',
    _ => value,
  };
}

class _Attribute extends StatelessWidget {
  const _Attribute({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(value, textAlign: TextAlign.end)),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
