# Relatório de validação executada

**Data:** 09/09/2026
**Ambiente:** Windows 10, Flutter 3.47.3, Dart 3.13.3, Chrome 152 e Android API 36.1.

## Resultado automatizado

| Verificação | Resultado |
|---|---|
| Formatação de `lib`, `test` e `integration_test` | Aprovada — 37 arquivos sem alteração pendente |
| `flutter analyze` | Aprovada — nenhum problema encontrado |
| `flutter test --coverage` | Aprovada — 20 testes |
| Cobertura de linhas | 518/688 — 75,3% |
| Teste integrado Android | Aprovado — cadastro → catálogo → detalhe → favorito/visto → listas |
| Build Web | Aprovado — `build/web/` |
| Build APK debug | Aprovado — `build/app/outputs/flutter-apk/app-debug.apk` |
| Smoke test da API real | Aprovado — 20 itens na página 1, próxima página e detalhe por ID |
| Varredura por segredos | Aprovada — nenhum padrão encontrado nos fontes de produção |

## Cenários cobertos

- Modelo completo, snapshot persistido e JSON inválido.
- Página válida, 404, erro de servidor e corpo inválido da API.
- Cadastro, hash sem senha em texto puro, login case-insensitive, sessão, logout e falha de armazenamento.
- Persistência e isolamento de Favoritos/Vistos por usuário.
- Paginação acumulada com deduplicação e busca com prioridade exata.
- Atualização global das coleções e rollback em falha de gravação.
- Validação da tela de autenticação, GridView, busca e segunda chamada de detalhe.
- Diretrizes automatizadas de contraste, rótulo e alvo de toque.
- Tela estreita com escala de texto 2× sem overflow.

## Validação dos requisitos

RF01–RF10 possuem implementação e evidência automatizada ou estrutural registrada em `docs/matriz_requisitos.md`. A conferência com TalkBack, reinício físico do aplicativo, screenshots e gravação do vídeo continua sendo uma etapa manual de entrega e está detalhada em `docs/validacao_manual.md`.

## Observações do ambiente

- O Flutter foi instalado em `E:\develop\flutter`.
- Caches de Pub/Gradle e a pasta de build foram direcionados ao disco E: devido ao espaço reduzido no C:.
- O AVD `Medium_Phone_API_36.1` está configurado para usar `E:\android-avd\Medium_Phone.avd`.
- O teste integrado foi executado no Android porque `flutter test -d chrome` não oferece suporte a integration tests nesta versão do runner.
- Nenhuma operação Git foi executada pelo assistente. A inicialização, os commits e o push devem ser realizados manualmente pelos integrantes após a revisão dos lotes.
