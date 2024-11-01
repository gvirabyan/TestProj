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
    if (_token.isEmpty) {
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

      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];

        List<HistoryItem> historyItems = data.map<HistoryItem>((item) {
          return HistoryItem(
            orderStatus: item['order_status'],
            amount: item['amount'],
            requestTime: item['request_time'],
            operationTime: item['operation_time'] ?? '',
          );
        }).toList();

        return historyItems;
      } else {
        print('Orders get fail: ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error occurred: $error');
      return [];
    }
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
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Start Date: ${item.requestTime}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Date: ${item.operationTime}'),
                      Text('Price: \$${item.amount}'),
                      Text('Status: ${item.orderStatus}'),
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
