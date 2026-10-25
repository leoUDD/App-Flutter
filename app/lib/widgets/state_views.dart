import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/error_info.dart';

/// Estructura común de las vistas de error y vacío: un título opcional arriba
/// (el de la pantalla) y el contenido centrado.
class _StateLayout extends StatelessWidget {
  const _StateLayout({required this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _circleIcon(IconData icon, {required bool danger}) {
  return Container(
    width: 96,
    height: 96,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: danger
          ? AppColors.accent.withValues(alpha: 0.12)
          : AppColors.surface,
      border: Border.all(
        color: danger
            ? AppColors.accent.withValues(alpha: 0.35)
            : AppColors.border,
      ),
    ),
    child: Icon(
      icon,
      size: 40,
      color: danger ? AppColors.accentSoft : AppColors.textMuted,
    ),
  );
}

/// La pantalla cuando una consulta falla: ícono, qué pasó, y un botón para reintentar.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.what = 'los datos',
    this.title,
  });

  final Object error;
  final VoidCallback onRetry;

  /// Lo que no se pudo cargar, para el mensaje ("la clasificación").
  final String what;

  /// Título de la pantalla, que se muestra arriba (opcional).
  final String? title;

  @override
  Widget build(BuildContext context) {
    final info = describeError(error);
    return _StateLayout(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          _circleIcon(info.icon, danger: true),
          Column(
            spacing: 6,
            children: [
              Text(
                info.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 26),
              ),
              Text(
                'No pudimos cargar $what. ${info.hint}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 52),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            'Código: ${info.code}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A8C98)),
          ),
        ],
      ),
    );
  }
}

/// La pantalla cuando la consulta salió bien pero no hay nada que mostrar.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.heading,
    required this.message,
    this.title,
    this.icon = Icons.flag_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String heading;
  final String message;
  final String? title;
  final IconData icon;

  /// Botón opcional (por ejemplo, "Ver temporada 2025").
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          _circleIcon(icon, danger: false),
          Column(
            spacing: 6,
            children: [
              Text(
                heading,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 26, height: 1.15),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null)
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                foregroundColor: AppColors.text,
                side: const BorderSide(color: Color(0xFF4A4C57)),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
