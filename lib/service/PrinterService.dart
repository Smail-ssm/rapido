// lib/utils/printer_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../model/PrintedArticle.dart';

class PrinterService {
  final PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  // Start scanning for available Bluetooth printers
  Future<void> startScan() async {
    printerManager.startScan(const Duration(seconds: 4));
  }

  // Print the bill: Generates PDF, prints to console, and sends to Bluetooth printer
  Future<void> printBill(BuildContext context, PrintedArticle printedArticle) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Add receipt header
    bytes += generator.text('RECEIPT', styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.text('Numero: ${printedArticle.bill.clientId}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Date: ${printedArticle.bill.date}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Vendeur: ${printedArticle.bill.vendor}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr(); // Horizontal line

    // Add client information
    bytes += generator.text('Client:', styles: const PosStyles(align: PosAlign.left, bold: true));
    bytes += generator.text('Raison Sociale: ${printedArticle.bill.clientName}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr();

    // Table header for products
    bytes += generator.row([
      PosColumn(text: 'QTE', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(text: 'DESIGNATION', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: 'P.U', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(text: 'TOTAL', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();

    // Product details
    for (var item in printedArticle.bill.items) {
      bytes += generator.row([
        PosColumn(text: '${item.quantity}', width: 2),
        PosColumn(text: item.name, width: 6),
        PosColumn(text: item.unitPrice.toStringAsFixed(3), width: 2, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: item.total.toStringAsFixed(3), width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    // Total lines
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Nombre de Lignes: ${printedArticle.lineCount}', width: 6),
      PosColumn(text: 'Nombre de Pieces: ${printedArticle.pieceCount}', width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'TOTAL HT:', width: 8),
      PosColumn(text: printedArticle.totalHT.toStringAsFixed(3), width: 4, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'TOTAL TVA:', width: 8),
      PosColumn(text: printedArticle.totalTVA.toStringAsFixed(3), width: 4, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'TOTAL TTC:', width: 8, styles: const PosStyles(bold: true)),
      PosColumn(text: printedArticle.totalTTC.toStringAsFixed(3), width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    bytes += generator.text('REGLEMENTS', styles: const PosStyles(align: PosAlign.left, bold: true));
    bytes += generator.row([
      PosColumn(text: 'RESTE A PAYER:', width: 8, styles: const PosStyles(bold: true)),
      PosColumn(text: printedArticle.remainingBalance.toStringAsFixed(3), width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    // Footer
    bytes += generator.hr();
    bytes += generator.text('Merci pour votre visite!', styles: const PosStyles(align: PosAlign.center));

    // Print to console for testing
    if (kDebugMode) {
      print('--- ESC/POS Commands ---');
      print(String.fromCharCodes(bytes));
      print('--- End of Commands ---'); }


    // Generate PDF for preview
    await _generatePdf(bytes);

    // Send to Bluetooth Printer
    PrinterBluetooth? selectedPrinter; // Replace this with the selected printer
    if (selectedPrinter != null) {
      printerManager.selectPrinter(selectedPrinter);
      final result = await printerManager.printTicket(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.msg)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No printer selected')),
      );
    }
  }

  // Generate a PDF for preview and open with open_file
  Future<void> _generatePdf(List<int> bytes) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              String.fromCharCodes(bytes),
              style: const pw.TextStyle(fontSize: 10),
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bill_preview_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file. path);
  }
}
