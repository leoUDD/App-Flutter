import 'package:flutter/material.dart';

import '../models/driver_standing.dart';
import '../theme/app_theme.dart';
import 'driver_avatar.dart';

class DriverCompareCard extends StatelessWidget {
  const DriverCompareCard({
    super.key,
    required this.title,
    required this.driver,
    required this.color,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final DriverStanding driver;
  final Color color;
  final List<DriverStanding> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              DriverAvatar(
                initials: driver.initials,
                size: 36,
                ringColor: color,
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  driver.familyName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: driver.driverId,
              isExpanded: true,
              dropdownColor: AppColors.surfaceAlt,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: const TextStyle(color: AppColors.text, fontSize: 12),
              items: options.map((d) {
                return DropdownMenuItem<String>(
                  value: d.driverId,
                  child: Text(d.fullName, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
