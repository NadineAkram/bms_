import 'package:flutter/material.dart';
// Use show to only import the BMSService class from the service file,
// preventing conflicts if other screens also accidentally import BMSService.
import '../services/bms_service.dart' show BMSService;
import 'analysis_screen.dart'; // Displays charts and cell data
import 'controls_screen.dart'; // Handles switches and connectivity
import 'alerts_screen.dart'; // Placeholder for future alerts

/// The main navigation hub of the application, managing the BottomNavigationBar.
class DashboardScreen extends StatefulWidget {
  final BMSService bmsService;

  const DashboardScreen({super.key, required this.bmsService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Index for BottomNavigationBar

  // List of pages to display in the main body.
  // The service is passed down to each screen that needs real-time data or control.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // CRITICAL FIX: Start the data stream/simulation immediately when the dashboard initializes.
    // This ensures that the BMSService history lists are populated
    // before the AnalysisScreen's chart painters try to read them.
    // We check if it's already online to prevent unnecessary restarts.
    if (!widget.bmsService.isSystemOnline) {
      widget.bmsService.updateSystemStatus(true);
    }

    _pages = <Widget>[
      AnalysisScreen(bmsService: widget.bmsService),
      // NOTE: ControlsScreen and AlertsScreen need to be defined in their respective files
      ControlsScreen(bmsService: widget.bmsService),
      const AlertsScreen(),
    ];
  }

  // Ensure the timer/simulation is stopped when the widget is disposed
  @override
  void dispose() {
    widget.bmsService.stopDataSimulation();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar title changes based on the selected page
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Display the selected page body
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // The navigation bar is placed at the bottom
      bottomNavigationBar: BottomNavigationBar(
        // Ensure consistent icon scaling and visual balance on all devices
        iconSize: 26.0, // Set a specific size for better scaling control
        selectedFontSize: 12.0, // Keep text small to prioritize icon space
        unselectedFontSize: 10.0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Controls',
            // Temporarily disable the interactive status indicator if needed
            // activeIcon: Icon(Icons.settings_applications),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: 'Alerts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Real-time Analysis';
      case 1:
        return 'System Controls & Connectivity';
      case 2:
        return 'Critical System Alerts';
      default:
        return 'BMS Dashboard';
    }
  }
}
