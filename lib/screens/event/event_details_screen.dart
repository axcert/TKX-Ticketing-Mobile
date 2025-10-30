import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../widgets/manual_checkin_bottom_sheet.dart';
import '../../widgets/ticket_details_bottom_sheet.dart';
import '../scanner/bluetooth_scanner_setup_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import 'scan_not_available_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  // Sample scan history data
  final List<Map<String, dynamic>> _scanHistory = [
    {
      'ticketId': 'TCK-98432',
      'name': 'Nadeesha Perera',
      'time': '06:02 PM',
      'status': 'Checked-In',
      'isVip': true,
      'ticketType': 'VIP',
      'seatNo': 'A12',
      'row': 'A',
      'column': '12',
      'recordId': '#0012',
      'scanTime': '10:32 AM, Oct 08, 2025',
      'scanType': 'Camera',
      'scannedBy': 'Kasun',
    },
    {
      'ticketId': 'TCK-78945',
      'name': 'Elena Martinez',
      'time': '06:02 PM',
      'status': 'Checked-In',
      'isVip': false,
      'ticketType': 'Regular',
      'seatNo': 'B15',
      'row': 'B',
      'column': '15',
      'recordId': '#0013',
      'scanTime': '10:35 AM, Oct 08, 2025',
      'scanType': 'Camera',
      'scannedBy': 'Kasun',
    },
    {
      'ticketId': 'TCK-65478',
      'name': 'Kamal Silva',
      'time': '06:02 PM',
      'status': 'Checked-In',
      'isVip': true,
      'ticketType': 'VIP',
      'seatNo': 'A10',
      'row': 'A',
      'column': '10',
      'recordId': '#0014',
      'scanTime': '10:40 AM, Oct 08, 2025',
      'scanType': 'Scanner',
      'scannedBy': 'Admin',
    },
    {
      'ticketId': 'TCK-91014',
      'name': 'Elena Martinez',
      'time': '06:30 PM',
      'status': 'Already Checked-In',
      'isVip': false,
      'ticketType': 'Regular',
      'seatNo': 'C20',
      'row': 'C',
      'column': '20',
      'recordId': '#0015',
      'scanTime': '10:45 AM, Oct 08, 2025',
      'scanType': 'Camera',
      'scannedBy': 'Kasun',
    },
    {
      'ticketId': 'TCK-56789',
      'name': 'N/A',
      'time': '06:15 PM',
      'status': 'Invalid',
      'isVip': false,
      'ticketType': 'N/A',
      'seatNo': 'N/A',
      'row': 'N/A',
      'column': 'N/A',
      'recordId': '#0016',
      'scanTime': '10:50 AM, Oct 08, 2025',
      'scanType': 'Camera',
      'scannedBy': 'Kasun',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5CBF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue background area
            Container(
              height: 60,
              color: const Color(0xFF1F5CBF),
            ),

            // Event Info Card (overlapping)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                          // Event Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              widget.event.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F5CBF).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.event,
                                    size: 30,
                                    color: Color(0xFF1F5CBF),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Event Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.event.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: Color(0xFF6B7280)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.event.formattedDateTime,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 12, color: Color(0xFF6B7280)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${widget.event.venue} - ${widget.event.location}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                            ],
                          ),
                        ),

                        // Ongoing Badge positioned at top-right on the border
                        Positioned(
                          top: -10,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF10B981),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Ongoing',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Event Statistics Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Event Statistics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle refresh
                        },
                        icon: const Icon(
                          Icons.sync,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F5CBF),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Statistics Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        // Progress Circle (Left side)
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(
                                  value: 0.68,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green,
                                  ),
                                ),
                              ),
                              const Text(
                                '68%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Middle Column (Registered & Remaining)
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // First row: Registered
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '500',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Registered',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Second row: Remaining
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '160',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Remaining',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Right Column (Checked-In & Invalid)
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // First row: Checked-In
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '340',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Checked-In',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Second row: Invalid
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '8',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Invalid',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

                  // Scan History Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Scan History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scan History List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _scanHistory.length,
                    itemBuilder: (context, index) {
                      final scan = _scanHistory[index];
                      return _buildScanHistoryItem(scan);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 80,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bottom bar background
                Container(
                  height: 80,
                  color: Colors.white,
                ),

                // Navigation items
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Manual Lookup
                      Expanded(
                        child: _buildBottomNavItem(
                          Icons.search,
                          'Manual Lookup',
                          false,
                          onTap: () {
                            showManualCheckInBottomSheet(context);
                          },
                        ),
                      ),

                      // Spacer for center camera button
                      const SizedBox(width: 80),

                      // External Scanner
                      Expanded(
                        child: _buildBottomNavItem(
                          Icons.qr_code_scanner_outlined,
                          'External Scanner',
                          false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BluetoothScannerSetupScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Elevated Camera Button in center
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 35,
                  top: -15,
                  child: GestureDetector(
                    onTap: () {
                      // Check if event is upcoming (scan not available)
                      if (widget.event.isUpcoming) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanNotAvailableScreen(event: widget.event),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F5CBF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1F5CBF).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                // Camera label below
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 35,
                  bottom: 8,
                  child: const SizedBox(
                    width: 70,
                    child: Text(
                      'Camera',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1F5CBF),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanHistoryItem(Map<String, dynamic> scan) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (scan['status']) {
      case 'Checked-In':
        statusColor = Colors.green;
        statusBgColor = Colors.green.shade50;
        statusIcon = Icons.check_circle;
        break;
      case 'Already Checked-In':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.shade50;
        statusIcon = Icons.warning;
        break;
      case 'Invalid':
        statusColor = Colors.red;
        statusBgColor = Colors.red.shade50;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.shade50;
        statusIcon = Icons.info;
    }

    return GestureDetector(
      onTap: () {
        showTicketDetailsBottomSheet(context, scan);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Ticket Icon (rounded circle)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
          // Ticket Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan['ticketId'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scan['name'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Status and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scan['status'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scan['time'],
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
                ],
              ),
            ),

            // VIP Badge positioned at top-left corner
            if (scan['isVip'] == true)
              Positioned(
                top: -4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    'VIP',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF1F5CBF) : Colors.grey.shade600,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xFF1F5CBF) : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
