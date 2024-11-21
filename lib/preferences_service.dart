import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'model/history_item.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _token = "";
  int _page = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();
  List<HistoryItem> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _getToken(); // Fetch the token and load initial data
  }

  Future<void> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storageToken = prefs.getString('token');
    if (storageToken != null) {
      setState(() {
        _token = storageToken;
      });
      _loadData(); // Load initial data once the token is fetched
    }
  }

  Future<void> _loadData() async {
    if (_token.isEmpty || _isLoading || _page > _lastPage) return;

    setState(() {
      _isLoading = true;
    });

    final url =
    Uri.parse('http://192.168.27.48:7000/api/driver/order?page=$_page');

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];
        _lastPage = jsonResponse['meta']['last_page'];

        List<HistoryItem> historyItems = data.map<HistoryItem>((item) {
          return HistoryItem(
            orderStatus: item['order_status'],
            amount: item['amount'].toString(),
            requestTime: item['request_time'],
            operationTime: item['operation_time'] ?? '',
          );
        }).toList();

        setState(() {
          _historyItems.addAll(historyItems); // Add the new items to the list
          _page++; // Increment the page number for next fetch
        });
      } else {
        print('Failed to load orders: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Scroll listener to detect when the user reaches the bottom
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_page <= _lastPage && !_isLoading) {
        _loadData(); // Load more data when scrolled to the bottom
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        controller: _scrollController,
        itemCount: _historyItems.length + (_isLoading ? 1 : 0),
        // Add one more for loading spinner
        itemBuilder: (context, index) {
          if (index == _historyItems.length) {
            return Center(child: CircularProgressIndicator());
          }

          final item = _historyItems[index];
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
      ),
    );
  }
}
