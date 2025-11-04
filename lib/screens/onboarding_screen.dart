import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:weather_app/screens/weather_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const WeatherScreen()));
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: GoogleFonts.lato(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyTextStyle: GoogleFonts.lato(fontSize: 18.0, color: Colors.white70),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: const Color(0xFF1B222E),
      imagePadding: const EdgeInsets.only(top: 60),
      imageFlex: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to WeatherNow",
          body:
              "Get real-time weather updates for any city around the world, right at your fingertips.",
          image: _buildImage(
            Icons.wb_sunny_rounded,
            color: Colors.yellow.shade600,
          ),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Search Any City",
          body:
              "Simply type the name of the city and get instant, accurate weather information.",
          image: _buildImage(
            Icons.search_rounded,
            color: const Color(0xFF007BFF),
          ),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Detailed Forecasts",
          body:
              "Access detailed information including humidity, wind speed, and visibility to plan your day better.",
          image: _buildImage(
            Icons.list_alt_rounded,
            color: Colors.green.shade400,
          ),
          decoration: _getPageDecoration(),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: Text(
        'Skip',
        style: GoogleFonts.lato(
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
      next: const Icon(Icons.arrow_forward, color: Colors.white),
      done: Text(
        'Done',
        style: GoogleFonts.lato(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.white24,
        activeColor: const Color(0xFF007BFF),
        activeSize: const Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      globalBackgroundColor: const Color(0xFF1B222E),
    );
  }

  Widget _buildImage(IconData icon, {required Color color}) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 100, color: color),
      ),
    );
  }
}
