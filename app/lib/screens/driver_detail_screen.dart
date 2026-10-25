import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'comparison_screen.dart';

import '../models/driver_standing.dart';
import '../models/driver_season_stats.dart';
import '../services/driver_stats_service.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';

class DriverDetailScreen extends StatefulWidget {
  const DriverDetailScreen({
    super.key,
    required this.standing,
    required this.season,
  });

  final DriverStanding standing;
  final int season;

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  final DriverStatsService _service = DriverStatsService();

  late Future<DriverSeasonStats> _futureStats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _futureStats = _service.getSeasonStats(
      season: widget.season,
      driverId: widget.standing.driverId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ficha de piloto')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _DriverHeader(standing: widget.standing, season: widget.season),

          const SizedBox(height: 16),

          FutureBuilder<DriverSeasonStats>(
            future: _futureStats,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(48),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.accent),
                      SizedBox(height: 18),
                      Text(
                        'Cargando estadísticas...',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return _MessageCard(
                  message: 'No se pudieron cargar las estadísticas.',
                  action: TextButton.icon(
                    onPressed: () {
                      setState(_loadStats);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                );
              }

              final stats = snapshot.data;

              if (stats == null || stats.races == 0) {
                return const _MessageCard(
                  message:
                      'Todavía no hay resultados disponibles '
                      'para este piloto en esta temporada.',
                );
              }

              return _StatisticsContent(
                stats: stats,
                initialDriverId: widget.standing.driverId,
              );
            },
          ),
        ],
      ),
    );
  }
}

// Cabecera con datos del piloto y animación Hero.
class _DriverHeader extends StatelessWidget {
  const _DriverHeader({required this.standing, required this.season});

  final DriverStanding standing;
  final int season;

  @override
  Widget build(BuildContext context) {
    final s = standing;
    final color = teamColor(s.teamId);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: 0.10),
          AppColors.surface,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            top: -40,
            child: IgnorePointer(
              child: Text(
                s.number ?? '',
                style: GoogleFonts.saira(
                  fontSize: 180,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: color.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'driver-${s.driverId}-$season',
                      child: DriverAvatar(
                        initials: s.initials,
                        size: 72,
                        fontSize: 26,
                        ringColor: color,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.givenName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            s.familyName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.saira(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: s.teamName, color: color),
                    _InfoChip(label: s.nationality, color: AppColors.textMuted),
                    if (s.number != null)
                      _InfoChip(
                        label: 'N.º ${s.number}',
                        color: AppColors.textMuted,
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                const Divider(color: AppColors.border),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Campeonato $season',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'P${s.position ?? "—"}  ·  ',
                            style: GoogleFonts.saira(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: s.pointsLabel,
                            style: GoogleFonts.saira(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: ' PTS',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// Estadísticas obtenidas de Jolpica.
class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({
    required this.stats,
    required this.initialDriverId,
  });

  final DriverSeasonStats stats;
  final String initialDriverId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _NumberCard(title: 'CARRERAS', value: '${stats.races}'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberCard(title: 'VICTORIAS', value: '${stats.wins}'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberCard(title: 'PODIOS', value: '${stats.podiums}'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _PercentageCard(
                title: '% de victorias',
                percentage: stats.winRate,
                description: '${stats.wins} de ${stats.races} carreras',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PercentageCard(
                title: '% de podios',
                percentage: stats.podiumRate,
                description: '${stats.podiums} de ${stats.races} carreras',
                color: AppColors.text,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ComparisonScreen(
                  initialDriverId: initialDriverId,
                  showBackButton: true,
                ),
              ),
            );
          },
          icon: const Icon(Icons.compare_arrows),
          label: const Text('Comparar con otro piloto'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.40),
            disabledForegroundColor: AppColors.text,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ],
    );
  }
}

// Tarjetas de carreras, victorias y podios.
class _NumberCard extends StatelessWidget {
  const _NumberCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.saira(
              fontSize: 40,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// Porcentaje circular con animación.
class _PercentageCard extends StatelessWidget {
  const _PercentageCard({
    required this.title,
    required this.percentage,
    required this.description,
    required this.color,
  });

  final String title;
  final double percentage;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = percentage.clamp(0.0, 100.0) / 100.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 950),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 94,
                height: 94,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.border,
                        color: color,
                      ),
                    ),
                    Text(
                      '${(value * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.saira(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// Mensajes para error o ausencia de resultados.
class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
