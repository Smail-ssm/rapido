import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:permission_handler/permission_handler.dart';

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
    final DatabaseReference clientsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('clients');
    final DatabaseReference deliveriesRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('deliveries');
    final DatabaseReference productsRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('products');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            children: [
              // Total Clients Card
              _buildDashboardCard(
                context: context,
                stream: clientsRef.onValue,
                title: "Total Clients",
                icon: Icons.people,
                onTap: () => Navigator.pushNamed(context, '/clients'),
              ),
              // Total Deliveries Card
              _buildDashboardCard(
                context: context,
                stream: deliveriesRef.onValue,
                title: "Total Deliveries",
                icon: Icons.delivery_dining,
                onTap: () => Navigator.pushNamed(context, '/deliveries'),
              ),
              // Revenue Card
              _buildRevenueCard(
                context: context,
                stream: deliveriesRef.onValue,
              ),
              // Products Card
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70.0,
        type: ExpandableFabType.up,
        children: [
          FloatingActionButton.small(
            heroTag: 'addClient',
            onPressed: () => Navigator.pushNamed(context, '/addClient'),
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
          return DashboardCard(
            title: title,
            value: "Loading...",
            icon: icon,
          );
        }

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
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

  Widget _buildRevenueCard({
    required BuildContext context,
    required Stream<DatabaseEvent> stream,
  }) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DashboardCard(
            title: "Revenue",
            value: "Loading...",
            icon: Icons.attach_money,
          );
        }

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          double totalRevenue = 0.0;

          dataMap.forEach((key, value) {
            final revenue = (value as Map<dynamic, dynamic>)['revenue'];
            if (revenue != null) {
              totalRevenue += double.tryParse(revenue.toString()) ?? 0.0;
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
    );
  }
}
