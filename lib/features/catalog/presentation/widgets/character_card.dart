import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';
import 'character_image.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    required this.character,
    required this.onTap,
    super.key,
  });

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir detalhes de ${character.name}',
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: CharacterImage(
                  imageUrl: character.imageUrl,
                  characterName: character.name,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  character.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
