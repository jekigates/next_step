import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedometerPage extends StatefulWidget {
  @override
  _PedometerPageState createState() => _PedometerPageState();
}

class _PedometerPageState extends State<PedometerPage> {
  // Deklarasikan variabel untuk menyimpan jumlah langkah yang diambil
  int _stepsCount = 0;
  User? _user;

  // Inisialisasi plugin notifikasi
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Deklarasikan variabel untuk ukuran lingkaran
  double _circleSize = 200.0;

  @override
  void initState() {
    super.initState();
    _validateUser();

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
          _updateUserStepCount();
        }
      });
    });
  }

  void _validateUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _user = user;
          _stepsCount = userData.get('step');
        });
        print('Name: ${userData.get('name')}');
        print('Email: ${_user!.email}');
        print('Step: ${userData.get('step')}');
        print('Total Step: ${userData.get('totalStep')}');
      }
    } else {
      Future.delayed(Duration.zero, () {
        _showAlert();
      });
    }
  }

  void _updateUserStepCount() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'step': _stepsCount});
    }
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('Please log in to access this page.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        // Buat AppBar dengan judul
        appBar: null,
        // Tampilkan jumlah langkah di tengah layar
        body: _user != null
            ? Center(
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
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Tampilkan dialog konfirmasi logout
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Logout'),
                              content: Text('Are you sure you want to logout?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Logout'),
                                  onPressed: () async {
                                    // Logout dari firebase
                                    await FirebaseAuth.instance.signOut();
                                    // Redirect ke halaman login
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/');
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Logout'),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
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
