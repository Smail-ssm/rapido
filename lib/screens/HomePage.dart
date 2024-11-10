// lib/screens/home_page.dart
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
      // If permissions are denied, show a dialog or a snackbar
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

    // Firebase Database references
    final DatabaseReference clientsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('clients');
    final DatabaseReference deliveriesRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('deliveries');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
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
                            onTap: () =>
                                Navigator.pushNamed(context, '/clients'),
                            child: DashboardCard(
                              title: "Total Clients",
                              value: "0",
                              icon: Icons.people,
                            ));
                      }
                    },
                  ),

                  // Total Deliveries Card
                  StreamBuilder(
                    stream: deliveriesRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DashboardCard(
                          title: "Total Deliveries",
                          value: "Loading...",
                          icon: Icons.delivery_dining,
                        );
                      }

                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final deliveriesMap = snapshot.data!.snapshot.value
                        as Map<dynamic, dynamic>;
                        final int deliveriesCount = deliveriesMap.length;
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/deliveries'),
                          child: DashboardCard(
                            title: "Total Deliveries",
                            value: deliveriesCount.toString(),
                            icon: Icons.delivery_dining,
                          ),
                        );
                      } else {
                        return GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/deliveries'),
                            child: DashboardCard(
                              title: "Total Deliveries",
                              value: "0",
                              icon: Icons.delivery_dining,
                            ));
                      }
                    },
                  ),

                  // Revenue Card
                  StreamBuilder(
                    stream: deliveriesRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DashboardCard(
                          title: "Revenue",
                          value: "Loading...",
                          icon: Icons.attach_money,
                        );
                      }

                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final deliveriesMap = snapshot.data!.snapshot.value
                        as Map<dynamic, dynamic>;
                        double totalRevenue = 0.0;

                        deliveriesMap.forEach((key, value) {
                          final revenue =
                          (value as Map<dynamic, dynamic>)['revenue'];
                          if (revenue != null) {
                            totalRevenue +=
                                double.tryParse(revenue.toString()) ?? 0.0;
                          }
                        });

                        return DashboardCard(
                          title: "Revenue",
                          value: "\$${totalRevenue.toStringAsFixed(2)}",
                          icon: Icons.attach_money,
                        );
                      } else {
                        return const DashboardCard(
                          title: "Revenue",
                          value: "\$0.00",
                          icon: Icons.attach_money,
                        );
                      }
                    },
                  ),

                  // Settings Card
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: const DashboardCard(
                      title: "Settings",
                      value: "",
                      icon: Icons.settings,
                    ),
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
            heroTag: 'addBill',
            onPressed: () {
              Navigator.pushNamed(context, '/addBill');
            },
            tooltip: 'Add Bill',
            child: const Icon(Icons.receipt_long),
          ),
          FloatingActionButton.small(
            heroTag: 'otherAction',
            onPressed: () {
              // Add other actions here
            },
            tooltip: 'Other Action',
            child: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }
}
