import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../model/Bill.dart';
import '../model/Client.dart';
import '../model/Product.dart';
import '../util/utils.dart';

class GenerateBillPage extends StatefulWidget {
  final Client client;

  const GenerateBillPage({Key? key, required this.client}) : super(key: key);

  @override
  _GenerateBillPageState createState() => _GenerateBillPageState();
}

class _GenerateBillPageState extends State<GenerateBillPage> {
  late final DatabaseReference _productsRef;
  List<Product> _products = [];
  Map<String, int> _selectedProductQuantities = {};
  Set<String> _selectedProductIds = {};
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();

  final DatabaseReference _billsRef = FirebaseDatabase.instance
      .ref()
      .child(Utils.getDatabasePath())
      .child('sari3')
      .child('bills');

  @override
  void initState() {
    super.initState();
    _productsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('products');
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final query = _productsRef.orderByKey().limitToFirst(50);
    final snapshot = await query.once();

    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> productsMap =
      snapshot.snapshot.value as Map<dynamic, dynamic>;

      final List<Product> newProducts = productsMap.entries
          .map((entry) => Product.fromMap(entry.key, entry.value))
          .toList();

      setState(() {
        _products = newProducts;
      });
    }
  }

  Future<void> _saveBill() async {
    // Create the BillItems
    final items = _selectedProductIds.map((id) {
      final product = _products.firstWhere((p) => p.id == id);
      return BillItem(
        name: product.name,
        quantity: _selectedProductQuantities[id] ?? 1,
        unitPrice: product.price,
        remise: 0, // Assuming no discount for now
        barcode: product.barcode ?? '',
      );
    }).toList();

    // Pre-calculate totals
    final totalHT = items.fold(0.0, (sum, item) => sum + item.total);
    final totalTVA = totalHT * 0.15; // Assuming a tax rate of 15%
    final totalTTC = totalHT + totalTVA;
    final lineCount = items.length;
    final pieceCount = items.fold(0, (sum, item) => sum + item.quantity);
    final remainingBalance = totalTTC;

    // Create the Bill object
    final bill = Bill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      client: widget.client,
      date: DateTime.now().toIso8601String(),
      vendor: _vendorController.text,
      items: items,
      totalHT: totalHT,
      totalTVA: totalTVA,
      totalTTC: totalTTC,
      remainingBalance: remainingBalance,
      lineCount: lineCount,
      pieceCount: pieceCount,
      description: 'Generated bill',
    );

    // Save the bill to Firebase
    await _billsRef.child(widget.client.id).push().set({
      'id': bill.id,
      'clientId': bill.client.id,
      'clientName': bill.client.name,
      'date': bill.date,
      'vendor': bill.vendor,
      'description': bill.description,
      'totalHT': bill.totalHT,
      'totalTVA': bill.totalTVA,
      'totalTTC': bill.totalTTC,
      'remainingBalance': bill.remainingBalance,
      'lineCount': bill.lineCount,
      'pieceCount': bill.pieceCount,
      'products': items.map((item) => {
        'name': item.name,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'remise': item.remise,
        'total': item.total,
        'barcode': item.barcode,
      }).toList(),
    });

    Navigator.pop(context);
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
        _selectedProductQuantities.remove(productId);
      } else {
        _selectedProductIds.add(productId);
        _selectedProductQuantities[productId] = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Bill for ${widget.client.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBill,
            tooltip: 'Save Bill',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClientInformationSection(),
            const Divider(height: 32),
            _buildProductListSection(),
            const Divider(height: 32),
            _buildBillPreviewSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.client.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Social Reason: ${widget.client.matriculeFiscal}'),
        Text('Contact Number: ${widget.client.contactNumber}'),
        const SizedBox(height: 16),
        TextField(
          controller: _vendorController,
          decoration: const InputDecoration(
            labelText: 'Vendor Name',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search Products',
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            setState(() {
              _products = _products
                  .where((product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            });
          },
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return Row(
              children: [
                Checkbox(
                  value: _selectedProductIds.contains(product.id),
                  onChanged: (_) => _toggleProductSelection(product.id),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      'Price: ${product.price} x ${_selectedProductQuantities[product.id] ?? 1} = ${(product.price * (_selectedProductQuantities[product.id] ?? 1)).toStringAsFixed(2)}',
                    ),
                  ),
                ),
                if (_selectedProductIds.contains(product.id))
                  Row(
                    children: [
                      const Text(
                        'QTE:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              final quantity = int.tryParse(value) ?? 1;
                              _selectedProductQuantities[product.id] =
                              quantity > 0 ? quantity : 1;
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                            '${_selectedProductQuantities[product.id] ?? 1}',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBillPreviewSection() {
    final totalAmount = _selectedProductIds.fold(
      0.0,
          (sum, id) =>
      sum +
          _products
              .firstWhere((p) => p.id == id)
              .price *
              (_selectedProductQuantities[id] ?? 1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _saveBill,
          child: const Text('Generate and Save Bill'),
        ),
      ],
    );
  }
}
