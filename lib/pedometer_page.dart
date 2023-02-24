import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';

class PedometerPage extends StatefulWidget {
  @override
  _PedometerPageState createState() => _PedometerPageState();
}

class _PedometerPageState extends State<PedometerPage> {
  // Deklarasikan variabel untuk menyimpan jumlah langkah yang diambil
  int _stepsCount = 0;

  @override
  void initState() {
    super.initState();
    // Dengarkan perubahan accelerometer dan perbarui jumlah langkah ketika langkah terdeteksi
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        if (event.y > 11.0) {
          _stepsCount++;
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
        appBar: AppBar(
          title: Text('Pedometer'),
        ),
        // Tampilkan jumlah langkah di tengah layar
        body: Center(
          child: Text('Steps taken: $_stepsCount'),
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
}
