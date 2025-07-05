// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loginUser(String username, String password) async {
  final url = Uri.parse('https://vishnuvahan.com/api/token/');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final accessToken = data['access'];
    final refreshToken = data['refresh'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);

    print('✅ Tokens saved successfully');
  } else {
    print('❌ Login failed: ${response.body}');
  }
}
