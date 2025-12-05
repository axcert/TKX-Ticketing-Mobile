import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
  RxBool isScanning = false.obs;
  Rx<BluetoothAdapterState> adapterState = BluetoothAdapterState.unknown.obs;

  // Check if Bluetooth is turned on
  Future<bool> isBluetoothOn() async {
    return adapterState.value == BluetoothAdapterState.on;
  }

  Future<void> scanDevices() async {
    // Check if Bluetooth is on before scanning
    if (!await isBluetoothOn()) {
      print('Bluetooth is not enabled');
      return;
    }

    // Check permissions
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      // Stop any existing scan first
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        print('Error stopping scan: $e');
      }

      // Wait a bit before starting new scan
      await Future.delayed(const Duration(milliseconds: 100));

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      print('Started scanning for devices...');
    } else {
      print('Bluetooth permissions not granted');
    }
  }

  Stream<List<ScanResult>> get ScanResults => FlutterBluePlus.scanResults;

  @override
  void onInit() {
    super.onInit();

    // Listen to Bluetooth adapter state changes
    FlutterBluePlus.adapterState.listen((state) {
      adapterState.value = state;
      update();

      // Auto-scan when Bluetooth is turned on
      if (state == BluetoothAdapterState.on && !isScanning.value) {
        scanDevices();
      }
    });

    // Listen to scan state from plugin (better & accurate)
    FlutterBluePlus.isScanning.listen((scanning) {
      isScanning.value = scanning;
      update();
    });

    // Trigger initial scan only if Bluetooth is on
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (await isBluetoothOn()) {
        scanDevices();
      }
    });
  }
}
