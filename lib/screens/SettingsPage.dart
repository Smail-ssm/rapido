import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _taxRateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _matriculeFiscaleController =
  TextEditingController();
  final TextEditingController _livreurNameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();

  double _currentTaxRate = 0.15; // Default tax rate
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  late final DatabaseReference _profileRef;

  @override
  void initState() {
    super.initState();
    _profileRef = FirebaseDatabase.instance
        .ref()
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('profile');
    _loadSettings();
    _initializeBluetooth();
    _fetchProfile(); // Fetch profile data when the page loads
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentTaxRate = prefs.getDouble('taxRate') ?? 0.15;
      _taxRateController.text = _currentTaxRate.toString();
    });
  }

  Future<void> _fetchProfile() async {
    try {
      final doc = await _profileRef.get();
      if (doc.exists) {
        final data = doc.value as Map<Object?, Object?>;
        setState(() {
          _addressController.text = (data['address'] ?? '') as String;
          _companyNameController.text = (data['companyName'] ?? '') as String;
          _matriculeFiscaleController.text =
          (data['matriculeFiscale'] ?? '') as String;
          _livreurNameController.text = (data['livreurName'] ?? '') as String;
          _telController.text = (data['tel'] ?? '') as String;
          _carPlateController.text = (data['carPlate'] ?? '') as String;
          _currentTaxRate = (data['taxRate'] ?? _currentTaxRate) as double;
          _taxRateController.text = _currentTaxRate.toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch profile: $e')),
      );
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final newTaxRate =
        double.tryParse(_taxRateController.text) ?? _currentTaxRate;
    await prefs.setDouble('taxRate', newTaxRate);

    try {
      await _profileRef.set({
        'address': _addressController.text,
        'companyName': _companyNameController.text,
        'matriculeFiscale': _matriculeFiscaleController.text,
        'livreurName': _livreurNameController.text,
        'tel': _telController.text,
        'carPlate': _carPlateController.text,
        'taxRate': newTaxRate,
      });

      setState(() {
        _currentTaxRate = newTaxRate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings: $e')),
      );
    }
  }

  Future<void> _initializeBluetooth() async {
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
    });

    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    setState(() {
      if (devices.isNotEmpty) {
        _connectedDevice = devices.first;
      }
    });
  }

  void _startScan() {
    setState(() {
      _scanResults.clear();
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Tax Rate Section
          _buildSectionTitle(context, 'Variable Settings'),
          const SizedBox(height: 10),
          _buildTextField(_taxRateController, 'Tax Rate (%)', '15 for 15%', isNumeric: true),
          const Divider(height: 40),

          // User Info Section
          _buildSectionTitle(context, 'User Information'),
          const SizedBox(height: 10),
          _buildTextField(_addressController, 'Address', 'Enter your address'),
          _buildTextField(
              _companyNameController, 'Company Name', 'Enter your company name'),
          _buildTextField(_matriculeFiscaleController, 'Matricule Fiscale', 'Enter your fiscal ID'),
          _buildTextField(_livreurNameController, 'Livreur Name', 'Enter livreur name'),
          _buildTextField(_telController, 'Telephone', 'Enter phone number', isNumeric: true),
          _buildTextField(_carPlateController, 'Car Plate', 'Enter car plate number'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
          const Divider(height: 40),

          // Bluetooth Section
          _buildSectionTitle(context, 'Bluetooth Settings'),
          const SizedBox(height: 10),
          _buildBluetoothStatus(),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _adapterState == BluetoothAdapterState.on ? _startScan : null,
            child: const Text('Search for Bluetooth Devices'),
          ),
          const SizedBox(height: 20),
          _buildBluetoothScanResults(),
          const SizedBox(height: 20),
          _buildConnectedDeviceInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildBluetoothStatus() {
    return Row(
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
    );
  }

  Widget _buildBluetoothScanResults() {
    if (_scanResults.isEmpty) {
      return const Text('No devices found.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Devices:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
    );
  }

  Widget _buildConnectedDeviceInfo() {
    if (_connectedDevice == null) {
      return const Text('No device connected.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connected Device:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        ListTile(
          title: Text(_connectedDevice!.name.isNotEmpty
              ? _connectedDevice!.name
              : 'Unnamed Device'),
          subtitle: Text(_connectedDevice!.remoteId.toString()),
        ),
      ],
    );
  }
}
