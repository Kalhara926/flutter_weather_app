import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();

  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  String _lastSearchedCityKey = 'last_city';

  @override
  void initState() {
    super.initState();
    _loadLastSearchedCity();
  }

  // Load the last searched city from shared_preferences
  Future<void> _loadLastSearchedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString(_lastSearchedCityKey);
    if (lastCity != null && lastCity.isNotEmpty) {
      _cityController.text = lastCity;
      _fetchWeather(); // Automatically fetch weather for the last city
    }
  }

  // Save the city to shared_preferences
  Future<void> _saveLastSearchedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSearchedCityKey, city);
  }

  // Fetch weather data
  Future<void> _fetchWeather() async {
    if (_cityController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a city name";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null; // Clear previous weather data
    });

    try {
      final weather = await _weatherService.fetchWeather(_cityController.text);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
      await _saveLastSearchedCity(_cityController.text); // Save on success
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _weather = null;
      });
    }
  }

  // Helper to get an emoji for a weather condition
  String _getWeatherEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'clear':
        return '☀️';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return '🌫️';
      default:
        return '🌍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather App'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade800],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // City Input TextField
                TextField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter City Name',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    hintText: 'e.g., Colombo',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: _fetchWeather,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _fetchWeather(),
                ),
                const SizedBox(height: 20),

                // Get Weather Button
                ElevatedButton(
                  onPressed: _fetchWeather,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Get Weather'),
                ),
                const SizedBox(height: 30),

                // Weather Display Area
                _buildWeatherDisplay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: Colors.white);
    } else if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.amberAccent, fontSize: 18),
        textAlign: TextAlign.center,
      );
    } else if (_weather != null) {
      return AnimatedOpacity(
        opacity: _weather != null ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Card(
          color: Colors.white.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                Text(
                  _weather!.cityName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getWeatherEmoji(_weather!.condition),
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_weather!.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _weather!.condition,
                  style: const TextStyle(fontSize: 22, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Initial state before any search
      return const Text(
        'Enter a city to get the weather',
        style: TextStyle(color: Colors.white, fontSize: 18),
      );
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
