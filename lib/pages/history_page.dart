import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../history_item.dart';

class HistoryPage extends StatelessWidget {
  String _token = "";

  Future<void> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storageToken = prefs.getString('token');
    _token = storageToken!;
  }

  Future<List<HistoryItem>> _getAllOrders() async {
    await _getToken();
    if (_token == null) {
      print('Token is null. Cannot get orders.');
      return [];
    }

    final url = Uri.parse('http://192.168.27.48:7000/api/driver/order');

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      print(response.body);

      Map<String, dynamic> decodedResponse = json.decode(response as String);
      String jsonData = decodedResponse['request_time'];
      String time = decodedResponse['data'][0]['id'];
      print(time+"-*---------");

      print("---------------"+jsonData+"----------------");
      if (response.statusCode == 200) {
      } else {
        print('Orders get fail: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {}

    return [
      HistoryItem(
        startDate: '2024-10-01',
        endDate: '2024-10-05',
        price: 99.99,
        status: 'Completed',
      )
    ];
  }

  Future<List<HistoryItem>> _loadHistoryItems() async {
    return [
      HistoryItem(
        startDate: '2024-10-01',
        endDate: '2024-10-05',
        price: 99.99,
        status: 'Completed',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryItem>>(
      future: _getAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final historyItems = snapshot.data!;
          return ListView.builder(
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Start Date: ${item.startDate}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Date: ${item.endDate}'),
                      Text('Price: \$${item.price.toStringAsFixed(2)}'),
                      Text('Status: ${item.status}'),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
