class EventStatistics {
  final int registeredCount;
  final int checkInCount;
  final int remainingCount;
  final int invalidCount;

  EventStatistics({
    required this.registeredCount,
    required this.checkInCount,
    required this.remainingCount,
    required this.invalidCount,
  });

  factory EventStatistics.fromJson(Map<String, dynamic> json) {
    return EventStatistics(
      registeredCount: json['registered_count'] ?? 0,
      checkInCount: json['check_in_count'] ?? 0,
      remainingCount: json['remaining_count'] ?? 0,
      invalidCount: json['invalid_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registered_count': registeredCount,
      'check_in_count': checkInCount,
      'remaining_count': remainingCount,
      'invalid_count': invalidCount,
    };
  }

  // Create an empty statistics object
  factory EventStatistics.empty() {
    return EventStatistics(
      registeredCount: 0,
      checkInCount: 0,
      remainingCount: 0,
      invalidCount: 0,
    );
  }
}
