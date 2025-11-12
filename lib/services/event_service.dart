import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/event_model.dart';
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
  Future<ApiResponse<Map<String, List<Event>>>> getMyEvents() async {
    try {
      final headers = await _getAuthHeaders();

      // Step 1: Get assigned events from gatekeeper
      print('📡 [GateKeeper] Fetching assigned events...');
      print(
        '📡 [GateKeeper] Endpoint: ${AppConfig.baseUrl}${AppConfig.gateKeeperEndpoint}',
      );
      // print('📡 [GateKeeper] Token: ${headers['Authorization']}');

      final gateKeeperResponse = await _dio.get(
        AppConfig.gateKeeperEndpoint,
        options: Options(headers: headers),
      );

      // print('📡 [GateKeeper] Status Code: ${gateKeeperResponse.statusCode}');
      // print('📡 [GateKeeper] Response Data: ${gateKeeperResponse.data}');

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

      if (gateKeeperData is Map<String, dynamic> &&
          gateKeeperData['data'] != null) {
        final eventsData = gateKeeperData['data'] as List;
        for (var eventJson in eventsData) {
          if (eventJson['id'] != null) {
            assignedEventIds.add(eventJson['id'] as int);
          }
          if (eventJson['organizer'] != null &&
              eventJson['organizer']['id'] != null) {
            organizerIds.add(eventJson['organizer']['id'] as int);
          }
        }
      }

      print('📋 [GateKeeper] Assigned Event IDs: $assignedEventIds');
      print('📋 [GateKeeper] Organizer IDs: $organizerIds');

      if (assignedEventIds.isEmpty) {
        // print('⚠️ [GateKeeper] No assigned events found');
        return ApiResponse.success({
          'today': <Event>[],
          'upcoming': <Event>[],
          'completed': <Event>[],
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
          print(
            '📅 [Today Events] Fetching from organizer $organizerId: ${AppConfig.baseUrl}$todayEndpoint',
          );

          final todayResponse = await _dio.get(
            todayEndpoint,
            options: Options(headers: headers),
          );
          print('📅 [Today Events] Status: ${todayResponse.statusCode}');
          print('📅 [Today Events] Response: ${todayResponse.data}');

          if (todayResponse.statusCode == 200) {
            final events = _parseEventsFromResponse(todayResponse.data);
            final filteredEvents = events
                .where((e) => assignedEventIds.contains(int.tryParse(e.id)))
                .toList();
            todayEvents.addAll(filteredEvents);
            // print(
            //   '📅 [Today Events] Found ${filteredEvents.length} assigned events from organizer $organizerId',
            // );
          }
        } catch (e) {
          print(
            '⚠️ [Today Events] Error fetching from organizer $organizerId: $e',
          );
        }

        // Fetch upcoming events
        try {
          final upcomingEndpoint = AppConfig.upcomingEventsEndpoint.replaceAll(
            '{id}',
            organizerId.toString(),
          );
          // print(
          //   '🔜 [Upcoming Events] Fetching from organizer $organizerId: ${AppConfig.baseUrl}$upcomingEndpoint',
          // );

          final upcomingResponse = await _dio.get(
            upcomingEndpoint,
            options: Options(headers: headers),
          );
          // print('🔜 [Upcoming Events] Status: ${upcomingResponse.statusCode}');
          // print('🔜 [Upcoming Events] Response: ${upcomingResponse.data}');

          if (upcomingResponse.statusCode == 200) {
            final events = _parseEventsFromResponse(upcomingResponse.data);
            final filteredEvents = events
                .where((e) => assignedEventIds.contains(int.tryParse(e.id)))
                .toList();
            upcomingEvents.addAll(filteredEvents);
            // print(
            //   '🔜 [Upcoming Events] Found ${filteredEvents.length} assigned events from organizer $organizerId',
            // );
          }
        } catch (e) {
          // print(
          //   '⚠️ [Upcoming Events] Error fetching from organizer $organizerId: $e',
          // );
        }

        // Fetch completed events
        try {
          final completedEndpoint = AppConfig.completedEventsEndpoint
              .replaceAll('{id}', organizerId.toString());
          // print(
          //   '✅ [Completed Events] Fetching from organizer $organizerId: ${AppConfig.baseUrl}$completedEndpoint',
          // );

          final completedResponse = await _dio.get(
            completedEndpoint,
            options: Options(headers: headers),
          );
          // print('✅ [Completed Events] Status: ${completedResponse.statusCode}');
          // print('✅ [Completed Events] Response: ${completedResponse.data}');

          if (completedResponse.statusCode == 200) {
            final events = _parseEventsFromResponse(completedResponse.data);
            final filteredEvents = events
                .where((e) => assignedEventIds.contains(int.tryParse(e.id)))
                .toList();
            completedEvents.addAll(filteredEvents);
            // print(
            //   '✅ [Completed Events] Found ${filteredEvents.length} assigned events from organizer $organizerId',
            // );
          }
        } catch (e) {
          // print(
          //   '⚠️ [Completed Events] Error fetching from organizer $organizerId: $e',
          // );
        }
      }

      // print(
      //   '📊 [Final Results] Today: ${todayEvents.length}, Upcoming: ${upcomingEvents.length}, Completed: ${completedEvents.length}',
      // );

      final categorizedEvents = {
        'today': todayEvents,
        'upcoming': upcomingEvents,
        'completed': completedEvents,
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
      imageUrl:
          json['image_url'] ??
          json['image'] ??
          json['poster_url'] ??
          json['banner_url'] ??
          'assets/event_placeholder.png',
      dateTime: _parseDateTime(
        json['date'] ??
            json['start_date'] ??
            json['event_date'] ??
            json['datetime'],
      ),
      venue: json['venue'] ?? json['location'] ?? 'TBA',
      location:
          json['location'] ??
          json['address'] ??
          json['city'] ??
          json['venue'] ??
          'TBA',
      isCompleted:
          json['is_completed'] ??
          json['completed'] ??
          json['status'] == 'completed' ??
          false,
    );
  }

  /// Parse DateTime from various formats
  DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        // print('⚠️ [Events API] Failed to parse date: $dateValue');
        return DateTime.now();
      }
    }

    return DateTime.now();
  }
}
