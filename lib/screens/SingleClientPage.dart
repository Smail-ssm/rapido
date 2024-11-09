// lib/screens/single_client_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rapido/screens/GenerateBillPage.dart';
import 'package:rapido/screens/SingleBillPage.dart';
import 'package:rapido/util/utils.dart';
import '../model/Client.dart';
import '../model/PrintedArticle.dart';
import '../model/bill.dart';
import '../widgets/BillHistoryItem.dart';

class SingleClientPage extends StatefulWidget {
  final Client client;

  const SingleClientPage({Key? key, required this.client}) : super(key: key);

  @override
  _SingleClientPageState createState() => _SingleClientPageState();
}

class _SingleClientPageState extends State<SingleClientPage> {
  late final DatabaseReference _billsRef;
  List<PrintedArticle> _bills = []; // Use List<PrintedArticle> type

  @override
  void initState() {
    super.initState();
    _billsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('bills')
        .child(widget.client.id);
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    final event = await _billsRef.once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final billsList = await Future.wait(data.entries.map((entry) async {
        // Create BillItems from products list
        final items = (entry.value['products'] as List<dynamic>? ?? []).map((product) {
          return BillItem(
            name: product['name'] ?? '',
            quantity: (product['quantity'] ?? 1).toInt(),
            unitPrice: (product['price'] ?? 0.0).toDouble(),
          );
        }).toList();

        // Create Bill object
        final bill = Bill(
          clientId: widget.client.id,
          clientName: widget.client.name,
          date: entry.value['date'] ?? '',
          vendor: entry.value['vendor'] ?? '', // Example vendor name, adjust as needed
          items: items,
        );

        // Await the creation of PrintedArticle
        return await PrintedArticle.fromBill(bill);
      }).toList());

      // Update state with the result
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
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make full width
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
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Social Reason: ${widget.client.socialReason}'),
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
                    final printedArticle = _bills[index];
                    return BillHistoryItem(
                      date: printedArticle.bill.date,
                      totalAmount: printedArticle.totalTTC,
                      description: printedArticle.bill.clientName,
                      vendor: printedArticle.bill.vendor, // Pass vendor name
                      onPrint: () {}, // Add print function if needed
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SingleBillPage(bill: printedArticle),
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
