class DriverStanding {
  final int position;
  final double points;
  final int wins;
  final String driverId;
  final String code;
  final String? number;
  final String givenName;
  final String familyName;
  final String nationality;
  final String teamName;

  const DriverStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.driverId,
    required this.code,
    required this.number,
    required this.givenName,
    required this.familyName,
    required this.nationality,
    required this.teamName,
  });

  String get fullName => '$givenName $familyName';

  factory DriverStanding.fromJson(Map<String, dynamic> json) {
    final driver = json['Driver'] as Map<String, dynamic>;
    final constructors = (json['Constructors'] as List?) ?? const [];
    final team = constructors.isNotEmpty
        ? (constructors.last as Map<String, dynamic>)['name'] as String
        : '-';
    return DriverStanding(
      position: int.parse(json['position'] as String),
      points: double.parse(json['points'] as String),
      wins: int.parse(json['wins'] as String),
      driverId: driver['driverId'] as String,
      code: (driver['code'] as String?) ?? '',
      number: driver['permanentNumber'] as String?,
      givenName: driver['givenName'] as String,
      familyName: driver['familyName'] as String,
      nationality: driver['nationality'] as String,
      teamName: team,
    );
  }
}
