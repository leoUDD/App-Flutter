import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const _bone = Color(0xFF24262E);
const _boneSoft = Color(0xFF1F2027);

/// Una pieza gris del "esqueleto": marca el lugar de algo que aún se está cargando.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
    this.soft = false,
  });

  final double? width;
  final double height;
  final double radius;

  /// Una versión más tenue, para textos secundarios.
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: soft ? _boneSoft : _bone,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _PodiumSkeleton extends StatelessWidget {
  const _PodiumSkeleton();

  Widget _card(double height, double avatar) {
    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          spacing: 10,
          children: [
            const SkeletonBox(width: 16, height: 18, radius: 4),
            SkeletonBox(width: avatar, height: avatar, radius: avatar / 2),
            const SkeletonBox(width: 64, height: 12),
            const SkeletonBox(width: 44, height: 10, soft: true),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [_card(158, 48), _card(186, 56), _card(146, 44)],
    );
  }
}

/// Esqueleto del Ranking (y del Resultado): título, podio y una lista de filas.
class StandingsSkeleton extends StatelessWidget {
  const StandingsSkeleton({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SkeletonHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 16),
        const _PodiumSkeleton(),
        const SizedBox(height: 16),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (var i = 0; i < 7; i++)
                Container(
                  height: 58,
                  padding: const EdgeInsets.fromLTRB(14, 0, 16, 0),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: _boneSoft)),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      const SkeletonBox(width: 18, height: 16, radius: 4),
                      const SkeletonBox(width: 36, height: 36, radius: 18),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            SkeletonBox(width: 120, height: 12),
                            SkeletonBox(width: 70, height: 10, soft: true),
                          ],
                        ),
                      ),
                      const SkeletonBox(width: 44, height: 16),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Esqueleto del Calendario: título, tarjeta de avance y varias tarjetas de carrera.
class CardsSkeleton extends StatelessWidget {
  const CardsSkeleton({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SkeletonHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 16),
        for (var i = 0; i < 6; i++) ...[
          Container(
            height: 88,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              spacing: 12,
              children: [
                SkeletonBox(width: 52, height: 60, radius: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      SkeletonBox(width: 60, height: 10, soft: true),
                      SkeletonBox(width: 150, height: 14),
                      SkeletonBox(width: 110, height: 10, soft: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
