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
  final _formKey = GlobalKey<FormState>();

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

    if (_formKey.currentState?.validate() ?? false) {

      print('Login successful');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful')));
    } else {
      print('Login failed');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed')));
    }

    if(email=='' || password == ''){
      return;
    }
    final url = Uri.parse('http://192.168.27.48:8000/login');

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
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      var decodeJson = jsonDecode(response.body);

      if (decodeJson.containsKey('access_token')) {
        String accessToken = decodeJson['access_token'];
        await _saveToken(accessToken);
        print(accessToken + "-------LOGIN----------");
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
    await prefs?.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
                validator:  (value) {
                      if (value == ''  ) {
                      return 'Please enter an email';
                      }
                      return null;
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
                validator:  (value) {
                  if (value == ''  ) {
                    return 'Please enter an password';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        String email = _loginController.text;
                        String password = _passwordController.text;
                        _sendLoginData(email, password);
                      },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
