import 'package:flutter/material.dart';

class BluetoothScannerSetupScreen extends StatefulWidget {
  const BluetoothScannerSetupScreen({super.key});

  @override
  State<BluetoothScannerSetupScreen> createState() => _BluetoothScannerSetupScreenState();
}

class _BluetoothScannerSetupScreenState extends State<BluetoothScannerSetupScreen> {
  bool _isSearching = true;

  // Sample available devices
  final List<Map<String, String>> _availableDevices = [
    {'name': 'Scanner_01'},
    {'name': 'Scanner_02'},
  ];

  @override
  void initState() {
    super.initState();
    // Simulate searching animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _handleRescan() {
    setState(() {
      _isSearching = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _handleConnectDevice(String deviceName) {
    // Handle device connection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connecting...'),
        content: Text('Connecting to $deviceName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bluetooth Scanner Setup',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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

              // Devices List
              if (_isSearching)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F5CBF)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Scanning...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = _availableDevices[index];
                    return _buildDeviceItem(device['name']!);
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
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 20),

              // Rescan Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleRescan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F5CBF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Rescan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceItem(String deviceName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Device Name
          Text(
            deviceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          // Tap to Connect Button
          GestureDetector(
            onTap: () => _handleConnectDevice(deviceName),
            child: Row(
              children: [
                const Text(
                  'Tap to Connect',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F5CBF),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.bluetooth,
                  size: 18,
                  color: Color(0xFF1F5CBF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
