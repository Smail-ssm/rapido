import 'package:flutter/material.dart';
import '../model/Product.dart';
import '../service/ProductService.dart';
import '../widgets/AddProductForm.dart';
import '../widgets/ProductCard.dart';
import 'ProductDetailsPage.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  bool _isSearching = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'name'; // default sort option
  bool _isAscending = true; // Default to ascending order

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _productsFuture = _productService.fetchProducts();
    });
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }
  List<Product> _sortProducts(List<Product> products) {
    if (_sortOption == 'name') {
      products.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortOption == 'price') {
      products.sort((a, b) => a.price.compareTo(b.price));
    }

    // Reverse the list if descending order is selected
    if (!_isAscending) {
      products = products.reversed.toList();
    }

    return products;
  }
  void _showAddOrEditProductBottomSheet({Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: AddProductForm(
          product: product,
          onSaveProduct: (newProduct) async {
            if (product == null) {
              await _productService.addProduct(newProduct);
            } else {
              await _productService.updateProduct(newProduct);
            }
            _refreshProducts();
          },
        ),
      ),
    );
  }

  void _deleteProduct(String productId) async {
    await _productService.deleteProduct(productId);
    _refreshProducts();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search Products...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          autofocus: true,
        )
            : const Text('Products'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchText = '';
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String result) {
              setState(() {
                if (result.endsWith('_asc')) {
                  _sortOption = result.split('_')[0];
                  _isAscending = true;
                } else if (result.endsWith('_desc')) {
                  _sortOption = result.split('_')[0];
                  _isAscending = false;
                }
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'name_asc',
                child: Text('Sort by Name (Ascending)'),
              ),
              const PopupMenuItem<String>(
                value: 'name_desc',
                child: Text('Sort by Name (Descending)'),
              ),
              const PopupMenuItem<String>(
                value: 'price_asc',
                child: Text('Sort by Price (Ascending)'),
              ),
              const PopupMenuItem<String>(
                value: 'price_desc',
                child: Text('Sort by Price (Descending)'),
              ),
            ],
          ),
        ],      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          } else {
            var products = _sortProducts(snapshot.data!);
            if (_searchText.isNotEmpty) {
              products = products
                  .where((product) => product.name.toLowerCase().contains(_searchText.toLowerCase()))
                  .toList();
            }
            return RefreshIndicator(
              onRefresh: _refreshProducts,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Dismissible(
                    key: Key(product.id),
                    background: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        _showAddOrEditProductBottomSheet(product: product);
                      } else if (direction == DismissDirection.endToStart) {
                        _deleteProduct(product.id);
                      }
                    },
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(product: product),
                          ),
                        );
                      },
                      child: ProductCard(product: product),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditProductBottomSheet(),
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}
