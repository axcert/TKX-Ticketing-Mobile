class Ticket {
  final int ticketId;
  final String attendeePublicId;
  final String attendeeName;
  final String attendeeEmail;
  final String ticketType;
  final String? seatNumber;
  final String? seatUuid;
  final String status;
  final String orderShortId;
  final String checkInStatus;
  final DateTime? checkedInAt;

  Ticket({
    required this.ticketId,
    required this.attendeePublicId,
    required this.attendeeName,
    required this.attendeeEmail,
    required this.ticketType,
    this.seatNumber,
    this.seatUuid,
    required this.status,
    required this.orderShortId,
    required this.checkInStatus,
    this.checkedInAt,
  });

  // Factory constructor to create Ticket from JSON
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticket_id'] ?? 0,
      attendeePublicId: json['attendee_public_id'] ?? '',
      attendeeName: json['attendee_name'] ?? '',
      attendeeEmail: json['attendee_email'] ?? '',
      ticketType: json['ticket_type'] ?? 'normal',
      seatNumber: json['seat_number'],
      seatUuid: json['seat_uuid'],
      status: json['status'] ?? 'valid',
      orderShortId: json['order_short_id'] ?? '',
      checkInStatus: json['check_in_status'] ?? 'check-out',
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'])
          : null,
    );
  }

  // Convert Ticket to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'attendee_public_id': attendeePublicId,
      'attendee_name': attendeeName,
      'attendee_email': attendeeEmail,
      'ticket_type': ticketType,
      'seat_number': seatNumber,
      'seat_uuid': seatUuid,
      'status': status,
      'order_short_id': orderShortId,
      'check_in_status': checkInStatus,
      'checked_in_at': checkedInAt?.toIso8601String(),
    };
  }

  // Check if ticket is valid
  bool get isValid => status == 'valid';

  // Helper getter for check-in status
  bool get isCheckedIn => checkInStatus == 'check-in';
}

// Response model for the ticket bundle API
class TicketBundleResponse {
  final List<Ticket> tickets;
  final int count;
  final String generatedAt;

  TicketBundleResponse({
    required this.tickets,
    required this.count,
    required this.generatedAt,
  });

  factory TicketBundleResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return TicketBundleResponse(
      tickets:
          (data['tickets'] as List<dynamic>?)
              ?.map((ticket) => Ticket.fromJson(ticket))
              .toList() ??
          [],
      count: data['count'] ?? 0,
      generatedAt: data['generated_at'] ?? '',
    );
  }
}
