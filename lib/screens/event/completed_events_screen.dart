import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import 'event_details_screen.dart';

class CompletedEventsScreen extends StatefulWidget {
  const CompletedEventsScreen({super.key});

  @override
  State<CompletedEventsScreen> createState() => _CompletedEventsScreenState();
}

class _CompletedEventsScreenState extends State<CompletedEventsScreen> {
  // Sample completed events data
  final List<Event> _completedEvents = [
    Event(
      id: 'completed-1',
      title: 'RAN RASA SADE',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
    Event(
      id: 'completed-2',
      title: 'Oktoberfest Kandana',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
    Event(
      id: 'completed-3',
      title: 'Mervin',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
    Event(
      id: 'completed-4',
      title: 'Prabhanandaya',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
    Event(
      id: 'completed-5',
      title: 'Serened',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5CBF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Completed Events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _completedEvents.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _completedEvents.length,
              itemBuilder: (context, index) {
                final event = _completedEvents[index];
                return _buildEventCard(event);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Completed Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed events will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Event Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  event.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Event Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Date and Time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(event.dateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Venue
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${event.venue} - ${event.location}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
