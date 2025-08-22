import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings Page'),
            ElevatedButton(
              onPressed: () {
                // Add your settings logic here
                print('Settings button pressed');
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
