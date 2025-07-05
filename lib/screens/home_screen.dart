import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/app_usage.dart';
import 'installed_apps_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;
  List<AppUsage> _usage = [];
  Duration _totalScreenTime = Duration.zero;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initDeviceLogic();
  }

  Future<void> _fetchUsage() async {
    const MethodChannel channel = MethodChannel('parent_control/device');
    List<AppUsage> usage = [];
    try {
      final startOfDay = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day);
      final List<dynamic>? result = await channel.invokeMethod<List<dynamic>>(
        'getUsageStats',
        {'dateMillis': startOfDay.millisecondsSinceEpoch},
      );
      if (result != null) {
        usage = result
            .map((e) => AppUsage.fromMap(Map<dynamic, dynamic>.from(e)))
            .toList();
        usage.sort((a, b) => b.usage.compareTo(a.usage));
      }
    } on PlatformException {
      usage = [];
    }

    setState(() {
      _usage = usage;
      _totalScreenTime = usage.fold(
          Duration.zero, (sum, item) => sum + item.usage);
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _fetchUsage();
    }
  }

  void _initDeviceLogic() async {
    await ApiService.registerDevice();
    final allDevices = await ApiService.fetchDevices();

    const MethodChannel channel = MethodChannel('parent_control/device');
    final bool hasPermission =
        await channel.invokeMethod<bool>('hasUsagePermission') ?? false;
    if (!hasPermission) {
      const intent = AndroidIntent(
        action: 'android.settings.USAGE_ACCESS_SETTINGS',
      );
      await intent.launch();
    }
    String? currentDeviceId;
    try {
      currentDeviceId = await channel.invokeMethod<String>('getDeviceId');
    } on PlatformException {
      currentDeviceId = null;
    }

    await _fetchUsage();

    if (currentDeviceId != null) {
      final filtered = allDevices
          .where((d) => d['device_id'] == currentDeviceId)
          .toList();
      setState(() {
        _devices = filtered;
        _isLoading = false;
      });
    } else {
      setState(() {
        _devices = allDevices;
        _isLoading = false;
      });
    }
  }

  void _toggleDeviceStatus(String deviceId, bool currentStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Status Change'),
        content: Text(
          currentStatus
              ? 'Are you sure you want to deactivate this device?'
              : 'Do you want to activate this device?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final newStatus = !currentStatus;
    final success = await ApiService.updateDeviceStatus(deviceId, newStatus);

    if (success) {
      final updatedDevices = await ApiService.fetchDevices();
      setState(() => _devices = updatedDevices);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device status updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  String _formatTotalScreenTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes - hours * 60).toString().padLeft(2, '0');
    return 'Total Screen Time: ${hours.toString().padLeft(2, '0')}:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registered Devices")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_devices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text("No devices found.")),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final d = _devices[index];
                  return ListTile(
                    title: Text(d['name'] ?? 'No name'),
                    subtitle: Text("ID: ${d['device_id'] ?? 'Unknown'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          d['is_active'] == true
                              ? Icons.check_circle
                              : Icons.block,
                          color: d['is_active'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                        IconButton(
                          icon: const Icon(Icons.sync),
                          tooltip: "Toggle Status",
                          onPressed: () => _toggleDeviceStatus(
                            d['device_id'],
                            d['is_active'],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                        "Selected: ${_selectedDate.toString().split(' ')[0]}"),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Choose Date'),
                  )
                ],
              ),
            ),
            if (_usage.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                    "App Usage (${_selectedDate.toString().split(' ')[0]})",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _formatTotalScreenTime(_totalScreenTime),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _usage.length,
                itemBuilder: (context, index) {
                  final u = _usage[index];
                  final hours = u.usage.inHours;
                  final minutes =
                  (u.usage.inMinutes - hours * 60).toString().padLeft(2, '0');
                  final duration = '${hours.toString().padLeft(2, '0')}:$minutes';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: MemoryImage(base64Decode(u.icon)),
                    ),
                    title: Text(u.appName),
                    subtitle: Text(u.packageName),
                    trailing: Text(duration),
                  );
                },
              ),
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InstalledAppsScreen()),
          );
        },
        tooltip: 'Installed Apps',
        child: const Icon(Icons.add),
      ),
    );
  }
}
