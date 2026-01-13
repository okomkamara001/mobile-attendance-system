import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeolocationService {
  GeolocationService._private();
  static final GeolocationService instance = GeolocationService._private();

  Future<bool> _ensureServiceAndPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Get a single position with acceptable accuracy (meters).
  Future<Position> getAccuratePosition({
    double maxAccuracyMeters = 20,
    Duration timeout = const Duration(seconds: 12),
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final ok = await _ensureServiceAndPermission();
    if (!ok) throw Exception('Location services or permission denied');

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout,
      );

      final acc = pos.accuracy;
      if (acc == 0 || acc.isNaN || acc > maxAccuracyMeters) {
        throw Exception('Poor GPS accuracy: ${acc.toStringAsFixed(1)} m');
      }
      return pos;
    } on TimeoutException {
      throw Exception('Location request timed out');
    } catch (e) {
      rethrow;
    }
  }

  /// Reverse-geocode a Position to a readable location string (nullable).
  Future<String?> getPlaceNameFromPosition(Position pos) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String?>[
        p.name,
        p.street,
        p.locality,
        p.subAdministrativeArea,
        p.administrativeArea,
        p.postalCode,
        p.country,
      ];
      return parts.where((s) => s != null && s.trim().isNotEmpty).join(', ');
    } catch (_) {
      return null;
    }
  }
}
