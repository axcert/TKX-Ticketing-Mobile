class Event {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime dateTime;
  final String venue;
  final String location;
  final bool isCompleted;

  Event({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.dateTime,
    required this.venue,
    required this.location,
    this.isCompleted = false,
  });

  // Format date as "Oct 12, 2025 • 06:00 PM"
  String get formattedDateTime {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year • ${hour == 0 ? 12 : hour}:$minute $period';
  }

  // Check if the event is upcoming (scan not yet available)
  // Scanning opens 4 hours before the event
  bool get isUpcoming {
    final now = DateTime.now();
    final scanOpenTime = dateTime.subtract(const Duration(hours: 4));
    return now.isBefore(scanOpenTime) && !isCompleted;
  }

  // Check if scanning is available (ongoing)
  bool get isOngoing {
    final now = DateTime.now();
    final scanOpenTime = dateTime.subtract(const Duration(hours: 4));
    final eventEndTime = dateTime.add(const Duration(hours: 6)); // Event lasts 6 hours
    return now.isAfter(scanOpenTime) && now.isBefore(eventEndTime) && !isCompleted;
  }

  // Copy with method for updating properties
  Event copyWith({
    String? id,
    String? title,
    String? imageUrl,
    DateTime? dateTime,
    String? venue,
    String? location,
    bool? isCompleted,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      location: location ?? this.location,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
