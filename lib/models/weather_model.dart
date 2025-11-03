class Weather {
  final String cityName;
  final double temperature; // In Celsius
  final String condition;
  final String iconCode;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  // Factory constructor to create a Weather object from JSON data
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      // Temperature is in Kelvin, convert to Celsius
      temperature: json['main']['temp'] - 273.15,
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}
