// ---------------------------------------------------------------------
// SETUP REQUIRED (one-time, no API key needed):
//
// 1. Add to pubspec.yaml:
//      dependencies:
//        flutter_map: ^6.1.0
//        latlong2: ^0.9.1
//        geolocator: ^11.0.0
//        http: ^1.2.0
//
// 2. Android — android/app/src/main/AndroidManifest.xml, inside <manifest>:
//      <uses-permission android:name="android.permission.INTERNET"/>
//      <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//      <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
//
// 3. iOS — ios/Runner/Info.plist, add:
//      <key>NSLocationWhenInUseUsageDescription</key>
//      <string>ZTEEEL uses your location to find nearby restaurants and
//      deliver to the right address.</string>
//
// Map tiles come from OpenStreetMap's free public tile server — no API key,
// no account, no billing. It does need an internet connection to fetch
// tile images and to reverse-geocode/search addresses via OSM's Nominatim
// service (also free, no key). OSM's usage policy requires: a descriptive
// User-Agent header (set below) and reasonable request rates (the debounce
// below keeps us well under 1 request/second).
// ---------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

/// ZTEEEL Location Picker — real, pannable OpenStreetMap map with a fixed
/// center pin (Google Maps / Uber style), live reverse geocoding, address
/// search, "use my location" via device GPS, and saved-address shortcuts.
///
/// Drop into a Flutter project (e.g. lib/location_picker_screen.dart).
/// Push it from the Home screen's location label and await the result:
///
/// ```dart
/// final picked = await Navigator.push<PickedLocation>(
///   context,
///   MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
/// );
/// if (picked != null) {
///   setState(() => _currentAddress = picked.address);
/// }
/// ```

class LocationColors {
  static const primary = Color(0xFFEE5B2B);
  static const backgroundLight = Color(0xFFF8F6F6);
  static const cardLight = Colors.white;
  static const borderLight = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
  );
}

/// ---------------------------------------------------------------------
/// Models
/// ---------------------------------------------------------------------
class PickedLocation {
  final String label;
  final String address;
  final LatLng position;
  const PickedLocation({
    required this.label,
    required this.address,
    required this.position,
  });
}

class SavedAddress {
  final String label;
  final String address;
  final IconData icon;
  final LatLng position;
  const SavedAddress({
    required this.label,
    required this.address,
    required this.icon,
    required this.position,
  });
}

// Default starting point (Kollam, Kerala) — swap for the user's last known
// location if you have one stored.
final LatLng _defaultCenter = LatLng(8.8932, 76.6141);

const _savedAddresses = [
  SavedAddress(
    label: 'Home',
    address: '221B Baker Street, Kollam',
    icon: Icons.home,
    position: LatLng(8.8932, 76.6141),
  ),
  SavedAddress(
    label: 'Work',
    address: 'Cyber Tower, Technopark, Kollam',
    icon: Icons.work,
    position: LatLng(8.9012, 76.5975),
  ),
];

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _pinController;

  LatLng _center = _defaultCenter;
  String _address = 'Move the map to select a location';
  bool _isDragging = false;
  bool _locating = false;
  bool _resolvingAddress = false;
  bool _searching = false;
  List<_SearchResult> _searchResults = [];
  Timer? _debounce;
  Timer? _searchDebounce;

  static const _userAgent = 'ZteeelApp/1.0 (contact@example.com)';

  @override
  void initState() {
    super.initState();
    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _reverseGeocode(_center);
  }

  @override
  void dispose() {
    _pinController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // -- Reverse geocoding (coords -> address) via OSM Nominatim --
  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _resolvingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(uri, headers: {'User-Agent': _userAgent});
      debugPrint(
        'Nominatim status: ${response.statusCode}, body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final name = data['display_name'] as String?;
        if (mounted) {
          setState(() => _address = name ?? 'No address found here');
        }
      } else {
        if (mounted) {
          setState(
            () => _address = 'Address lookup failed (${response.statusCode})',
          );
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      if (mounted) {
        setState(() => _address = 'Unable to fetch address — check connection');
      }
    } finally {
      if (mounted) setState(() => _resolvingAddress = false);
    }
  }

  // -- Forward geocoding / search (text -> places) via Nominatim --
  Future<void> _search(String query) async {
    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?format=json&q=${Uri.encodeQueryComponent(query)}&limit=6&addressdetails=1',
      );
      final response = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        if (mounted) {
          setState(() {
            _searchResults = list
                .map(
                  (e) => _SearchResult(
                    label: e['display_name'] as String,
                    position: LatLng(
                      double.parse(e['lat'] as String),
                      double.parse(e['lon'] as String),
                    ),
                  ),
                )
                .toList();
          });
        }
      }
    } catch (_) {
      // Silently ignore search failures; the field simply shows no results.
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _search(value),
    );
  }

  void _selectSearchResult(_SearchResult result) {
    setState(() {
      _searchResults = [];
      _searchController.text = result.label;
    });
    FocusScope.of(context).unfocus();
    _mapController.move(result.position, 16);
    setState(() => _center = result.position);
    _reverseGeocode(result.position);
  }

  // -- Map pan handling: keep pin fixed, lift it while dragging, and
  //    reverse-geocode once the user stops moving the map. --
  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveStart) {
      setState(() => _isDragging = true);
      _pinController.forward();
    } else if (event is MapEventMove) {
      setState(() => _center = event.camera.center);
    } else if (event is MapEventMoveEnd) {
      setState(() => _isDragging = false);
      _pinController.reverse();
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(milliseconds: 400),
        () => _reverseGeocode(_center),
      );
    }
  }

  // -- Device GPS via geolocator --
  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required.')),
          );
        }
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services.')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final point = LatLng(position.latitude, position.longitude);
      _mapController.move(point, 16);
      setState(() => _center = point);
      await _reverseGeocode(point);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch your location.')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _confirm(String label, String address, LatLng position) {
    Navigator.of(
      context,
    ).pop(PickedLocation(label: label, address: address, position: position));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- Real OpenStreetMap map ---
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 15,
                onMapEvent: _onMapEvent,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.zteeel.app',
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),

          // --- Fixed center pin with lift animation + ground shadow ---
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 110),
              child: AnimatedBuilder(
                animation: _pinController,
                builder: (context, child) {
                  final lift = _pinController.value * 14;
                  final shadowScale = 1 - _pinController.value * 0.4;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -lift),
                        child: child,
                      ),
                      const SizedBox(height: 2),
                      Transform.scale(
                        scale: shadowScale,
                        child: Container(
                          width: 16,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                child: const _MapPin(),
              ),
            ),
          ),

          // --- Top search bar + back button + results dropdown ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _RoundButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: LocationColors.cardLight,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(
                                color: LocationColors.textPrimary,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search for area, street, landmark…',
                                hintStyle: const TextStyle(
                                  color: LocationColors.textMuted,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: LocationColors.textMuted,
                                  size: 20,
                                ),
                                suffixIcon: _searching
                                    ? const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: LocationColors.primary,
                                          ),
                                        ),
                                      )
                                    : null,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: LocationColors.cardLight,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: LocationColors.borderLight,
                          ),
                          itemBuilder: (context, i) {
                            final result = _searchResults[i];
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.location_on_outlined,
                                color: LocationColors.primary,
                                size: 20,
                              ),
                              title: Text(
                                result.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: LocationColors.textPrimary,
                                ),
                              ),
                              onTap: () => _selectSearchResult(result),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // --- Floating GPS button ---
          Positioned(
            right: 16,
            bottom: 300,
            child: _RoundButton(
              icon: Icons.my_location,
              iconColor: LocationColors.primary,
              loading: _locating,
              onTap: _useCurrentLocation,
            ),
          ),

          // --- Bottom sheet ---
          Align(
            alignment: Alignment.bottomCenter,
            child: _LocationSheet(
              address: _address,
              resolving: _resolvingAddress,
              locating: _locating,
              onUseCurrentLocation: _useCurrentLocation,
              onSelectSaved: (saved) =>
                  _confirm(saved.label, saved.address, saved.position),
              onConfirm: () => _confirm('Selected Location', _address, _center),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResult {
  final String label;
  final LatLng position;
  const _SearchResult({required this.label, required this.position});
}

/// ---------------------------------------------------------------------
/// Small reusable round icon button (back, GPS, etc.)
/// ---------------------------------------------------------------------
class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool loading;
  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LocationColors.cardLight,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: loading ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LocationColors.primary,
                  ),
                )
              : Icon(
                  icon,
                  size: 19,
                  color: iconColor ?? LocationColors.textSecondary,
                ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Fixed center map pin (teardrop with a dot)
/// ---------------------------------------------------------------------
class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 52,
      child: CustomPaint(painter: _PinPainter()),
    );
  }
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path();
    final w = size.width;
    final h = size.height;
    final radius = w / 2;
    path.addOval(
      Rect.fromCircle(center: Offset(w / 2, radius), radius: radius),
    );
    final trianglePath =
        ui.Path() // ← fixed
          ..moveTo(w / 2 - radius * 0.55, radius * 1.5)
          ..lineTo(w / 2 + radius * 0.55, radius * 1.5)
          ..lineTo(w / 2, h)
          ..close();
    path.addPath(trianglePath, Offset.zero);

    final paint = Paint()..color = LocationColors.primary;
    canvas.drawShadow(path, Colors.black, 3, false);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w / 2, radius), radius * 0.4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------
/// Bottom sheet: current address, saved addresses, confirm button
/// ---------------------------------------------------------------------
class _LocationSheet extends StatelessWidget {
  final String address;
  final bool resolving;
  final bool locating;
  final VoidCallback onUseCurrentLocation;
  final ValueChanged<SavedAddress> onSelectSaved;
  final VoidCallback onConfirm;
  const _LocationSheet({
    required this.address,
    required this.resolving,
    required this.locating,
    required this.onUseCurrentLocation,
    required this.onSelectSaved,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: LocationColors.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: LocationColors.borderLight,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LocationColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: LocationColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deliver to this location',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: LocationColors.textMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: resolving
                          ? const Text(
                              'Locating address…',
                              key: ValueKey('loading'),
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: LocationColors.textMuted,
                              ),
                            )
                          : Text(
                              address,
                              key: ValueKey(address),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: LocationColors.textPrimary,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: locating ? null : onUseCurrentLocation,
                style: TextButton.styleFrom(
                  foregroundColor: LocationColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                icon: locating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: LocationColors.primary,
                        ),
                      )
                    : const Icon(Icons.gps_fixed, size: 16),
                label: const Text(
                  'Locate',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (final saved in _savedAddresses) ...[
                Expanded(
                  child: _SavedAddressChip(
                    saved: saved,
                    onTap: () => onSelectSaved(saved),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: _AddAddressChip(onTap: () {})),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: LocationColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: LocationColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedAddressChip extends StatelessWidget {
  final SavedAddress saved;
  final VoidCallback onTap;
  const _SavedAddressChip({required this.saved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: LocationColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LocationColors.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(saved.icon, size: 18, color: LocationColors.primary),
            const SizedBox(height: 4),
            Text(
              saved.label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: LocationColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAddressChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAddressChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: LocationColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LocationColors.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, size: 18, color: LocationColors.textSecondary),
            SizedBox(height: 4),
            Text(
              'Add New',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: LocationColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
