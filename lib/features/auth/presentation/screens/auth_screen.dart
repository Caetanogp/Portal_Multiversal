import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  bool _registerMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final AuthProvider provider = context.read<AuthProvider>();
    if (_registerMode) {
      await provider.register(
        username: _usernameController.text,
        password: _passwordController.text,
      );
    } else {
      await provider.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );
    }
  }

  void _toggleMode() {
    context.read<AuthProvider>().clearError();
    setState(() {
      _registerMode = !_registerMode;
      _confirmationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Semantics(
                      image: true,
                      label: 'Símbolo de portal multiversal',
                      child: ExcludeSemantics(
                        child: Icon(
                          Icons.blur_circular,
                          size: 88,
                          color: AppTheme.portalGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Portal Multiversal',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _registerMode
                          ? 'Crie uma conta local para explorar.'
                          : 'Entre para acessar o catálogo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      key: const ValueKey<String>('username-field'),
                      controller: _usernameController,
                      autofillHints: const <String>[AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (String? value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe o usuário.';
                        }
                        if (_registerMode && value!.trim().length < 3) {
                          return 'Use pelo menos 3 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey<String>('password-field'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const <String>[AutofillHints.password],
                      textInputAction: _registerMode
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onFieldSubmitted: _registerMode ? null : (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Mostrar senha'
                              : 'Ocultar senha',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (String? value) {
                        if ((value ?? '').isEmpty) return 'Informe a senha.';
                        if (_registerMode && value!.length < 4) {
                          return 'Use pelo menos 4 caracteres.';
                        }
                        return null;
                      },
                    ),
                    if (_registerMode) ...<Widget>[
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey<String>('confirmation-field'),
                        controller: _confirmationController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Confirmar senha',
                          prefixIcon: Icon(Icons.lock_reset),
                        ),
                        validator: (String? value) =>
                            value != _passwordController.text
                            ? 'As senhas não coincidem.'
                            : null,
                      ),
                    ],
                    Consumer<AuthProvider>(
                      builder: (BuildContext context, AuthProvider state, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            if (state.errorMessage != null) ...<Widget>[
                              const SizedBox(height: 14),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  state.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            ElevatedButton(
                              key: const ValueKey<String>('auth-submit-button'),
                              onPressed:
                                  state.status == AuthStatus.authenticating
                                  ? null
                                  : _submit,
                              child: state.status == AuthStatus.authenticating
                                  ? const SizedBox.square(
                                      dimension: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _registerMode ? 'Criar conta' : 'Entrar',
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const ValueKey<String>('toggle-auth-mode'),
                      onPressed: _toggleMode,
                      child: Text(
                        _registerMode
                            ? 'Já tenho conta'
                            : 'Ainda não tenho conta',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Acesso local para fins acadêmicos. Não reutilize uma senha real.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
