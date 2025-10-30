// lib/screens/controls_screen.dart

import 'package:flutter/material.dart';
import '../services/bms_service.dart' show BMSService;
import '../widgets/analysis_card.dart';
import '../models/battery_data.dart';

/// A screen dedicated to controlling the BMS system and viewing connectivity status.
class ControlsScreen extends StatefulWidget {
  final BMSService bmsService;

  const ControlsScreen({super.key, required this.bmsService});

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  // Simulates connectivity state, separate from the main BMS system state
  bool _isWifiConnected = true;
  bool _isBluetoothConnected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<BatteryData>(
          // Use null assertion operator as required by your environment
          stream: widget.bmsService.batteryDataStream,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final isSystemOnline = data?.isSystemOnline ?? false;
            final isDataAvailable = snapshot.hasData;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- 1. Master Power Control ---
                _buildMasterControlCard(isSystemOnline, isDataAvailable),
                const SizedBox(height: 16),

                // --- 2. Emergency Shutoff ---
                _buildEmergencyShutoffCard(isSystemOnline),
                const SizedBox(height: 24),

                // --- 3. Connectivity Status ---
                const Text(
                  'BMS Communication Status',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 12),
                _buildConnectivityCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildMasterControlCard(bool isSystemOnline, bool isDataAvailable) {
    final statusText = isSystemOnline ? 'ONLINE' : 'OFFLINE';
    final statusColor = isSystemOnline ? Colors.green : Colors.red;

    return AnalysisCard(
      title: 'Master Power Switch',
      status: isDataAvailable ? statusText : 'CONNECTING',
      icon: Icons.power,
      color: statusColor,
      description: 'Controls the main high-voltage contactor. Switch OFF for maintenance.',
      contentWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isSystemOnline ? 'System is ACTIVE' : 'System is INACTIVE',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: statusColor),
          ),
          Switch.adaptive(
            value: isSystemOnline,
            onChanged: (newValue) {
              widget.bmsService.updateSystemStatus(newValue);
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyShutoffCard(bool isSystemOnline) {
    return AnalysisCard(
      title: 'Emergency Cutoff (BMS Hard Stop)',
      status: 'CRITICAL',
      icon: Icons.stop_circle,
      color: Colors.red.shade800,
      description: 'Immediately disconnects all power sources and loads. USE WITH CAUTION.',
      contentWidget: Center(
        child: ElevatedButton.icon(
          onPressed: isSystemOnline ? () => _showEmergencyDialog(context) : null,
          icon: const Icon(Icons.emergency_outlined, size: 28),
          label: const Text('PERFORM EMERGENCY SHUTDOWN'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
          ),
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CONFIRM SHUTDOWN'),
          content: const Text(
            'Are you absolutely sure you want to perform an Emergency Cutoff? This will immediately disconnect all power. This action cannot be easily reversed.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('SHUTDOWN NOW'),
              onPressed: () {
                // Call the service to turn the system OFF
                widget.bmsService.updateSystemStatus(false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildConnectivityCard() {
    return AnalysisCard(
      title: 'External Communications',
      status: 'OK',
      icon: Icons.router,
      color: Colors.teal,
      description: 'Status of external data links to the BMS system.',
      contentWidget: Column(
        children: [
          _buildConnectionToggle(
            'Wi-Fi Link',
            Icons.wifi,
            _isWifiConnected,
                (newValue) => setState(() => _isWifiConnected = newValue),
          ),
          _buildConnectionToggle(
            'Bluetooth Link',
            Icons.bluetooth,
            _isBluetoothConnected,
                (newValue) => setState(() => _isBluetoothConnected = newValue),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionToggle(
      String label,
      IconData icon,
      bool isConnected,
      ValueChanged<bool> onChanged,
      ) {
    final statusText = isConnected ? 'Connected' : 'Disconnected';
    final statusColor = isConnected ? Colors.green.shade600 : Colors.red.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Row(
            children: [
              Text(
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
              Switch.adaptive(
                value: isConnected,
                onChanged: onChanged,
                activeColor: Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}