import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/season_provider.dart';

class SeasonDropdown extends StatelessWidget {
  const SeasonDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    return DropdownButton<int>(
      value: season,
      underline: const SizedBox(),
      items: [
        for (var year = DateTime.now().year; year >= 1950; year--)
          DropdownMenuItem(value: year, child: Text('$year')),
      ],
      onChanged: (year) {
        if (year == null) return;
        context.read<SeasonProvider>().setseason(year);
      },
    );
  }
}
