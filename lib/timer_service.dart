import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TimerService {
  DateTime? _orderStartTime; // Order start time
  Timer? _timer; // The timer for periodic updates
  int _elapsedTimeInSeconds = 0; // Track elapsed time in seconds

  TimerService();

  // Initialize the order start time
  Future<void> initializeOrderTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedOrderTime = prefs.getString('order_start_time');

    if (storedOrderTime != null) {
      _orderStartTime = DateTime.parse(storedOrderTime);
      _elapsedTimeInSeconds = DateTime.now().difference(_orderStartTime!).inSeconds;
    } else {
      _elapsedTimeInSeconds = 0;
    }
  }

  // Save the order start time
  Future<void> saveOrderStartTime() async {
    _orderStartTime = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('order_start_time', _orderStartTime!.toIso8601String());
  }

  // Calculate elapsed time as string (hh:mm:ss)
  String getElapsedTime() {
    if (_orderStartTime == null) return "00:00:00";

    // Calculate elapsed time in seconds
    _elapsedTimeInSeconds = DateTime.now().difference(_orderStartTime!).inSeconds;

    // Convert seconds to hours, minutes, and seconds
    int hours = _elapsedTimeInSeconds ~/ 3600;
    int minutes = (_elapsedTimeInSeconds % 3600) ~/ 60;
    int seconds = _elapsedTimeInSeconds % 60;

    // Return formatted time string
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Stop the timer if needed
  void stopTimer() {
    _timer?.cancel();
  }

  // Start the periodic update for the timer
  void startPeriodicUpdate(Function onTick) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      onTick();
    });
  }
}
