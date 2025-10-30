// lib/services/bms_service.dart

import 'dart:async';
import 'dart:math';
import '../models/battery_data.dart';

/// Service class to manage BMS data stream and history.
class BMSService {
  // Constants used for alert checking in AnalysisScreen
  static const double maxSafeVoltage = 14.5;
  static const double maxSafeTemperature = 35.0;

  final _controller = StreamController<BatteryData>.broadcast();
  Stream<BatteryData> get batteryDataStream => _controller.stream;
  Timer? _timer;

  // --- History Storage Fields ---
  final List<List<double>> _voltageSocHistory = [];
  final List<double> _temperatureHistory = [];

  static const int historyLimit = 60; // Keep last 60 data points

  // --- PUBLIC GETTERS for AnalysisScreen Charts ---
  List<double> get voltageHistory => _voltageSocHistory.map((item) => item[1]).toList();
  List<double> get temperatureHistory => _temperatureHistory;

  // Public stream for connectivity status (used in Dashboard AppBar)
  final _connectivityController = StreamController<Map<String, bool>>.broadcast();
  Stream<Map<String, bool>> get connectivityStream => _connectivityController.stream;


  // Current state object
  late BatteryData _currentState;

  BMSService({bool autoStart = false}) {
    // Initial mock state setup
    _currentState = const BatteryData(
      voltage: 14.2,
      current: 0.5,
      temperature: 25.0,
      stateOfCharge: 80.0,
      stateOfHealth: 95.0,
      deltaVoltage: 0.0,
      cellVoltages: [3.55, 3.56, 3.54, 3.57],
      isSystemOnline: false,
    );

    // Initial connectivity status
    _connectivityController.add({'bluetooth': false, 'wifi': false});

    if (autoStart) {
      updateSystemStatus(true);
    }
  }

  // Getter for online status
  bool get isSystemOnline => _currentState.isSystemOnline;

  void startDataSimulation() {
    _timer?.cancel();
    // Simulate connectivity change on start
    _connectivityController.add({'bluetooth': true, 'wifi': true});

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_currentState.isSystemOnline) {
        _updateMockData();
        _updateHistory();
      }
      _broadcastData();
    });
  }

  void _updateMockData() {
    final random = Random();

    // --- 1. SoC Decay (Faster to show curve over 60 seconds) ---
    double newSoc = (_currentState.stateOfCharge - 0.25).clamp(20.0, 100.0);

    // --- 2. Voltage Update (Simulated based on SoC) ---
    double baseV = 13.8 + ((newSoc - 20) / 80) * 0.8;
    double newVoltage = (baseV + random.nextDouble() * 0.05 - 0.025).clamp(13.8, 14.6);

    // 3. Current and Temperature
    double newCurrent = (0.5 + random.nextDouble() * 0.2).clamp(0.0, 0.7);
    double tempChange = random.nextDouble() * 0.4 - 0.2;
    double tempDriftFactor = (_currentState.temperature < 25.0) ? 0.05 : -0.05;
    double newTemperature = (_currentState.temperature + tempChange + tempDriftFactor).clamp(20.0, 40.0);

    // 4. Cell Voltages
    List<double> newCellVoltages = List.from(_currentState.cellVoltages);
    double baseCellV = newVoltage / 4.0;
    for (int i = 0; i < 4; i++) {
      newCellVoltages[i] = (baseCellV + random.nextDouble() * 0.02 - 0.01).clamp(3.45, 3.65);
    }
    double newDeltaVoltage = newCellVoltages.reduce(max) - newCellVoltages.reduce(min);

    // Update the state object immutably
    _currentState = _currentState.copyWith(
      voltage: newVoltage,
      current: newCurrent,
      temperature: newTemperature,
      stateOfCharge: newSoc,
      deltaVoltage: newDeltaVoltage,
      cellVoltages: newCellVoltages,
    );
  }

  // --- History Update Method ---
  void _updateHistory() {
    // Log {SoC, Voltage} pair and Temperature over time
    _voltageSocHistory.add([_currentState.stateOfCharge, _currentState.voltage]);
    _temperatureHistory.add(_currentState.temperature);

    if (_voltageSocHistory.length > historyLimit) {
      _voltageSocHistory.removeAt(0);
    }
    if (_temperatureHistory.length > historyLimit) {
      _temperatureHistory.removeAt(0);
    }
  }

  void _broadcastData() {
    _controller.add(_currentState);
  }

  void updateSystemStatus(bool newState) {
    if (_currentState.isSystemOnline == newState) return;

    _currentState = _currentState.copyWith(isSystemOnline: newState);

    if (newState) {
      startDataSimulation();
    } else {
      stopDataSimulation();
      // Reset current and connectivity when turning off
      _currentState = _currentState.copyWith(current: 0.0);
      _connectivityController.add({'bluetooth': false, 'wifi': false});
    }
    _broadcastData();
  }

  void stopDataSimulation() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopDataSimulation();
    _controller.close();
    _connectivityController.close();
  }
}