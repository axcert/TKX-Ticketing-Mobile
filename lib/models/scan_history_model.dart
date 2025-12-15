class ScanHistory {
  final String ticketId;
  final String name;
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
      ticketId: json['ticketId'] ?? json['ticket_id'] ?? 'N/A',
      name: json['name'] ?? 'N/A',
      time: json['time'] ?? 'N/A',
      status: json['status'] ?? 'Unknown',
      isVip: json['isVip'] ?? json['is_vip'] ?? false,
      ticketType: json['ticketType'] ?? json['ticket_type'] ?? 'N/A',
      seatNo: json['seatNo'] ?? json['seat_no'] ?? 'N/A',
      row: json['row'] ?? 'N/A',
      column: json['column'] ?? 'N/A',
      recordId: json['recordId'] ?? json['record_id'] ?? 'N/A',
      scanTime: json['scanTime'] ?? json['scan_time'] ?? 'N/A',
      scanType: json['scanType'] ?? json['scan_type'] ?? 'N/A',
      scannedBy: json['scannedBy'] ?? json['scanned_by'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'name': name,
      'time': time,
      'status': status,
      'isVip': isVip,
      'ticketType': ticketType,
      'seatNo': seatNo,
      'row': row,
      'column': column,
      'recordId': recordId,
      'scanTime': scanTime,
      'scanType': scanType,
      'scannedBy': scannedBy,
    };
  }
}
