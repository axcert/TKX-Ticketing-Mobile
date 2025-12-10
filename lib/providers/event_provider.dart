import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/connectivity_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<Event> _todayEvents = [];
  List<Event> _upcomingEvents = [];
  List<Event> _completedEvents = [];
  String? _organizerName;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Event> get todayEvents => _todayEvents;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<Event> get completedEvents => _completedEvents;
  String? get organizerName => _organizerName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all events
  Future<void> fetchEvents() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check internet connectivity
      if (_connectivityService.isOffline) {
        _errorMessage = 'No internet connection. Please check your network.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _eventService.getMyEvents();

      if (response.success && response.data != null) {
        _todayEvents =
            (response.data!['today'] as List<dynamic>?)?.cast<Event>() ?? [];
        _upcomingEvents =
            (response.data!['upcoming'] as List<dynamic>?)?.cast<Event>() ?? [];
        _completedEvents =
            (response.data!['completed'] as List<dynamic>?)?.cast<Event>() ??
            [];
        _organizerName = response.data!['organizerName'] as String?;
        _errorMessage = null;

        debugPrint('✅ [EventProvider] Events loaded successfully');
        debugPrint('   Today: ${_todayEvents.length}');
        debugPrint('   Upcoming: ${_upcomingEvents.length}');
        debugPrint('   Completed: ${_completedEvents.length}');
        if (_organizerName != null) {
          debugPrint('   Organizer: $_organizerName');
        }
      } else {
        _errorMessage = response.message ?? 'Failed to fetch events';
        debugPrint('❌ [EventProvider] Failed: $_errorMessage');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ [EventProvider] Error: $e');
    }
  }

  /// Refresh events (for pull-to-refresh)
  Future<void> refreshEvents() async {
    debugPrint('🔄 [EventProvider] Refreshing events...');
    await fetchEvents();
  }

  /// Clear all events
  void clearEvents() {
    _todayEvents = [];
    _upcomingEvents = [];
    _completedEvents = [];
    _organizerName = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('🗑️ [EventProvider] Events cleared');
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
