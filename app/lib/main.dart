import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/season_provider.dart';
import 'screens/standings_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const StandingsScreen(),
    );
  }
}
