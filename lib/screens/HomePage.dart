import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart'; // Import the global themeModeNotifier
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
          content: const Text(
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
    final brightness = MediaQuery.of(context).platformBrightness;
    final Query billsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('bills')
        .orderByChild('totalTTC');
    final DatabaseReference clientsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('clients');
    final DatabaseReference productsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('products');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Indicators Section
            Padding(
              padding: const EdgeInsets.all(16.0),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildTotalDeliveriesIndicator(
                                context, billsRef.onValue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildRevenueIndicator(
                                context, billsRef.onValue),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildDashboardCard(
                        context: context,
                        stream: clientsRef.onValue,
                        title: "Clients",
                        icon: Icons.people,
                        onTap: () => Navigator.pushNamed(context, '/clients'),
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildDashboardCard(
                        context: context,
                        stream: productsRef.onValue,
                        title: "Products",
                        icon: Icons.inventory,
                        onTap: () => Navigator.pushNamed(context, '/products'),
                      ),
                    ],
                  ),
                ),
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
            heroTag: 'settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
            child: const Icon(Icons.settings),
          ),
          FloatingActionButton.small(
            heroTag: 'addClient',
            onPressed: () => Navigator.pushNamed(context, '/clients'),
            tooltip: 'Add Client',
            child: const Icon(Icons.person_add),
          ),
          FloatingActionButton.small(
            heroTag: 'addBill',
            onPressed: () => Navigator.pushNamed(context, '/addBill'),
            tooltip: 'Add Bill',
            child: const Icon(Icons.receipt_long),
          ),
          FloatingActionButton.small(
            heroTag: 'themeSwitch',
            onPressed: () {
              // Toggle between light and dark themes
              themeModeNotifier.value = brightness == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            tooltip: 'Switch Theme',
            child: const Icon(Icons.brightness_6),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueIndicator(
      BuildContext context, Stream<DatabaseEvent> stream) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator("Revenue", Icons.attach_money);
        }

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          double totalRevenue = 0.0;
          final dataMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          dataMap.forEach((_, clientBills) {
            final clientBillsMap = clientBills as Map<dynamic, dynamic>;
            clientBillsMap.forEach((_, bill) {
              if (bill['totalTTC'] != null) {
                totalRevenue +=
                    double.tryParse(bill['totalTTC'].toString()) ?? 0.0;
              }
            });
          });

          return _buildIndicatorCard(
              "Revenue", "${totalRevenue.toStringAsFixed(2)} DT");
        } else {
          return _buildIndicatorCard("Revenue", "0.00 DT");
        }
      },
    );
  }

  Widget _buildTotalDeliveriesIndicator(
      BuildContext context, Stream<DatabaseEvent> stream) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator("N° livraison", Icons.delivery_dining);
        }

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final dataMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          int totalDeliveries = dataMap.entries.fold(0, (sum, entry) {
            final clientBillsMap = entry.value as Map<dynamic, dynamic>;
            return sum + clientBillsMap.length;
          });

          return _buildIndicatorCard(
              "N° livraison", totalDeliveries.toString());
        } else {
          return _buildIndicatorCard("N° livraison", "0");
        }
      },
    );
  }

  Widget _buildIndicatorCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required Stream<DatabaseEvent> stream,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(title, icon);
        }

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final dataMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final int count = dataMap.length;
          return GestureDetector(
            onTap: onTap,
            child: DashboardCard(
              title: title,
              value: count.toString(),
              icon: icon,
            ),
          );
        } else {
          return GestureDetector(
            onTap: onTap,
            child: DashboardCard(
              title: title,
              value: "0",
              icon: icon,
            ),
          );
        }
      },
    );
  }

  Widget _buildLoadingCard(String title, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.grey),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String title, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.grey),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
