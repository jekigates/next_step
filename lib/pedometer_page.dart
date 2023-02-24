import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PedometerPage extends StatefulWidget {
  @override
  _PedometerPageState createState() => _PedometerPageState();
}

class _PedometerPageState extends State<PedometerPage> {
  // Deklarasikan variabel untuk menyimpan jumlah langkah yang diambil
  int _stepsCount = 0;

  // Inisialisasi plugin notifikasi
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Deklarasikan variabel untuk ukuran lingkaran
  double _circleSize = 200.0;

  @override
  void initState() {
    super.initState();

    // Konfigurasi plugin notifikasi
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Dengarkan perubahan accelerometer dan perbarui jumlah langkah ketika langkah terdeteksi
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        if (event.y > 11.0) {
          _stepsCount++;
          // Check if the number of steps is a multiple of 100
          if (_stepsCount % 100 == 0) {
            _sendNotification();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        // Buat AppBar dengan judul
        appBar: null,
        // Tampilkan jumlah langkah di tengah layar
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: _circleSize,
                height: _circleSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_stepsCount',
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          'STEP',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Panggil method untuk mengirim notifikasi di sini
                  _sendNotification();
                },
                child: Text('Test Notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure to close this app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  // Keluar dari aplikasi ketika tombol OK ditekan
                  SystemNavigator.pop();
                },
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Method untuk mengirim notifikasi
  Future<void> _sendNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Hey!',
        'Don’t forget to drink during your walking exercise.',
        platformChannelSpecifics,
        payload: 'Default_Sound');
  }
}
