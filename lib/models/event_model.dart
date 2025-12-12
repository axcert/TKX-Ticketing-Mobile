class Event {
  final String id;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String location;
  final String organizerName;
  final bool isCompleted;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.location,
    this.isCompleted = false,
    required this.organizerName,
  });

  // Format date as "Oct 12, 2025 • 06:00 PM"
  String get formattedDateTime {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[startDate.month - 1];
    final day = startDate.day;
    final year = startDate.year;

    final hour = startDate.hour > 12 ? startDate.hour - 12 : startDate.hour;
    final minute = startDate.minute.toString().padLeft(2, '0');
    final period = startDate.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year • ${hour == 0 ? 12 : hour}:$minute $period';
  }

  // Check if the event is upcoming (scan not yet available)
  // Scanning opens 4 hours before the event starts
  bool get isUpcoming {
    final now = DateTime.now();
    final scanOpenTime = startDate.subtract(const Duration(hours: 4));
    return now.isBefore(scanOpenTime) && !isCompleted;
  }

  // Check if scanning is available (ongoing)
  // Event is ongoing from 4 hours before start until the end date
  bool get isOngoing {
    final now = DateTime.now();
    final scanOpenTime = startDate.subtract(const Duration(hours: 4));
    return now.isAfter(scanOpenTime) && now.isBefore(endDate) && !isCompleted;
  }

  // Check if the event has ended
  bool get isEnded {
    final now = DateTime.now();
    return now.isAfter(endDate) || isCompleted;
  }

  // Copy with method for updating properties
  Event copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? venue,
    String? location,
    bool? isCompleted,
    String? organizerName,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      location: location ?? this.location,
      isCompleted: isCompleted ?? this.isCompleted,
      organizerName: organizerName ?? this.organizerName,
    );
  }
}
