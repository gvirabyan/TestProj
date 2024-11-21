import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../model/history_item.dart';

class HistoryPage extends StatefulWidget {

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  String _token = "";
  int _lastPage = 1;
  int _page = 1;
  ScrollController _scrollController = ScrollController();
  List<HistoryItem> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _getAllOrders();
  }

  Uri getAllOrdersUrl() {
    String baseUrl = dotenv.env['GET_ALL_ORDERS_URL'] ?? 'http://default-url.com/api/driver/order';
    return Uri.parse(baseUrl + _lastPage.toString());
  }
  Future<void> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storageToken = prefs.getString('token');
    _token = storageToken ?? '';
  }

  Future<void> _getAllOrders() async {
    await _getToken();
    if (_token.isEmpty) {
      print('Token is null. Cannot get orders.');
      return;
    }

    try {
      final response = await http.get(
        getAllOrdersUrl(),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];
        var decodeJson = jsonResponse['meta']['last_page'];
        _lastPage = decodeJson;

        setState(() {
          _historyItems.addAll(data.map<HistoryItem>((item) {
            return HistoryItem(
              orderStatus: item['order_status'],
              amount: item['amount'].toString(),
              requestTime: item['request_time'],
              operationTime: item['operation_time'] ?? '',
            );
          }).toList());
        });
      } else {
        print('Orders get fail: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_lastPage > _page) {
        _page++;
        _getAllOrders();
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
    final size = MediaQuery.of(context).size;

    return Scaffold(

      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _historyItems.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          controller: _scrollController,
          itemCount: _historyItems.length,
          itemBuilder: (context, index) {
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
      ),
    );
  }
}
