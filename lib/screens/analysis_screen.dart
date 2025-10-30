import 'dart:async';
import 'package:flutter/material.dart';
// Note: SfCartesianChart, CartesianSeries are used for charts
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:bms/services/bms_service.dart';
import 'package:bms/widgets/analysis_card.dart';
import 'package:bms/models/battery_data.dart';
import 'package:bms/widgets/battery_gauge.dart';
import 'package:intl/intl.dart';

// --- Chart Data Model (used internally by Syncfusion) ---
class ChartData {
  ChartData(this.time, this.value);
  final DateTime time;
  final double value;
}

/// Screen dedicated to displaying real-time BMS analysis and historical trends.
class AnalysisScreen extends StatefulWidget {
  final BMSService bmsService;

  const AnalysisScreen({super.key, required this.bmsService});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // Chart Controllers for efficient, incremental updates
  late ChartSeriesController _voltageController;
  late ChartSeriesController _temperatureController;

  // Local data lists that mirror the history in BMSService
  final List<ChartData> _voltageChartData = [];
  final List<ChartData> _temperatureChartData = [];

  // Stream subscription to listen to the service data changes
  late StreamSubscription<BatteryData> _dataSubscription;

  // --- Utility for showing non-intrusive alerts (SnackBar) ---
  void _showAlert(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize chart data with current history from the service
    _initializeChartData();

    // Subscribe to the stream to receive real-time updates
    _dataSubscription = widget.bmsService.batteryDataStream.listen(_updateCharts);
  }

  void _initializeChartData() {
    final now = DateTime.now();
    final voltageHistory = widget.bmsService.voltageHistory;
    final temperatureHistory = widget.bmsService.temperatureHistory;

    // Based on BMSService, the update interval is 1000ms (1 second)
    const int updateIntervalMs = 1000;

    // We populate the initial data points, using time as the X-axis
    // The history in the service is newest-to-oldest, so we reverse the indexing logic
    for (int i = 0; i < voltageHistory.length; i++) {
      // Calculate the time for each point, working backwards from 'now'
      final timeOffset = (voltageHistory.length - 1 - i) * updateIntervalMs;
      final time = now.subtract(Duration(milliseconds: timeOffset));

      _voltageChartData.add(ChartData(time, voltageHistory[i]));
      _temperatureChartData.add(ChartData(time, temperatureHistory[i]));
    }
  }

  void _updateCharts(BatteryData newData) {
    // This method is called every time BMSService emits new data (every 1000ms)

    // Only update if controllers are ready (charts have been rendered)
    if (mounted && _voltageController != null && _temperatureController != null) {
      final newTime = DateTime.now();

      // --- 1. Voltage Chart Update ---
      final newVoltagePoint = ChartData(newTime, newData.voltage);
      _voltageChartData.add(newVoltagePoint);

      // --- 2. Temperature Chart Update ---
      final newTemperaturePoint = ChartData(newTime, newData.temperature);
      _temperatureChartData.add(newTemperaturePoint);

      // Use the fixed history limit (60 points)
      const int limit = BMSService.historyLimit;
      final shouldRemove = _voltageChartData.length > limit;

      if (shouldRemove) {
        // Remove the oldest point (at index 0)
        _voltageChartData.removeAt(0);
        _temperatureChartData.removeAt(0);

        // Update the chart using the ChartSeriesController (High Performance)
        // Adding the newest point at the end, removing the oldest point at the start.
        _voltageController.updateDataSource(
          addedDataIndex: limit - 1,
          removedDataIndex: 0,
        );
        _temperatureController.updateDataSource(
          addedDataIndex: limit - 1,
          removedDataIndex: 0,
        );
      } else {
        // If the chart is still filling up (less than 60 points)
        _voltageController.updateDataSource(addedDataIndex: _voltageChartData.length - 1);
        _temperatureController.updateDataSource(addedDataIndex: _temperatureChartData.length - 1);
      }
    }
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<BatteryData>(
            stream: widget.bmsService.batteryDataStream,
            builder: (context, snapshot) {
              final data = snapshot.data;
              final isDataAvailable = snapshot.hasData;

              // --- ALERT CHECKING LOGIC ---
              if (isDataAvailable) {
                String? alertMessage;
                Color? alertColor;

                // Use constants from BMSService
                const double maxV = BMSService.maxSafeVoltage;
                const double maxT = BMSService.maxSafeTemperature;

                // Check critical voltage alert
                if (data!.voltage > maxV) {
                  alertMessage = 'CRITICAL: Voltage ${data.voltage.toStringAsFixed(2)}V Over Limit!';
                  alertColor = Colors.red.shade700;
                }
                // Check warning temperature alert
                else if (data.temperature > maxT) {
                  alertMessage = 'WARNING: Temperature ${data.temperature.toStringAsFixed(1)}°C High!';
                  alertColor = Colors.orange.shade700;
                }

                if (alertMessage != null) {
                  // Use a post-frame callback to avoid calling setState during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showAlert(context, alertMessage!, alertColor!);
                  });
                }
              }
              // --- END ALERT CHECKING LOGIC ---

              // Determine if the battery is charging (Current > 0)
              final isCharging = (data?.current ?? 0.0) > 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- 1. System Status & Core Metrics Header ---
                  _buildSystemStatusHeader(context, data, isDataAvailable, isCharging),
                  const SizedBox(height: 20),

                  // --- 2. Real-time Cell Monitoring (Vertical List) ---
                  const Text(
                    'Individual Cell Monitoring',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 12),
                  _buildCellMonitoringList(data),
                  const SizedBox(height: 24),

                  // --- 3. Pack Trend Charts ---
                  const Text(
                    'Historical Pack Trends (Real-time)',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 12),

                  // Voltage Trend Card (using SfCartesianChart)
                  _buildPackTrendCard(
                    title: 'Pack Voltage Trend (V)',
                    icon: Icons.bolt,
                    color: Colors.blue.shade700,
                    data: data?.voltage,
                    chartData: _voltageChartData,
                    yMin: 13.8,
                    yMax: 14.6,
                    unit: 'V',
                    onRendererCreated: (controller) => _voltageController = controller,
                  ),

                  // Temperature Trend Card (using SfCartesianChart)
                  _buildPackTrendCard(
                    title: 'Temperature Trend (°C)',
                    icon: Icons.thermostat,
                    color: Colors.orange.shade700,
                    data: data?.temperature,
                    chartData: _temperatureChartData,
                    yMin: 20.0,
                    yMax: 40.0,
                    unit: '°C',
                    onRendererCreated: (controller) => _temperatureController = controller,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildSystemStatusHeader(
      BuildContext context, BatteryData? data, bool isDataAvailable, bool isCharging) {
    final statusText = data?.isSystemOnline == true ? 'ONLINE' : 'OFFLINE';
    final statusColor = data?.isSystemOnline == true ? Colors.green : Colors.red;

    final voltage = data?.voltage ?? 0.0;
    final current = data?.current ?? 0.0;
    final temperature = data?.temperature ?? 0.0;
    final soc = data?.stateOfCharge ?? 0.0;

    return AnalysisCard(
      title: 'BMS System Status',
      status: isDataAvailable ? statusText : 'CONNECTING',
      icon: Icons.battery_full,
      color: statusColor,
      description: 'Core health, performance, and charging metrics for the pack.',
      contentWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Battery Gauge (SoC)
          _buildGaugeAndMetric(
            'SoC',
            '${soc.toStringAsFixed(1)}%',
            'Capacity',
            BatteryGauge(soc: soc, isCharging: isCharging),
          ),
          // Main Metrics
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMainMetric('Voltage', '${voltage.toStringAsFixed(2)} V', Icons.flash_on, Colors.blue),
                _buildMainMetric('Current', '${current.toStringAsFixed(2)} A', Icons.speed, Colors.purple),
                _buildMainMetric('Temp', '${temperature.toStringAsFixed(1)} °C', Icons.thermostat, Colors.orange),
                _buildMainMetric('SoH', '${data?.stateOfHealth.toStringAsFixed(1) ?? 0.0}%', Icons.favorite, Colors.teal),
                _buildMainMetric('Delta V', '${data?.deltaVoltage.toStringAsFixed(3) ?? 0.0} V', Icons.compare_arrows, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeAndMetric(
      String title, String value, String unit, Widget gauge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        SizedBox(
          width: 80, // Fixed width for the gauge area
          height: 80,
          child: gauge,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMainMetric(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 80, // Ensures alignment
            child: Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCellMonitoringList(BatteryData? data) {
    final cellVoltages = data?.cellVoltages ?? [];

    if (cellVoltages.isEmpty) {
      return const Center(child: Text('No cell data available.'));
    }

    return ListView.builder(
      // Use Column and Fixed heights to ensure it works within SingleChildScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cellVoltages.length,
      itemBuilder: (context, index) {
        final cellV = cellVoltages[index];
        // Mocked values for cell-specific display
        // Calculate cell-specific temperature and SOC for variety
        final cellTemp = (data?.temperature ?? 25.0) + (index * 0.2) - (cellVoltages.length / 2 * 0.1);
        final cellSOC = (data?.stateOfCharge ?? 80.0) - (index * 0.5) + (cellVoltages.length / 2 * 0.2);

        return AnalysisCard(
          title: 'Cell ${index + 1}',
          status: cellV > 3.65 ? 'High V' : (cellV < 3.5 ? 'Low V' : 'Nominal'),
          icon: Icons.radio_button_checked,
          color: cellV > 3.65 ? Colors.red : (cellV < 3.5 ? Colors.orange : Colors.green),
          description: 'Voltage: ${cellV.toStringAsFixed(3)}V',
          contentWidget: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCellMetric('Voltage', '${cellV.toStringAsFixed(3)} V', Colors.blue.shade700),
              _buildCellMetric('Capacity', '${cellSOC.toStringAsFixed(1)} %', Colors.purple.shade700),
              _buildCellMetric('Temp', '${cellTemp.toStringAsFixed(1)} °C', Colors.orange.shade700),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCellMetric(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPackTrendCard({
    required String title,
    required IconData icon,
    required Color color,
    required double? data,
    required List<ChartData> chartData,
    required double yMin,
    required double yMax,
    required String unit,
    required ChartSeriesController Function(ChartSeriesController) onRendererCreated,
  }) {
    // Dynamically format the description to show the time limit in minutes
    const int historyLimit = BMSService.historyLimit;
    // NOTE: Based on your BMSService, updateInterval is 1000ms (1 second)
    const int updateIntervalMs = 1000;

    final int limitSeconds = historyLimit * (updateIntervalMs ~/ 1000);
    final String limitText = limitSeconds >= 60
        ? '${limitSeconds ~/ 60} minute'
        : '$limitSeconds seconds';

    // Calculate the time window for the X-axis
    final now = DateTime.now();
    final startTime = now.subtract(Duration(seconds: limitSeconds));

    return AnalysisCard(
      title: title,
      status: 'Current: ${data?.toStringAsFixed(2) ?? 'N/A'} $unit',
      icon: icon,
      color: color,
      description: 'Displays the last $limitText of performance data.',
      contentWidget: SizedBox(
        height: 200, // Increased height for better chart visibility
        child: SfCartesianChart(
          // --- Primary X-Axis (Time) ---
          primaryXAxis: DateTimeAxis(
            // Ensure the visible range is the last 'limitSeconds' window
            minimum: startTime,
            maximum: now,
            intervalType: DateTimeIntervalType.seconds,
            // Calculate interval based on total duration
            interval: (limitSeconds / 4).ceilToDouble(),
            isVisible: true,
            labelStyle: const TextStyle(fontSize: 10),
            dateFormat: DateFormat('m:ss'), // Show time in minutes:seconds
            rangePadding: ChartRangePadding.none,
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
          ),
          // --- Primary Y-Axis (Value) ---
          primaryYAxis: NumericAxis(
            minimum: yMin,
            maximum: yMax,
            interval: (yMax - yMin) / 4, // 4 intervals for the Y-axis
            numberFormat: NumberFormat('0.00'),
            majorGridLines: MajorGridLines(color: Colors.grey.shade300, width: 0.8),
            majorTickLines: const MajorTickLines(size: 0),
            title: AxisTitle(text: unit, textStyle: const TextStyle(fontSize: 12)),
          ),
          // --- Chart Area Configuration ---
          plotAreaBorderWidth: 0,
          margin: const EdgeInsets.all(5),
          tooltipBehavior: TooltipBehavior(enable: true),

          // --- Series (Line Chart) ---
          // FIX 1: Changed from ChartSeries to CartesianSeries to resolve type mismatch
          series: <CartesianSeries<ChartData, DateTime>>[
            AreaSeries<ChartData, DateTime>(
              onRendererCreated: onRendererCreated, // Assign the controller
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.time,
              yValueMapper: (ChartData data, _) => data.value,
              name: title,
              color: color.withOpacity(0.5), // Area fill color
              borderColor: color, // Line color
              borderWidth: 2,
              animationDuration: 0, // Disable animation for real-time
              // Customize the fill gradient
              gradient: LinearGradient(
                colors: [color.withOpacity(0.4), color.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // FIX 2: Removed 'splineType' and 'cardinalSplineTension' to resolve undefined parameter error.
              // The line will now be straight instead of curved.
            ),
          ],
        ),
      ),
    );
  }
}
