import 'package:flutter/material.dart';

import '../models/driver_standing.dart';
import '../theme/app_theme.dart';
import 'driver_avatar.dart';

class PodiumCard extends StatelessWidget {
  const PodiumCard({
    super.key,
    required this.standing,
    required this.place,
    required this.seasonFinished,
  });

  final DriverStanding standing;
  final int place; // 1, 2 o 3
  final bool seasonFinished;

  bool get _isChampion => place == 1;

  // Altura mínima: da el efecto de escalón. Si el contenido necesita más
  // (por ejemplo, con texto grande), la tarjeta crece en vez de desbordarse.
  double get _minHeight => switch (place) {
    1 => 218.0,
    2 => 184.0,
    _ => 172.0,
  };

  double get _avatarSize => switch (place) {
    1 => 56.0,
    2 => 48.0,
    _ => 44.0,
  };

  double get _avatarFont => switch (place) {
    1 => 19.0,
    2 => 17.0,
    _ => 16.0,
  };

  /// Oro, plata y bronce: el borde y el número de cada tarjeta.
  Color get _medalColor => switch (place) {
    1 => AppColors.gold,
    2 => AppColors.silver,
    _ => AppColors.bronze,
  };

  @override
  Widget build(BuildContext context) {
    final s = standing;
    return Container(
      constraints: BoxConstraints(minHeight: _minHeight),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: _isChampion ? AppColors.championSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _medalColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (_isChampion)
            Text(
              seasonFinished ? 'CAMPEÓN' : 'LÍDER',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.gold,
              ),
            ),
          Text(
            '$place',
            style: TextStyle(
              fontSize: _isChampion ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: _medalColor,
              height: 1,
            ),
          ),
          DriverAvatar(
            initials: s.initials,
            size: _avatarSize,
            fontSize: _avatarFont,
            ringColor: teamColor(s.teamId),
          ),
          Text(
            s.familyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _isChampion ? 15 : 14,
              fontWeight: _isChampion ? FontWeight.w700 : FontWeight.w600,
              height: 1.1,
            ),
          ),
          Text(
            s.teamName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              height: 1,
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: s.pointsLabel,
                  style: TextStyle(
                    fontSize: _isChampion ? 24 : 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: ' PTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Podium extends StatelessWidget {
  const Podium({super.key, required this.top3, required this.seasonFinished});

  /// `true` si la temporada ya terminó (el 1.º es CAMPEÓN); si no, es LÍDER.
  final bool seasonFinished;

  /// Los tres primeros, en orden: 1.º, 2.º y 3.º.
  final List<DriverStanding> top3;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [
        Expanded(
          child: PodiumCard(
            standing: top3[1],
            place: 2,
            seasonFinished: seasonFinished,
          ),
        ),
        Expanded(
          child: PodiumCard(
            standing: top3[0],
            place: 1,
            seasonFinished: seasonFinished,
          ),
        ),
        Expanded(
          child: PodiumCard(
            standing: top3[2],
            place: 3,
            seasonFinished: seasonFinished,
          ),
        ),
      ],
    );
  }
}
