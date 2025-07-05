class AppUsage {
  final String packageName;
  final Duration usage;
  final String appName;
  final String icon;

  AppUsage({
    required this.packageName,
    required this.usage,
    required this.appName,
    required this.icon,
  });

  factory AppUsage.fromMap(Map<dynamic, dynamic> map) {
    final int millis = map['usage'] ?? 0;
    return AppUsage(
      packageName: map['packageName'] ?? '',
      usage: Duration(milliseconds: millis),
      appName: map['appName'] ?? '',
      icon: map['icon'] ?? '',
    );
  }
}
