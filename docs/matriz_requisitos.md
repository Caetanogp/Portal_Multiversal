# Matriz de atendimento aos requisitos

| RF | Status | Implementação principal | Evidência |
|---|---|---|---|
| RF01 — Catálogo e paginação | Sim | `catalog_screen.dart`, `character_grid.dart`, `catalog_provider.dart` | GridView, placeholder e botão “Carregar Mais”; teste de provider e widget |
| RF02 — Navegação | Sim | `catalog_screen.dart`, `collection_screen.dart` | `Navigator.push` ao tocar em card; fluxo integrado |
| RF03 — Detalhes | Sim | `detail_screen.dart`, `character_remote_data_source.dart` | `FutureBuilder`, chamada por ID e atributos completos; teste de widget/API |
| RF04 — Favoritos com Provider | Sim | `collection_provider.dart`, `detail_screen.dart` | `ChangeNotifier` global e alternância imediata; teste de provider |
| RF05 — Tela de Favoritos | Sim | `collection_screen.dart`, `home_screen.dart` | Aba própria reativa; fluxo integrado |
| RF06 — Persistência local | Sim | `local_collection_repository.dart`, `shared_preferences_store.dart` | Snapshots versionados por usuário; testes de persistência/restauração |
| RF07 — Login e Vistos | Sim | `auth_screen.dart`, `local_auth_repository.dart`, `collection_screen.dart` | Gate de sessão, cadastro/login, logout e aba Vistos; testes unitários/integrados |
| RF08 — Busca | Sim | `catalog_screen.dart`, `catalog_provider.dart` | TextField + TextEditingController + botão Buscar + detalhe direto; testes de busca/widget |
| RF09 — Feedback de UI | Sim | telas de autenticação, catálogo, detalhe e coleções | Indicadores em operações assíncronas e mensagens amigáveis; testes de erros/API |
| RF10 — Acessibilidade | Sim | tema e widgets de apresentação | Semantics, labels, tooltips, 48×48, grade adaptativa e testes `meetsGuideline` |

## Organização por camada

- Entidades e contratos: `lib/features/*/domain/`.
- API e persistência: `lib/features/*/data/` e `lib/core/storage/`.
- Estado e interface: `lib/features/*/presentation/`.
- Composição/injeção: `lib/app.dart`.
- Testes: `test/` e `integration_test/`.

## Observação sobre bônus

O projeto implementa o baseline obrigatório com persistência e login locais. Firebase/Supabase e autenticação real não fazem parte desta versão.
