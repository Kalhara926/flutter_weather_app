// lib/models/weather_model.dart

class Weather {
  final String cityName;
  final String country; // <-- අලුතින් එකතු කළා
  final double temperature;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final double visibility; // <-- අලුතින් එකතු කළා

  Weather({
    required this.cityName,
    required this.country, // <-- අලුතින් එකතු කළා
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.visibility, // <-- අලුතින් එකතු කළා
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      country: json['sys']['country'], // <-- රටේ නම ලබාගැනීම
      temperature: (json['main']['temp'] - 273.15),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'] * 3.6, // m/s to km/h
      visibility: (json['visibility'] / 1000), // meters to kilometers
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@4x.png';
}
