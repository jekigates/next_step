import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'login_page.dart';
import 'pedometer_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedometer',
      // Set halaman login sebagai halaman awal
      initialRoute: '/',
      routes: {
        // Map route '/' ke widget LoginPage
        '/': (context) => LoginPage(),
        // Map route '/pedometer' ke widget PedometerPage
        '/pedometer': (context) => PedometerPage(),
      },
    );
  }
}
