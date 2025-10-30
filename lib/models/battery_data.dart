import 'package:flutter/foundation.dart';

/// Data model for a single snapshot of BMS data.
@immutable
class BatteryData {
  final double voltage; // Total pack voltage (V)
  final double current; // Current flow (A)
  final double temperature; // Max pack temperature (°C)
  final double stateOfCharge; // SoC (%)
  final double stateOfHealth; // SoH (%)
  final double deltaVoltage; // Max cell voltage difference (V)
  final List<double> cellVoltages; // Individual cell voltages (V)
  final bool isSystemOnline; // True if the simulation/system is running

  const BatteryData({
    required this.voltage,
    required this.current,
    required this.temperature,
    required this.stateOfCharge,
    required this.stateOfHealth,
    required this.deltaVoltage,
    required this.cellVoltages,
    required this.isSystemOnline,
  });

  /// Creates a new BatteryData instance, copying all fields and allowing
  /// specific fields to be overridden with new values.
  BatteryData copyWith({
    double? voltage,
    double? current,
    double? temperature,
    double? stateOfCharge,
    double? stateOfHealth,
    double? deltaVoltage,
    List<double>? cellVoltages,
    bool? isSystemOnline,
  }) {
    return BatteryData(
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      temperature: temperature ?? this.temperature,
      stateOfCharge: stateOfCharge ?? this.stateOfCharge,
      stateOfHealth: stateOfHealth ?? this.stateOfHealth,
      deltaVoltage: deltaVoltage ?? this.deltaVoltage,
      cellVoltages: cellVoltages ?? this.cellVoltages,
      isSystemOnline: isSystemOnline ?? this.isSystemOnline,
    );
  }

  @override
  String toString() {
    return 'BatteryData(V: ${voltage.toStringAsFixed(2)}, Temp: ${temperature.toStringAsFixed(1)}, SoC: ${stateOfCharge.toStringAsFixed(1)}%)';
  }
}
