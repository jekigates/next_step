import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  bool _obscureText = true;

  Future<void> register() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your password'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password should be at least 8 characters long.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        final now = DateTime.now();
        final date = "${now.year}-${now.month}-${now.day}";

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'step': 0,
          'totalStep': 0,
          'currentDate': date,
        });
        Navigator.pop(context);
        Navigator.pushNamed(context, '/pedometer');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The password provided is too weak.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The account already exists for that email.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png', // replace with your image path
                    width: 120, // adjust the size as needed
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Walk for health.",
                    style: TextStyle(
                      color: Color(0xff6a6a6a),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Name input with label and rounded corners
                  SizedBox(
                    height: 20,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Your email address",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: nameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        hintText: 'Example Name',
                        hintStyle: TextStyle(color: Color(0xFF6B6B6B)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Email input with label and rounded corners
                  SizedBox(
                    height: 20,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Your email address",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        hintText: 'example@gmail.com',
                        hintStyle: TextStyle(color: Color(0xFF6B6B6B)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password input with label and rounded corners
                  SizedBox(
                    height: 20,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Your password",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        hintText: '********',
                        hintStyle: TextStyle(color: Color(0xFF6B6B6B)),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Login button with rounded corners
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      color: Colors.black,
                    ),
                    child: TextButton(
                      onPressed: () {
                        register();
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Text link to register page
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/');
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
