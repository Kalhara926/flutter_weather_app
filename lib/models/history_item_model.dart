// lib/models/history_item_model.dart

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

  // Convert a HistoryItem object into a Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'condition': condition,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to a string
    };
  }

  // Create a HistoryItem object from a Map (JSON deserialization)
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      cityName: json['cityName'],
      condition: json['condition'],
      temperature: json['temperature'],
      timestamp: DateTime.parse(
        json['timestamp'],
      ), // Convert string back to DateTime
    );
  }
}
