import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/models/driver_standing.dart';
import 'package:app_flutter/models/race.dart';

void main() {
  test('DriverStanding.fromJson convierte textos a números', () {
    final s = DriverStanding.fromJson({
      'position': '1',
      'points': '340',
      'wins': '8',
      'Driver': {
        'driverId': 'antonelli',
        'permanentNumber': '12',
        'code': 'ANT',
        'givenName': 'Andrea Kimi',
        'familyName': 'Antonelli',
        'nationality': 'Italian',
      },
      'Constructors': [
        {'name': 'Mercedes'}
      ],
    });
    expect(s.position, 1);
    expect(s.points, 340);
    expect(s.fullName, 'Andrea Kimi Antonelli');
    expect(s.teamName, 'Mercedes');
  });

  test('Race.fromJson lee fecha y circuito', () {
    final r = Race.fromJson({
      'round': '1',
      'raceName': 'Australian Grand Prix',
      'date': '2026-03-08',
      'time': '04:00:00Z',
      'Circuit': {
        'circuitName': 'Albert Park Grand Prix Circuit',
        'Location': {'locality': 'Melbourne', 'country': 'Australia'},
      },
    });
    expect(r.round, 1);
    expect(r.date, DateTime.utc(2026, 3, 8, 4));
    expect(r.country, 'Australia');
  });
}
