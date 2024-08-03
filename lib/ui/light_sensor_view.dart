import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_smart/sensors/light_sensor_manager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:fl_chart/fl_chart.dart';

class LightSensorView extends StatefulWidget {
  const LightSensorView({Key? key}) : super(key: key);

  @override
  _LightSensorViewState createState() => _LightSensorViewState();
}

class _LightSensorViewState extends State<LightSensorView> {
  final LightSensorManager _lightSensorManager = LightSensorManager();
  double _currentLightLevel = 0.0;
  final ScreenBrightness _screenBrightness = ScreenBrightness();
  final List<FlSpot> _lightLevelData = [];
  bool _shouldUpdateChart = false;

  @override
  void initState() {
    super.initState();
    _initSensor();
  }

  @override
  void dispose() {
    _lightSensorManager.dispose();
    super.dispose();
  }

  Future<void> _initSensor() async {
    try {
      _lightSensorManager.lightLevelStream.listen((lightLevel) {
        setState(() {
          _currentLightLevel = lightLevel;
          _lightLevelData
              .add(FlSpot(_lightLevelData.length.toDouble(), lightLevel));
          _shouldUpdateChart = true;
        });
        _adjustScreenBrightness(lightLevel);
      });
    } on PlatformException catch (e) {
      print("Failed to initialize ambient light sensor: '${e.message}'.");
    }
  }

  void _adjustScreenBrightness(double lightLevel) {
    try {
      _screenBrightness.setScreenBrightness(
        lightLevel / 100, // Scale light level to 0-1 range
      );
    } on PlatformException catch (e) {
      print("Failed to set screen brightness: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Sensor View'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
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
                  maxX: _lightLevelData.isEmpty
                      ? 0
                      : _lightLevelData.length.toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _shouldUpdateChart ? _lightLevelData : [],
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
            const SizedBox(height: 20),
            Slider(
              value: _currentLightLevel,
              min: 0,
              max: 100,
              divisions: 100,
              label: _currentLightLevel.round().toString(),
              onChanged: (newValue) {
                setState(() {
                  _currentLightLevel = newValue;
                  _adjustScreenBrightness(newValue);
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Light Level: $_currentLightLevel lx',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
