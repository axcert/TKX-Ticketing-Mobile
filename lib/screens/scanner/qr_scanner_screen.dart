import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../widgets/scan_history_bottom_sheet.dart';
import '../ticket/valid_ticket_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _isTorchOn = false;

  // Scanner preferences
  bool _vibrateOnScan = true;
  bool _beepOnScan = false;
  bool _autoCheckIn = false;

  // Sample scan history data
  final List<Map<String, dynamic>> _scanHistory = [
    {
      'ticketId': 'TCK1234',
      'name': 'Nimali Silva',
      'time': '06:02 PM',
      'status': 'Checked-In',
      'isVip': true,
    },
    {
      'ticketId': 'TCK1234',
      'name': 'Elena Martinez',
      'time': '06:02 PM',
      'status': 'Checked-In',
      'isVip': false,
    },
    {
      'ticketId': 'TCK1234',
      'name': 'Kamal Silva',
      'time': '06:02 PM',
      'status': 'Checked-In',
      'isVip': false,
    },
  ];

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;

      if (code != null && code.isNotEmpty) {
        setState(() {
          _isScanning = false;
        });

        // Show scanned result
        _showScanResult(code);
      }
    }
  }

  void _showScanResult(String code) async {
    // Parse the scanned code and create ticket data
    // In a real app, you would fetch this from an API
    final ticketData = {
      'ticketId': code,
      'name': 'Nadeesha Perera',
      'isVip': true,
      'seatNo': 'A31',
      'row': 'A',
      'column': '31',
      'recordId': '#0012',
      'checkedCount': '325',
      'totalCount': '500',
    };

    // Navigate to valid ticket screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ValidTicketScreen(ticketData: ticketData),
      ),
    );

    // If check-in was completed, close scanner
    // Otherwise, resume scanning
    if (result == true) {
      // Check-in completed, close scanner
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      // User cancelled, resume scanning
      setState(() {
        _isScanning = true;
      });
    }
  }

  void _showPreferencesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Scanner Preferences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Horizontal divider
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      height: 1,
                    ),

                    const SizedBox(height: 16),

                    // Vibrate option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vibrate',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vibrate if scan is successful',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _vibrateOnScan,
                          onChanged: (value) {
                            setState(() {
                              this.setState(() {
                                _vibrateOnScan = value;
                              });
                            });
                          },
                          activeTrackColor: const Color(0xFF1F5CBF),
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: const WidgetStatePropertyAll(Colors.white),
                          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Horizontal divider
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      height: 1,
                    ),

                    const SizedBox(height: 16),

                    // Beep option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Beep',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Beep if scan is successful',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _beepOnScan,
                          onChanged: (value) {
                            setState(() {
                              this.setState(() {
                                _beepOnScan = value;
                              });
                            });
                          },
                          activeTrackColor: const Color(0xFF1F5CBF),
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: const WidgetStatePropertyAll(Colors.white),
                          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Horizontal divider
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      height: 1,
                    ),

                    const SizedBox(height: 16),

                    // Auto Check-in option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Auto Check-in',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Scans check in automatically',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoCheckIn,
                          onChanged: (value) {
                            setState(() {
                              this.setState(() {
                                _autoCheckIn = value;
                              });
                            });
                          },
                          activeTrackColor: const Color(0xFF1F5CBF),
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: const WidgetStatePropertyAll(Colors.white),
                          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
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
                    const Text(
                      'Scan Tickets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Three-dot menu button
                    IconButton(
                      onPressed: _showPreferencesDialog,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
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
                                  : Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isTorchOn ? Icons.lightbulb : Icons.lightbulb_outline,
                              color: _isTorchOn ? Colors.white : Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isTorchOn ? 'Light On' : 'Touch for more light',
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
              child: GestureDetector(
                onTap: () {
                  showScanHistoryBottomSheet(context, _scanHistory);
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
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
                          if (_scanHistory.isNotEmpty)
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
                                    '${_scanHistory.length}',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Transparent center area for scanning
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            // Corner decorations
            SizedBox(
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
                          top: BorderSide(color: const Color(0xFF1F5CBF), width: 4),
                          left: BorderSide(color: const Color(0xFF1F5CBF), width: 4),
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
                          top: BorderSide(color: const Color(0xFF1F5CBF), width: 4),
                          right: BorderSide(color: const Color(0xFF1F5CBF), width: 4),
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
                          bottom: BorderSide(color: const Color(0xFF1F5CBF), width: 4),
                          left: BorderSide(color: const Color(0xFF1F5CBF), width: 4),
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
                          bottom: BorderSide(color: const Color(0xFF1F5CBF), width: 4),
                          right: BorderSide(color: const Color(0xFF1F5CBF), width: 4),
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

            // Scanning line animation
            if (_isScanning)
              SizedBox(
                width: 280,
                height: 280,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _ScanningLineAnimation(),
                ),
              ),
          ],
        ),
      ),
    );
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
        return CustomPaint(
          painter: ScanLinePainter(_animation.value),
        );
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
      ..color = const Color(0xFF1F5CBF).withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final y = size.height * progress;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
