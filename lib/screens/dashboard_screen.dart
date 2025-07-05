import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_status.dart';
import '../providers/device_provider.dart';
import '../services/api_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const DashboardScreen({required this.deviceId, Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialStatus();
  }

  Future<void> _loadInitialStatus() async {
    print('Loading initial status for device: ${widget.deviceId}');
    final status = await ApiService.getDeviceStatus(widget.deviceId);
    if (status != null && mounted) {
      ref.read(deviceStatusProvider.notifier).updateStatus(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(deviceStatusProvider);
    print('Building Dashboard with status: ${status.toJson()}');

    return Scaffold(
      appBar: AppBar(title: const Text('Device Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Device ID: ${widget.deviceId}'),
            Text('Web Filtering: ${status.webFiltering}'),
            ElevatedButton(
              onPressed: () async {
                final newStatus = DeviceStatus(
                  deviceId: widget.deviceId,
                  webFiltering: !status.webFiltering,
                  // Copy other existing values
                  protectionStatus: status.protectionStatus,
                  appControl: status.appControl,
                  screenTime: status.screenTime,
                  location: status.location,
                  dashboard: status.dashboard,
                  timeline: status.timeline,
                  rules: status.rules,
                );
                await ref
                    .read(deviceStatusProvider.notifier)
                    .updateStatus(newStatus);
                await ApiService.updateDeviceStatus(
                  widget.deviceId,
                  newStatus.webFiltering,
                );
              },
              child: const Text('Toggle Web Filtering'),
            ),
          ],
        ),
      ),
    );
  }
}