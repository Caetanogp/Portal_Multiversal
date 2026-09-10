import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';
import 'character_card.dart';

class CharacterGrid extends StatelessWidget {
  const CharacterGrid({
    required this.characters,
    required this.onCharacterTap,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final List<Character> characters;
  final ValueChanged<Character> onCharacterTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    final double extraHeight = ((textScale - 1).clamp(0, 2)) * 54;
    return GridView.builder(
      key: const ValueKey<String>('character-grid'),
      padding: padding,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 230,
        mainAxisExtent: 270 + extraHeight,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: characters.length,
      itemBuilder: (BuildContext context, int index) {
        final Character character = characters[index];
        return CharacterCard(
          character: character,
          onTap: () => onCharacterTap(character),
        );
      },
    );
  }
}
