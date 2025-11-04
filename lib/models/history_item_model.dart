class HistoryItem {
  final String cityName;
  final String condition;
  final double temperature;
  final DateTime timestamp;

  HistoryItem({
    required this.cityName,
    required this.condition,
    required this.temperature,
    required this.timestamp,
  });
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'condition': condition,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      cityName: json['cityName'],
      condition: json['condition'],
      temperature: json['temperature'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
