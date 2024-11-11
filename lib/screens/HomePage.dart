// lib/screens/home_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../service/AuthenticationService.dart';
import '../util/utils.dart';
import '../widgets/dashboard_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
     _requestPermissions();
  }



  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bluetooth and Location permissions are required to use this feature.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationService authService =
    Provider.of<AuthenticationService>(context, listen: false);

    // Firebase Database references for the connected user's clients and products
    final DatabaseReference clientsRef = FirebaseDatabase.instance
        .ref().child(Utils.getDatabasePath())
        .child('users')
        .child(Utils.getDatabasePath())
        .child('clients');

    final DatabaseReference productsRef = FirebaseDatabase.instance
        .ref().child(Utils.getDatabasePath())
        .child('users')
        .child(Utils.getDatabasePath())
        .child('products'); // Reference for the user's products

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Total Clients Card
                  StreamBuilder(
                    stream: clientsRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DashboardCard(
                          title: "Total Clients",
                          value: "Loading...",
                          icon: Icons.people,
                        );
                      }

                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final clientsMap = snapshot.data!.snapshot.value
                        as Map<dynamic, dynamic>;
                        final int clientCount = clientsMap.length;
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/clients'),
                          child: DashboardCard(
                            title: "Total Clients",
                            value: clientCount.toString(),
                            icon: Icons.people,
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/clients'),
                          child: DashboardCard(
                            title: "Total Clients",
                            value: "0",
                            icon: Icons.people,
                          ),
                        );
                      }
                    },
                  ),

                  // Total Products Card (Stock)
                  StreamBuilder(
                    stream: productsRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DashboardCard(
                          title: "Total Products",
                          value: "Loading...",
                          icon: Icons.inventory,
                        );
                      }

                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final productsMap = snapshot.data!.snapshot.value
                        as Map<dynamic, dynamic>;
                        final int productCount = productsMap.length;
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/products'),
                          child: DashboardCard(
                            title: "Total Products",
                            value: productCount.toString(),
                            icon: Icons.inventory,
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/products'),
                          child: DashboardCard(
                            title: "Total Products",
                            value: "0",
                            icon: Icons.inventory,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70.0,
        type: ExpandableFabType.up,
        children: [
          FloatingActionButton.small(
            heroTag: 'addClient',
            onPressed: () {
              Navigator.pushNamed(context, '/addClient');
            },
            tooltip: 'Add Client',
            child: const Icon(Icons.person_add),
          ),
          FloatingActionButton.small(
            heroTag: 'addProduct',
            onPressed: () {
              Navigator.pushNamed(context, '/addProduct');
            },
            tooltip: 'Add Product',
            child: const Icon(Icons.inventory),
          ),
        ],
      ),
    );
  }
}
