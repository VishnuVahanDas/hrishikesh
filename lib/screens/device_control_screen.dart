// screens/device_control_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_status.dart';
import '../providers/device_provider.dart';

class DeviceControlScreen extends ConsumerWidget {
  final String deviceId;

  const DeviceControlScreen({required this.deviceId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(deviceStatusProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Device Control')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildToggleSwitch(
              context: context,
              label: 'Web Filtering',
              value: status.webFiltering,
              onChanged: (value) => _updateStatus(ref, webFiltering: value),
            ),
            _buildToggleSwitch(
              context: context,
              label: 'App Control',
              value: status.appControl,
              onChanged: (value) => _updateStatus(ref, appControl: value),
            ),
            // Add more controls as needed
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch({
    required BuildContext context,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        value ? Icons.check_circle : Icons.remove_circle,
        color: value ? Colors.green : Colors.red,
      ),
    );
  }

  void _updateStatus(WidgetRef ref, {
    bool? webFiltering,
    bool? appControl,
    // Add other parameters as needed
  }) {
    final current = ref.read(deviceStatusProvider);
    final newStatus = DeviceStatus(
      deviceId: deviceId,
      webFiltering: webFiltering ?? current.webFiltering,
      appControl: appControl ?? current.appControl,
      // Copy other fields from current status
      protectionStatus: current.protectionStatus,
      screenTime: current.screenTime,
      location: current.location,
      dashboard: current.dashboard,
      timeline: current.timeline,
      rules: current.rules,
    );

    ref.read(deviceStatusProvider.notifier).updateStatus(newStatus);
  }
}