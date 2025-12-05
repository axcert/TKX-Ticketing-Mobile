import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/screens/scanner/controller/bluetooth_controller.dart';
import 'package:tkx_ticketing/widgets/custom_elevated_button.dart';

class BluetoothScannerBottomSheet extends StatefulWidget {
  const BluetoothScannerBottomSheet({super.key});

  @override
  State<BluetoothScannerBottomSheet> createState() =>
      _BluetoothScannerBottomSheetState();
}

class _BluetoothScannerBottomSheetState
    extends State<BluetoothScannerBottomSheet> {
  final BluetoothController controller = Get.put(BluetoothController());

  @override
  void initState() {
    super.initState();

    // Check Bluetooth state after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBluetoothState();
    });
  }

  void _checkBluetoothState() {
    // Listen to Bluetooth state changes
    controller.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        _showBluetoothOffDialog();
      }
    });
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
              // Note: On Android, you can't programmatically turn on Bluetooth
              // User must do it manually from settings
              // You can open Bluetooth settings if needed
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
    required BluetoothDevice deviceName,
    required String id,
    required String rssi,
  }) {
    return GestureDetector(
      onTap: () async {
        await _connectToDevice(deviceName);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(12),
        //   border: Border.all(color: Colors.grey.shade200, width: 1),
        // ),
        child: ListTile(
          title: Text(deviceName.toString()),
          subtitle: Text(id),
          trailing: Text(rssi),
        ),
      ),
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      print('Connecting to device: ${device.name}');
      await device.connect();
      print('Connected to device: ${device.name}');
      var sevices = await device.discoverServices();
      print('Discovered services: ${sevices.length}');
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  void _showSearchingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Searching...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we scan for devices.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Listen to scanning state and close dialog when scanning stops
    final scanSubscription = controller.isScanning.listen((scanning) {
      if (!scanning && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });

    // Clean up subscription when dialog is dismissed
    Future.delayed(const Duration(seconds: 6), () {
      scanSubscription.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _handleRescan() {
    _showSearchingDialog();
    controller.scanDevices();
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
      child: Obx(() {
        // Check if Bluetooth is off
        if (controller.adapterState.value == BluetoothAdapterState.off) {
          return _buildBluetoothOffWidget();
        }
        // Check if scanning
        else if (controller.isScanning.value) {
          // Show loading widget while scanning
          return _buildSearchingDevices();
        } else {
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
                      // Searching Section
                      const Text(
                        'Searching for Nearby Devices...',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Make sure your scanner is turned on and in pairing mode.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Available Devices Section
                      const Text(
                        'Available Devices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      GetBuilder<BluetoothController>(
                        builder: (controller) {
                          return Expanded(
                            child: StreamBuilder<List<ScanResult>>(
                              stream: controller.ScanResults,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final devices = snapshot.data!;
                                  if (devices.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No Devices Found',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: devices.length,
                                    itemBuilder: (context, index) {
                                      final device = devices[index];
                                      return _buildDeviceItem(
                                        deviceName: device.device,
                                        id: device.device.id.id,
                                        rssi: devices[index].rssi.toString(),
                                      );
                                    },
                                  );
                                } else {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(color: AppColors.error),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                      const Spacer(),

                      // Bottom Info and Rescan Button
                      Text(
                        'If you don\'t see your scanner, make sure it\'s nearby and try again.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Rescan Button
                      CustomElevatedButton(
                        text: 'Rescan',
                        onPressed: _handleRescan,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}

// Function to show the bottom sheet
void showBluetoothScannerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    builder: (context) => const BluetoothScannerBottomSheet(),
  );
}
