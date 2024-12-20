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
            client.matriculeFiscal.toLowerCase().contains(query) ||
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
            hintText: 'Search by name, matricule fiscal, or phone',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
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
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleClientPage(client: client),
                      ),
                    ),
                    title: Text(
                      client.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Matricule Fiscal: ${client.matriculeFiscal}'),
                        Text('Contact: ${client.contactNumber}'),
                        Text('Deliveries: ${client.deliveriesCount}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.blue),
                  ),
                );
              },
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No clients found. Please add a client."),
                  duration: Duration(seconds: 3),
                ),
              );
              _showAddClientBottomSheet(context);
            });

            return const Center(child: Text("No clients found."));
          }
        },
      ),
    );
  }
}
