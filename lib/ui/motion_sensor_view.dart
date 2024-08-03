import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_smart/notifications/notification_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class MotionSensorView extends StatefulWidget {
  @override
  _MotionSensorViewState createState() => _MotionSensorViewState();
}

class _MotionSensorViewState extends State<MotionSensorView> {
  bool isMotionDetected = false;
  late StreamSubscription<AccelerometerEvent> _streamSubscription;
  final NotificationManager _notificationManager = NotificationManager();
  final List<FlSpot> _accelerometerData = [];
  bool _shouldUpdateChart = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    startListening();
  }

  Future<void> _initializeNotifications() async {
    await _notificationManager.init();
  }

  void startListening() {
    _streamSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      double magnitude = sqrt(x * x + y * y + z * z);
      bool motionDetected = magnitude > 15.0;

      setState(() {
        isMotionDetected = motionDetected;
        _accelerometerData
            .add(FlSpot(_accelerometerData.length.toDouble(), magnitude));
        _shouldUpdateChart = true;
      });

      if (motionDetected) {
        _notificationManager.showMotionDetectedNotification();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motion Sensor View'),
      ),
      body: Container(
        // color: isMotionDetected
        //     ? const Color.fromARGB(255, 166, 208, 14)
        //     : const Color.fromARGB(255, 203, 22, 130),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const Text(
                //   'Motion Sensor',
                //   textAlign: TextAlign.center,
                //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 16),
                // Card(
                //   elevation: 4,
                //   child: Padding(
                //     padding: const EdgeInsets.all(16.0),
                //     child: Text(
                //       isMotionDetected
                //           ? 'Significant Motion Detected'
                //           : 'No Significant Motion Detected',
                //       textAlign: TextAlign.center,
                //       style: const TextStyle(fontSize: 18),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (value, _) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: Colors.black, width: 2),
                          left: BorderSide(color: Colors.black, width: 2),
                          right: BorderSide(color: Colors.transparent),
                          top: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      minX: 0,
                      maxX: _accelerometerData.isEmpty
                          ? 0
                          : _accelerometerData.length.toDouble(),
                      minY: 0,
                      maxY: 20,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _shouldUpdateChart ? _accelerometerData : [],
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff23b6e6),
                              const Color(0xff02d39a),
                            ],
                            stops: const [0.1, 0.9],
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0x6623b6e6),
                                const Color(0x6602d39a),
                              ],
                              stops: const [0.1, 0.9],
                            ),
                          ),
                        ),
                      ],
                    ),
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
