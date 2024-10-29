import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  SharedPreferences? prefs;

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _sendLoginData(String email, String password) async {
    final url = Uri.parse('http://192.168.27.48:7000/login');

    final Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
      'type': '1',
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode(requestBody), // Convert to JSON string
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      var decodeJson = jsonDecode(response.body);

      // Check if access_token exists in the response
      if (decodeJson.containsKey('access_token')) {
        String accessToken = decodeJson['access_token'];
        await _saveToken(accessToken);
        print(accessToken + "-------LOGIN----------"); // Save token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('Login failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToken(String token) async {
    await prefs?.setString('token', token); // Use the initialized prefs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        // Disable button while loading
                        String email = _loginController.text;
                        String password = _passwordController.text;
                        _sendLoginData(email, password);
                      },
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              if (_isLoading) CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
