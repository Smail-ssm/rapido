// lib/services/pdf_generator_service.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../model/PrintedArticle.dart';
import 'GoogleDriveService.dart';

class PdfGeneratorService {
  final GoogleDriveService _googleDriveService = GoogleDriveService();

  // Generate ESC/POS commands for printing
  List<int> generateEscPosCommands(Generator generator, PrintedArticle printedArticle) {
    List<int> bytes = [];

    // Add receipt header and other ESC/POS content
    bytes += generator.text('RECEIPT', styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.text('Numero: ${printedArticle.bill.clientId}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Date: ${printedArticle.bill.date}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Vendeur: ${printedArticle.bill.vendor}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr(); // Horizontal line

    // Add client and item details, totals, and footer
    // (Add rest of ESC/POS data as in your current code)

    return bytes;
  }

  // Generate a readable, well-formatted PDF file and ask user if they want to upload it
  Future<void> generateReadablePdf(BuildContext context, PrintedArticle printedArticle) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'RECEIPT',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Numero: ${printedArticle.bill.clientName}', style: pw.TextStyle(fontSize: 14)),
                pw.Text('Date: ${printedArticle.bill.date}', style: pw.TextStyle(fontSize: 14)),
                pw.Text('Vendeur: ${printedArticle.bill.vendor}', style: pw.TextStyle(fontSize: 14)),
                pw.Divider(),

                pw.Text('Client:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Raison Sociale: ${printedArticle.bill.clientName}', style: pw.TextStyle(fontSize: 14)),
                pw.Divider(),

                // Product Details
                pw.Row(
                  children: [
                    pw.Expanded(flex: 1, child: pw.Text('QTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 3, child: pw.Text('DESIGNATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 2, child: pw.Text('P.U', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Expanded(flex: 2, child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  ],
                ),
                pw.Divider(),

                ...printedArticle.bill.items.map((item) {
                  return pw.Row(
                    children: [
                      pw.Expanded(flex: 1, child: pw.Text('${item.quantity}')),
                      pw.Expanded(flex: 3, child: pw.Text(item.name)),
                      pw.Expanded(flex: 2, child: pw.Text(item.unitPrice.toStringAsFixed(3), textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 2, child: pw.Text(item.total.toStringAsFixed(3), textAlign: pw.TextAlign.right)),
                    ],
                  );
                }).toList(),
                pw.Divider(),

                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL HT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(printedArticle.totalHT.toStringAsFixed(3)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL TVA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(printedArticle.totalTVA.toStringAsFixed(3)),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL TTC:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(printedArticle.totalTTC.toStringAsFixed(3)),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('RESTE A PAYER:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(printedArticle.remainingBalance.toStringAsFixed(3)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text('Merci pour votre visite!', style: pw.TextStyle(fontSize: 14)),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bill_readable_${DateTime.now()
        .millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open the generated PDF
    await OpenFile.open(file.path);

    // Show dialog to ask if the user wants to upload the bill to Google Drive
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Bill to Google Drive'),
          content: const Text('Would you like to upload this bill to Google '
              'Drive under the client\'s folder?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    // If the user confirms, upload the file
    if (shouldUpload == true) {
      final socialReason = printedArticle.bill.clientName; // Use the client name as the folder name
      final fileName = 'bill_readable_${DateTime.now().toIso8601String()}.pdf';
      await _googleDriveService.uploadFileToDrive(file, fileName, socialReason);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill uploaded to Google Drive.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill not uploaded.')),
      );
    }
  }

  // Generate a simple ESC/POS style PDF preview
  Future<void> generateEscPosPdf(List<int> bytes) async {
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
    await OpenFile.open(file.path);
  }
}
