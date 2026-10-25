import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/season_provider.dart';

class SeasonDropdown extends StatelessWidget {
  const SeasonDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Temporada',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: season,
              dropdownColor: AppColors.surfaceAlt,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              items: [
                for (var year = DateTime.now().year; year >= 1950; year--)
                  DropdownMenuItem(value: year, child: Text('$year')),
              ],
              onChanged: (year) {
                if (year == null) return;
                context.read<SeasonProvider>().setSeason(year);
              },
            ),
          ),
        ],
      ),
    );
  }
}
