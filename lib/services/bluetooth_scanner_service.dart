import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tkx_ticketing/services/ticket_service.dart';
import 'package:tkx_ticketing/screens/ticket/valid_ticket_screen.dart';
import 'package:tkx_ticketing/screens/ticket/invalid_ticket_screen.dart';
import 'package:tkx_ticketing/screens/ticket/already_checked_in_screen.dart';

class BluetoothScannerService extends GetxController {
  static BluetoothScannerService get instance => Get.find();

  final TicketService _ticketService = TicketService();
  final AudioPlayer _player = AudioPlayer();

  BluetoothConnection? _connection;
  StreamSubscription? _dataSubscription;
  String _scannedData = '';
  bool _isProcessing = false;

  // Observable properties
  RxBool isConnected = false.obs;
  RxString connectedDeviceName = ''.obs;
  RxString currentEventId = ''.obs;
  RxString lastScannedCode = ''.obs;
  Rx<DateTime?> lastScanTime = Rx<DateTime?>(null);

  // User preferences
  bool enableVibration = true;
  bool enableSound = true;

  void setUserPreferences({bool? vibrate, bool? beep}) {
    if (vibrate != null) enableVibration = vibrate;
    if (beep != null) enableSound = beep;
  }

  Future<void> connectToScanner({
    required BluetoothConnection connection,
    required String deviceName,
    required String eventId,
  }) async {
    try {
      // Disconnect previous connection if exists
      await disconnect();

      _connection = connection;
      connectedDeviceName.value = deviceName;
      currentEventId.value = eventId;
      isConnected.value = true;

      // Reset state
      lastScannedCode.value = '';
      lastScanTime.value = null;

      // Start listening to data
      _listenToBluetoothData();

      print('Bluetooth scanner connected: $deviceName');
    } catch (e) {
      print('Error connecting to scanner: $e');
      await disconnect();
    }
  }

  void _listenToBluetoothData() {
    _dataSubscription = _connection?.input?.listen(
      (Uint8List data) {
        // Convert bytes to string
        String receivedData = utf8.decode(data);

        // Accumulate data until we get a complete barcode/QR code
        _scannedData += receivedData;

        // Check if we have a complete scan (ends with newline or carriage return)
        if (_scannedData.contains('\n') || _scannedData.contains('\r')) {
          // Clean up the scanned data
          String cleanedData = _scannedData
              .replaceAll('\n', '')
              .replaceAll('\r', '')
              .trim();

          if (cleanedData.isNotEmpty && !_isProcessing) {
            _handleScannedCode(cleanedData);
          }

          // Reset buffer
          _scannedData = '';
        }
      },
      onError: (error) {
        print('Bluetooth error: $error');
        disconnect();
      },
      onDone: () {
        print('Bluetooth connection closed');
        disconnect();
      },
    );
  }

  Future<void> _handleScannedCode(String code) async {
    if (_isProcessing) return;

    // Prevent duplicate scans within 2 seconds
    if (lastScannedCode.value == code && lastScanTime.value != null) {
      final difference = DateTime.now().difference(lastScanTime.value!);
      if (difference.inSeconds < 2) {
        return;
      }
    }

    _isProcessing = true;
    lastScannedCode.value = code;
    lastScanTime.value = DateTime.now();

    // Vibration feedback
    if (enableVibration) {
      Vibration.vibrate(duration: 100);
    }

    // Sound feedback
    if (enableSound) {
      try {
        await _player.play(AssetSource('invalid.mp3'));
      } catch (e) {
        print("Error playing sound: $e");
      }
    }

    await _processTicket(code);

    _isProcessing = false;
  }

  Future<void> _processTicket(String code) async {
    if (currentEventId.value.isEmpty) {
      print('No event ID set');
      return;
    }

    try {
      // 1. Load tickets locally
      final tickets = await _ticketService.loadTicketsLocally(
        currentEventId.value,
      );

      // 2. Find matching ticket
      final ticket = tickets.firstWhere(
        (t) => t.attendeePublicId == code,
        orElse: () => throw Exception('Ticket not found'),
      );

      // 3. Check stats
      final totalCount = tickets.length;
      final checkedCount = tickets.where((t) => t.isCheckedIn).length;

      // 4. Prepare data
      final ticketData = {
        'ticketId': ticket.attendeePublicId,
        'name': ticket.attendeeName,
        'isVip': ticket.ticketType.toLowerCase().contains('vip'),
        'seatNo': ticket.seatNumber ?? 'N/A',
        'row': '',
        'column': '',
        'recordId': '${ticket.ticketId}',
        'checkedCount': checkedCount.toString(),
        'totalCount': totalCount.toString(),
        'status': ticket.status,
      };

      // 5. Navigate based on status
      Widget nextScreen;

      if (ticket.isCheckedIn) {
        // Already checked in case
        nextScreen = AlreadyCheckedInScreen(ticketData: ticketData);
      } else {
        // Valid ticket - auto check-in
        try {
          // Perform automatic check-in
          final checkInResult = await _ticketService.checkInTicket(
            currentEventId.value,
            ticket.attendeePublicId,
          );

          if (checkInResult['success'] == true) {
            // Check-in success

            // Navigate to ValidTicketScreen in checked-in mode
            nextScreen = ValidTicketScreen(
              ticketData: ticketData,
              eventId: currentEventId.value,
              isCheckedIn: true,
            );
          } else {
            // Check-in failed (but valid ticket)
            // Fallback to manual check-in screen so user can try again or see error
            print('Auto check-in failed: ${checkInResult['message']}');

            nextScreen = ValidTicketScreen(
              ticketData: ticketData,
              eventId: currentEventId.value,
              isCheckedIn: false,
            );
          }
        } catch (e) {
          print('Error during auto check-in: $e');
          // Fallback to manual check-in screen
          nextScreen = ValidTicketScreen(
            ticketData: ticketData,
            eventId: currentEventId.value,
            isCheckedIn: false,
          );
        }
      }

      // Navigate with fast animation
      Get.to(
        () => nextScreen,
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 200),
      );
    } catch (e) {
      // Ticket not found - Show Invalid Screen

      Get.to(
        () => InvalidTicketScreen(ticketData: {'ticketId': code}),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  Future<void> disconnect() async {
    try {
      await _dataSubscription?.cancel();
      _connection?.dispose();

      _connection = null;
      _dataSubscription = null;
      _scannedData = '';
      _isProcessing = false;

      isConnected.value = false;
      connectedDeviceName.value = '';
      currentEventId.value = '';

      print('Bluetooth scanner disconnected');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  @override
  void onClose() {
    disconnect();
    _player.dispose();
    super.onClose();
  }
}
