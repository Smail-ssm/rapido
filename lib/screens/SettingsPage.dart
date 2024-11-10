import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _taxRateController = TextEditingController();
  double _currentTaxRate = 0.15; // Default tax rate
   BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeBluetooth();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentTaxRate = prefs.getDouble('taxRate') ?? 0.15;
      _taxRateController.text = _currentTaxRate.toString();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final newTaxRate = double.tryParse(_taxRateController.text) ?? _currentTaxRate;
    await prefs.setDouble('taxRate', newTaxRate);

    setState(() {
      _currentTaxRate = newTaxRate;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  Future<void> _initializeBluetooth() async {
    // Listen for changes in the Bluetooth adapter state
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
    });

    // Check for connected devices
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    setState(() {
      if (devices.isNotEmpty) {
        _connectedDevice = devices.first;
      }
    });
  }

  void _startScan() {
    // Clear previous scan results
    setState(() {
      _scanResults.clear();
    });

    // Start scanning
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
      });
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      _connectedDevice = device;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Variable Settings Section
            Text('Variable Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            TextField(
              controller: _taxRateController,
              decoration: const InputDecoration(
                labelText: 'Tax Rate (%)',
                hintText: 'Enter the tax rate as a percentage (e.g., 15 for 15%)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
            const Divider(height: 40),

            // Bluetooth Section
            Text('Bluetooth Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  _adapterState == BluetoothAdapterState.on
                      ? Icons.bluetooth
                      : Icons.bluetooth_disabled,
                  color: _adapterState == BluetoothAdapterState.on ? Colors.blue : Colors.red,
                ),
                const SizedBox(width: 10),
                Text(_adapterState == BluetoothAdapterState.on
                    ? 'Bluetooth is ON'
                    : 'Bluetooth is OFF'),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _adapterState == BluetoothAdapterState.on ? _startScan : null,
              child: const Text('Search for Bluetooth Devices'),
            ),
            const SizedBox(height: 20),
            _scanResults.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Devices:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ..._scanResults.map((result) {
                  return ListTile(
                    title: Text(result.device.name.isNotEmpty
                        ? result.device.name
                        : 'Unnamed Device'),
                    subtitle: Text(result.device.remoteId.toString()),
                    trailing: ElevatedButton(
                      onPressed: () => _connectToDevice(result.device),
                      child: const Text('Connect'),
                    ),
                  );
                }).toList(),
              ],
            )
                : const Text('No devices found.'),
            const SizedBox(height: 20),
            _connectedDevice != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connected Device:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(_connectedDevice!.name.isNotEmpty
                      ? _connectedDevice!.name
                      : 'Unnamed Device'),
                  subtitle: Text(_connectedDevice!.remoteId.toString()),
                ),
              ],
            )
                : const Text('No device connected.'),
          ],
        ),
      ),
    );
  }
}
