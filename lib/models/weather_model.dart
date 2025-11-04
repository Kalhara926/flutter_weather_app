class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final double visibility;

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      country: json['sys']['country'],
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: ((json['wind']?['speed'] ?? 0.0) as num).toDouble() * 3.6,
      visibility: ((json['visibility'] ?? 0.0) as num).toDouble() / 1000,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@4x.png';
}
