import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDeviceLogic();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registered Devices")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
          ? const Center(child: Text("No devices found."))
          : ListView.builder(
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
    );
  }
}
