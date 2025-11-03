// lib/screens/weather_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_detail_item.dart';

// UI එකේ ඇති වර්ණ
const Color kBackgroundColor = Color(0xFF1B222E);
const Color kCardColor = Color(0xFF2C3644);
const Color kPrimaryColor = Color(0xFF007BFF);
const Color kErrorColor = Color(0xFFD93636);

const String kSearchHistoryKey =
    'search_history'; // SharedPreferences key for history

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

  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadLastSearchedCity();
  }

  // --- Search History Functions ---
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList(kSearchHistoryKey) ?? [];
    });
  }

  Future<void> _addCityToHistory(String city) async {
    final formattedCity = city.trim().toLowerCase();
    if (formattedCity.isEmpty) return;

    final capitalizedCity =
        formattedCity[0].toUpperCase() + formattedCity.substring(1);

    setState(() {
      _searchHistory.removeWhere(
        (item) => item.toLowerCase() == capitalizedCity.toLowerCase(),
      );
      _searchHistory.insert(0, capitalizedCity);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kSearchHistoryKey, _searchHistory);
  }
  // --- End of Search History Functions ---

  Future<void> _loadLastSearchedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = (prefs.getStringList(kSearchHistoryKey) ?? []).firstOrNull;
    if (lastCity != null && lastCity.isNotEmpty) {
      _fetchWeather(city: lastCity);
    }
  }

  Future<void> _fetchWeather({String? city}) async {
    final cityName = city ?? _cityController.text;
    if (cityName.isEmpty) {
      setState(() => _errorMessage = "Please enter a city name.");
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(cityName);
      setState(() {
        _weather = weather;
      });
      await _addCityToHistory(cityName);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('City not found')
            ? 'Could not find city. Please try again.'
            : 'An unexpected error occurred.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Text(
          'Weather Now',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 32),
            // AnimatedSwitcher මගින් states අතර මාරුවීම සජීවීකරණය කිරීම
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildContentSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City Name',
          style: GoogleFonts.lato(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),

        // --- Autocomplete Widget for Search History ---
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _searchHistory.isEmpty
                  ? const Iterable<String>.empty()
                  : _searchHistory;
            }
            return _searchHistory.where(
              (option) => option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Text field එකේ text එක පාලනය කිරීමට අපේ _cityController එක ලබාදීම
            _cityController.value = controller.value;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onFieldSubmitted: (value) {
                _cityController.text = value;
                _fetchWeather();
                onFieldSubmitted();
              },
              style: GoogleFonts.lato(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter city name',
                hintStyle: GoogleFonts.lato(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white70),
                  onPressed: () {
                    _cityController.text = controller.text;
                    _fetchWeather();
                  },
                ),
                filled: true,
                fillColor: kCardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: kCardColor,
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(
                          Icons.history,
                          color: Colors.white70,
                        ),
                        title: Text(
                          option,
                          style: GoogleFonts.lato(color: Colors.white),
                        ),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (selection) {
            _cityController.text = selection;
            _fetchWeather();
          },
        ),

        // --- End of Autocomplete Widget ---
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _fetchWeather(),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Get Weather',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    if (_isLoading) {
      return _buildLoading();
    } else if (_weather != null) {
      return _buildWeatherDisplay();
    } else if (_errorMessage != null) {
      return _buildError();
    } else {
      return _buildInitial();
    }
  }

  // --- එක් එක් State එක සඳහා වෙන වෙනම Widgets ---

  Widget _buildInitial() {
    return Center(
      key: const ValueKey('initial'),
      child: Column(
        children: [
          Icon(Icons.wb_sunny_outlined, color: kPrimaryColor, size: 60),
          const SizedBox(height: 16),
          Text(
            'Search for a City',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a city name above to get the latest\nweather information.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      key: ValueKey('loading'),
      child: Column(
        children: [
          CircularProgressIndicator(color: kPrimaryColor),
          SizedBox(height: 16),
          Text(
            'Fetching weather data...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      key: const ValueKey('error'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kErrorColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kErrorColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: kErrorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: GoogleFonts.lato(
                    color: kErrorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    return Container(
      key: ValueKey(
        _weather!.cityName,
      ), // නගරය වෙනස් වන විට animation එක trigger කිරීමට
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_weather!.cityName}, ${_weather!.country}',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _weather!.condition,
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.network(
                _weather!.iconUrl,
                height: 80,
                width: 80,
                errorBuilder: (c, o, s) =>
                    const Icon(Icons.cloud_off, color: Colors.yellow, size: 80),
              ),
              const SizedBox(width: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weather!.temperature.toStringAsFixed(0),
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '°C',
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WeatherDetailItem(
                icon: Icons.air,
                value: '${_weather!.windSpeed.toStringAsFixed(1)} km/h',
                label: 'Wind',
              ),
              WeatherDetailItem(
                icon: Icons.water_drop_outlined,
                value: '${_weather!.humidity}%',
                label: 'Humidity',
              ),
              WeatherDetailItem(
                icon: Icons.visibility_outlined,
                value: '${_weather!.visibility.toStringAsFixed(1)} km',
                label: 'Visibility',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
