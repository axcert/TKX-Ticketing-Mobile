import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:intl/intl.dart';

class TicketDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketDetailsBottomSheet({super.key, required this.ticketData});

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr == 'N/A' || dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('h:mm a, MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          const SizedBox(height: 24),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ticket Details',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Ticket Details List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  'Ticket ID / Code',
                  ticketData['ticketId'] ?? 'N/A',
                ),
                _buildDetailRow(
                  context,
                  'Attendee Name',
                  ticketData['name'] ?? 'N/A',
                ),
                _buildDetailRow(
                  context,
                  'Ticket Type',
                  ticketData['ticketType'] ?? 'N/A',
                ),
                _buildDetailRow(
                  context,
                  'Seat No.',
                  ticketData['seatNumber'] ?? 'N/A',
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'Record ID',
                  ticketData['recordId'] ?? 'N/A',
                ),
                _buildDetailRow(
                  context,
                  'Scan Time',
                  _formatDate(ticketData['scanTime']),
                ),
                _buildDetailRow(
                  context,
                  'Scan Type',
                  ticketData['scanType'] ?? 'N/A',
                ),
                _buildDetailRow(
                  context,
                  'Scanned By',
                  ticketData['scannedBy'] ?? 'N/A',
                ),
                _buildDetailRowWithStatus(
                  context,
                  'Status',
                  ticketData['status'] ?? 'N/A',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.roboto().fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithStatus(
    BuildContext context,
    String label,
    String value,
  ) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (value.toLowerCase().trim()) {
      case 'valid':
      case 'active':
      case 'checked-in':
      case 'checked in':
      case 'success':
        statusColor = AppColors.success;
        statusBgColor = Colors.green.shade50;
        statusIcon = Icons.check_circle;
        break;
      case 'invalid':
      case 'used':
      case 'already checked in':
      case 'already checked-in':
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.roboto().fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textSecondary,
                        fontFamily: GoogleFonts.inter().fontFamily,
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
}

// Function to show the ticket details bottom sheet
void showTicketDetailsBottomSheet(
  BuildContext context,
  Map<String, dynamic> ticketData,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TicketDetailsBottomSheet(ticketData: ticketData),
  );
}
