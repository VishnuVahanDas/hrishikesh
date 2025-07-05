import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../services/api_service.dart';
import '../models/app_usage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;
  List<AppUsage> _usage = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeviceLogic();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUsageStats();
    }
  }

  void _initDeviceLogic() async {
    await ApiService.registerDevice();
    final allDevices = await ApiService.fetchDevices();

    const MethodChannel channel = MethodChannel('parent_control/device');
    String? currentDeviceId;
    try {
      currentDeviceId = await channel.invokeMethod<String>('getDeviceId');
    } on PlatformException {
      currentDeviceId = null;
    }

    if (currentDeviceId != null) {
      final filtered =
          allDevices.where((d) => d['device_id'] == currentDeviceId).toList();
      setState(() {
        _devices = filtered;
      });
    } else {
      setState(() {
        _devices = allDevices;
      });
    }

    await _checkUsagePermission(openSettings: true);
    await _fetchUsageStats();

    setState(() => _isLoading = false);
  }

  Future<bool> _checkUsagePermission({bool openSettings = false}) async {
    const MethodChannel channel = MethodChannel('parent_control/device');
    final bool hasPermission =
        await channel.invokeMethod<bool>('hasUsagePermission') ?? false;
    if (!hasPermission && openSettings) {
      const intent = AndroidIntent(
        action: 'android.settings.USAGE_ACCESS_SETTINGS',
      );
      await intent.launch();
    }
    return hasPermission;
  }

  Future<void> _fetchUsageStats({DateTime? date}) async {
    const MethodChannel channel = MethodChannel('parent_control/device');
    final bool granted =
        await channel.invokeMethod<bool>('hasUsagePermission') ?? false;
    if (!granted) {
      setState(() => _usage = []);
      return;
    }

    try {
      final target = date ?? _selectedDate;
      final start = DateTime(target.year, target.month, target.day)
          .millisecondsSinceEpoch;
      final end = DateTime(target.year, target.month, target.day)
          .add(const Duration(days: 1))
          .millisecondsSinceEpoch;

      final List<dynamic>? result = await channel.invokeMethod<List<dynamic>>(
        'getUsageStats',
        {'start': start, 'end': end},
      );
      if (result != null) {
        final usage = result
            .map((e) => AppUsage.fromMap(Map<dynamic, dynamic>.from(e)))
            .toList();
        usage.sort((a, b) => b.usage.compareTo(a.usage));
        setState(() => _usage = usage);
      } else {
        setState(() => _usage = []);
      }
    } on PlatformException {
      setState(() => _usage = []);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _fetchUsageStats(date: picked);
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'App Usage (${_selectedDate.toString().split(' ')[0]})',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ),
                  if (_usage.isNotEmpty)
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
                          title: Text(u.packageName),
                          trailing: Text(duration),
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No usage data available.'),
                    )
                ],
              ),
            ),
    );
  }
}
