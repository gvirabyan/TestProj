import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      home: FutureBuilder<bool>(
        future: _checkToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if token exists and navigate accordingly
          if (snapshot.hasData && snapshot.data == true) {
            return HomePage(); // If token exists, go to HomePage
          } else {
            return const LoginPage(); // If token does not exist, go to LoginPage
          }
        },
      ),
    );
  }

  // Method to check if token exists in Shared Preferences
  Future<bool> _checkToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null; // Return true if token exists
  }
}
