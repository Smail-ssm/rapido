// lib/screens/clients_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/Client.dart';
import '../util/utils.dart';
import '../widgets/AddClientForm.dart';
import '../widgets/ClientItem.dart';
import 'SingleClientPage.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({Key? key}) : super(key: key);

  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late final DatabaseReference _clientsRef;
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('clients');
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClients);
    _searchController.dispose();
    super.dispose();
  }

  void _showAddClientBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: AddClientForm(),
        );
      },
    );
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients = _clients.where((client) {
        return client.name.toLowerCase().contains(query) ||
            client.socialReason.toLowerCase().contains(query) ||
            client.contactNumber.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by name, social reason, or phone',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black),
              )
            : const Text('Clients'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredClients = _clients;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddClientBottomSheet(context),
            tooltip: 'Add Client',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _clientsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final Map<dynamic, dynamic> clientsMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            _clients = clientsMap.entries
                .map((entry) => Client.fromMap(entry.key, entry.value))
                .toList();

            _filteredClients =
                _filteredClients.isEmpty && _searchController.text.isEmpty
                    ? _clients
                    : _filteredClients;

            if (_filteredClients.isEmpty) {
              return const Center(child: Text("No clients found."));
            }

            return ListView.builder(
              itemCount: _filteredClients.length,
              itemBuilder: (context, index) {
                final client = _filteredClients[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SingleClientPage(client: client),
                    ),
                  ),
                  child: ClientItem(
                    name: client.name,
                    socialReason: client.socialReason,
                    deliveriesCount: client.deliveriesCount,
                  ),
                );
              },
            );
          } else {
            // Show Snackbar and prompt to add a client if no clients found
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No clients found. Please add a client."),
                  duration: Duration(seconds: 3),
                ),
              );
              _showAddClientBottomSheet(
                  context); // Automatically open Add Client form
            });

            return const Center(child: Text("No clients found."));
          }
        },
      ),
    );
  }
}
