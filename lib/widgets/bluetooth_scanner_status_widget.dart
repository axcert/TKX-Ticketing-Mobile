import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkx_ticketing/services/bluetooth_scanner_service.dart';

class BluetoothScannerStatusWidget extends StatelessWidget {
  const BluetoothScannerStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BluetoothScannerService>(
      init: BluetoothScannerService(),
      builder: (service) {
        return Obx(() {
          if (!service.isConnected.value) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Connection indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bluetooth_connected,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Device name and stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.connectedDeviceName.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ready to Scan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Disconnect button
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.red,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Disconnect Scanner'),
                        content: const Text(
                          'Are you sure you want to disconnect the Bluetooth scanner?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              service.disconnect();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Disconnect'),
                          ),
                        ],
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
