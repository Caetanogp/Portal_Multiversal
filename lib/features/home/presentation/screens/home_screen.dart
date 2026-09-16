import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../catalog/presentation/providers/catalog_provider.dart';
import '../../../catalog/presentation/screens/catalog_screen.dart';
import '../../../collections/presentation/providers/collection_provider.dart';
import '../../../collections/presentation/screens/collection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.user, super.key});

  final AuthUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = <String>[
    'Catálogo Multiversal',
    'Favoritos',
    'Personagens vistos',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<CatalogProvider>().loadInitial());
      unawaited(context.read<CollectionProvider>().loadForUser(widget.user.id));
    });
  }

  Future<void> _logout() async {
    context.read<CollectionProvider>().clear();
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    const List<Widget> screens = <Widget>[
      CatalogScreen(),
      CollectionScreen(showWatched: false),
      CollectionScreen(showWatched: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_titles[_selectedIndex]),
            Text(
              'Olá, ${widget.user.displayName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sair da conta',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.visibility_outlined),
            selectedIcon: Icon(Icons.visibility),
            label: 'Vistos',
          ),
        ],
      ),
    );
  }
}
