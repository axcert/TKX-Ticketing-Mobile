import 'dart:async';

import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/widgets/custom_elevated_button.dart';
import 'package:app_settings/app_settings.dart';

class BluetoothScannerBottomSheet extends StatefulWidget {
  const BluetoothScannerBottomSheet({super.key});

  @override
  State<BluetoothScannerBottomSheet> createState() =>
      _BluetoothScannerBottomSheetState();
}

class _BluetoothScannerBottomSheetState
    extends State<BluetoothScannerBottomSheet>
    with WidgetsBindingObserver {
  final _flutterBlueClassicPlugin = FlutterBlueClassic();

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription? _adapterStateSubscription;

  final Set<BluetoothDevice> _scanResults = {};
  StreamSubscription? _scanSubscription;

  bool _isScanning = false;
  int? _connectingToIndex;
  StreamSubscription? _scanningStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    // Start scan automatically when opened
    // Small delay to ensure platform state is ready
    Future.delayed(const Duration(milliseconds: 500), _startScan);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanningStateSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app resumes (e.g., returning from Bluetooth settings), refresh the device list
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        // Small delay to ensure Bluetooth state is updated
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _startScan();
        });
      }
    }
  }

  Future<void> initPlatformState() async {
    BluetoothAdapterState adapterState = _adapterState;

    try {
      adapterState = await _flutterBlueClassicPlugin.adapterStateNow;
      _adapterStateSubscription = _flutterBlueClassicPlugin.adapterState.listen(
        (current) {
          if (mounted) setState(() => _adapterState = current);
        },
      );
      _scanSubscription = _flutterBlueClassicPlugin.scanResults.listen((
        device,
      ) {
        if (mounted) setState(() => _scanResults.add(device));
      });
      _scanningStateSubscription = _flutterBlueClassicPlugin.isScanning.listen((
        isScanning,
      ) {
        if (mounted) setState(() => _isScanning = isScanning);
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }

    if (!mounted) return;

    setState(() {
      _adapterState = adapterState;
    });
  }

  void _startScan() {
    if (mounted) {
      setState(() {
        _scanResults.clear();
      });
    }
    _flutterBlueClassicPlugin.startScan();
  }

  void _showBluetoothOffDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bluetooth_disabled, color: AppColors.error),
            const SizedBox(width: 12),
            const Text('Bluetooth is Off'),
          ],
        ),
        content: const Text(
          'Please turn on Bluetooth to scan for nearby devices.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingDevices() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'Searching for devices...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we scan for nearby Bluetooth devices.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothOffWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bluetooth is Off',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please turn on Bluetooth to scan for nearby devices.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem({
    required BluetoothDevice device,
    required String name,
    required String id,
    String? rssi,
    bool isScanner = false,
  }) {
    return GestureDetector(
      onLongPress: () async {
        // Only show unpair option for bonded devices
        if (device.bondState == BluetoothBondState.bonded) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Unpair Device"),
                content: Text(
                  "To unpair '${device.name ?? 'this device'}', please go to your device's Bluetooth settings.\n\nNote: Programmatic unpairing is restricted by Android for security reasons.",
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text("Open Settings"),
                    onPressed: () async {
                      Navigator.pop(context);
                      // Open Bluetooth settings
                      await AppSettings.openAppSettings(
                        type: AppSettingsType.bluetooth,
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      onTap: () async {
        await _connectToDevice(device);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              isScanner ? Icons.qr_code_scanner : Icons.bluetooth,
              color: AppColors.primary,
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            id,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$rssi dBm',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    BluetoothConnection? connection;
    try {
      if (mounted) setState(() => _connectingToIndex = 1); // Loading state

      // Stop scanning before connecting - crucial for stable connection
      _flutterBlueClassicPlugin.stopScan();

      if (device.bondState != BluetoothBondState.bonded) {
        if (kDebugMode) print("Bonding with ${device.name}...");
        await _flutterBlueClassicPlugin.bondDevice(device.address);
      }

      // Add a small delay after bonding/stop scan to let the stack settle
      await Future.delayed(const Duration(milliseconds: 500));

      print("Connecting to ${device.address}...");
      connection = await _flutterBlueClassicPlugin.connect(device.address);

      if (!mounted) return;

      if (connection != null && connection.isConnected) {
        if (kDebugMode) print("Connected to ${device.name}");
        Navigator.pop(context); // Close bottom sheet on success
      }
    } catch (e) {
      if (mounted) setState(() => _connectingToIndex = null);
      if (kDebugMode) print(e);
      connection?.dispose();

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text("Error connecting to device")),
      );
    } finally {
      if (mounted) setState(() => _connectingToIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Builder(
        builder: (context) {
          if (_adapterState == BluetoothAdapterState.off) {
            return _buildBluetoothOffWidget();
          }

          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Text(
                            _isScanning ? 'Scanning...' : 'Available Devices',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (!_isScanning)
                        Text(
                          'Make sure your scanner is turned on and in pairing mode.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: _scanResults.isEmpty && _isScanning
                            ? _buildSearchingDevices()
                            : _scanResults.isEmpty
                            ? const Center(
                                child: Text(
                                  "No Devices Found",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final bonded = _scanResults
                                          .where(
                                            (d) =>
                                                d.bondState ==
                                                BluetoothBondState.bonded,
                                          )
                                          .toList();
                                      final available = _scanResults
                                          .where(
                                            (d) =>
                                                d.bondState !=
                                                BluetoothBondState.bonded,
                                          )
                                          .toList();

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (bonded.isNotEmpty) ...[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Text(
                                                "Paired Devices",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            ...bonded.map((device) {
                                              final String name =
                                                  (device.name != null &&
                                                      device.name!.isNotEmpty)
                                                  ? device.name!
                                                  : 'Unknown Device';
                                              return _buildDeviceItem(
                                                device: device,
                                                name: name,
                                                id: device.address,
                                                rssi: (device.rssi ?? 0)
                                                    .toString(),
                                              );
                                            }),
                                            const SizedBox(height: 12),
                                            const Divider(thickness: 1),
                                            const SizedBox(height: 12),
                                          ],

                                          if (available.isNotEmpty ||
                                              bonded.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Text(
                                                "Available Devices",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),

                                          if (available.isEmpty &&
                                              bonded.isNotEmpty)
                                            const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Center(
                                                child: Text(
                                                  "No new devices found",
                                                ),
                                              ),
                                            ),

                                          ...available.map((device) {
                                            final String name =
                                                (device.name != null &&
                                                    device.name!.isNotEmpty)
                                                ? device.name!
                                                : 'Unknown Device';
                                            return _buildDeviceItem(
                                              device: device,
                                              name: name,
                                              id: device.address,
                                              rssi: (device.rssi ?? 0)
                                                  .toString(),
                                            );
                                          }),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 20),

                      // Rescan Button
                      if (!_isScanning) ...[
                        CustomElevatedButton(
                          text: 'Rescan',
                          onPressed: _startScan,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void showBluetoothScannerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    builder: (context) => const BluetoothScannerBottomSheet(),
  );
}
