import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/models/scan_history_model.dart';
import 'package:tkx_ticketing/providers/event_provider.dart';
import 'package:tkx_ticketing/widgets/ticket_details_bottom_sheet.dart';
import 'package:provider/provider.dart';

class ScanHistoryBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> scanHistory;

  const ScanHistoryBottomSheet({super.key, required this.scanHistory});

  @override
  State<ScanHistoryBottomSheet> createState() => _ScanHistoryBottomSheetState();
}

class _ScanHistoryBottomSheetState extends State<ScanHistoryBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final statistics = eventProvider.eventStatistics;
        final scanHistory = eventProvider.scanHistory;

        return DraggableScrollableSheet(
          controller: _controller,
          initialChildSize: 0.4,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan History',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${statistics?.checkInCount ?? 0}/${statistics?.registeredCount ?? 0}',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Scan History List
                  Expanded(
                    child: scanHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No scan history yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: scanHistory.length,
                            itemBuilder: (context, index) {
                              final scan = ScanHistory.fromJson(
                                scanHistory[index],
                              );
                              return _buildScanHistoryItem(scan);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScanHistoryItem(ScanHistory scan) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (scan.status.toLowerCase().trim()) {
      case 'checked-in':
      case 'checked in':
      case 'valid':
      case 'active':
      case 'success':
        statusColor = AppColors.success;
        statusBgColor = Colors.green.shade50;
        statusIcon = Icons.check_circle;
        break;
      case 'already checked-in':
      case 'already checked in':
      case 'invalid':
      case 'used':
      case 'duplicate':
      case 'failed':
        statusColor = AppColors.error;
        statusBgColor = Colors.red.shade50;
        statusIcon = Icons.cancel;
        break;
      case 'cancelled':
      case 'canceled':
        statusColor = AppColors.warning;
        statusBgColor = Colors.yellow.shade50;
        statusIcon = Icons.info_outline;
        break;
      default:
        statusColor = AppColors.error;
        statusBgColor = Colors.red.shade50;
        statusIcon = Icons.help_outline;
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // VIP Badge or Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset('assets/icons/tickets.svg'),
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
                // Status and Time
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
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
}

// Function to show the scan history bottom sheet
void showScanHistoryBottomSheet(
  BuildContext context,
  List<Map<String, dynamic>> scanHistory,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    builder: (context) => ScanHistoryBottomSheet(scanHistory: scanHistory),
  );
}
