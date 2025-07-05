import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class InstalledAppsScreen extends StatefulWidget {
  const InstalledAppsScreen({super.key});

  @override
  State<InstalledAppsScreen> createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<InstalledAppsScreen> {
  final Map<String, List<Application>> _categorizedApps = {
    'Entertainment': [],
    'Gaming': [],
    'Education': [],
    'Social': [],
    'Other': [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      includeAppIcons: true,
    );

    apps = apps
        .where((app) => !app.packageName.startsWith('com.android'))
        .toList();

    for (final app in apps) {
      final cat = _mapCategory(app);
      _categorizedApps[cat]?.add(app);
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _mapCategory(Application app) {
    if (app is ApplicationWithIcon) {
      final category = app.category;
      if (category != null) {
        switch (category) {
          case ApplicationCategory.game:
            return 'Gaming';
          case ApplicationCategory.audio:
          case ApplicationCategory.video:
          case ApplicationCategory.image:
            return 'Entertainment';
          case ApplicationCategory.social:
            return 'Social';
          default:
            break;
        }
      }
    }

    final name = app.appName.toLowerCase();
    if (name.contains('game')) return 'Gaming';
    if (name.contains('edu')) return 'Education';
    if (name.contains('music') ||
        name.contains('video') ||
        name.contains('movie') ||
        name.contains('tv')) {
      return 'Entertainment';
    }
    if (name.contains('facebook') ||
        name.contains('whatsapp') ||
        name.contains('twitter') ||
        name.contains('chat') ||
        name.contains('social') ||
        name.contains('instagram')) {
      return 'Social';
    }
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Installed Apps')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _categorizedApps.entries.map((entry) {
                if (entry.value.isEmpty) return const SizedBox.shrink();
                return ExpansionTile(
                  title: Text(entry.key),
                  children: entry.value.map((app) {
                    return ListTile(
                      leading: app is ApplicationWithIcon
                          ? Image.memory(app.icon, width: 32, height: 32)
                          : null,
                      title: Text(app.appName),
                      subtitle: Text(app.packageName),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}
