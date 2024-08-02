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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: _shouldUpdateChart ? _lightLevelData : [],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        Slider(
          value: _currentLightLevel,
          min: 0,
          max: 100,
          onChanged: (newValue) {
            _adjustScreenBrightness(newValue);
          },
        ),
        SizedBox(height: 20),
        Text('Light Level: $_currentLightLevel lx'),
      ],
    );
  }
}
