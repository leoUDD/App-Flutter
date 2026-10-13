class Race {
  final int round;
  final String name;
  final String circuitName;
  final String locality;
  final String country;
  final DateTime? date;

  const Race({
    required this.round,
    required this.name,
    required this.circuitName,
    required this.locality,
    required this.country,
    required this.date,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    final circuit = json['Circuit'] as Map<String, dynamic>;
    final location = circuit['Location'] as Map<String, dynamic>;
    final dateStr = json['date'] as String?;
    final timeStr = json['time'] as String?;
    return Race(
      round: int.parse(json['round'] as String),
      name: json['raceName'] as String,
      circuitName: circuit['circuitName'] as String,
      locality: location['locality'] as String,
      country: location['country'] as String,
      date: dateStr == null
          ? null
          : DateTime.tryParse(timeStr == null ? dateStr : '${dateStr}T$timeStr'),
    );
  }
}
