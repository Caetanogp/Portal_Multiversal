import 'package:flutter/material.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({
    required this.imageUrl,
    required this.characterName,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imageUrl;
  final String characterName;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _Placeholder(characterName: characterName);
    return Image.network(
      imageUrl,
      fit: fit,
      width: double.infinity,
      semanticLabel: 'Imagem de $characterName',
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) return child;
            final int? total = progress.expectedTotalBytes;
            return Center(
              child: Semantics(
                label: 'Carregando imagem de $characterName',
                child: CircularProgressIndicator(
                  value: total == null
                      ? null
                      : progress.cumulativeBytesLoaded / total,
                ),
              ),
            );
          },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _Placeholder(characterName: characterName),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.characterName});

  final String characterName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Imagem indisponível para $characterName',
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: ExcludeSemantics(child: Icon(Icons.person_off, size: 56)),
        ),
      ),
    );
  }
}
