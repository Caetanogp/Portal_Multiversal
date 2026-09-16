import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/storage/shared_preferences_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/local_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/catalog/data/datasources/character_remote_data_source.dart';
import 'features/catalog/data/repositories/character_repository_impl.dart';
import 'features/catalog/domain/repositories/character_repository.dart';
import 'features/catalog/presentation/providers/catalog_provider.dart';
import 'features/collections/data/repositories/local_collection_repository.dart';
import 'features/collections/domain/repositories/collection_repository.dart';
import 'features/collections/presentation/providers/collection_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';

class PortalMultiversalApp extends StatefulWidget {
  const PortalMultiversalApp({
    this.characterRepository,
    this.authRepository,
    this.collectionRepository,
    super.key,
  });

  final CharacterRepository? characterRepository;
  final AuthRepository? authRepository;
  final CollectionRepository? collectionRepository;

  @override
  State<PortalMultiversalApp> createState() => _PortalMultiversalAppState();
}

class _PortalMultiversalAppState extends State<PortalMultiversalApp> {
  http.Client? _httpClient;
  late final CharacterRepository _characterRepository;
  late final AuthRepository _authRepository;
  late final CollectionRepository _collectionRepository;

  @override
  void initState() {
    super.initState();
    final SharedPreferencesStore store = SharedPreferencesStore();
    _characterRepository =
        widget.characterRepository ?? _createRemoteRepository();
    _authRepository = widget.authRepository ?? LocalAuthRepository(store);
    _collectionRepository =
        widget.collectionRepository ?? LocalCollectionRepository(store);
  }

  CharacterRepository _createRemoteRepository() {
    _httpClient = http.Client();
    return CharacterRepositoryImpl(CharacterRemoteDataSource(_httpClient!));
  }

  @override
  void dispose() {
    _httpClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CharacterRepository>.value(value: _characterRepository),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(_authRepository)..restoreSession(),
        ),
        ChangeNotifierProvider<CatalogProvider>(
          create: (_) => CatalogProvider(_characterRepository),
        ),
        ChangeNotifierProvider<CollectionProvider>(
          create: (_) => CollectionProvider(_collectionRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Portal Multiversal',
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (BuildContext context, AuthProvider auth, _) {
        if (auth.status == AuthStatus.bootstrapping) {
          return Scaffold(
            body: Center(
              child: Semantics(
                label: 'Restaurando sessão',
                child: const CircularProgressIndicator(),
              ),
            ),
          );
        }
        if (auth.status == AuthStatus.authenticated && auth.user != null) {
          return HomeScreen(
            key: ValueKey<String>(auth.user!.id),
            user: auth.user!,
          );
        }
        return const AuthScreen();
      },
    );
  }
}
