import 'package:intl/intl.dart';

class ScanHistory {
  final String ticketId;
  final String name;
  final String email;
  final String time;
  final String status;
  final bool isVip;
  final String ticketType;
  final String seatNo;
  final String row;
  final String column;
  final String recordId;
  final String scanTime;
  final String? Time;
  final String scanType;
  final String scannedBy;

  ScanHistory({
    required this.ticketId,
    required this.name,
    required this.email,
    required this.time,
    required this.status,
    required this.isVip,
    required this.ticketType,
    required this.seatNo,
    required this.row,
    required this.column,
    required this.recordId,
    required this.scanTime,
    this.Time,
    required this.scanType,
    required this.scannedBy,
  });

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    // Some APIs might nest the ticket/attendee info
    final nested = json['ticket'] ?? json['attendee'] ?? json['check_in'] ?? {};
    final Map<String, dynamic> data = nested is Map<String, dynamic>
        ? nested
        : {};

    return ScanHistory(
      ticketId:
          json['attendee_public_id'] ??
          data['attendee_public_id'] ??
          json['ticketId'] ??
          data['id']?.toString() ??
          'N/A',
      name:
          json['attendee_name'] ??
          data['attendee_name'] ??
          json['name'] ??
          data['name'] ??
          'N/A',
      email:
          json['attendee_email'] ??
          data['attendee_email'] ??
          json['email'] ??
          data['email'] ??
          'N/A',
      time: json['time'] ?? 'N/A',
      status:
          json['status'] ??
          json['check_in_status'] ??
          data['status'] ??
          data['check_in_status'] ??
          'Unknown',
      isVip:
          (json['ticket_type']?.toString().toLowerCase().contains('vip') ??
          data['ticket_type']?.toString().toLowerCase().contains('vip') ??
          json['ticketType']?.toString().toLowerCase().contains('vip') ??
          json['isVip'] == true || data['is_vip'] == true),
      ticketType:
          json['ticket_type'] ??
          data['ticket_type'] ??
          json['ticketType'] ??
          'N/A',
      seatNo:
          json['seat_number'] ??
          data['seat_number'] ??
          json['seat_label'] ??
          data['seat_label'] ??
          json['seatNumber'] ??
          'N/A',
      row: json['row'] ?? data['row'] ?? 'N/A',
      column: json['column'] ?? data['column'] ?? 'N/A',
      recordId:
          (json['ticket_id'] ?? data['ticket_id'] ?? json['recordId'] ?? 'N/A')
              .toString(),
      scanTime:
          json['scan_time'] ??
          json['scanned_at'] ??
          data['scan_time'] ??
          json['scanTime'] ??
          'N/A',
      scanType: json['scan_type'] ?? json['scanType'] ?? 'N/A',
      scannedBy:
          json['scanned_by'] ??
          json['scannedBy'] ??
          json['gatekeeper_name'] ??
          'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'name': name,
      'email': email,
      'time': time,
      'status': status,
      'isVip': isVip,
      'ticketType': ticketType,
      'seatNumber': seatNo,
      'row': row,
      'column': column,
      'recordId': recordId,
      'scanTime': scanTime,
      'scanType': scanType,
      'scannedBy': scannedBy,
    };
  }

  String dateFormat() {
    try {
      if (scanTime == 'N/A' || scanTime.isEmpty) return 'N/A';
      final dateTime = DateTime.parse(scanTime);
      return DateFormat('h:mm a, MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return scanTime;
    }
  }

  String timeFormat() {
    try {
      if (scanTime == 'N/A' || scanTime.isEmpty) return 'N/A';
      final Time = DateTime.parse(scanTime);
      return DateFormat('h:mm a').format(Time);
    } catch (e) {
      return scanTime;
    }
  }
}
