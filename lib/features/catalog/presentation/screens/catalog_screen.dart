import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_message.dart';
import '../../domain/entities/character.dart';
import '../providers/catalog_provider.dart';
import '../widgets/character_grid.dart';
import 'detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    final CatalogProvider provider = context.read<CatalogProvider>();
    final Character? character = await provider.search(_searchController.text);
    if (!mounted) return;
    if (character == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.searchError ?? 'Personagem não encontrado.'),
        ),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(characterId: character.id),
      ),
    );
  }

  void _openCharacter(Character character) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(characterId: character.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget field = TextField(
                key: const ValueKey<String>('search-field'),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: const InputDecoration(
                  labelText: 'Nome do personagem',
                  hintText: 'Ex.: Rick Sanchez',
                  prefixIcon: Icon(Icons.search),
                ),
              );
              final Widget button = Consumer<CatalogProvider>(
                builder: (BuildContext context, CatalogProvider state, _) {
                  return ElevatedButton(
                    key: const ValueKey<String>('search-button'),
                    onPressed: state.isSearching ? null : _search,
                    child: state.isSearching
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Buscar'),
                  );
                },
              );
              final double textScale = MediaQuery.textScalerOf(context)
                  .scale(1);
              if (constraints.maxWidth < 440 || textScale > 1.3) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[field, const SizedBox(height: 8), button],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: field),
                  const SizedBox(width: 8),
                  button,
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Consumer<CatalogProvider>(
              builder: (BuildContext context, CatalogProvider state, _) {
                final bool isLoading = state.status == CatalogStatus.loading;
                final String actionLabel = isLoading
                    ? 'Atualizando catálogo'
                    : 'Atualizar catálogo';
                return Semantics(
                  button: true,
                  label: actionLabel,
                  liveRegion: isLoading,
                  child: IconButton(
                    key: const ValueKey<String>('refresh-catalog-button'),
                    tooltip: actionLabel,
                    onPressed: isLoading
                        ? null
                        : () => state.loadInitial(force: true),
                    icon: isLoading
                        ? const SizedBox.square(
                            key: ValueKey<String>('refresh-catalog-progress'),
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Consumer<CatalogProvider>(
            builder: (BuildContext context, CatalogProvider state, _) {
              if (state.status == CatalogStatus.loading) {
                return Center(
                  child: Semantics(
                    label: 'Carregando catálogo',
                    child: const CircularProgressIndicator(),
                  ),
                );
              }
              if (state.status == CatalogStatus.error) {
                return AsyncMessage(
                  icon: Icons.cloud_off,
                  title: 'Não foi possível abrir o portal',
                  message: state.errorMessage ?? 'Tente novamente.',
                  actionLabel: 'Tentar novamente',
                  onAction: () => state.loadInitial(force: true),
                );
              }
              return Column(
                children: <Widget>[
                  Expanded(
                    child: CharacterGrid(
                      characters: state.characters,
                      onCharacterTap: _openCharacter,
                    ),
                  ),
                  if (state.paginationError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        state.paginationError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const ValueKey<String>('load-more-button'),
                        onPressed: state.hasNextPage && !state.isLoadingMore
                            ? state.loadMore
                            : null,
                        child: state.isLoadingMore
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                state.hasNextPage
                                    ? 'Carregar Mais'
                                    : 'Todos os personagens foram carregados',
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
