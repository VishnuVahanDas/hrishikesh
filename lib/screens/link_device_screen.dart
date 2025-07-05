import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // For MethodChannel and PlatformException

class LinkDeviceScreen extends StatefulWidget {
  const LinkDeviceScreen({super.key});

  @override
  State<LinkDeviceScreen> createState() => _LinkDeviceScreenState();
}

class _LinkDeviceScreenState extends State<LinkDeviceScreen> {
  final _deviceNameController = TextEditingController();
  String _platform = 'ANDROID';
  bool _loading = false;
  String _message = '';
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    try {
      const channel = MethodChannel('parent_control/device');
      final id = await channel.invokeMethod<String>('getDeviceId');
      setState(() {
        _deviceId = id;
      });
    } catch (e) {
      print("Error getting device ID: $e");
      setState(() {
        _deviceId = 'Unavailable';
      });
    }
  }

  Future<void> _linkDevice() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';

    if (_deviceId == null || _deviceId == 'Unavailable') {
      setState(() {
        _message = '❌ Device ID is unavailable.';
        _loading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('https://vishnuvahan.com/api/devices/register/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': _deviceNameController.text,
        'platform': _platform,
        'device_id': _deviceId,
      }),
    );

    setState(() {
      _loading = false;
    });
    if (response.statusCode == 201) {
      await prefs.setString('device_id', _deviceId!);
      await prefs.setBool('logged_in', true);

      setState(() {
        _message = '✅ Device linked successfully!';
      });

      Navigator.pushReplacementNamed(context, '/home');

    } else if (response.statusCode == 200 && response.body.contains('Device already linked')) {
      setState(() {
        _message = '✅ Device already linked to your account.';
      });

      Navigator.pushReplacementNamed(context, '/home');

    } else if (response.statusCode == 403 && response.body.contains('another user')) {
      setState(() {
        final msg = json.decode(response.body)['error'];
        _message = '❌ $msg';
      });
    } else {
      setState(() {
        _message = '❌ Failed (${response.statusCode}): ${response.body}';
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Your Device')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _deviceNameController,
              decoration: const InputDecoration(labelText: 'Device Name'),
            ),
            DropdownButton<String>(
              value: _platform,
              items: ['ANDROID', 'IOS', 'WINDOWS', 'MAC', 'LINUX']
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) => setState(() => _platform = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _linkDevice,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Link Device'),
            ),
            const SizedBox(height: 20),
            if (_deviceId != null)
              Text('Device ID: $_deviceId', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            if (_message.isNotEmpty) Text(_message),
          ],
        ),
      ),
    );
  }
}
