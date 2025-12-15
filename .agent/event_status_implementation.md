# Event Details Status Display Implementation

## Changes Made

Implemented dynamic status display in the `EventDetailsScreen` AppBar.

### 1. **Added Helper Method** (`_getEventStatus`)

```dart
Map<String, dynamic> _getEventStatus() {
  if (widget.event.isCompleted) {
    return {'text': 'Completed', 'color': Colors.grey};
  } else if (widget.event.isOngoing) {
    return {'text': 'Ongoing', 'color': AppColors.success};
  } else if (widget.event.isUpcoming) {
    return {'text': 'Upcoming', 'color': Colors.blue};
  } else {
    return {'text': 'Ended', 'color': Colors.red};
  }
}
```

### 2. **Updated AppBar Action**

```dart
actions: [
  Builder(
    builder: (context) {
      final status = _getEventStatus();
      return Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: status['color'] as Color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          status['text'] as String,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
        ),
      );
    }
  ),
],
```

## Result

- **Ongoing Events**: Show "Ongoing" in Green
- **Upcoming Events**: Show "Upcoming" in Blue
- **Completed Events**: Show "Completed" in Grey
- **Ended Events**: Show "Ended" in Red

This provides immediate visual feedback about the event's state to the user.
