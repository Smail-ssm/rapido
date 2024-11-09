// lib/models/bill.dart
class Bill {
  final String clientId;
  final String clientName;
  final String date;
  final String vendor;
  final List<BillItem> items;

  Bill({
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.vendor,
    required this.items,
  });
}

class BillItem {
  final String name;
  final int quantity;
  final double unitPrice;

  BillItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}
