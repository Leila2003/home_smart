import 'package:flutter/material.dart';
import 'package:home_smart/ui/geofence_selection_screen.dart';
import 'package:home_smart/ui/location_sensor_view.dart';
import 'light_sensor_view.dart';
import 'motion_sensor_view.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Smart Home App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/images/icon.png',
                height: 150,
                width: 150,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LightSensorView()),
                );
              },
              child: const Text('Smart Light Detector'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MotionSensorView()),
                );
              },
              child: const Text('Smart Motion Detector'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for LocationView
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationSensorView()),
                );
              },
              child: const Text('My location'),
            ),
          ],
        ),
      ),
    );
  }
}
