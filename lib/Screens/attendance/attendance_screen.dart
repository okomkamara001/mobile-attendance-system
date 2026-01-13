import 'package:flutter/material.dart';
import 'package:flutter_application/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_application/auth/auth_service.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/Screens/geolocation/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _sending = false;
  // NEW: store last resolved location name (used in UI)
  String? _lastLocationName;

  // standard work day length (change if needed)
  final Duration _standardWork = const Duration(hours: 8);

  Future<void> _captureAndSend(String action) async {
    setState(() => _sending = true);
    try {
      // 1) get an accurate position (threshold 20 meters)
      final Position pos = await GeolocationService.instance
          .getAccuratePosition(
            maxAccuracyMeters: 20,
            timeout: const Duration(seconds: 12),
          );

      // 1.5) compute distance to configured work location
      final double distanceMeters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        kWorkLatitude,
        kWorkLongitude,
      );

      if (distanceMeters > kAllowedRadiusMeters) {
        // Reject and inform user (do not record)
        final msg =
            'You are ${distanceMeters.toStringAsFixed(1)} m away from the work location (allowed ${kAllowedRadiusMeters.toInt()} m). Move closer and try again.';
        if (!mounted) return;
        _showAccuracyDialog(msg); // reuse existing dialog
        return;
      }

      // 2) prepare payload (print instead of sending to server)
      final user = AuthService.instance.currentUser;
      final employeeId = user?.uid ?? 'unknown_employee_id';

      // reverse geocode to get readable location
      final String? placeName = await GeolocationService.instance
          .getPlaceNameFromPosition(pos);

      // Save last resolved name for display (prevents unused-field warning)
      setState(() {
        _lastLocationName = placeName ?? '';
      });

      final payload = {
        'employee_id': employeeId,
        'action': action,
        'device_latitude': pos.latitude,
        'device_longitude': pos.longitude,
        'accuracy_m': pos.accuracy,
        'timestamp': pos.timestamp.toIso8601String(),
        'location_name': placeName ?? '',
        'distance_to_work_m': distanceMeters,
      };

      // Print payload to console / log for testing
      debugPrint('Attendance payload: ${jsonEncode(payload)}');

      // 3) simulate success and update UI
      setState(() {
        if (action == 'check-in') {
          _checkIn = DateTime.now();
          _checkOut = null;
        } else {
          _checkOut = DateTime.now();
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance $action recorded (printed to console)'),
          backgroundColor: Colors.green,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('Poor GPS accuracy') || msg.contains('timed out')) {
        _showAccuracyDialog(msg);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record attendance: $msg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _checkInNow() => _captureAndSend('check-in');
  void _checkOutNow() => _captureAndSend('check-out');

  Duration? get _workedDuration {
    if (_checkIn == null) return null;
    final end = _checkOut ?? DateTime.now();
    return end.difference(_checkIn!);
  }

  Duration get _overtime {
    final worked = _workedDuration ?? Duration.zero;
    if (worked > _standardWork) return worked - _standardWork;
    return Duration.zero;
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '--';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d  $hh:$mm:$ss';
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _signOut() async {
    try {
      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
    }
  }

  void _showAccuracyDialog(String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Location accuracy'),
        content: Text('$message\n\nMove to an open area and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final worked = _workedDuration;
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Attendance Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          centerTitle: true,
          toolbarHeight: 120,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Check in:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(_formatDateTime(_checkIn)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Check out:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                          Text(_formatDateTime(_checkOut)),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // Show last resolved human-readable location (uses _lastLocationName)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Location:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              (_lastLocationName == null ||
                                      _lastLocationName!.isEmpty)
                                  ? '--'
                                  : _lastLocationName!,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Worked',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            worked == null ? '--' : _formatDuration(worked),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Overtime',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatDuration(_overtime),
                            style: TextStyle(
                              color: _overtime > Duration.zero
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_checkIn == null && !_sending)
                          ? _checkInNow
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: _checkIn == null
                            ? theme.primaryColor
                            : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      child: _sending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Check In',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_checkIn != null && _checkOut == null && !_sending)
                          ? _checkOutNow
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: (_checkIn != null && _checkOut == null)
                            ? Colors.blue
                            : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      child: _sending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Check Out',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Standard work day: 08:00:00. Overtime is any time worked beyond that.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Live update when user hasn't checked out
              if (_checkIn != null && _checkOut == null)
                StreamBuilder<DateTime>(
                  stream: Stream<DateTime>.periodic(
                    const Duration(seconds: 1),
                    (_) => DateTime.now(),
                  ),
                  builder: (context, snap) {
                    final liveWorked = _workedDuration ?? Duration.zero;
                    return Text(
                      'Live worked: ${_formatDuration(liveWorked)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    );
                  },
                ),
              const SizedBox(height: 20),

              if (_checkOut != null) ...[
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
