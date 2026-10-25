import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import '../widgets/season_dropdown.dart';
import 'standings_screen.dart';
import 'calendar_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 16,
        title: const AppLogo(),
        actions: const [SeasonDropdown(), SizedBox(width: 16)],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          StandingsScreen(),
          Center(child: Text('Comparador (próximamente)')),
          CalendarScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() {
            _index = i;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows),
            label: 'Comparador',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
        ],
      ),
    );
  }
}
