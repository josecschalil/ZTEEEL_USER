import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'restaurant_service.dart';
import 'offer_service.dart';

class SavedLocationCoordinates {
  final double latitude;
  final double longitude;
  final String label;
  final String address;

  const SavedLocationCoordinates({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.address,
  });
}

/// Persistent coordinate store for location-aware frontend processing.
class LocationService {
  LocationService._();

  static const SavedLocationCoordinates defaultFallbackLocation =
      SavedLocationCoordinates(
    latitude: 12.9715987,
    longitude: 77.5945627,
    label: 'Bengaluru',
    address: 'MG Road, Bengaluru, Karnataka',
  );

  static final ValueNotifier<String> addressNotifier =
      ValueNotifier<String>('Choose your location');

  static final ValueNotifier<SavedLocationCoordinates?> locationNotifier =
      ValueNotifier<SavedLocationCoordinates?>(null);

  static const _latitudeKey = 'selected_location_latitude';
  static const _longitudeKey = 'selected_location_longitude';
  static const _labelKey = 'selected_location_label';
  static const _addressKey = 'selected_location_address';

  static Future<bool> hasSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_latitudeKey) && prefs.containsKey(_longitudeKey);
  }

  static Future<void> save(SavedLocationCoordinates location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latitudeKey, location.latitude);
    await prefs.setDouble(_longitudeKey, location.longitude);
    await prefs.setString(_labelKey, location.label);
    await prefs.setString(_addressKey, location.address);
    if (location.address.isNotEmpty) {
      addressNotifier.value = location.address;
    }
    // Clear stale in-memory cached feeds
    RestaurantService.clearCache();
    OfferService.clearCache();
    // Notify active listeners
    locationNotifier.value = location;
  }

  static Future<SavedLocationCoordinates?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble(_latitudeKey);
    final longitude = prefs.getDouble(_longitudeKey);
    if (latitude == null || longitude == null) return null;
    final address = prefs.getString(_addressKey) ?? '';
    final label = prefs.getString(_labelKey) ?? 'Selected Location';
    if (address.isNotEmpty) {
      addressNotifier.value = address;
    }
    final loc = SavedLocationCoordinates(
      latitude: latitude,
      longitude: longitude,
      label: label,
      address: address,
    );
    if (locationNotifier.value == null) {
      locationNotifier.value = loc;
    }
    return loc;
  }

  /// Ensures a valid location coordinate is available.
  /// 1. Reads existing saved coordinates from storage.
  /// 2. If null, attempts GPS detection (allowing user time to respond to permission dialog).
  /// 3. If GPS is unavailable/denied, returns defaultFallbackLocation without saving it to disk.
  static Future<SavedLocationCoordinates> ensureLocation() async {
    final existing = await load();
    if (existing != null) return existing;

    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
        locationNotifier.value = defaultFallbackLocation;
        return defaultFallbackLocation;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission()
            .timeout(const Duration(seconds: 2), onTimeout: () => LocationPermission.denied);
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 6),
            ),
          );
          final detected = SavedLocationCoordinates(
            latitude: position.latitude,
            longitude: position.longitude,
            label: 'Current Location',
            address: 'Current Location (GPS)',
          );
          await save(detected);
          return detected;
        }
      }
    } catch (_) {}

    // When GPS is unavailable or permission is skipped, set in-memory fallback
    // without polluting SharedPreferences so future detection attempts remain possible.
    if (locationNotifier.value == null) {
      locationNotifier.value = defaultFallbackLocation;
    }
    if (addressNotifier.value == 'Choose your location') {
      addressNotifier.value = defaultFallbackLocation.address;
    }
    return defaultFallbackLocation;
  }
}

