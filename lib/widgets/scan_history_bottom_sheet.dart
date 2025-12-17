import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/models/scan_history_model.dart';

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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${widget.scanHistory.length}/${widget.scanHistory.length}',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                child: widget.scanHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No scan history yet',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: widget.scanHistory.length,
                        itemBuilder: (context, index) {
                          final scan = ScanHistory.fromJson(
                            widget.scanHistory[index],
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
        statusColor = Colors.orange;
        statusBgColor = const Color.fromARGB(255, 255, 225, 172);
        statusIcon = Icons.warning;
        break;
      case 'Invalid':
        statusColor = Colors.red;
        statusBgColor = const Color.fromARGB(255, 255, 190, 200);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.shade50;
        statusIcon = Icons.info;
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scan.name,
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
                    scan.dateFormat(),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ScanHistoryBottomSheet(scanHistory: scanHistory),
  );
}
