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

  // --- Scan History Management ---
  List<Map<String, dynamic>> _scanHistory = [];
  int _unseenScanCount = 0; // New: Track unseen scans

  List<Map<String, dynamic>> get scanHistory => _scanHistory;
  int get unseenScanCount => _unseenScanCount;

  /// Fetch scan history for a specific event
  Future<void> fetchScanHistory(String eventId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _eventService.getScanHistory(eventId);

      if (response.success && response.data != null) {
        // Convert List<ScanHistory> to List<Map<String, dynamic>> for the UI
        final newHistory = response.data!.map((scan) => scan.toJson()).toList();

        // Calculate unseen count (for now, simplistic logic: new total - old total)
        // Or if you want to count all fetched as unseen initially:
        _unseenScanCount = newHistory.length;

        _scanHistory = newHistory;

        debugPrint(
          '✅ [EventProvider] Scan history loaded: ${_scanHistory.length} items',
        );
      } else {
        debugPrint(
          '❌ [EventProvider] Failed to fetch scan history: ${response.message}',
        );
      }
    } catch (e) {
      debugPrint('❌ [EventProvider] Error fetching scan history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark all scans as seen (reset unseen count)
  void markScansAsSeen() {
    _unseenScanCount = 0;
    notifyListeners();
  }

  /// Add a test scan for UI testing
  void addTestScan() {
    final testScan = {
      'ticketId': 'TEST-123',
      'name': 'Test User',
      'time': '12:00 PM',
      'status': 'Checked-In',
      'isVip': true,
      'ticketType': 'VIP',
      'seatNo': 'A1',
      'row': 'A',
      'column': '1',
      'recordId': 'REC-001',
      'scanTime': DateTime.now().toIso8601String(),
      'scanType': 'Manual',
      'scannedBy': 'Tester',
    };
    _scanHistory.insert(0, testScan);
    _unseenScanCount++;
    notifyListeners();
  }

  /// Clear scan history
  void clearScanHistory() {
    _scanHistory = [];
    _unseenScanCount = 0;
    notifyListeners();
  }
}
