import 'package:flutter/material.dart';
import '../services/bms_service.dart';

/// Screen for managing Bluetooth/Connection settings, now with device listing.
class ConnectivityScreen extends StatelessWidget {
  final BMSService bmsService;

  const ConnectivityScreen({super.key, required this.bmsService});

  // Mock list of devices for demonstration
  final List<String> mockDevices = const [
    'BMS-LiFePO4-001',
    'BMS-NMC-002 (In Use)',
    'BLE_Scanner_123',
    'BMS-Debug-Unit',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to BMS'),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Connection Status Card ---
            _buildStatusCard(context),
            const SizedBox(height: 24),

            // --- 2. Device List Header and Button ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Devices',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Future logic to start Bluetooth scanning
                  },
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Scan', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- 3. Device List ---
            _buildDeviceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    // Current status is hardcoded since we are mocking data
    const isConnected = true;
    final statusText = isConnected ? 'Connected' : 'Disconnected';
    final statusColor = isConnected ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle_outline : Icons.link_off,
              size: 40,
              color: statusColor,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status: $statusText',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
                ),
                const SizedBox(height: 4),
                Text(
                  isConnected ? 'Data streaming successfully from device.' : 'Simulated data is active. Connect to a device.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockDevices.length,
      itemBuilder: (context, index) {
        final deviceName = mockDevices[index];
        final isConnected = deviceName.contains('(In Use)');

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: Icon(
              Icons.devices_other,
              color: isConnected ? Colors.green.shade700 : Colors.blue.shade400,
            ),
            title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(isConnected ? 'Active Connection' : 'RSSI: -75 dBm'),
            trailing: isConnected
                ? const Chip(label: Text('Connected', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green)
                : ElevatedButton(
              onPressed: () {
                // Future connection logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: const Text('Connect'),
            ),
          ),
        );
      },
    );
  }
}
