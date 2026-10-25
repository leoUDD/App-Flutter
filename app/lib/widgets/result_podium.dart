import 'package:flutter/material.dart';

import '../models/race_result.dart';
import '../theme/app_theme.dart';
import 'driver_avatar.dart';

/// El podio de una carrera: tres columnas en escalón (2.º · 1.º · 3.º) con el
/// tiempo del ganador y la diferencia de los otros dos.
class ResultPodium extends StatelessWidget {
  const ResultPodium({super.key, required this.top3});

  /// Los tres primeros, en orden: 1.º, 2.º y 3.º.
  final List<RaceResult> top3;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [
        Expanded(child: _PodiumColumn(result: top3[1], place: 2)),
        Expanded(child: _PodiumColumn(result: top3[0], place: 1)),
        Expanded(child: _PodiumColumn(result: top3[2], place: 3)),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({required this.result, required this.place});

  final RaceResult result;
  final int place;

  bool get _isWinner => place == 1;

  Color get _medalColor => switch (place) {
    1 => AppColors.gold,
    2 => AppColors.silver,
    _ => AppColors.bronze,
  };

  double get _stepHeight => switch (place) {
    1 => 112.0,
    2 => 84.0,
    _ => 68.0,
  };

  double get _avatarSize => _isWinner ? 52.0 : 44.0;

  double get _avatarFont => _isWinner ? 18.0 : 16.0;

  double get _numberSize => switch (place) {
    1 => 38.0,
    2 => 30.0,
    _ => 26.0,
  };

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (_isWinner)
          const Icon(Icons.emoji_events, size: 20, color: AppColors.gold),
        DriverAvatar(
          initials: r.initials,
          size: _avatarSize,
          fontSize: _avatarFont,
          ringColor: teamColor(r.teamId),
        ),
        Column(
          children: [
            Text(
              r.familyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: _isWinner ? FontWeight.w700 : FontWeight.w600,
                height: 1.15,
              ),
            ),
            Text(
              r.teamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          child: Container(
            width: double.infinity,
            height: _stepHeight,
            color: _isWinner ? AppColors.championSurface : AppColors.surface,
            child: Column(
              children: [
                Container(height: 3, color: _medalColor),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 2,
                    children: [
                      Text(
                        '$place',
                        style: TextStyle(
                          fontSize: _numberSize,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          color: _medalColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          r.time ?? r.status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _isWinner
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _isWinner
                                ? AppColors.text
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
