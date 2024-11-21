class HistoryItem {
  final String orderStatus;
  final String? amount;
  final String requestTime;
  final String? operationTime;

  HistoryItem({
    required this.orderStatus,
    this.amount,
    required this.requestTime,
    this.operationTime,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      orderStatus: json['order_status'],
      amount: json['amount'],
      requestTime: json['request_time'],
      operationTime: json['operation_time'],
    );
  }

  @override
  String toString() {
    return 'HistoryItem{orderStatus: $orderStatus, amount: $amount, requestTime: $requestTime, operationTime: $operationTime}';
  }
}
