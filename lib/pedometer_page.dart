import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PedometerPage extends StatefulWidget {
  @override
  _PedometerPageState createState() => _PedometerPageState();
}

class _PedometerPageState extends State<PedometerPage> {
  // Deklarasikan variabel untuk menyimpan jumlah langkah yang diambil
  int _totalStepsCount = 0;
  int _stepsCount = 0; // used to load user's step in firebase too
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
          _totalStepsCount++;
          _updateUserStepCount();

          // Check if the number of steps is a multiple of 100
          if (_stepsCount % 100 == 0) {
            _sendNotification();
          }
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
        final currentDate =
            DateTime.now().toLocal().toString().substring(0, 10);
        final firebaseDate = userData.get('currentDate');
        if (firebaseDate != currentDate) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'step': 0,
            'currentDate': currentDate,
          });
          setState(() {
            _stepsCount = 0;
          });
        } else {
          setState(() {
            _stepsCount = userData.get('step');
          });
        }
        setState(() {
          _user = user;
          _totalStepsCount = userData.get('totalStep');
        });
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
      // Get the user's data from Firebase
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        final currentDate =
            DateTime.now().toLocal().toString().substring(0, 10);
        final firebaseDate = userData.get('currentDate');

        // Check if the dates are different
        if (firebaseDate != currentDate) {
          // Reset the step count
          _stepsCount = 0;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'step': 0,
            'currentDate': currentDate,
          });
          // Show a notification
          Fluttertoast.showToast(
            msg: 'Your step count has been reset to 0 because day changed',
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
          );
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'step': _stepsCount, 'totalStep': _totalStepsCount});
        }
      }
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Image.asset(
                      'assets/images/logo.png', // replace with your image path
                      width: 80, // adjust the size as needed
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 360,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: 0.5,
                              child: Text(
                                'STEP',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                            Text(
                              '$_stepsCount',
                              style:
                                  TextStyle(fontSize: 50, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Color(0xFFF0BE15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/fire.svg',
                                  color: Color(0xFFF0BE15),
                                  height: 15,
                                  width: 15,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '${(_stepsCount / 1300 * 60).toStringAsFixed(0)}cal',
                                  style: TextStyle(color: Color(0xFFF0BE15)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                            ),
                            onPressed: () {
                              // Tampilkan dialog konfirmasi logout
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Logout'),
                                    content: Text(
                                        'Are you sure you want to logout?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Opacity(
                                          opacity: 0.5,
                                          child: Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Logout',
                                          style: TextStyle(color: Colors.black),
                                        ),
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
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/walking.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Walking',
                              style:
                                  TextStyle(fontSize: 32, color: Colors.white),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Walking is a great way to improve or maintain your overall health. Just 30 minutes every day can increase cardiovascular fitness, strengthen bones, reduce excess body fat, and boost muscle power and endurance. It can also reduce your risk of developing conditions such as heart disease, type 2 diabetes, osteoporosis and some cancers. Unlike some other forms of exercise, walking is free and doesn’t require any special equipment or training. ',
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xFFC2C2C2)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Copyright © 2023 by Jeki Gates',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Text('Total Step All Time: ${_totalStepsCount}')
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
