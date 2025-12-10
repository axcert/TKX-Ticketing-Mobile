import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/event_model.dart';
import '../models/event_statistics_model.dart';
import '../models/scan_history_model.dart';
import 'storage_service.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final StorageService _storageService = StorageService();

  /// Get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.getAuthToken();
    return {'Authorization': 'Bearer $token'};
  }

  /// Fetch all events for the user (gatekeeper)
  Future<ApiResponse<Map<String, dynamic>>> getMyEvents() async {
    try {
      final headers = await _getAuthHeaders();

      // Step 1: Get assigned events from gatekeeper
      print('📡 [GateKeeper] Fetching assigned events...');
      print(
        '📡 [GateKeeper] Endpoint: ${AppConfig.baseUrl}${AppConfig.gateKeeperEndpoint}',
      );

      final gateKeeperResponse = await _dio.get(
        AppConfig.gateKeeperEndpoint,
        options: Options(headers: headers),
      );

      if (gateKeeperResponse.statusCode != 200) {
        print(
          '❌ [GateKeeper] Failed with status: ${gateKeeperResponse.statusCode}',
        );
        return ApiResponse.error(
          'Failed to fetch assigned events',
          statusCode: gateKeeperResponse.statusCode,
        );
      }

      // Extract assigned event IDs and organizer IDs
      final gateKeeperData = gateKeeperResponse.data;
      Set<int> assignedEventIds = {};
      Set<int> organizerIds = {};
      String? organizerName;

      if (gateKeeperData is Map<String, dynamic> &&
          gateKeeperData['data'] != null) {
        final eventsData = gateKeeperData['data'] as List;
        for (var eventJson in eventsData) {
          if (eventJson['id'] != null) {
            assignedEventIds.add(eventJson['id'] as int);
          }
          if (eventJson['organizer'] != null) {
            if (eventJson['organizer']['id'] != null) {
              organizerIds.add(eventJson['organizer']['id'] as int);
            }
            // Capture organizer name from the first available event
            if (organizerName == null) {
              organizerName = eventJson['organizer']['name'].toString();
            }
          }
        }
      }

      print('📋 [GateKeeper] Assigned Event IDs: $assignedEventIds');
      print('📋 [GateKeeper] Organizer IDs: $organizerIds');
      if (organizerName != null) {
        print('📋 [GateKeeper] Organizer Name: $organizerName');
      }

      if (assignedEventIds.isEmpty) {
        return ApiResponse.success({
          'today': <Event>[],
          'upcoming': <Event>[],
          'completed': <Event>[],
          'organizerName': organizerName,
        }, message: 'No assigned events');
      }

      // Step 2: Fetch events from each endpoint
      List<Event> todayEvents = [];
      List<Event> upcomingEvents = [];
      List<Event> completedEvents = [];

      // Fetch from each organizer
      for (var organizerId in organizerIds) {
        // Fetch today's events
        try {
          final todayEndpoint = AppConfig.todayEventsEndpoint.replaceAll(
            '{id}',
            organizerId.toString(),
          );

          final todayResponse = await _dio.get(
            todayEndpoint,
            options: Options(headers: headers),
          );

          if (todayResponse.statusCode == 200) {
            final events = _parseEventsFromResponse(todayResponse.data);
            final filteredEvents = events
                .where((e) => assignedEventIds.contains(int.tryParse(e.id)))
                .toList();
            todayEvents.addAll(filteredEvents);
          }
        } catch (e) {
          print('⚠️ Error fetching today events: $e');
        }

        // Fetch upcoming events
        try {
          final upcomingEndpoint = AppConfig.upcomingEventsEndpoint.replaceAll(
            '{id}',
            organizerId.toString(),
          );

          final upcomingResponse = await _dio.get(
            upcomingEndpoint,
            options: Options(headers: headers),
          );

          if (upcomingResponse.statusCode == 200) {
            final events = _parseEventsFromResponse(upcomingResponse.data);
            final filteredEvents = events
                .where((e) => assignedEventIds.contains(int.tryParse(e.id)))
                .toList();
            upcomingEvents.addAll(filteredEvents);
          }
        } catch (e) {
          print('⚠️ Error fetching upcoming events: $e');
        }

        // Fetch completed events
        try {
          final completedEndpoint = AppConfig.completedEventsEndpoint
              .replaceAll('{id}', organizerId.toString());

          final completedResponse = await _dio.get(
            completedEndpoint,
            options: Options(headers: headers),
          );

          if (completedResponse.statusCode == 200) {
            final events = _parseEventsFromResponse(completedResponse.data);
            final filteredEvents = events
                .where((e) => assignedEventIds.contains(int.tryParse(e.id)))
                .toList();
            completedEvents.addAll(filteredEvents);
          }
        } catch (e) {
          print('⚠️ Error fetching completed events: $e');
        }
      }

      final categorizedEvents = {
        'today': todayEvents,
        'upcoming': upcomingEvents,
        'completed': completedEvents,
        'organizerName': organizerName,
      };

      return ApiResponse.success(
        categorizedEvents,
        message: 'Events fetched successfully',
      );
    } on DioException catch (e) {
      // print('❌ [Events API] DioException: ${e.type}');
      // print('❌ [Events API] Message: ${e.message}');
      // print('❌ [Events API] Response: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout) {
        return ApiResponse.error('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.error('Receive timeout');
      } else if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Failed to fetch events';
        return ApiResponse.error(message, statusCode: e.response?.statusCode);
      } else {
        return ApiResponse.error('Network error occurred');
      }
    } catch (e) {
      // print('❌ [Events API] Unexpected error: $e');
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  /// Parse events from API response
  List<Event> _parseEventsFromResponse(dynamic responseData) {
    List<Event> events = [];

    if (responseData is Map<String, dynamic> && responseData['data'] != null) {
      final eventsData = responseData['data'] as List;
      events = eventsData.map((eventJson) => _parseEvent(eventJson)).toList();
    } else if (responseData is List) {
      events = responseData.map((eventJson) => _parseEvent(eventJson)).toList();
    }

    return events;
  }

  /// Parse event from JSON
  Event _parseEvent(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Untitled Event',
      imageUrl: json['image_url'] ?? 'assets/event_placeholder.png',
      startDate: _parseDateTime(json['start_date']),
      endDate: _parseDateTime(json['end_date']),
      venue: json['venue'] ?? json['location'] ?? 'N/A',
      location: json['location'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
      description: json['description'] ?? 'No description available',
    );
  }

  /// Parse DateTime from various formats
  DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is String) {
      try {
        // Strip the 'Z' to treat the time as local
        final dateString = dateValue.endsWith('Z')
            ? dateValue.substring(0, dateValue.length - 1)
            : dateValue;
        return DateTime.parse(dateString);
      } catch (e) {
        // print('⚠️ [Events API] Failed to parse date: $dateValue');
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  /// Fetch event statistics by event ID
  Future<ApiResponse<EventStatistics>> getEventStatistics(
    String eventId,
  ) async {
    try {
      final headers = await _getAuthHeaders();

      // Build the endpoint with event_id
      final endpoint = AppConfig.eventStastics.replaceAll(
        '{event_id}',
        eventId,
      );

      print('📊 [Event Statistics] Fetching statistics for event $eventId...');
      print('📊 [Event Statistics] Endpoint: ${AppConfig.baseUrl}$endpoint');

      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      print('📊 [Event Statistics] Status Code: ${response.statusCode}');
      print('📊 [Event Statistics] Response Data: ${response.data}');

      if (response.statusCode != 200) {
        print(
          '❌ [Event Statistics] Failed with status: ${response.statusCode}',
        );
        return ApiResponse.error(
          'Failed to fetch event statistics',
          statusCode: response.statusCode,
        );
      }

      // Parse the response
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        final statistics = EventStatistics.fromJson(responseData['data']);
        return ApiResponse.success(
          statistics,
          message: 'Event statistics fetched successfully',
        );
      } else {
        return ApiResponse.error('Invalid response format');
      }
    } on DioException catch (e) {
      print('❌ [Event Statistics] DioException: ${e.type}');
      print('❌ [Event Statistics] Message: ${e.message}');
      print('❌ [Event Statistics] Response: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout) {
        return ApiResponse.error('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.error('Receive timeout');
      } else if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Failed to fetch event statistics';
        return ApiResponse.error(message, statusCode: e.response?.statusCode);
      } else {
        return ApiResponse.error('Network error occurred');
      }
    } catch (e) {
      print('❌ [Event Statistics] Unexpected error: $e');
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  /// Fetch scan history by event ID
  Future<ApiResponse<List<ScanHistory>>> getScanHistory(String eventId) async {
    try {
      final headers = await _getAuthHeaders();

      // Build the endpoint with event_id
      final endpoint = AppConfig.scanhistory.replaceAll('{event_id}', eventId);

      print('📜 [Scan History] Fetching scan history for event $eventId...');
      print('📜 [Scan History] Endpoint: ${AppConfig.baseUrl}$endpoint');

      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      print('📜 [Scan History] Status Code: ${response.statusCode}');
      print('📜 [Scan History] Response Data: ${response.data}');

      if (response.statusCode != 200) {
        print('❌ [Scan History] Failed with status: ${response.statusCode}');
        return ApiResponse.error(
          'Failed to fetch scan history',
          statusCode: response.statusCode,
        );
      }

      // Parse the response
      final responseData = response.data;
      List<ScanHistory> scanHistoryList = [];

      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        final dataList = responseData['data'] as List;
        scanHistoryList = dataList
            .map((item) => ScanHistory.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(
          scanHistoryList,
          message: 'Scan history fetched successfully',
        );
      } else if (responseData is List) {
        scanHistoryList = responseData
            .map((item) => ScanHistory.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(
          scanHistoryList,
          message: 'Scan history fetched successfully',
        );
      } else {
        return ApiResponse.error('Invalid response format');
      }
    } on DioException catch (e) {
      print('❌ [Scan History] DioException: ${e.type}');
      print('❌ [Scan History] Message: ${e.message}');
      print('❌ [Scan History] Response: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout) {
        return ApiResponse.error('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.error('Receive timeout');
      } else if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Failed to fetch scan history';
        return ApiResponse.error(message, statusCode: e.response?.statusCode);
      } else {
        return ApiResponse.error('Network error occurred');
      }
    } catch (e) {
      print('❌ [Scan History] Unexpected error: $e');
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }
}
