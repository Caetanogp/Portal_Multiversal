# Checklist de validação manual

Registrar data, dispositivo e resultado de cada execução antes de gravar o vídeo.

## Fluxo funcional

- [ ] Instalação nova abre Login, nunca o catálogo.
- [ ] Cadastro mostra indicador, valida confirmação e abre o catálogo.
- [ ] Logout retorna ao Login; novo login restaura o acesso.
- [ ] Catálogo apresenta cards em GridView com imagem e nome.
- [ ] “Carregar Mais” acrescenta 20 itens sem apagar os anteriores.
- [ ] Card abre detalhes e dispara uma requisição por ID.
- [ ] Busca vazia é rejeitada; busca válida abre detalhes diretamente.
- [ ] Busca inexistente mostra mensagem amigável.
- [ ] Favoritar/desfavoritar atualiza detalhes e Favoritos imediatamente.
- [ ] Marcar/desmarcar Visto atualiza detalhes e Vistos imediatamente.
- [ ] Fechar completamente e reabrir preserva sessão, Favoritos e Vistos.
- [ ] Uma segunda conta não enxerga coleções da primeira.

## Rede e imagens

- [ ] Sem internet no carregamento inicial: indicador, erro amigável e “Tentar novamente”.
- [ ] Falha durante “Carregar Mais”: cards anteriores permanecem visíveis.
- [ ] Falha durante busca/detalhe: app não fecha e informa o problema.
- [ ] URL de imagem inválida apresenta placeholder e não quebra o card.

## Acessibilidade

- [ ] TalkBack anuncia login, busca, cards, imagens, favorito, visto e logout.
- [ ] Todos os controles são acionáveis sem precisão excessiva de toque.
- [ ] Contraste mantém textos legíveis no tema escuro.
- [ ] Fonte do Android no maior tamanho não provoca overflow ou texto inacessível.
- [ ] Tela estreita empilha campo e botão de busca.
- [ ] Orientação retrato funciona nas telas principais.

## Evidências

- [ ] Screenshot do Login.
- [ ] Screenshot do Catálogo.
- [ ] Screenshot dos Detalhes.
- [ ] Screenshot dos Favoritos.
- [ ] Screenshot dos Vistos.
- [ ] Registrar saída de `flutter analyze`, `flutter test`, build Web e build Android.
