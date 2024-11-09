// lib/models/printed_article.dart
import 'bill.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintedArticle {
  final Bill bill;
  final double totalHT;        // Total before tax
  final double totalTVA;       // Total tax amount
  final double totalTTC;       // Total including tax
  final double remainingBalance;
  final int lineCount;
  final int pieceCount;

  PrintedArticle({
    required this.bill,
    required this.totalHT,
    required this.totalTVA,
    required this.totalTTC,
    required this.remainingBalance,
    required this.lineCount,
    required this.pieceCount,
  });

  static Future<double> _getTaxRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('taxRate') ?? 0.15; // Default to 15%
  }

  static Future<PrintedArticle> fromBill(Bill bill) async {
    double totalHT = 0;
    int lineCount = bill.items.length;
    int pieceCount = bill.items.fold(0, (sum, item) => sum + item.quantity);

    for (var item in bill.items) {
      totalHT += item.total;
    }

    final taxRate = await _getTaxRate();
    double totalTVA = totalHT * taxRate;
    double totalTTC = totalHT + totalTVA;
    double remainingBalance = totalTTC; // Placeholder, calculate as needed

    return PrintedArticle(
      bill: bill,
      totalHT: totalHT,
      totalTVA: totalTVA,
      totalTTC: totalTTC,
      remainingBalance: remainingBalance,
      lineCount: lineCount,
      pieceCount: pieceCount,
    );
  }
}
