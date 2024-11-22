import 'dart:async';
import 'dart:convert';

import 'package:DriveTax/pages/settings_page.dart';
import 'package:DriveTax/timer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../shared_prefs.dart';
import 'history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  int _selectedIndex = 0;
  bool _isLoading = false;
  bool _current_order = false;
  String _amount = '';
  String _income_type = 'CASHLESS';
  String _income_source = 'FROM_INDIVIDUAL';
  final List<String> _income_type_options = ['CASHLESS', '2'];
  final List<String> __income_source_options = [
    'FROM_INDIVIDUAL',
    'FROM_LEGAL_ENTITY'
  ];

  String timer = "00:00:00";
  TimerService _timerManager = TimerService();

  final List<Widget> _pages = [
    const PageContent(title: ''),
    HistoryPage(),
    const SettingsPage(),
  ];
  String _token = '';

  @override
  void initState() {
    super.initState();

    _getToken();
    _loadOrderDetails();
    _timerManager.initializeOrderTime();
    _startTimer();
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storageToken = prefs.getString('token');
    _token = storageToken!;
    if (_token != '') {
      _isInProgress();
    }
  }

  void _startTimer() {
    // timer = _timer.
  }

  void _onItemTapped(int index) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _selectedIndex = index;
      _isLoading = false;
    });
  }

  Future<void> _loadOrderDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('order') != "" || prefs.getString('order') != null) {
      _current_order = true;
    }
  }

  Future<void> _isInProgress() async {
    if (_token == '') {
      print('Token is null. Cannot add order.');
      return;
    }
    String url =
        dotenv.env['ACTIVE_ORDER_URL'] ?? 'https://default-login-url.com';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        _current_order = true;
      } else {
        _current_order = false;
        print('Current order not exists: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOrderDetails(String details) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('order', details);
  }

  Future<void> _addNewOrder() async {
    if (_token == '') {
      print('Token is null. Cannot add order.');
      return;
    }
    String newOrderUrl =
        dotenv.env['NEW_ORDER_URL'] ?? 'https://default-login-url.com';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(newOrderUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        await _timerManager.saveOrderStartTime();
        setState(() {});
        _current_order = true;
      } else {
        print('Order creation failed: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    _saveOrderDetails(DateTime.now().toUtc().toString().substring(11, 19));
  }

  Future<void> _completeOrder() async {
    if (_token == '') {
      print('Token is null. Cannot complete order.');
      return;
    }

    final String completeOrderUrl =
        dotenv.env['COMPLETE_ORDER_URL'] ?? 'https://default-login-url.com';

    setState(() {
      _isLoading = true;
    });

    // Validate fields before making the request
    if (_income_type.isEmpty || _amount.isEmpty || _income_source.isEmpty) {
      print('Please fill in all required fields.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final double amount = double.tryParse(_amount) ?? 0.0;

    Map<String, dynamic> requestBody = {
      'income_type': _income_type,
      'service_amount': amount.toString(),
      'income_source': _income_source,
      'service_quantity': '1',
    };

    if (_income_source == 'FROM_LEGAL_ENTITY') {
      requestBody['partner_id'] = '1';
    }

    print('Request Body: $requestBody');
    try {
      final response = await http.post(
        Uri.parse(completeOrderUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: json.encode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _current_order = false;
          _amount = '';
        });
        print('Order completed successfully.');
      } else {
        print('Order failed: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    _saveOrderDetails('');
  }



  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _selectedIndex == 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _pages[_selectedIndex],
                              SizedBox(height: 20),
                              _current_order
                                  ? Column(
                                      children: [
                                        Text(
                                          timer,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          onChanged: (value) {
                                            _amount = value;
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Amount',
                                            hintText: 'Enter  amount',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        DropdownButton<String>(
                                          value: _income_type,
                                          hint: Text('CASHLESS'),
                                          items: _income_type_options
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              _income_type = newValue!;
                                            });
                                          },
                                        ),
                                        DropdownButton<String>(
                                          value: _income_source,
                                          hint: Text('FROM_INDIVIDUAL'),
                                          items: __income_source_options
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              _income_source = newValue!;
                                            });
                                          },
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: _completeOrder,
                                              child: Text('Complete Order'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: _cancelOrder,
                                              child: Text('Cancel Order'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : ElevatedButton(
                                      onPressed: _addNewOrder,
                                      child: Text('Add Order'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                            ],
                          )
                        : _pages[_selectedIndex],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildButton('Home', 0),
                _buildButton('History', 1),
                _buildButton('Settings', 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelOrder() async {
    if (_token == '') {
      print('Token is null. Cannot add order.');
      return;
    }
    final String cancleOrderUrl =
        dotenv.env['CANCLE_ORDER_URL'] ?? 'https://default-login-url.com';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(cancleOrderUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      print(response.statusCode);
      print(_token);
      if (response.statusCode == 201) {
        // _orderDetails = "15:30";
        SharedPrefs.deleteCurrentOrder();
        print(response.body);
      } else {
        print('Order cancel failed: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    setState(() {
      _current_order = false;
      _amount = '';
    });
    _saveOrderDetails('');
  }

  Widget _buildButton(String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.black : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class PageContent extends StatelessWidget {
  final String title;

  const PageContent({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 24),
      textAlign: TextAlign.center,
    );
  }
}
