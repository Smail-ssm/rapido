// lib/widgets/add_product_form.dart
import 'package:flutter/material.dart';

import '../model/Product.dart';

class AddProductForm extends StatefulWidget {
  final Product? product;
  final Function(Product) onSaveProduct;

  const AddProductForm({Key? key, this.product, required this.onSaveProduct}) : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? DateTime.now().toString(), // Use existing ID for edit
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        description: _descriptionController.text,
      );
      widget.onSaveProduct(product);
      Navigator.pop(context); // Close the bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Product Name'),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          ),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
          ),
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Please enter quantity' : null,
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.product == null ? 'Add Product' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
