import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoveryPreferencesService {
  static const String _keyMaxRadius = 'pref_max_discovery_radius_km';
  static const double defaultMaxRadiusKm = 100.0;
  static const double minAllowedRadiusKm = 5.0;
  static const double hardMaxRadiusKm = 100.0;

  static double _maxRadiusKm = defaultMaxRadiusKm;
  static final ValueNotifier<double> maxRadiusNotifier =
      ValueNotifier<double>(defaultMaxRadiusKm);

  static double get maxRadiusKm => _maxRadiusKm;

  static void initialize() {
    init();
  }

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getDouble(_keyMaxRadius);
      if (stored != null && stored >= minAllowedRadiusKm) {
        _maxRadiusKm = stored.clamp(minAllowedRadiusKm, hardMaxRadiusKm);
        maxRadiusNotifier.value = _maxRadiusKm;
      }
    } catch (_) {}
  }

  static Future<void> setMaxRadius(double radiusKm) async {
    final clamped = radiusKm.clamp(minAllowedRadiusKm, hardMaxRadiusKm);
    _maxRadiusKm = clamped;
    maxRadiusNotifier.value = clamped;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyMaxRadius, clamped);
    } catch (_) {}
  }
}
