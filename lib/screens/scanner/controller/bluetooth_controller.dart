import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class BluetoothController extends GetxController {
  final FlutterBlueClassic _flutterBlueClassic = FlutterBlueClassic();

  RxBool isScanning = false.obs;
  RxBool isBluetoothOn = false.obs;

  StreamSubscription? _scanSubscription;
  StreamSubscription? _stateSubscription;

  // List to store discovered devices
  RxList<BluetoothDevice> discoveredDevices = <BluetoothDevice>[].obs;

  Future<void> scanDevices() async {
    // Check permissions
    // Android 12+ usually deals with BLE permissions, but for Classic we need BLUETOOTH_CONNECT/SCAN
    // and Location for older devices.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if ((statuses[Permission.bluetoothScan]?.isGranted ?? false) ||
        (statuses[Permission.location]?.isGranted ?? false)) {
      try {
        isScanning.value = true;
        discoveredDevices.clear(); // Clear previous results

        _flutterBlueClassic.startScan();

        // Auto stop after timeout since classic scan drains battery and is heavy
        Future.delayed(const Duration(seconds: 30), () {
          stopScan();
        });
      } catch (e) {
        print('Error starting scan: $e');
        isScanning.value = false;
      }
    } else {
      print('Bluetooth permissions not granted');
    }
  }

  void stopScan() async {
    _flutterBlueClassic.stopScan();
    isScanning.value = false;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await _flutterBlueClassic.connect(device.address);
    // Note: Logic for managing connection stream would go here
  }

  @override
  void onInit() {
    super.onInit();

    // Check initial state
    // isBluetoothAvailable returns a Future<bool>, so we must await it or use then
    // isBluetoothAvailable returns a Future<bool>, so we must await it or use then

    // Initial Scan if available
    Future.delayed(const Duration(seconds: 1), () {
      if (isBluetoothOn.value) {
        scanDevices();
      }
    });

    // Listen to scan results
    _scanSubscription = _flutterBlueClassic.scanResults.listen((device) {
      if (!discoveredDevices.any((d) => d.address == device.address)) {
        discoveredDevices.add(device);
      }
    });

    // Listen to scanning status (if available, otherwise we manage manually)
    _flutterBlueClassic.isScanning.listen((scanning) {
      isScanning.value = scanning;
    });
  }

  @override
  void onClose() {
    _scanSubscription?.cancel();
    _stateSubscription?.cancel();
    super.onClose();
  }
}
