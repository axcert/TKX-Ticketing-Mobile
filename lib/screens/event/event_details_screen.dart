import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:tkx_ticketing/widgets/offline_indicator.dart';
import 'package:tkx_ticketing/widgets/bluetooth_scanner_status_widget.dart';

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
    return Column(
      children: [
        // Offline Indicator at the very top
        const OfflineIndicator(),
        // Main Scaffold
        Expanded(
          child: Scaffold(
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
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: AppColors.background,
                ),
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                // Top Section (Fixed Header + Stats)
                Stack(
                  children: [
                    Container(height: 60, color: AppColors.primary),
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: EventCard(event: widget.event),
                        ),
                        const SizedBox(height: 24),

                        // Event Statistics
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Event Statistics',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
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
                                      _isLoadingStatistics
                                          ? 'Loading...'
                                          : 'Refresh',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
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
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
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
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
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
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
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
                                        ' ${_statisticsError!}\n Event statistics will appear once the connection is restored.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: AppColors.error),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton(
                                        onPressed: _fetchEventStatistics,
                                        child: Text(
                                          'Try Again',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                color: _isLoadingStatistics
                                                    ? Colors.grey
                                                    : AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (_eventStatistics != null)
                                EventStatisticWidget(
                                  checkInCount: _eventStatistics!.checkInCount,

                                  registerCount:
                                      _eventStatistics!.registeredCount,
                                  remainingCount:
                                      _eventStatistics!.remainingCount,
                                )
                              else
                                EventStatisticWidget(
                                  checkInCount: 0,
                                  registerCount: 0,
                                  remainingCount: 0,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),

                // Bluetooth Scanner Status (shows when connected)
                const BluetoothScannerStatusWidget(),

                // Scan History Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scan History',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Expanded Scan History List
                Expanded(
                  child: _isLoadingScanHistory
                      ? const Center(child: CircularProgressIndicator())
                      : _scanHistoryError != null
                      ? Center(child: Text(_scanHistoryError!))
                      : _scanHistory.isEmpty
                      ? Padding(
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
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _scanHistory.length,
                          itemBuilder: (context, index) {
                            final scan = _scanHistory[index];
                            return _buildScanHistoryItem(scan);
                          },
                        ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.2),
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
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildBottomNavItem(
                                "manual_check-in.svg",
                                'Manual Lookup',
                                false,
                                onTap: () {
                                  showManualCheckInBottomSheet(
                                    context,
                                    widget.event.id,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 80),
                            Expanded(
                              child: _buildBottomNavItem(
                                "External_scanner.svg",
                                'External Scanner',
                                false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BluetoothScannerSetupScreen(
                                            eventId: widget.event.id,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 35,
                        top: -15,
                        child: GestureDetector(
                          onTap: () {
                            if (widget.event.isUpcoming) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScanNotAvailableScreen(
                                    event: widget.event,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QRScannerScreen(eventId: widget.event.id),
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
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.background,
                                  size: 28,
                                ),
                                Text(
                                  'Camera',
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: AppColors.background,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanHistoryItem(ScanHistory scan) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (scan.status) {
      case 'Checked-In':
        statusColor = AppColors.success;
        statusBgColor = const Color.fromARGB(255, 179, 236, 182);
        statusIcon = Icons.check_circle;
        break;
      case 'Already Checked-In':
        statusColor = AppColors.warning;
        statusBgColor = const Color.fromARGB(255, 255, 225, 172);
        statusIcon = Icons.warning;
        break;
      case 'Invalid':
        statusColor = AppColors.error;
        statusBgColor = const Color.fromARGB(255, 255, 190, 200);
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: SvgPicture.asset('assets/icons/tickets.svg'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.ticketId,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scan.name,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
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
                                .copyWith(
                                  fontSize: 14,
                                  color: statusColor,
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.timeFormat(),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          scan.isVip
              ? Positioned(
                  top: -9,
                  left: 25,
                  child: Container(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset('assets/icons/VIP Badge.svg'),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    String icon,
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
          SvgPicture.asset(
            "assets/icons/$icon",
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
