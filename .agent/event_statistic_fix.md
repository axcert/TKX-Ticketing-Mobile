# Event Statistic Widget Fix

## Issue
The `EventStatisticWidget` was displaying "Infinity%" or crashing when `registerCount` was 0, due to a division by zero error. The progress indicator was also hardcoded to 0.8.

## Fix Implemented
Updated `lib/widgets/event_statistic.dart` to safely calculate the percentage and progress value.

### Changes:
1.  **Percentage Text**:
    ```dart
    '${widget.registerCount > 0 ? ((widget.checkInCount / widget.registerCount) * 100).toInt() : 0}%'
    ```
    Now checks if `registerCount > 0` before dividing. If 0, it displays "0%".

2.  **CircularProgressIndicator**:
    ```dart
    value: widget.registerCount > 0
        ? widget.checkInCount / widget.registerCount
        : 0.0,
    ```
    Now uses the actual calculated progress instead of a static value.

## Result
- When `registerCount` is 0, the widget displays "0%" and an empty progress bar.
- When `registerCount` > 0, it displays the correct percentage and progress.
