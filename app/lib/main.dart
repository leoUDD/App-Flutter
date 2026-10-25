import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/season_provider.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SeasonProvider(),
      child: const F1StatsApp(),
    ),
  );
}

class F1StatsApp extends StatelessWidget {
  const F1StatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Stats',
      theme: buildAppTheme(),
      home: const HomeShell(),
    );
  }
}
