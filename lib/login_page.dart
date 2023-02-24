import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Deklarasikan dua objek TextEditingController untuk mengelola inputan
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Buat AppBar dengan judul
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Atur tata letak vertical menjadi tengah layar
          mainAxisAlignment: MainAxisAlignment.center,
          // Atur tata letak horizontal menjadi penuh layar
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Buat TextField untuk input email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            // Buat TextField untuk input password
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            // Buat tombol untuk mengirimkan form login
            ElevatedButton(
              onPressed: () {
                // TODO: Implementasi fungsi login
                // Navigasi ke halaman pedometer ketika tombol ditekan
                Navigator.pushReplacementNamed(context, '/pedometer');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
