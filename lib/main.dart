import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'pedometer_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

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
        '/register': (context) => RegisterPage(),
        // Map route '/pedometer' ke widget PedometerPage
        '/pedometer': (context) => PedometerPage(),
      },
    );
  }
}
