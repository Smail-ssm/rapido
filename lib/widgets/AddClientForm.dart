import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../util/utils.dart';

class AddClientForm extends StatefulWidget {
  @override
  _AddClientFormState createState() => _AddClientFormState();
}

class _AddClientFormState extends State<AddClientForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _matriculeFiscalController =
  TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController =
  TextEditingController();

  final DatabaseReference _clientsRef = FirebaseDatabase.instance
      .ref()
      .child(Utils.getDatabasePath())
      .child('sari3')
      .child('clients');

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _clientsRef.push().set({
          'name': _nameController.text.trim(),
          'matriculeFiscal': _matriculeFiscalController.text.trim(),
          'address': _addressController.text.trim(),
          'contactNumber': _contactNumberController.text.trim(),
          'deliveriesCount': 0, // Default value for new clients
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client added successfully')),
        );
        Navigator.pop(context); // Close the bottom sheet
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save client: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Client',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please enter the client\'s name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _matriculeFiscalController,
              decoration: const InputDecoration(
                labelText: 'Matricule Fiscal (Tax ID)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty
                  ? 'Please enter the matricule fiscal (tax ID)'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please enter the client\'s address' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactNumberController,
              decoration: const InputDecoration(
                labelText: 'N° tel',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter the N° tel' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveClient,
              child: const Text('Save Client'),
            ),
          ],
        ),
      ),
    );
  }
}
