import 'package:flutter/material.dart';

class ScanHistoryBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> scanHistory;

  const ScanHistoryBottomSheet({
    super.key,
    required this.scanHistory,
  });

  @override
  State<ScanHistoryBottomSheet> createState() => _ScanHistoryBottomSheetState();
}

class _ScanHistoryBottomSheetState extends State<ScanHistoryBottomSheet> {
  final DraggableScrollableController _controller = DraggableScrollableController();

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
          decoration: const BoxDecoration(
            color: Colors.white,
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
                  color: Colors.grey.shade300,
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
                    const Text(
                      'Scan History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${widget.scanHistory.length}/${widget.scanHistory.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
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
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No scan history yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: widget.scanHistory.length,
                        itemBuilder: (context, index) {
                          final scan = widget.scanHistory[index];
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

    return Container(
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
              color: scan['isVip'] == true ? Colors.yellow.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: scan['isVip'] == true
                  ? const Text(
                      'VIP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  : Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.grey.shade600,
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
                  scan['ticketId'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scan['name'] ?? 'N/A',
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
                      scan['status'] ?? 'Unknown',
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
                scan['time'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Function to show the scan history bottom sheet
void showScanHistoryBottomSheet(BuildContext context, List<Map<String, dynamic>> scanHistory) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ScanHistoryBottomSheet(scanHistory: scanHistory),
  );
}
