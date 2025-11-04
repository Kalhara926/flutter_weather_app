import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/weather_model.dart';
import '../models/history_item_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_detail_item.dart';
import 'settings_screen.dart';

const Color kBackgroundColor = Color(0xFF1B222E);
const Color kCardColor = Color(0xFF2C3644);
const Color kPrimaryColor = Color(0xFF007BFF);
const Color kErrorColor = Color(0xFFD93636);

const String kSearchHistoryKey = 'search_history_cities';
const String kWeatherHistoryKey = 'weather_history';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  VideoPlayerController? _videoController;
  String _currentVideo = 'assets/videos/default_bg.mp4';

  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();

  Weather? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  List<String> _searchHistory = [];
  List<HistoryItem> _weatherHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(_currentVideo);
    _loadSearchHistory();
    _loadWeatherHistory();
    _fetchCurrentLocationWeather();
  }

  void _initializeVideoPlayer(String videoAsset) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.asset(videoAsset)
      ..initialize().then((_) {
        _videoController?.play();
        _videoController?.setLooping(true);
        if (mounted) {
          setState(() {});
        }
      });
  }

  void _updateBackgroundVideo(Weather? weather) {
    String newVideo;
    if (weather == null) {
      newVideo = 'assets/videos/default_bg.mp4';
    } else {
      switch (weather.condition.toLowerCase()) {
        case 'clear':
          newVideo = 'assets/videos/clear_sky.mp4';
          break;
        case 'clouds':
          newVideo = 'assets/videos/cloudy.mp4';
          break;
        case 'rain':
        case 'drizzle':
        case 'thunderstorm':
          newVideo = 'assets/videos/rainy.mp4';
          break;
        default:
          newVideo = 'assets/videos/default_bg.mp4';
      }
    }
    if (_currentVideo != newVideo) {
      _currentVideo = newVideo;
      _initializeVideoPlayer(newVideo);
    }
  }

  Future<void> _fetchCurrentLocationWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final weather = await _weatherService.fetchWeatherByCoords(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _weather = weather;
        });
        await _addWeatherToHistory(weather);
        _updateBackgroundVideo(weather);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        _updateBackgroundVideo(null);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchWeatherByCity() async {
    final cityName = _cityController.text;
    if (cityName.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
    });
    try {
      final weather = await _weatherService.fetchWeather(cityName);
      if (mounted) {
        setState(() {
          _weather = weather;
          _cityController.clear();
        });
        await _addCityToSearchHistory(cityName);
        await _addWeatherToHistory(weather);
        _updateBackgroundVideo(weather);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        _updateBackgroundVideo(null);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        _searchHistory = prefs.getStringList(kSearchHistoryKey) ?? [];
      });
  }

  Future<void> _loadWeatherHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson =
        prefs.getStringList(kWeatherHistoryKey) ?? [];
    if (mounted)
      setState(() {
        _weatherHistory = historyJson
            .map((item) => HistoryItem.fromJson(jsonDecode(item)))
            .toList();
      });
  }

  Future<void> _addCityToSearchHistory(String city) async {
    final formattedCity = city.trim().toLowerCase();
    if (formattedCity.isEmpty) return;
    final capitalizedCity =
        formattedCity[0].toUpperCase() + formattedCity.substring(1);
    if (mounted)
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

  Future<void> _addWeatherToHistory(Weather weather) async {
    final newItem = HistoryItem(
      cityName: weather.cityName,
      condition: weather.condition,
      temperature: weather.temperature,
      timestamp: DateTime.now(),
    );
    _weatherHistory.insert(0, newItem);
    if (_weatherHistory.length > 20) {
      _weatherHistory = _weatherHistory.sublist(0, 20);
    }
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = _weatherHistory
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(kWeatherHistoryKey, historyJson);
    if (mounted) setState(() {});
  }

  String _getWeatherEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
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
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          Container(color: Colors.black.withOpacity(0.4)),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Weather Now',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: _fetchCurrentLocationWeather,
                  tooltip: 'Get Current Location Weather',
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(),
                  const SizedBox(height: 50),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildLoading(key: const ValueKey('loading'));
    if (_errorMessage != null) return _buildError(key: const ValueKey('error'));
    if (_weather != null)
      return _buildWeatherDisplay(key: ValueKey(_weather!.cityName));
    return const SizedBox.shrink(key: ValueKey('empty'));
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
        TextFormField(
          controller: _cityController,
          style: GoogleFonts.lato(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter city name',
            hintStyle: GoogleFonts.lato(color: Colors.white54),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white70),
              onPressed: _fetchWeatherByCity,
            ),
            filled: true,
            fillColor: kCardColor.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onFieldSubmitted: (_) => _fetchWeatherByCity(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _fetchWeatherByCity,
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

  Widget _buildLoading({Key? key}) {
    return Center(
      key: key,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Fetching weather data...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError({Key? key}) {
    return Container(
      key: key,
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
            child: Text(
              _errorMessage!,
              style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDisplay({Key? key}) {
    if (_weather == null) return const SizedBox.shrink();

    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _AnimatedSlideFadeIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              _weather!.cityName,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          _AnimatedSlideFadeIn(
            delay: const Duration(milliseconds: 400),
            child: Text(
              _getWeatherEmoji(_weather!.condition),
              style: const TextStyle(fontSize: 70),
            ),
          ),
          _AnimatedSlideFadeIn(
            delay: const Duration(milliseconds: 500),
            child: Text(
              '${_weather!.temperature.round()}°C',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          _AnimatedSlideFadeIn(
            delay: const Duration(milliseconds: 600),
            child: Text(
              _weather!.condition,
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 20),
            ),
          ),

          const SizedBox(height: 24),

          _AnimatedSlideFadeIn(
            delay: const Duration(milliseconds: 700),
            child: const Divider(color: Colors.white24),
          ),
          const SizedBox(height: 16),
          _AnimatedSlideFadeIn(
            delay: const Duration(milliseconds: 800),
            child: Row(
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _cityController.dispose();
    super.dispose();
  }
}

class _AnimatedSlideFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  const _AnimatedSlideFadeIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
  });
  @override
  State<_AnimatedSlideFadeIn> createState() => _AnimatedSlideFadeInState();
}

class _AnimatedSlideFadeInState extends State<_AnimatedSlideFadeIn> {
  bool _animate = false;
  @override
  void initState() {
    super.initState();
    Timer(widget.delay, () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _animate ? 1.0 : 0.0,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOut,
        padding: EdgeInsets.only(top: _animate ? 0 : 20.0),
        child: widget.child,
      ),
    );
  }
}
