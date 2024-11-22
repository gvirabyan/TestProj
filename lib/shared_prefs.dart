import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<String?> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> orderIsProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('order');
  }

  static Future<void> saveOrderDetails(String details) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('order', details);
  }

  static Future<void> deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<void> deleteCurrentOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('order');
  }
}
