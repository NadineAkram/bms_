import 'package:flutter/material.dart';
import 'package:bms/services/bms_service.dart';
import 'package:bms/screens/auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  // CORRECT: Must accept the BMSService instance
  final BMSService bmsService;
  const WelcomeScreen({super.key, required this.bmsService});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the Auth screen after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => AuthScreen(bmsService: widget.bmsService),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Dark Blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Logo/Icon ---
            const Icon(
              Icons.bolt,
              color: Colors.white,
              size: 100,
            ),
            const SizedBox(height: 20),
            // --- Title ---
            Text(
              'BMS Console',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 10),
            // --- Tagline ---
            const Text(
              'Real-time Power, Simplified Control',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 50),
            // --- Loading Indicator ---
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
