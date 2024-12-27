import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../model/Bill.dart';
import '../model/Client.dart';
import '../util/utils.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({Key? key}) : super(key: key);

  @override
  _BillsPageState createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  List<Map<dynamic, dynamic>> _bills = [];
  List<Map<dynamic, dynamic>> _filteredBills = [];
  final TextEditingController _searchController = TextEditingController();
  final DatabaseReference _billsRef = FirebaseDatabase.instance
      .ref()
      .child(Utils.getDatabasePath())
      .child('sari3')
      .child('bills');

  @override
  void initState() {
    super.initState();
    _fetchAllBills();
    _searchController.addListener(_filterBills);
  }

  Future<void> _fetchAllBills() async {
    try {
      // Fetch the data from the database
      final event = await _billsRef.once();
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Bill> billsList = [];

        // Iterate through all clients (outer map keys)
        data.forEach((clientId, clientBills) {
          final clientBillsMap = clientBills as Map<dynamic, dynamic>;

          // Iterate through each client's bills (inner map keys)
          clientBillsMap.forEach((billId, billData) {
            final billDetails = billData as Map<dynamic, dynamic>;

            // Parse the products list
            final products = (billDetails['products'] as List<dynamic>? ?? [])
                .map((product) {
              return BillItem(
                name: product['name'] ?? 'Unknown',
                quantity: int.tryParse(product['quantity'].toString()) ?? 1,
                unitPrice:
                    double.tryParse(product['unitPrice'].toString()) ?? 0.0,
                remise: double.tryParse(product['remise'].toString()) ?? 0.0,
                barcode: product['barcode'] ?? '',
              );
            }).toList();

            // Add the parsed bill to the list
            billsList.add(Bill(
              id: billId,
              client: Client(
                id: clientId,
                name: billDetails['clientName'] ?? 'Unknown Client',
                matriculeFiscal: '',
                contactNumber: '',
                address: '',
                deliveriesCount: 0,
              ),
              date: billDetails['date'] ?? '',
              vendor: billDetails['vendor'] ?? '',
              items: products,
              totalHT:
                  double.tryParse(billDetails['totalHT'].toString()) ?? 0.0,
              totalTVA:
                  double.tryParse(billDetails['totalTVA'].toString()) ?? 0.0,
              totalTTC:
                  double.tryParse(billDetails['totalTTC'].toString()) ?? 0.0,
              remainingBalance:
                  double.tryParse(billDetails['remainingBalance'].toString()) ??
                      0.0,
              lineCount: int.tryParse(billDetails['lineCount'].toString()) ?? 0,
              pieceCount:
                  int.tryParse(billDetails['pieceCount'].toString()) ?? 0,
            ));
          });
        });

        // Update the state with the parsed bills
        setState(() {
          _bills = billsList.cast<Map>();
        });
      } else {
        // No data found, set empty list
        setState(() {
          _bills = [];
        });
      }
    } catch (e, stackTrace) {
      // Handle potential errors
      debugPrint("Error fetching all bills: $e");
      debugPrint(stackTrace.toString());
      setState(() {
        _bills = [];
      });
    }
  }

  void _filterBills() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredBills = _bills.where((bill) {
        final clientName = (bill['clientName'] ?? '').toLowerCase();
        final date = (bill['date'] ?? '').toLowerCase();
        return clientName.contains(query) || date.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bills"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search by client or date",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredBills.isEmpty
                ? const Center(child: Text("No bills found"))
                : ListView.builder(
                    itemCount: _bills.length,
                    itemBuilder: (context, index) {
                      final bill = _filteredBills[index];
                      return ListTile(
                        title: Text(bill['clientName']),
                        subtitle: Text("Date: ${bill['date']}"),
                        trailing: Text("${bill['totalTTC']} DT"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
