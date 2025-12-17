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
    required this.scanType,
    required this.scannedBy,
  });

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      ticketId: json['attendee_public_id'] ?? 'N/A',
      name: json['attendee_name'] ?? 'N/A',
      email: json['attendee_email'] ?? 'N/A',
      time: json['time'] ?? 'N/A',
      status: json['status'] ?? 'Unknown',
      isVip:
          json['ticket_type']?.toString().toLowerCase().contains('vip') ??
          false,
      ticketType: json['ticket_type'] ?? 'N/A',
      seatNo: json['seat_number'] ?? 'N/A',
      row: json['row'] ?? 'N/A',
      column: json['column'] ?? 'N/A',
      recordId: (json['ticket_id'] ?? 'N/A').toString(),
      scanTime: json['scan_time'] ?? 'N/A',
      scanType: json['scan_type'] ?? 'N/A',
      scannedBy: json['scanned_by'] ?? 'N/A',
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
}
