import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});



  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storageToken = prefs.getString('token');
    return storageToken;
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

  Future<void> logOut(String? token) async {
    if (token == null || token.isEmpty) {
      print('No token provided for logout');
      return; // Exit early if no token
    }

    final url = Uri.parse('http://192.168.27.48:7000/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 204) {
        print("logout succes");
      } else {
        print('Logout failed: ${response.body}');
      }

      print(token + "--------------LOGUOT------------");
    } catch (error) {
      print('Error occurred: $error');
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
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
            buildUserInfo('Full Name:', 'AA aa'),
            buildUserInfo('Phone Number:', '+37494182880'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                String? token = await _getToken(); // Await the token
                await logOut(token); // Pass the token
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
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

