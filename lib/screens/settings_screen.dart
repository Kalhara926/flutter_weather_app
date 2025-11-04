import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history_screen.dart';

const Color kBackgroundColor = Color(0xFF1B222E);
const Color kCardColor = Color(0xFF2C3644);
const Color kPrimaryColor = Color(0xFF007BFF);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCelsius = true;
  bool _useCurrentLocation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('HISTORY'),
          _buildSettingsCard(
            children: [
              _buildSettingRow(
                icon: Icons.history,
                title: 'Search History',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('UNITS'),
          _buildSettingsCard(
            children: [
              _buildTemperatureUnitSelector(),
              const _Divider(),
              _buildSettingRow(
                icon: Icons.air,
                title: 'Wind Speed',
                value: 'km/h',
              ),
              const _Divider(),
              _buildSettingRow(
                icon: Icons.speed_outlined,
                title: 'Pressure',
                value: 'hPa',
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('GENERAL'),
          _buildSettingsCard(
            children: [
              _buildToggleSettingRow(
                icon: Icons.location_on_outlined,
                title: 'Use Current Location',
                value: _useCurrentLocation,
                onChanged: (val) {
                  setState(() => _useCurrentLocation = val);
                },
              ),
              const _Divider(),
              _buildSettingRow(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('ABOUT'),
          _buildSettingsCard(
            children: [
              _buildSettingRow(
                icon: Icons.info_outline,
                title: 'App Version',
                value: '1.2.0',
                showArrow: false,
              ),
              const _Divider(),
              _buildSettingRow(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lato(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTemperatureUnitSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.thermostat_outlined, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Temperature',
              style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ToggleButtons(
              isSelected: [_isCelsius, !_isCelsius],
              onPressed: (index) {
                setState(() {
                  _isCelsius = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              color: Colors.white70,
              fillColor: kPrimaryColor,
              splashColor: kPrimaryColor.withOpacity(0.2),
              borderColor: Colors.transparent,
              selectedBorderColor: Colors.transparent,
              children: [_buildUnitToggle('°C'), _buildUnitToggle('°F')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? value,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 16),
                ),
              if (showArrow) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white38,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSettingRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: kPrimaryColor.withOpacity(0.5),
            activeColor: kPrimaryColor,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56.0),
      child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
    );
  }
}
