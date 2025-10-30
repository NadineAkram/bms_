import 'package:flutter/material.dart';
import 'package:bms/services/bms_service.dart';
import 'package:bms/screens/welcome_screen.dart';
import 'dart:convert';

// --- APPLICATION ENTRYPOINT ---
void main() {
  // Ensures all Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BMSApp());
}

// Create the main application widget
class BMSApp extends StatelessWidget {
  const BMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Professional BMS Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Professional, modern look
        primaryColor: const Color(0xFF0D47A1), // Dark Blue
        scaffoldBackgroundColor: const Color(0xFFF0F4F8), // Light Gray/Blue background

        textTheme: const TextTheme(
          headlineSmall: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E) // Dark Indigo
          ),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        useMaterial3: true,
      ),
      home: const InitializationWrapper(),
    );
  }
}

/// Handles service initialization and initial routing.
class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  // Use 'late' since it will be initialized in initState
  late final BMSService _bmsService;

  @override
  void initState() {
    super.initState();
    // 1. Initialize the service
    _bmsService = BMSService();

    // 2. Start data simulation IMMEDIATELY so history begins accumulating.
    _bmsService.startDataSimulation();

    // NEW: Explicitly set the system status to online immediately.
    // This ensures data generation starts regardless of the service's internal starting conditions.
    _bmsService.updateSystemStatus(true);
  }

  @override
  Widget build(BuildContext context) {
    // The service is passed to the initial screen (WelcomeScreen).
    return WelcomeScreen(bmsService: _bmsService);
  }

  @override
  void dispose() {
    _bmsService.dispose();
    super.dispose();
  }
}
