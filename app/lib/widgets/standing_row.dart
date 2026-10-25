import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver_standing.dart';
import '../providers/season_provider.dart';
import '../screens/driver_detail_screen.dart';
import '../theme/app_theme.dart';
import 'driver_avatar.dart';

class StandingRow extends StatelessWidget {
  const StandingRow({super.key, required this.standing});

  final DriverStanding standing;

  @override
  Widget build(BuildContext context) {
    final s = standing;
    final season = context.watch<SeasonProvider>().season;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DriverDetailScreen(standing: s, season: season),
            ),
          );
        },
        child: Container(
          height: 58,
          padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
          child: Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  s.position?.toString() ?? '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              Container(
                width: 4,
                height: 34,
                decoration: BoxDecoration(
                  color: teamColor(s.teamId),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Avatar compartido con la ficha del piloto.
              Hero(
                tag: 'driver-${s.driverId}-$season',
                child: DriverAvatar(
                  initials: s.initials,
                  ringColor: teamColor(s.teamId),
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      s.teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: s.pointsLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}
