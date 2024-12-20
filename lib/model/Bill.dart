import 'package:Rappido/model/Client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bill {
  final String id;
  final Client client;
   final String date;
  final String vendor;
  final String description;
  final List<BillItem> items;

  // Totals and counts
  final double totalHT; // Total excluding tax
  final double totalTVA; // Total tax
  final double totalTTC; // Total including tax
  final double remainingBalance; // Placeholder for future updates
  final int lineCount; // Number of unique items
  final int pieceCount; // Total quantity of all items

  Bill({
    required this.id,
    required this.client,
     required this.date,
    required this.vendor,
    required this.items,
    required this.totalHT,
    required this.totalTVA,
    required this.totalTTC,
    required this.remainingBalance,
    required this.lineCount,
    required this.pieceCount,
    required this.description,
  });

  /// Factory constructor to create a `Bill` object from a list of `BillItem`s.
  /// Automatically calculates totals, line count, and piece count.
  factory Bill.fromItems({
    required String id,
    required Client client,
     required String date,
    required String vendor,
    required String description,
    required List<BillItem> items,
    double? taxRate,
  }) {
    // Calculate totals
    double totalHT = items.fold(0.0, (sum, item) => sum + item.total);
    int lineCount = items.length;
    int pieceCount = items.fold(0, (sum, item) => sum + item.quantity);

    // Use the provided tax rate or fetch it from SharedPreferences
    double effectiveTaxRate = taxRate ?? 0.15; // Default to 15%
    double totalTVA = totalHT * effectiveTaxRate;
    double totalTTC = totalHT + totalTVA;

    // Placeholder for remaining balance, can be updated based on payments
    double remainingBalance = totalTTC;

    return Bill(
      id: id,
      client: client,
       date: date,
      vendor: vendor,
      items: items,
      totalHT: totalHT,
      totalTVA: totalTVA,
      totalTTC: totalTTC,
      remainingBalance: remainingBalance,
      lineCount: lineCount,
      pieceCount: pieceCount,
      description: description,
    );
  }


  /// Static method to fetch the tax rate from `SharedPreferences`.
  /// Returns a default tax rate of 15% if not set.
  static Future<double> fetchTaxRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('taxRate') ?? 0.15;
  }

  /// Factory async constructor to dynamically fetch and use the tax rate
  /// stored in `SharedPreferences`.
  static Future<Bill> createWithDynamicTaxRate({
    required String id,
    required Client client,
    required String clientName,
    required String date,
    required String description,
    required String vendor,
    required List<BillItem> items,
  }) async {
    double taxRate = await fetchTaxRate();
    return Bill.fromItems(
      id: id,
      client: client,
       date: date,
      vendor: vendor,
      items: items,
      taxRate: taxRate,
      description: description,
    );
  }
}

class BillItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double remise; // Discount per unit
  final String barcode;

  BillItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.remise,
    required this.barcode,
  });

  /// Calculate the total price for this item, considering the discount (`remise`).
  double get total => quantity * (unitPrice - remise);
}
