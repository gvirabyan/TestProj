// preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  static SharedPreferences? _prefs;

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get token => _prefs?.getString('token');

  Future<void> saveToken(String token) async {
    await _prefs?.setString('token', token);
  }

// Add more methods as needed for other preferences
}
