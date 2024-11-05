import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled3/pages/settings_page.dart';
import 'history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  String _orderDetails = '';
  String _amount = '';

  final List<Widget> _pages = [
    PageContent(title: 'Welcome to the Home Page!'),
    HistoryPage(),
    SettingsPage(),
  ];
  String _token = "";

  Future<void> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storageToken = prefs.getString('token');
    _token = storageToken!;
    _isInProgress();
  }

  @override
  void initState() {
    super.initState();
    _getToken();
    _loadOrderDetails();
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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orderDetails = prefs.getString('order') ?? '';
    });
  }

  Future<void> _isInProgress() async {
    if (_token == null) {
      print('Token is null. Cannot add order.');
      return;
    }

    final url = Uri.parse('http://192.168.27.48:7000/api/driver/active_order');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        _orderDetails = "16:30";
      } else {
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
    if (_token == null) {
      print('Token is null. Cannot add order.');
      return;
    }

    final url = Uri.parse('http://192.168.27.48:7000/api/driver/order');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        _orderDetails = "15:30";
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
  }

  Future<void> _completeOrder() async {
    print('Order completed with amount: $_amount');

    if (_token == null) {
      print('Token is null. Cannot add order.');
      return;
    }

    final url =
        Uri.parse('http://192.168.27.48:7000/api/driver/order_complete');

    setState(() {
      _isLoading = true;
    });
    final Map<String, dynamic> requestBody = {
      'income_type': 'CASHLESS',
      'service_amount': _amount,
      'income_source': 'FROM_INDIVIDUAL',
      'service_quantity': '1'
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: (requestBody), // Convert to JSON string
      );
      print(response.statusCode);
      print(response.body);
      print(_token);
      if (response.statusCode == 201) {
        _orderDetails = "15:30";
        print(response.body);
      } else {
        print('Complete faild: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    setState(() {
      _orderDetails = '';
      _amount = '';
    });
    _saveOrderDetails('');
  }

  Future<void> _cancelOrder() async {
    print('Order cancelled');
    if (_token == null) {
      print('Token is null. Cannot add order.');
      return;
    }

    final url = Uri.parse(
        'http://192.168.27.48:7000/api/driver/order_cancel?_method=PUT');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      print(response.statusCode);
      print(_token);
      if (response.statusCode == 201) {
        _orderDetails = "15:30";
        print(response.body);
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

    setState(() {
      _orderDetails = '';
      _amount = '';
    });
    _saveOrderDetails('');
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : _selectedIndex == 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _pages[_selectedIndex],
                              SizedBox(height: 20),
                              _orderDetails.isNotEmpty
                                  ? Column(
                                      children: [
                                        Text(
                                          _orderDetails,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(height: 20),
                                        TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Amount',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _amount = value;
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
