class AppUsage {
  final String packageName;
  final Duration usage;

  AppUsage({required this.packageName, required this.usage});

  factory AppUsage.fromMap(Map<dynamic, dynamic> map) {
    final int millis = map['usage'] ?? 0;
    return AppUsage(
      packageName: map['packageName'] ?? '',
      usage: Duration(milliseconds: millis),
    );
  }
}
