import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import 'package:flutter/services.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  /// Login and store tokens
  static Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/token/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'access', value: data['access']);
      await _storage.write(key: 'refresh', value: data['refresh']);
      return true;
    } else {
      return false;
    }
  }

  /// Read access token from secure storage
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access');
  }

  /// Clear tokens on logout
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// Register device if not already registered
  static Future<bool> registerDevice() async {
    final token = await getAccessToken();
    if (token == null) return false;

    const platform = "Android";
    const deviceName = "RMX3371";
    const MethodChannel channel = MethodChannel('parent_control/device');

    String? deviceId;
    try {
      deviceId = await channel.invokeMethod<String>('getDeviceId');
    } on PlatformException catch (e) {
      print('Failed to get device ID: ${e.message}');
      return false;
    }

    // Check if already registered
    final listResponse = await http.get(
      Uri.parse('$baseUrl/devices/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (listResponse.statusCode == 200) {
      final List devices = json.decode(listResponse.body);
      final exists = devices.any((d) => d['device_id'] == deviceId);
      if (exists) return true; // already registered
    }

    // Register device
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/devices/register/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "name": deviceName,
        "platform": platform,
        "device_id": deviceId,
      }),
    );

    return registerResponse.statusCode == 201;
  }

  /// Get all devices registered by the current user
  static Future<List<Map<String, dynamic>>> fetchDevices() async {
    final token = await getAccessToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/devices/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      return [];
    }
  }

  /// Update device status (active/inactive)
  static Future<bool> updateDeviceStatus(String deviceId, bool isActive) async {
    final token = await getAccessToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/update-device-status/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "device_id": deviceId,
        "is_active": isActive,
      }),
    );

    return response.statusCode == 200;
  }
}
