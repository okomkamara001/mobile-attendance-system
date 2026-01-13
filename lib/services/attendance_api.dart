import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceApi {
  /// Replace with your Odoo attendance endpoint
  static const String _endpoint =
      'https://your-odoo-host.example.com/api/attendance';

  /// Sends attendance payload. Return true on success.
  static Future<bool> sendAttendance({
    required String employeeId,
    required String action, // "check-in" or "check-out"
    required double deviceLatitude,
    required double deviceLongitude,
    String? authToken, // optional bearer token
  }) async {
    final uri = Uri.parse(_endpoint);
    final body = jsonEncode({
      'employee_id': employeeId,
      'action': action,
      'device_latitude': deviceLatitude,
      'device_longitude': deviceLongitude,
    });

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final resp = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));
    if (resp.statusCode >= 200 && resp.statusCode < 300) return true;
    throw Exception('Server error ${resp.statusCode}: ${resp.body}');
  }
}
