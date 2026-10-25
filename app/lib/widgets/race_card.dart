import 'package:flutter/material.dart';

import '../models/calendar_entry.dart';
import '../theme/app_theme.dart';

const _months = [
  'ENE',
  'FEB',
  'MAR',
  'ABR',
  'MAY',
  'JUN',
  'JUL',
  'AGO',
  'SEP',
  'OCT',
  'NOV',
  'DIC',
];

/// Una carrera del calendario. Si ya se disputó, es tocable y muestra el ganador.
class RaceCard extends StatelessWidget {
  const RaceCard({super.key, required this.entry, this.onTap});

  final CalendarEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final race = entry.race;
    final winner = entry.winner;
    final played = entry.played;
    final date = race.date?.toLocal();

    return Material(
      color: played ? AppColors.surface : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: played ? AppColors.border : AppColors.avatar),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onTap: played ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 52,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date == null ? '-' : _months[date.month - 1],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      date == null ? '-' : date.day.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'RONDA ${race.round}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: played
                            ? AppColors.accentSoft
                            : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      race.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: played ? AppColors.text : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${race.circuitName} · ${race.country}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: winner == null
                          ? const Text(
                              'Próximamente',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            )
                          : Row(
                              spacing: 6,
                              children: [
                                const Icon(
                                  Icons.emoji_events_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: 'Ganador: '),
                                        TextSpan(
                                          text: winner.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: teamColor(winner.teamId),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              if (played)
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
