import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const _apiKey = 'ca4be3c05cf3724c215f4ecf3c8e1d3e';
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeather(String cityName) async {
    final url = '$_baseUrl?q=$cityName&appid=$_apiKey';
    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Weather.fromJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the spelling.');
      } else {
        throw Exception(
          'Failed to load weather data. Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Handle network errors or other exceptions
      throw Exception(
        'Failed to connect to the service. Please check your internet connection.',
      );
    }
  }
}
