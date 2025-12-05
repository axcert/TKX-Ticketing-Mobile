import 'package:flutter/material.dart';
import 'package:tkx_ticketing/models/event_model.dart';
import 'package:tkx_ticketing/widgets/empty_state_widget.dart';
import 'package:tkx_ticketing/widgets/event_card.dart';

class UpcomingEventsTab extends StatelessWidget {
  final List<Event> events;

  const UpcomingEventsTab({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyStateWidget(message: 'No events available');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: events.map((event) => EventCard(event: event)).toList(),
      ),
    );
  }
}
