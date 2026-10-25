
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = false;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final auth = Supabase.instance.client.auth;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isRegister) {
        final response = await auth.signUp(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (response.session == null) {
          _showMessage(
            'Cuenta creada. Revisa tu correo para confirmar.',
          );
        }
      } else {
        await auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (e) {
      if (mounted) {
        _showMessage('No fue posible conectarse a Supabase.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.sports_motorsports,
                    size: 64,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'F1 STATS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegister
                        ? 'CREAR UNA CUENTA'
                        : 'INICIAR SESIÓN',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email)) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if ((value?.length ?? 0) < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.all(18),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            _isRegister
                                ? 'REGISTRARSE'
                                : 'INGRESAR',
                          ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _isRegister = !_isRegister;
                            });
                          },
                    child: Text(
                      _isRegister
                          ? '¿Ya tienes cuenta? Inicia sesión'
                          : '¿No tienes cuenta? Regístrate',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
