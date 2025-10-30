import 'package:flutter/material.dart';

/// A screen dedicated to displaying historical and active system alerts.
class AlertsScreen extends StatelessWidget {
  // Use const constructor to allow instantiation as a const object
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 64, color: Colors.amber),
          SizedBox(height: 16),
          Text(
            'System Alerts and Warnings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This section will display critical battery events and fault logs in real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
