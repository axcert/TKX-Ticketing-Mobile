import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/models/user_model.dart';
import 'package:tkx_ticketing/providers/auth_provider.dart';
import 'package:tkx_ticketing/models/ticket_model.dart';
import 'package:tkx_ticketing/providers/event_provider.dart';
import '../../widgets/scan_history_bottom_sheet.dart';
import '../../widgets/showpreferences_dialog_box.dart';
import '../ticket/valid_ticket_screen.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tkx_ticketing/services/ticket_service.dart';
import 'package:tkx_ticketing/screens/ticket/invalid_ticket_screen.dart';
import 'package:tkx_ticketing/screens/ticket/already_checked_in_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final String? eventId;
  const QRScannerScreen({super.key, this.eventId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _isTorchOn = false;
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // Fetch scan history if eventId is available
    if (widget.eventId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EventProvider>().fetchScanHistory(widget.eventId!);
      });
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleScannedCode(String code, User user) async {
    if (user.isVibrate ?? true) {
      Vibration.vibrate(duration: 100);
    }

    if (user.isBeep ?? true) {
      try {
        await _player.play(AssetSource('invalid.mp3'));
        print("Sound played successfully");
      } catch (e) {
        print("Error playing sound: $e");
      }
    }

    _showScanResult(code);
  }

  // Ticket service for validation
  final TicketService _ticketService = TicketService();

  void _showScanResult(String code) async {
    setState(() {
      _isScanning = false;
    });
    final eventId = widget.eventId;
    if (eventId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No event ID found')),
        );
        setState(() {
          _isScanning = true;
        });
      }
      return;
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isOnline = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi,
    );
    Map<String, dynamic> ticketData;
    Widget nextScreen;

    try {
      if (isOnline) {
        final onlineResult = await _ticketService.checkInTicket(eventId, code);

        if (onlineResult['success'] == true) {
          await _ticketService.downloadTicketsForOffline(eventId);

          final tickets = await _ticketService.loadTicketsLocally(eventId);
          final ticket = tickets.cast<Ticket?>().firstWhere(
            (t) => t?.attendeePublicId == code,
            orElse: () => null,
          );

          if (ticket != null) {
            final totalCount = tickets.length;
            final checkedCount = tickets.where((t) => t.isCheckedIn).length;

            ticketData = {
              'ticketId': ticket.attendeePublicId,
              'name': ticket.attendeeName,
              'email': ticket.attendeeEmail,
              'ticketType': ticket.ticketType,
              'isVip': ticket.ticketType.toLowerCase().contains('vip'),
              'seatNo': ticket.seatNumber ?? 'N/A',
              'row': '',
              'column': '',
              'recordId': ticket.ticketId.toString(),
              'checkedCount': checkedCount.toString(),
              'totalCount': totalCount.toString(),
              'status': ticket.status,
            };
          } else {
            ticketData = {
              'ticketId': code,
              'name': 'Unknown',
              'isVip': false,
              'seatNo': 'N/A',
              'row': '',
              'column': '',
              'recordId': code,
              'checkedCount': '0',
              'totalCount': '0',
              'status': 'Unknown',
            };
          }

          if (onlineResult['status'] == 'success') {
            nextScreen = ValidTicketScreen(
              ticketData: ticketData,
              eventId: eventId,
            );
          } else if (onlineResult['status'] == 'duplicate' ||
              (ticket?.isCheckedIn ?? false)) {
            nextScreen = AlreadyCheckedInScreen(ticketData: ticketData);
          } else {
            nextScreen = InvalidTicketScreen(ticketData: ticketData);
          }

          // Add to scan history for real-time UI update
          final historyMap = {
            'attendee_public_id': ticket?.attendeePublicId ?? code,
            'attendee_name': ticket?.attendeeName ?? 'Unknown',
            'attendee_email': ticket?.attendeeEmail ?? 'N/A',
            'ticket_type': ticket?.ticketType ?? 'N/A',
            'ticket_id': ticket?.ticketId.toString() ?? 'N/A',
            'seat_number': ticket?.seatNumber ?? 'N/A',
            'status': onlineResult['status'] == 'success'
                ? 'Checked-In'
                : (onlineResult['status'] == 'duplicate' ? 'Valid' : 'Invalid'),
            'scan_time': DateTime.now().toIso8601String(),
            'scan_type': 'QR',
            'scanned_by': 'Device',
            'is_vip': ticket?.ticketType.toLowerCase().contains('vip') ?? false,
          };

          if (mounted) {
            context.read<EventProvider>().addScanToHistory(historyMap, eventId);
          }

          if (mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => nextScreen),
            );
          }
        } else {
          // Handle online check-in failure (e.g. invalid ticket)
          throw Exception(onlineResult['message'] ?? 'Invalid Ticket');
        }
      } else {
        final tickets = await _ticketService.loadTicketsLocally(eventId);

        final ticket = tickets.firstWhere(
          (t) => t.attendeePublicId == code,
          orElse: () => throw Exception('Ticket not found'),
        );

        final totalCount = tickets.length;
        final checkedCount = tickets.where((t) => t.isCheckedIn).length;

        ticketData = {
          'ticketId': ticket.attendeePublicId,
          'name': ticket.attendeeName,
          'email': ticket.attendeeEmail,
          'ticketType': ticket.ticketType,
          'isVip': ticket.ticketType.toLowerCase().contains('vip'),
          'seatNo': ticket.seatNumber ?? 'N/A',
          'row': '',
          'column': '',
          'recordId': '${ticket.ticketId}',
          'checkedCount': checkedCount.toString(),
          'totalCount': totalCount.toString(),
          'status': ticket.status,
        };

        final historyMap = {
          'attendee_public_id': ticket.attendeePublicId,
          'attendee_name': ticket.attendeeName,
          'attendee_email': ticket.attendeeEmail,
          'ticket_type': ticket.ticketType,
          'ticket_id': ticket.ticketId,
          'seat_number': ticket.seatNumber ?? 'N/A',
          'status': ticket.isCheckedIn ? 'Already Checked-In' : 'Checked-In',
          'scan_time': DateTime.now().toIso8601String(),
          'scan_type': 'QR',
          'scanned_by': 'Device',
        };

        if (mounted) {
          context.read<EventProvider>().addScanToHistory(historyMap, eventId);
        }

        if (!mounted) return;

        if (ticket.isCheckedIn) {
          nextScreen = AlreadyCheckedInScreen(ticketData: ticketData);
        } else {
          nextScreen = ValidTicketScreen(
            ticketData: ticketData,
            eventId: eventId,
          );
        }

        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        }
      }

      // 6. Handle return
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
      }
    } catch (e) {
      // Ticket not found - Show Invalid Screen

      // Add invalid scan to history
      final invalidHistoryMap = {
        'attendee_public_id': code,
        'attendee_name': 'Unknown',
        'attendee_email': 'N/A',
        'ticket_type': 'N/A',
        'ticket_id': 'N/A',
        'seat_number': 'N/A',
        'status': 'Invalid',
        'scan_time': DateTime.now().toIso8601String(),
        'scan_type': 'QR',
        'scanned_by': 'Device',
        'is_vip': false,
      };
      if (mounted) {
        context.read<EventProvider>().addScanToHistory(
          invalidHistoryMap,
          eventId,
        );
      }

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvalidTicketScreen(
              ticketData: {
                'ticketId': code,
                // We don't have other data since not found
              },
            ),
          ),
        );

        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      }
    }
  }

  // Show preferences dialog
  void _showPreferencesDialog(User user, AuthProvider authProvider) {
    ShowPreferencesDialogBox.show(
      context,
      onPreferencesChanged: (vibrateOnScan, beepOnScan, autoCheckIn) {
        authProvider.updateUserPreferences(
          isVibrate: vibrateOnScan,
          isBeep: beepOnScan,
          isAutoCheckIn: autoCheckIn,
        );
      },
    );
  }

  void _onDetect(BarcodeCapture capture, User user) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;

      if (code != null && code.isNotEmpty) {
        setState(() {
          _isScanning = false;
        });

        _handleScannedCode(code, user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          // You might want to show a loading indicator or an error message
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Camera View
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) => _onDetect(capture, user),
              ),

              // Overlay with scanning frame
              _buildScanOverlay(),

              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close Button
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // Title
                        GestureDetector(
                          onLongPress: () {
                            context.read<EventProvider>().addTestScan();
                          },
                          child: const Text(
                            'Scan Tickets',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Three-dot menu button
                        IconButton(
                          onPressed: () =>
                              _showPreferencesDialog(user, authProvider),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Info and Flash Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Position the QR code within the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Flash Toggle Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isTorchOn = !_isTorchOn;
                            });
                            cameraController.toggleTorch();
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _isTorchOn
                                      ? Colors.yellow.shade600
                                      : Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isTorchOn
                                      ? Icons.lightbulb
                                      : Icons.lightbulb_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isTorchOn
                                    ? 'Light On'
                                    : 'Touch for more light',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Scan History Button (bottom right)
              Positioned(
                bottom: 30,
                right: 20,
                child: SafeArea(
                  child: Consumer<EventProvider>(
                    builder: (context, eventProvider, _) {
                      return GestureDetector(
                        onTap: () {
                          // Show history and verify scanned
                          showScanHistoryBottomSheet(
                            context,
                            eventProvider.scanHistory,
                          );
                          // Mark as seen when opened
                          eventProvider.markScansAsSeen();
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  // Show badge only if there are unseen scans
                                  if (eventProvider.unseenScanCount > 0)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${eventProvider.unseenScanCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Scan History',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanOverlay() {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 280,
      height: 280,
    );

    return Stack(
      children: [
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ScannerOverlayPainter(scanWindow),
        ),
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              children: [
                // Top-left corner
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFF1F5CBF),
                          width: 4,
                        ),
                        left: BorderSide(
                          color: const Color(0xFF1F5CBF),
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Top-right corner
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFF1F5CBF),
                          width: 4,
                        ),
                        right: BorderSide(
                          color: const Color(0xFF1F5CBF),
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Bottom-left corner
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF1F5CBF),
                          width: 4,
                        ),
                        left: BorderSide(
                          color: const Color(0xFF1F5CBF),
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Bottom-right corner
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF1F5CBF),
                          width: 4,
                        ),
                        right: BorderSide(
                          color: const Color(0xFF1F5CBF),
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;

  ScannerOverlayPainter(this.scanWindow);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5);

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, const Radius.circular(16)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow;
  }
}

// Scanning line animation widget
class _ScanningLineAnimation extends StatefulWidget {
  const _ScanningLineAnimation();

  @override
  State<_ScanningLineAnimation> createState() => _ScanningLineAnimationState();
}

class _ScanningLineAnimationState extends State<_ScanningLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(painter: ScanLinePainter(_animation.value));
      },
    );
  }
}

// Custom painter for scanning line animation
class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F5CBF).withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final y = size.height * progress;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
