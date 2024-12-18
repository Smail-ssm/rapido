import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
  List<Product> _filteredProducts = [];
  Map<String, int> _selectedProductQuantities = {}; // Store selected product quantities
  Set<String> _selectedProductIds = {}; // To track selected product IDs
  bool _isSearching = false;
  bool _hasMoreProducts = true;
  final TextEditingController _searchController = TextEditingController();

  final DatabaseReference _billsRef = FirebaseDatabase.instance
      .ref()
      .child(Utils.getDatabasePath())
      .child('sari3')
      .child('bills');
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _vendorController =
  TextEditingController(); // Controller for vendor name

  @override
  void initState() {
    super.initState();
    _productsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('products');
    _searchController.addListener(_filterProducts);
    _loadMoreProducts(); // Initial load
  }

  Future<void> _loadMoreProducts() async {
    if (!_hasMoreProducts) return;

    final query = _productsRef
        .orderByKey()
        .startAt(_products.length.toString())
        .limitToFirst(10);
    final snapshot = await query.once();

    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> productsMap =
      snapshot.snapshot.value as Map<dynamic, dynamic>;

      final List<Product> newProducts = productsMap.entries
          .map((entry) => Product.fromMap(entry.key, entry.value))
          .toList();

      setState(() {
        _products.addAll(newProducts);
        _filteredProducts =
        _filteredProducts.isEmpty && _searchController.text.isEmpty
            ? _products
            : _filteredProducts;

        if (newProducts.length < 10) {
          _hasMoreProducts = false; // No more products to load
        }
      });
    }
  }

  Future<void> _saveBill() async {
    final billData = {
      'clientId': widget.client.id,
      'clientName': widget.client.name,
      'vendor': _vendorController.text,
      'products': _filteredProducts
          .where((product) => _selectedProductIds.contains(product.id))
          .map((product) => {
        'name': product.name,
        'price': product.price,
        'quantity': _selectedProductQuantities[product.id] ?? product.quantity,
        'total': (product.price * (_selectedProductQuantities[product.id] ?? product.quantity)).toDouble(),
      })
          .toList(),
      'totalAmount': _filteredProducts
          .where((product) => _selectedProductIds.contains(product.id))
          .fold(0.0, (sum, item) => sum + (item.price * (_selectedProductQuantities[item.id] ?? item.quantity))),
      'date': DateTime.now().toIso8601String(),
    };

    await _billsRef.child(widget.client.id).push().set(billData);
    Navigator.pop(context);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleProductSelection(String productId) async {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
        _showQuantityDialog(productId);
      }
    });
  }

  Future<void> _showQuantityDialog(String productId) async {
    final currentQuantity = _selectedProductQuantities[productId] ?? 1;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Quantity'),
          content: TextField(
            controller: _quantityController..text = currentQuantity.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Quantity'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  _selectedProductQuantities[productId] = int.parse(_quantityController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            // Client Information Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.client.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Social Reason: ${widget.client.socialReason}'),
                      Text('Contact Number: ${widget.client.contactNumber}'),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _vendorController,
                        decoration: const InputDecoration(labelText: 'Vendor Name'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product List Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search by name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  StreamBuilder(
                    stream: _productsRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final Map<dynamic, dynamic> productsMap =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                        _products = productsMap.entries
                            .map((entry) => Product.fromMap(entry.key, entry.value))
                            .cast<Product>()
                            .toList();

                        _filteredProducts = _filteredProducts.isEmpty &&
                            _searchController.text.isEmpty
                            ? _products
                            : _filteredProducts;

                        if (_filteredProducts.isEmpty) {
                          return const Center(child: Text("No products found."));
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return CheckboxListTile(
                              value: _selectedProductIds.contains(product.id),
                              onChanged: (bool? value) {
                                _toggleProductSelection(product.id);
                              },
                              title: Text(product.name),
                              subtitle: Text(
                                  'Price: \$${product.price} x ${_selectedProductQuantities[product.id] ?? product.quantity}'),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(),
                        );
                      } else {
                        return const Center(child: Text("No products found."));
                      }
                    },
                  ),
                  if (_hasMoreProducts)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: _loadMoreProducts,
                          child: const Text('Load More Products'),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bill Preview Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Total Amount: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('\$${_filteredProducts.where((product) => _selectedProductIds.contains(product.id)).fold(0.0, (sum, item) => sum + (item.price * (_selectedProductQuantities[item.id] ?? item.quantity))).toStringAsFixed(2)}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveBill,
                    child: const Text('Generate and Save Bill'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
