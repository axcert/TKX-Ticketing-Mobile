import 'package:flutter/material.dart';
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ticket Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                  'Ticket ID / Code',
                  ticketData['ticketId'] ?? 'N/A',
                ),
                _buildDetailRow('Attendee Name', ticketData['name'] ?? 'N/A'),
                _buildDetailRow(
                  'Ticket Type',
                  ticketData['ticketType'] ?? 'N/A',
                ),
                _buildDetailRow('Seat No.', ticketData['seatNo'] ?? 'N/A'),
                _buildDetailRow('Row', ticketData['row'] ?? 'N/A'),
                _buildDetailRow('Column', ticketData['column'] ?? 'N/A'),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 16),
                _buildDetailRow('Record ID', ticketData['recordId'] ?? 'N/A'),
                _buildDetailRow(
                  'Scan Time',
                  _formatDate(ticketData['scanTime']),
                ),
                _buildDetailRow('Scan Type', ticketData['scanType'] ?? 'N/A'),
                _buildDetailRow('Scanned By', ticketData['scannedBy'] ?? 'N/A'),
                _buildDetailRowWithStatus(
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithStatus(String label, String value) {
    Color statusColor;
    Color statusBgColor;

    switch (value) {
      case 'Checked-In':
        statusColor = Colors.green;
        statusBgColor = Colors.green.shade50;
        break;
      case 'Already Checked-In':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.shade50;
        break;
      case 'Invalid':
        statusColor = Colors.red;
        statusBgColor = Colors.red.shade50;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.shade50;
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
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
