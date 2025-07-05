import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_status.dart';

final deviceStatusProvider = StateNotifierProvider<DeviceStatusNotifier, DeviceStatus>((ref) {
  return DeviceStatusNotifier(
    DeviceStatus(deviceId: 'default-id'), // Initial state
  );
});

class DeviceStatusNotifier extends StateNotifier<DeviceStatus> {
  DeviceStatusNotifier(super.state);

  Future<void> updateStatus(DeviceStatus newStatus) async {
    state = newStatus;
    // Add any async operations here if needed
    print('Status updated: ${newStatus.toJson()}');
  }
}