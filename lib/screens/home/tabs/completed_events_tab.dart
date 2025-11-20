import 'package:flutter/material.dart';
import 'package:mobile_app/models/event_model.dart';
import 'package:mobile_app/screens/home/widgets/event_card.dart';
import 'package:mobile_app/screens/home/widgets/empty_state_widget.dart';

class CompletedEventsTab extends StatelessWidget {
  final List<Event> events;

  const CompletedEventsTab({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyStateWidget(
        message: 'No events available',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Column(
        children: events.map((event) => EventCard(event: event)).toList(),
      ),
    );
  }
}
