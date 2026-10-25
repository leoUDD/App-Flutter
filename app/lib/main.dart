import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'providers/season_provider.dart';
import 'screens/home_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/saved_comparisons_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de Supabase
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError('Falta configurar Supabase con --dart-define-from-file');
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  runApp(
    ChangeNotifierProvider(
      create: (_) => SeasonProvider(),
      child: const F1StatsApp(),
    ),
  );
}

class F1StatsApp extends StatelessWidget {
  const F1StatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'F1 Stats',
      theme: buildAppTheme(),
      home: const AuthGate(),
    );
  }
}

// Decide si mostrar Login o la aplicación.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;

        if (session == null) {
          return const AuthScreen();
        }

        return const _AuthenticatedHome();
      },
    );
  }
}

// Aplicación principal cuando el usuario inició sesión.
class _AuthenticatedHome extends StatelessWidget {
  const _AuthenticatedHome();

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return Scaffold(
      body: Column(
        children: [
          Material(
            color: AppColors.surface,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const SizedBox(width: 12),

                  // Icono del usuario
                  const Icon(Icons.account_circle, color: AppColors.accent),

                  const SizedBox(width: 8),

                  // Correo del usuario autenticado
                  Expanded(
                    child: Text(
                      auth.currentUser?.email ?? 'Usuario',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  // NUEVO: acceso a comparaciones guardadas
                  IconButton(
                    tooltip: 'Mis comparaciones',
                    icon: const Icon(Icons.bookmarks_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SavedComparisonsScreen(),
                        ),
                      );
                    },
                  ),

                  // Cerrar sesión
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      try {
                        await auth.signOut();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se pudo cerrar sesión.'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Mantiene las pantallas existentes
          const Expanded(child: HomeShell()),
        ],
      ),
    );
  }
}
