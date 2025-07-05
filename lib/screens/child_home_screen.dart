import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _askUsagePermission);
  }

  void _askUsagePermission() async {
    final intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Child Mode")),
      body: const Center(
        child: Text("Monitoring is active. Please grant usage access."),
      ),
    );
  }
}
