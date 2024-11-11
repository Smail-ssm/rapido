// lib/services/printer_service.dart
import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../model/PrintedArticle.dart';
import 'PdfGeneratorService.dart';

class PrinterService {
  final PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  final PdfGeneratorService pdfGenerator = PdfGeneratorService();

  // Start scanning for available Bluetooth printers
  Future<void> startScan() async {
    printerManager.startScan(const Duration(seconds: 4));
  }

  // Print the bill: Generates ESC/POS commands for Bluetooth printer
  Future<void> printBill(BuildContext context, PrintedArticle printedArticle) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = pdfGenerator.generateEscPosCommands(generator, printedArticle);

    // Generate a readable PDF for preview or sharing
    await pdfGenerator.generateReadablePdf(  context,printedArticle);

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
}
