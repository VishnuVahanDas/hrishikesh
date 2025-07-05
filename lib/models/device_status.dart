class DeviceStatus {
  final String deviceId;
  final bool protectionStatus;
  final bool webFiltering;
  final bool appControl;
  final bool screenTime;
  final bool location;
  final bool dashboard;
  final bool timeline;
  final bool rules;

  DeviceStatus({
    required this.deviceId,
    this.protectionStatus = false,
    this.webFiltering = false,
    this.appControl = false,
    this.screenTime = false,
    this.location = false,
    this.dashboard = false,
    this.timeline = false,
    this.rules = false,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      deviceId: json['device_id'],
      protectionStatus: json['protection_status'] ?? false,
      webFiltering: json['web_filtering'] ?? false,
      appControl: json['app_control'] ?? false,
      screenTime: json['screen_time'] ?? false,
      location: json['location'] ?? false,
      dashboard: json['dashboard'] ?? false,
      timeline: json['timeline'] ?? false,
      rules: json['rules'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'protection_status': protectionStatus,
      'web_filtering': webFiltering,
      'app_control': appControl,
      'screen_time': screenTime,
      'location': location,
      'dashboard': dashboard,
      'timeline': timeline,
      'rules': rules,
    };
  }
}