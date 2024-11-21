import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:DriveTax/model/user_info_model.dart';
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
  List<UserInfoModel> _userInfoModel = [];
  bool _isLoading = true; // To show loading indicator while fetching data

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
    final String logoutApi =
        dotenv.env['LOGOUT_URL'] ?? 'https://default-login-url.com';

    try {
      final response = await http.post(
        Uri.parse(logoutApi),
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

    final String userInfo = dotenv.env['GET_USER_INFO'] ?? 'https://default-login-url.com';


    try {
      final response = await http.get(
        Uri.parse(userInfo),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _userInfoModel = [
            UserInfoModel(
              name: data['data']['name'],
              username: data['data']['username'],
              phoneNumber: data['data']['phone_number'],
              companyName: data['data']['company_name'],
              car: data['data']['car']['model'],
              registrationDate: data['data']['registered_at'],
              driverLicenseNumber: data['data']['driver_license_number'],
            )
          ];
          _isLoading = false; // Set loading to false after data is fetched
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
            // Show loading indicator while data is being fetched
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_userInfoModel.isNotEmpty)
              Column(
                children: [
                  buildUserInfo('Phone Number:', _userInfoModel[0].phoneNumber),
                  buildUserInfo('Company Name', _userInfoModel[0].companyName),
                  buildUserInfo(' Name', _userInfoModel[0].name),
                  buildUserInfo('Username', _userInfoModel[0].username),
                  buildUserInfo('Driver license number ',
                      _userInfoModel[0].driverLicenseNumber),
                  buildUserInfo(
                      'Registration Date', _userInfoModel[0].registrationDate),
                  buildUserInfo('Car', _userInfoModel[0].car),
                ],
              )
            else
              const Text('No user info available'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                String? token = await _getToken();
                await logOut(token);
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
