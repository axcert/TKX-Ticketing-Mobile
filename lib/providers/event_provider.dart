import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/connectivity_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  final ConnectivityService _connectivityService = ConnectivityService();

  static const String _eventsCacheKey = 'cached_events_data';

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
        debugPrint(
          '⚠️ [EventProvider] Offline mode detected. Attempting to load from cache...',
        );
        final hasCachedData = await _loadEventsFromCache();

        if (hasCachedData) {
          debugPrint('✅ [EventProvider] Loaded events from cache.');
          _isLoading = false;
          // We don't set error message here so UI shows content
          // But we could add a "Showing offline data" flag if needed
          notifyListeners();
          return;
        } else {
          _errorMessage =
              'No internet connection and no offline data available.';
          _isLoading = false;
          notifyListeners();
          return;
        }
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

        // Save to cache
        _saveEventsToCache();
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

  /// Save events to local cache
  Future<void> _saveEventsToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheMap = {
        'today': _todayEvents.map((e) => e.toJson()).toList(),
        'upcoming': _upcomingEvents.map((e) => e.toJson()).toList(),
        'completed': _completedEvents.map((e) => e.toJson()).toList(),
        'organizerName': _organizerName,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_eventsCacheKey, json.encode(cacheMap));
      debugPrint('💾 [EventProvider] Events cached successfully');
    } catch (e) {
      debugPrint('❌ [EventProvider] Failed to cache events: $e');
    }
  }

  /// Load events from local cache
  Future<bool> _loadEventsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_eventsCacheKey);

      if (jsonString != null) {
        final decoded = json.decode(jsonString) as Map<String, dynamic>;

        if (decoded['today'] != null) {
          _todayEvents = (decoded['today'] as List)
              .map((e) => Event.fromJson(e))
              .toList();
        }
        if (decoded['upcoming'] != null) {
          _upcomingEvents = (decoded['upcoming'] as List)
              .map((e) => Event.fromJson(e))
              .toList();
        }
        if (decoded['completed'] != null) {
          _completedEvents = (decoded['completed'] as List)
              .map((e) => Event.fromJson(e))
              .toList();
        }
        _organizerName = decoded['organizerName'] as String?;

        return true;
      }
    } catch (e) {
      debugPrint('❌ [EventProvider] Error loading cache: $e');
    }
    return false;
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

      // Check offline
      if (_connectivityService.isOffline) {
        debugPrint('⚠️ [EventProvider] Offline. Loading scan history cache...');
        final hasCached = await _loadScanHistoryFromCache(eventId);
        if (hasCached) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

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

        // Save to cache
        _saveScanHistoryToCache(eventId);
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

  String _scanHistoryCacheKey(String eventId) => 'scan_history_$eventId';

  Future<void> _saveScanHistoryToCache(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scanHistoryCacheKey(eventId),
        json.encode(_scanHistory),
      );
    } catch (e) {
      debugPrint('❌ [EventProvider] Failed to cache scan history: $e');
    }
  }

  Future<bool> _loadScanHistoryFromCache(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_scanHistoryCacheKey(eventId));
      if (jsonString != null) {
        final List<dynamic> decoded = json.decode(jsonString);
        _scanHistory = decoded.cast<Map<String, dynamic>>();
        _unseenScanCount = 0; // Reset for cached data
        return true;
      }
    } catch (e) {
      debugPrint('❌ [EventProvider] Error loading scan history cache: $e');
    }
    return false;
  }

  /// Mark all scans as seen (reset unseen count)
  void markScansAsSeen() {
    _unseenScanCount = 0;
    notifyListeners();
  }

  /// Add a scan to history locally and cache it
  Future<void> addScanToHistory(
    Map<String, dynamic> scanData,
    String eventId,
  ) async {
    _scanHistory.insert(0, scanData);
    _unseenScanCount++;
    notifyListeners();
    await _saveScanHistoryToCache(eventId);
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
    // Use an arbitrary event ID or handle caching separately if needed for tests
    // For UI testing, we might not need persistence, but let's keep it simple.
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
