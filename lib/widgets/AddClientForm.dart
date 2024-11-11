// lib/screens/widgets/add_client_form.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../util/utils.dart';

class AddClientForm extends StatefulWidget {
  @override
  _AddClientFormState createState() => _AddClientFormState();
}

class _AddClientFormState extends State<AddClientForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _socialReasonController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();

  final DatabaseReference _clientsRef = FirebaseDatabase.instance.ref().child(Utils.getDatabasePath())
        .child('users')
        .child(Utils.getDatabasePath()).child('clients');

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      await _clientsRef.push().set({
        'name': _nameController.text.trim(),
        'socialReason': _socialReasonController.text.trim(),
        'address': _addressController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
      });
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
          Text(
            'Add Client',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _socialReasonController,
            decoration: InputDecoration(labelText: 'Social Reason'),
            validator: (value) => value!.isEmpty ? 'Please enter a social reason' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Address'),
            validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _contactNumberController,
            decoration: InputDecoration(labelText: 'Contact Number'),
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Please enter a contact number' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveClient,
            child: const Text('Save Client'),
          ),
        ],
      ),
    );
  }
}
