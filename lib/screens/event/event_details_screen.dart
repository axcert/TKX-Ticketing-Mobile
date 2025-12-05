import 'package:flutter/material.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/screens/event/scan_not_available_screen.dart';
import 'package:tkx_ticketing/widgets/event_card.dart';
import 'package:tkx_ticketing/widgets/event_statistic.dart';
import 'package:tkx_ticketing/models/event_model.dart';
import 'package:tkx_ticketing/models/event_statistics_model.dart';
import 'package:tkx_ticketing/models/scan_history_model.dart';
import 'package:tkx_ticketing/services/event_service.dart';
import 'package:tkx_ticketing/widgets/manual_checkin_bottom_sheet.dart';
import 'package:tkx_ticketing/widgets/ticket_details_bottom_sheet.dart';
import 'package:tkx_ticketing/screens/scanner/bluetooth_scanner_setup_screen.dart';
import 'package:tkx_ticketing/screens/scanner/qr_scanner_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventService _eventService = EventService();
  EventStatistics? _eventStatistics;
  bool _isLoadingStatistics = false;
  String? _statisticsError;

  List<ScanHistory> _scanHistory = [];
  bool _isLoadingScanHistory = false;
  String? _scanHistoryError;

  @override
  void initState() {
    super.initState();
    _fetchEventStatistics();
    _fetchScanHistory();
  }

  /// Fetch event statistics from the API
  Future<void> _fetchEventStatistics() async {
    setState(() {
      _isLoadingStatistics = true;
      _statisticsError = null;
    });

    try {
      final response = await _eventService.getEventStatistics(widget.event.id);

      if (response.success && response.data != null) {
        setState(() {
          _eventStatistics = response.data;
          _isLoadingStatistics = false;
        });
      } else {
        setState(() {
          _statisticsError = response.message ?? 'Failed to load statistics';
          _isLoadingStatistics = false;
        });
      }
    } catch (e) {
      setState(() {
        _statisticsError = 'An error occurred: $e';
        _isLoadingStatistics = false;
      });
    }
  }

  /// Fetch scan history from the API
  Future<void> _fetchScanHistory() async {
    setState(() {
      _isLoadingScanHistory = true;
      _scanHistoryError = null;
    });

    try {
      final response = await _eventService.getScanHistory(widget.event.id);

      if (response.success && response.data != null) {
        setState(() {
          _scanHistory = response.data!;
          _isLoadingScanHistory = false;
        });
      } else {
        setState(() {
          _scanHistoryError = response.message ?? 'Failed to load scan history';
          _isLoadingScanHistory = false;
        });
      }
    } catch (e) {
      setState(() {
        _scanHistoryError = 'An error occurred: $e';
        _isLoadingScanHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.background),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.event.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(color: AppColors.background),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue background area
            Container(height: 60, color: AppColors.primary),

            // Event Info Card (overlapping)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: EventCard(event: widget.event),
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
                            Text(
                              'Event Statistics',
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextButton.icon(
                              onPressed: _isLoadingStatistics
                                  ? null
                                  : _fetchEventStatistics,
                              icon: Icon(
                                Icons.refresh,
                                size: 18,
                                color: _isLoadingStatistics
                                    ? Colors.grey
                                    : AppColors.primary,
                              ),
                              label: Text(
                                _isLoadingStatistics ? 'Loading...' : 'Refresh',
                                style: Theme.of(context).textTheme.labelLarge!
                                    .copyWith(
                                      color: _isLoadingStatistics
                                          ? Colors.grey
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Statistics Card
                        if (_isLoadingStatistics)
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_statisticsError != null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _statisticsError!,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: AppColors.error),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _fetchEventStatistics,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          )
                        else if (_eventStatistics != null)
                          EventStatisticWidget(
                            checkInCount: _eventStatistics!.checkInCount,
                            invalidCount: _eventStatistics!.invalidCount,
                            registerCount: _eventStatistics!.registeredCount,
                            remainingCount: _eventStatistics!.remainingCount,
                          )
                        else
                          EventStatisticWidget(
                            checkInCount: 0,
                            invalidCount: 0,
                            registerCount: 0,
                            remainingCount: 0,
                          ),
                      ],
                    ),
                  ),

                  // Scan History Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Scan History',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scan History List with loading/error states
                  if (_isLoadingScanHistory)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (_scanHistoryError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _scanHistoryError!,
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _fetchScanHistory,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_scanHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              color: AppColors.border,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No scan history available',
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: AppColors.border,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
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
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
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
                            showBluetoothScannerBottomSheet(context);
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
                            builder: (context) =>
                                ScanNotAvailableScreen(event: widget.event),
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
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.6),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.background,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                // Camera label below
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 35,
                  bottom: 10,
                  child: SizedBox(
                    width: 70,
                    child: Text(
                      'Camera',
                      style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildScanHistoryItem(ScanHistory scan) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (scan.status) {
      case 'Checked-In':
        statusColor = AppColors.success;
        statusBgColor = Colors.green.shade50;
        statusIcon = Icons.check_circle;
        break;
      case 'Already Checked-In':
        statusColor = AppColors.warning;
        statusBgColor = Colors.orange.shade50;
        statusIcon = Icons.warning;
        break;
      case 'Invalid':
        statusColor = AppColors.error;
        statusBgColor = Colors.red.shade50;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.border;
        statusBgColor = Colors.grey.shade50;
        statusIcon = Icons.info;
    }

    return GestureDetector(
      onTap: () {
        showTicketDetailsBottomSheet(context, scan.toJson());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // VIP Badge or Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scan.isVip
                    ? Colors.yellow.shade100
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: scan.isVip
                    ? Text(
                        'VIP',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge!.copyWith(fontSize: 12),
                      )
                    : Icon(
                        Icons.confirmation_number_outlined,
                        color: AppColors.border,
                        size: 24,
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
                    scan.ticketId,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scan.name,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            // Status and Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        scan.status,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(fontSize: 11, color: statusColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scan.time,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium!.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.border,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: isActive ? AppColors.primary : AppColors.border,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
