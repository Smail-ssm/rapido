import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/Client.dart';
import '../model/Bill.dart';
import '../service/PrinterService.dart';
import '../util/utils.dart';
import '../widgets/BillHistoryItem.dart';
import 'GenerateBillPage.dart';
import 'SingleBillPage.dart';

class SingleClientPage extends StatefulWidget {
  final Client client;

  const SingleClientPage({Key? key, required this.client}) : super(key: key);

  @override
  _SingleClientPageState createState() => _SingleClientPageState();
}

class _SingleClientPageState extends State<SingleClientPage> {
  late final DatabaseReference _billsRef;
  final PrinterService _printerService = PrinterService();
  List<Bill> _bills = [];
  Future<void> _printBill(BuildContext context,bill) async {
    await _printerService.printBill(context, bill); // Pass PrintedArticle directly
  }

  @override
  void initState() {
    super.initState();
    _billsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('bills')
        .child(widget.client.id);
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    final event = await _billsRef.once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final billsList = await Future.wait(data.entries.map((entry) async {
        final products = (entry.value['products'] as List<dynamic>? ?? []);
        final items = products.map((product) {
          return BillItem(
            name: product['name'] ?? 'Unknown',
            quantity: (product['quantity'] ?? 1).toInt(),
            unitPrice: (product['unitPrice'] ?? 0.0).toDouble(),
            remise: (product['remise'] ?? 0.0).toDouble(),
            barcode: product['barcode'] ?? '',
          );
        }).toList();

        return await Bill.fromItems(
          id: entry.value['id']?? '',
          client: widget.client,
           date: entry.value['date'] ?? '',
          vendor: entry.value['vendor'] ?? 'Unknown Vendor',
          items: items,
          description: entry.value['description'] ?? '',
        );
      }).toList());

      setState(() {
        _bills = billsList;
      });
    } else {
      setState(() {
        _bills = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenerateBillPage(client: widget.client),
                ),
              );
            },
            tooltip: 'Generate Bill',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBills,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display Client Info
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.client.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Social Reason: ${widget.client.matriculeFiscal}'),
                        Text('Contact Number: ${widget.client.contactNumber}'),
                        Text('Address: ${widget.client.address}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Display List of Bills
                const Text(
                  'Bill History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _bills.isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _bills.length,
                  itemBuilder: (context, index) {
                    final bill = _bills[index];
                    return BillHistoryItem(
                      date: bill.date,
                      totalAmount: bill.totalTTC,
                      description: bill.description,
                      vendor: bill.vendor,
                      onPrint: () {
                         _printBill(context,bill) ;
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleBillPage(bill: bill),
                          ),
                        );
                      },
                    );
                  },
                )
                    : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No bills found.'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
