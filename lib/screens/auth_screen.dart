import 'package:flutter/material.dart';
import '../services/bms_service.dart';
import 'dashboard_screen.dart'; // REQUIRED to define DashboardScreen

/// A screen for simulated authentication/login.
/// Upon pressing the button, it navigates to the Dashboard.
class AuthScreen extends StatefulWidget {
  final BMSService bmsService;

  const AuthScreen({super.key, required this.bmsService});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false; // State to manage button loading visual

  // Simulates a quick asynchronous sign-in process
  void _simulateLogin() async {
    // Prevent multiple presses while logging in
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for a better user experience (UX)
    await Future.delayed(const Duration(milliseconds: 800));

    // Use pushReplacement to ensure the user cannot navigate back to the AuthScreen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => DashboardScreen(bmsService: widget.bmsService),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24.0),
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.power_settings_new,
                  size: 60,
                  color: Color(0xFF1A237E),
                ),
                const SizedBox(height: 10),
                const Text(
                  'BMS System Access',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tap below to start the simulated data stream and access the dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _simulateLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    'Connect to BMS', // Updated text here
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
