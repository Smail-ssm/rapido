import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart'; // Firebase for profile fetching
import 'dart:io';
import '../model/Bill.dart';
import '../util/utils.dart';

class PrinterService {
  final PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  final DatabaseReference _profileRef = FirebaseDatabase.instance
      .ref()
      .child(Utils.getDatabasePath())
      .child('sari3')
      .child('profile');

  /// Start scanning for Bluetooth printers
  Future<void> startScan() async {
    printerManager.startScan(const Duration(seconds: 4));
  }

  /// Fetch the profile data from Firebase
  Future<Map<String, dynamic>> fetchProfile() async {
    final snapshot = await _profileRef.get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    } else {
      throw Exception("Profile data not found.");
    }
  }

  /// Print the bill to a selected Bluetooth printer and generate a PDF preview
  Future<void> printBill(BuildContext context, Bill bill) async {
    try {
      // Fetch profile data
      final profile = await fetchProfile();

      // Load printer profile
      final profileData = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profileData);
      List<int> bytes = [];

      // Header
      bytes += generator.text(
        profile['companyName'] ?? 'COMPANY NAME',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        profile['address'] ?? 'Company Address',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Tel: ${profile['tel'] ?? ''} | Matricule Fiscale:Matricule Fiscale:Matricule Fiscale:Matricule Fiscale: ${profile['matriculeFiscale'] ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      // Commercial Information
      bytes += generator.text('Livreur: ${profile['livreurName'] ?? 'Livreur Name'}');
      bytes += generator.text('Camion: ${profile['carPlate'] ?? 'N/A'}');
      bytes += generator.hr();

      // Client Details
      bytes += generator.text('Nom Client: ${bill.client.name}');
      bytes += generator.text('Tel Client: ${bill.client.contactNumber}');
      bytes += generator.text('Adresse: ${bill.client.address}');
      bytes += generator.text('Matricule Fiscale: ${bill.client.matriculeFiscal}');
      bytes += generator.hr();

      // Delivery Information
      bytes += generator.text('Bon de Livraison N: ${bill.id}');
      bytes += generator.text('Date: ${bill.date}');
      bytes += generator.text('Net à Payer: ${bill.totalTTC.toStringAsFixed(3)}');
      bytes += generator.hr();

      // Items Header
      bytes += generator.row([
        PosColumn(text: 'QTE', width: 2, styles: const PosStyles(bold: true)),       // Quantity
        PosColumn(text: 'P.U', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)), // Unit Price
        PosColumn(text: 'REMISE', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)), // Discount
        PosColumn(text: 'M.NET', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)), // Net Amount
        PosColumn(text: 'M.TTC', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)), // Total with Tax
      ]);
      bytes += generator.hr();

      // Items
      for (var item in bill.items) {
        // Product Name
        bytes += generator.text(item.name, styles: const PosStyles(align: PosAlign.left, bold: true));

        // Barcode
        if (item.barcode.isNotEmpty) {
          bytes += generator.text(item.barcode, styles: const PosStyles(align: PosAlign.left, height: PosTextSize.size1));
        }

        // Item details
        bytes += generator.row([
          PosColumn(text: '${item.quantity}', width: 2), // QTE
           PosColumn(
              text: item.unitPrice.toStringAsFixed(3),
              width: 2,
              styles: const PosStyles(align: PosAlign.right)),
          PosColumn(
              text: item.remise.toStringAsFixed(2),
              width: 2,
              styles: const PosStyles(align: PosAlign.right)),
          PosColumn(
              text: item.total.toStringAsFixed(3),
              width: 3,
              styles: const PosStyles(align: PosAlign.right)),
          PosColumn(
              text: item.total.toStringAsFixed(3),
              width: 3,
              styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      bytes += generator.hr();

      // Totals
      bytes += generator.row([
        PosColumn(text: 'TOTAL HT:', width: 8),
        PosColumn(
            text: bill.totalHT.toStringAsFixed(3),
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'TOTAL VAT:', width: 8),
        PosColumn(
            text: bill.totalTVA.toStringAsFixed(3),
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(text: 'TOTAL TTC:', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(
            text: bill.totalTTC.toStringAsFixed(3),
            width: 4,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      bytes += generator.hr();

      // Footer
      bytes += generator.text('Nombre d\'articles: ${bill.items.length}',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(
          'Mode de Paiement: Espèce ${bill.totalTTC.toStringAsFixed(3)}',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.hr();
      bytes += generator.text(
        'Powered by CLEDISS\nwww.clediss.com\nwww.nomadis.online',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(2);
      await _generatePdf(bill, profile);

      // Print to Bluetooth Printer
      await _printToBluetoothPrinter(context, bytes,bill);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing bill: $e')),
      );
    }
  }

  /// Generate a PDF receipt for the bill
  Future<void> _generatePdf(Bill bill, Map<String, dynamic> profile) async {
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
                // Header Section (User Profile Information)
                pw.Center(
                  child: pw.Text(
                    profile['companyName'] ?? 'COMPANY NAME',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    profile['address'] ?? 'Company Address',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Tel: ${profile['tel'] ?? ''} | Matricule Fiscale: ${profile['matriculeFiscale'] ?? ''}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Divider(),

                // Commercial Information
                pw.Text('Livreur: ${profile['livreurName'] ?? 'Livreur Name'}'),
                pw.Text('Camion: ${profile['carPlate'] ?? 'N/A'}'),
                pw.Divider(),

                // Client Information
                pw.Text('Nom Client: ${bill.client.name}'),
                pw.Text('Tel Client: ${bill.client.contactNumber}'),
                pw.Text('Adresse: ${bill.client.address}'),
                pw.Text('Matricule Fiscale: ${bill.client.matriculeFiscal}'),
                pw.Divider(),

                // Delivery Information
                pw.Text('Bon de Livraison N: ${bill.id}'),
                // Use bill.id for this field
                pw.Text('Date: ${bill.date}'),
                pw.Text('Net à Payer: ${bill.totalTTC.toStringAsFixed(3)}'),
                pw.Divider(),

                // Items Table Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('QTE',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 8)),
                    // Quantity
                    pw.Text('P.U',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 8)),
                    // Unit Price
                    pw.Text('REMISE',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 8)),
                    // Discount
                    pw.Text('MONTANT NET',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 8)),
                    // Net Amount
                    pw.Text('MONTANT TTC',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 8)),
                    // Total with Tax
                  ],
                ),
                pw.Divider(),

                // Items
                // Items
                ...bill.items.map((item) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Product Name and Barcode
                      pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          item.barcode+" | "+item.name+" | "+item.barcode,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Text(
                        item.barcode,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      // Item Details (QTY, P.U, REMISE, MONTANT NET, MONTANT TTC)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${item.quantity}'),
                          // QTE
                          pw.Text('${item.unitPrice.toStringAsFixed(3)}'),
                          // P.U
                          pw.Text('${item.remise.toStringAsFixed(2)}'),
                          // REMISE
                          pw.Text('${item.total.toStringAsFixed(3)}'),
                          // MONTANT NET
                          pw.Text('${(item.total).toStringAsFixed(3)}'),
                          // MONTANT TTC
                        ],
                      ),
                      pw.Divider(thickness: 0.5),
                      // Separator between items
                    ],
                  );
                }),

                pw.Divider(),

                // Totals Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL HT:'),
                    pw.Text(bill.totalHT.toStringAsFixed(3)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL VAT:'),
                    pw.Text(bill.totalTVA.toStringAsFixed(3)),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL TTC:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(bill.totalTTC.toStringAsFixed(3),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Divider(),

                // Footer
                pw.Text('Nombre d\'article= ${bill.items.length}'),
                pw.Text(
                    'Mode de Paiement: Espece ${bill.totalTTC.toStringAsFixed(3)}'),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'Powered by CLEDISS\nwww.clediss.com\nwww.nomadis.online',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
        '${output.path}/bill_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  Future<void> _printToBluetoothPrinter(
      BuildContext context, List<int> bytes, Bill bill) async {
    // Simulate ticket layout in console
    _simulateTicketInConsole(bill);

    printerManager.scanResults.listen((printers) async {
      if (printers.isNotEmpty) {
        final selectedPrinter = printers.first;
        printerManager.selectPrinter(selectedPrinter);
        try {
          await printerManager.printTicket(bytes);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Print successful!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Print failed: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No printer found')),
        );
      }
    });

    startScan();
  }

  /// Simulate ticket output in console with real bill data
  void _simulateTicketInConsole(Bill bill) {
    final simulatedTicket = StringBuffer();

    simulatedTicket.writeln('==============================');
    simulatedTicket.writeln('         ${bill.client.name.toUpperCase()}         ');
    simulatedTicket.writeln('      ${bill.client.address}         ');
    simulatedTicket.writeln(
        'Tel: ${bill.client.contactNumber} | Matricule: ${bill.client.matriculeFiscal}');
    simulatedTicket.writeln('==============================');

    simulatedTicket.writeln('Livreur: Example Livreur');
    simulatedTicket.writeln('Camion: Example Camion');
    simulatedTicket.writeln('------------------------------');

    simulatedTicket.writeln('Nom Client: ${bill.client.name}');
    simulatedTicket.writeln('Tel Client: ${bill.client.contactNumber}');
    simulatedTicket.writeln('Adresse: ${bill.client.address}');
    simulatedTicket.writeln('Matricule Fiscale: ${bill.client.matriculeFiscal}');
    simulatedTicket.writeln('------------------------------');

    simulatedTicket.writeln('Bon de Livraison N: ${bill.id}');
    simulatedTicket.writeln('Date: ${bill.date}');
    simulatedTicket.writeln('Net à Payer: ${bill.totalTTC.toStringAsFixed(3)}');
    simulatedTicket.writeln('------------------------------');

    simulatedTicket.writeln(
        'QTY   DESCRIPTION          P.U    REMISE    M.NET   M.TTC');
    simulatedTicket.writeln('------------------------------');

    for (var item in bill.items) {
      simulatedTicket.writeln(
          '${item.quantity.toString().padRight(5)} ${item.name.padRight(20)} ${item.unitPrice.toStringAsFixed(3).padRight(6)} ${item.remise.toStringAsFixed(2).padRight(7)} ${item.total.toStringAsFixed(3).padRight(7)} ${item.total.toStringAsFixed(3)}');
    }

    simulatedTicket.writeln('------------------------------');

    simulatedTicket.writeln('TOTAL HT: ${bill.totalHT.toStringAsFixed(3)}');
    simulatedTicket.writeln('TOTAL VAT: ${bill.totalTVA.toStringAsFixed(3)}');
    simulatedTicket.writeln('------------------------------');
    simulatedTicket.writeln(
        'TOTAL TTC: ${bill.totalTTC.toStringAsFixed(3)}');
    simulatedTicket.writeln('------------------------------');

    simulatedTicket.writeln('Nombre d\'articles: ${bill.items.length}');
    simulatedTicket.writeln(
        'Mode de Paiement: Espece ${bill.totalTTC.toStringAsFixed(3)}');
    simulatedTicket.writeln('------------------------------');

    simulatedTicket.writeln('Powered by CLEDISS');
    simulatedTicket.writeln('www.clediss.com');
    simulatedTicket.writeln('www.nomadis.online');
    simulatedTicket.writeln('==============================');

    // Output to console
    debugPrint(simulatedTicket.toString());
  }


}
