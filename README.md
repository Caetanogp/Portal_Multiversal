# Portal Multiversal

Aplicativo Flutter acadêmico que apresenta um catálogo interativo de personagens de **Rick and Morty**. O projeto consome a [Rick and Morty API](https://rickandmortyapi.com/documentation) e implementa os requisitos RF01–RF10 da atividade somativa de Desenvolvimento Mobile Híbrido.

**Integrantes:** Caetano Padoin, Davi Henrique, Matheus Brehm e Rafael Gabardo.

## Funcionalidades

- cadastro e login locais com sessão persistente;
- catálogo paginado em grade;
- busca por nome com abertura direta dos detalhes;
- detalhes completos obtidos em uma segunda requisição;
- favoritos e personagens vistos gerenciados globalmente com Provider;
- listas persistidas e separadas por usuário;
- carregamento, estados vazios, falhas amigáveis e nova tentativa;
- interface responsiva e acessível para leitor de tela e fonte ampliada.

## Stack

- Flutter 3.47.3 / Dart 3.13.3;
- `http` para API REST;
- `provider` para estado compartilhado;
- `shared_preferences` para contas, sessão e coleções locais;
- `crypto` para hash SHA-256 com salt das senhas locais.

O login é propositalmente local e serve apenas à demonstração acadêmica. Não reutilize uma senha real.

## Executar

Pré-requisitos: Flutter estável, Chrome para Web e Android Studio/SDK para Android.

```powershell
flutter pub get
flutter run -d chrome
```

Para Android, conecte um aparelho ou inicie um emulador e execute:

```powershell
flutter devices
flutter run -d <id-do-dispositivo>
```

Neste computador, o Flutter foi instalado em `E:\develop\flutter`. Se o terminal não o localizar, adicione temporariamente `E:\develop\flutter\bin` ao `PATH`.

## Arquitetura

O código usa organização por funcionalidade com camadas inspiradas em Clean Architecture:

- `domain`: entidades e contratos independentes de framework;
- `data`: API, modelos JSON, persistência e implementações;
- `presentation`: telas, widgets e `ChangeNotifier`s;
- `core`: tema, armazenamento, erros e widgets compartilhados.

As dependências são injetadas por construtor. O cliente HTTP e os repositórios podem ser substituídos por fakes, permitindo testes determinísticos sem acessar a internet.

## API e decisões de comportamento

- Base REST: `https://rickandmortyapi.com/api`.
- A listagem usa `/character?page=N` e acrescenta páginas sem duplicar IDs.
- A busca usa `/character?name=...`, prioriza nome exato sem diferenciar maiúsculas e, se necessário, abre o primeiro resultado.
- A tela de detalhes usa `/character/{id}` mesmo quando o personagem veio do catálogo ou da busca.
- Imagens indisponíveis são substituídas por um placeholder acessível.

## Qualidade

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test --coverage
flutter test integration_test/app_test.dart -d <id-android>
flutter build web
flutter build apk --debug
```

Consulte também:

- [Matriz RF01–RF10](docs/matriz_requisitos.md)
- [Checklist de validação manual](docs/validacao_manual.md)
- [Relatório de validação executada](docs/relatorio_validacao.md)
- [Modelo do PDF de entrega](docs/modelo_entrega.md)
- [Roteiro do vídeo](docs/roteiro_video.md)

## Persistência e privacidade

`shared_preferences` armazena dados simples no aparelho/navegador. As coleções são salvas como snapshots JSON sob chaves versionadas por usuário. Senhas não são armazenadas em texto puro, mas este mecanismo local não substitui autenticação real. Não há segredos, serviços em nuvem ou rastreamento no aplicativo.

## Entrega

O repositório não é criado nem publicado automaticamente. Antes da entrega, o grupo deve preencher nomes, links e screenshots no modelo, converter tudo em um único PDF e enviar exclusivamente pelo campo oficial do AVA.
