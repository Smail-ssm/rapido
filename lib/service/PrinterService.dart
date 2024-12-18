import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../model/PrintedArticle.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PrinterService {
  final PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  Future<void> startScan() async {
    printerManager.startScan(const Duration(seconds: 4));
  }

  Future<void> printBill(BuildContext context, PrintedArticle printedArticle) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      'RECEIPT',
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );
    bytes += generator.text('Numero: ${printedArticle.bill.clientId}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Date: ${printedArticle.bill.date}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Vendeur: ${printedArticle.bill.vendor}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr();

    // Client Info
    bytes += generator.text('Client:',
        styles: const PosStyles(align: PosAlign.left, bold: true));
    bytes += generator.text('Raison Sociale: ${printedArticle.bill.clientName}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.feed(1); // Adds a line space
    bytes += generator.hr();

    // Table Header
    bytes += generator.row([
      PosColumn(text: 'QTE', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(text: 'DESIGNATION', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: 'P.U', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(text: 'TOTAL', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();

    // Items
    for (var item in printedArticle.bill.items) {
      bytes += generator.row([
        PosColumn(text: '${item.quantity}', width: 2),
        PosColumn(text: item.name, width: 6),
        PosColumn(text: item.unitPrice.toStringAsFixed(3), width: 2, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: item.total.toStringAsFixed(3), width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    // Totals
    bytes += generator.feed(1); // Space
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Nombre de Lignes:', width: 6),
      PosColumn(text: '${printedArticle.lineCount}', width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Nombre de Pieces:', width: 6),
      PosColumn(text: '${printedArticle.pieceCount}', width: 6, styles: const PosStyles(align: PosAlign.right)),
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

    // Footer Message
    bytes += generator.feed(1);
    bytes += generator.text('Merci pour votre visite!', styles: const PosStyles(align: PosAlign.center));

    // Print to console for testing
    if (kDebugMode) {
      print('--- ESC/POS Commands ---');
      print(String.fromCharCodes(bytes));
      print('--- End of Commands ---'); }

    // Generate PDF Preview
    await _generatePdf(printedArticle);

    // Send to Bluetooth Printer
    PrinterBluetooth? selectedPrinter; // Replace this with the selected printer
    if (selectedPrinter != null) {
      printerManager.selectPrinter(selectedPrinter);
      await printerManager.printTicket(bytes);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No printer selected')),
      );
    }
  }

  Future<void> _generatePdf(PrintedArticle printedArticle) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text('RECEIPT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 5),
                pw.Text('Numero: ${printedArticle.bill.clientId}'),
                pw.Text('Date: ${printedArticle.bill.date}'),
                pw.Text('Vendeur: ${printedArticle.bill.vendor}'),
                pw.Divider(),
                pw.Text('Client:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Raison Sociale: ${printedArticle.bill.clientName}'),
                pw.Divider(),
                ...printedArticle.bill.items.map(
                      (item) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('QTE'),
                      pw.Text('P.U'),
                      pw.Text('REMISE'),
                      pw.Text('MONTANT'),
                      pw.Text('NET'),
                    ],
                  ),
                ),
                pw.Divider(),

                ...printedArticle.bill.items.map(
                      (item) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(item.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), // Bold product name
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${item.quantity}'),
                          pw.Text(item.unitPrice.toStringAsFixed(3)),
                          pw.Text('0'),
                          pw.Text((item.unitPrice*item.quantity).toStringAsFixed(4)),
                          pw.Text((item.unitPrice*item.quantity).toStringAsFixed(4)),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Divider(),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text('TOTAL TTC:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(printedArticle.totalTTC.toStringAsFixed(3)),
                ]),

                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text('Merci pour votre visite!' )),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bill_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
