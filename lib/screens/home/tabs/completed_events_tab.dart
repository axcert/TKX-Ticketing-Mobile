import 'package:flutter/material.dart';
import 'package:tkx_ticketing/models/event_model.dart';
import 'package:tkx_ticketing/screens/event/event_details_screen.dart';
import 'package:tkx_ticketing/screens/event/offline_checkin_screen.dart';
import 'package:tkx_ticketing/screens/event/scan_not_available_screen.dart';
import 'package:tkx_ticketing/widgets/empty_state_widget.dart';
import 'package:tkx_ticketing/widgets/event_card.dart';

class CompletedEventsTab extends StatelessWidget {
  final List<Event> events;

  const CompletedEventsTab({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: EmptyStateWidget(message: 'No events available'),
      );
    }

    // Sort events by endDate in descending order (most recently ended first)
    final sortedEvents = List<Event>.from(events)
      ..sort((a, b) => b.endDate.compareTo(a.endDate));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return EventCard(event: event, onTap: () => _handleTap(context, event));
      },
    );
  }

  Future<void> _handleTap(BuildContext context, Event event) async {
    // Navigate to different screens based on event status
    if (event.isUpcoming) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanNotAvailableScreen(event: event),
        ),
      );
    } else {
      // Show offline check-in preparation screen first
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OfflineCheckInScreen(eventId: event.id, eventName: event.title),
        ),
      );

      // If download completed successfully, navigate to event details
      if (result == true && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      }
    }
  }
}
