import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String phoneNumber = '';
  String companyName = '';
  String name = '';
  String username = '';
  String driverLicenseNumber = '';
  String registrationDate = '';
  String car = '';

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logOut(String? token) async {
    if (token == null || token.isEmpty) {
      print('No token provided for logout');
      return;
    }

    final url = Uri.parse('http://192.168.27.48:8000/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 204) {
        print("Logout successful");
      } else {
        print('Logout failed: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> getUserInfo() async {

    String? token = await _getToken();
    if (token == null || token.isEmpty) {
      print('No token provided for fetching user info');
      return;
    }

    final url = Uri.parse('http://192.168.27.48:8000/api/general/user_info');

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          name = data['data']['name'] ?? 'Unknown';
          username = data['data']['username'] ?? 'Unknown';
          driverLicenseNumber =
              data['data']['driver_license_number'] ?? 'Unknown';
          phoneNumber = data['data']['phone_number'] ?? 'Unknown';
          registrationDate = data['data']['registered_at'] ?? 'Unknown';
          car = data['data']['car']['model'] ?? 'Unknown';
          companyName = data['data']['company_name'] ?? 'Unknown';
          phoneNumber = data['data']['phone_number'] ?? 'Unknown';
        });
      } else {
        print('Failed to fetch user info: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Widget buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
            const Text(
              'User Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            buildUserInfo('Phone Number:', phoneNumber),
            buildUserInfo('Company Name', companyName),
            buildUserInfo(' Name', name),
            buildUserInfo('Username', username),
            buildUserInfo('Driver license number ', driverLicenseNumber),
            buildUserInfo('Registration Date', registrationDate),
            buildUserInfo('Car', car),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                String? token = await _getToken(); // Await the token
                await logOut(token); // Pass the token
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
