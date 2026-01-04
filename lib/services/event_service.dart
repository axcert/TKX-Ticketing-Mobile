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

      final gateKeeperResponse = await _dio.get(
        AppConfig.gateKeeperEndpoint,
        options: Options(headers: headers),
      );

      if (gateKeeperResponse.statusCode != 200) {
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
        } catch (e) {}

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
        } catch (e) {}

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
        } catch (e) {}
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
    // Safely parse organizer name
    String organizerName = 'N/A';
    if (json['organizer'] != null && json['organizer'] is Map) {
      organizerName = json['organizer']['name']?.toString() ?? 'N/A';
    }

    // Parse Venue and Location
    // Parse Venue and Location
    String? venue;
    String? location;

    // Determine where location_details are stored
    Map<String, dynamic>? locDetails;
    if (json['settings'] != null &&
        json['settings'] is Map &&
        json['settings']['location_details'] != null) {
      locDetails = json['settings']['location_details'] as Map<String, dynamic>;
    } else if (json['location_details'] != null &&
        json['location_details'] is Map) {
      locDetails = json['location_details'] as Map<String, dynamic>;
    }

    if (locDetails != null) {
      // Parse Venue
      if (locDetails['venue_name'] != null) {
        final v = locDetails['venue_name'].toString().trim();
        if (v.isNotEmpty && v.toLowerCase() != 'null') {
          venue = v;
        }
      }

      // Parse Location (Build address from parts)
      final List<String> addressParts = [];
      final addressFields = [
        'address_line_1',
        'address_line_2',
        'city',
        'state_or_region',
      ];

      for (var field in addressFields) {
        final val = locDetails[field];
        if (val != null) {
          final strVal = val.toString().trim();
          if (strVal.isNotEmpty && strVal.toLowerCase() != 'null') {
            addressParts.add(strVal);
          }
        }
      }

      if (addressParts.isNotEmpty) {
        location = addressParts.join(', ');
      }
    }

    // Fallbacks if not found in location_details
    if (venue == null) {
      final v = json['venue']?.toString() ?? json['location']?.toString();
      if (v != null && v.isNotEmpty && v.toLowerCase() != 'null') {
        venue = v;
      }
    }

    if (location == null) {
      final l = json['location']?.toString();
      if (l != null && l.isNotEmpty && l.toLowerCase() != 'null') {
        location = l;
      }
    }

    final imageUrl = _resolveEventImageUrl(json);

    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Untitled Event',
      imageUrl: imageUrl,
      startDate: _parseDateTime(json['start_date']),
      endDate: _parseDateTime(json['end_date']),
      venue: venue ?? 'N/A',
      location: location ?? 'N/A',
      category: json['category'] ?? 'N/A',
      description: json['description'] ?? 'No description available',
      organizerName: organizerName,
    );
  }

  String _resolveEventImageUrl(Map<String, dynamic> json) {
    final rawImageUrl = json['image_url']?.toString().trim();
    if (rawImageUrl != null &&
        rawImageUrl.isNotEmpty &&
        rawImageUrl != 'null') {
      return _normalizeImageUrl(rawImageUrl);
    }

    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      Map<String, dynamic>? coverImage;
      for (final image in images) {
        if (image is Map && image['type']?.toString() == 'EVENT_COVER') {
          coverImage = Map<String, dynamic>.from(image);
          break;
        }
      }

      final selectedImage =
          coverImage ??
          (images.first is Map
              ? Map<String, dynamic>.from(images.first)
              : null);
      if (selectedImage != null) {
        final url = selectedImage['url']?.toString().trim();
        if (url != null && url.isNotEmpty && url != 'null') {
          return _normalizeImageUrl(url);
        }
        final path = selectedImage['path']?.toString().trim();
        if (path != null && path.isNotEmpty && path != 'null') {
          return _normalizeImageUrl(path);
        }
      }
    }

    return 'assets/event_placeholder.png';
  }

  String _normalizeImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty || rawUrl.toLowerCase() == 'null') {
      return 'assets/event_placeholder.png';
    }

    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    if (rawUrl.startsWith('/')) {
      return '${AppConfig.baseUrl}$rawUrl';
    }

    return rawUrl;
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

      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
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
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  /// Fetch scan history by event ID
  Future<ApiResponse<List<ScanHistory>>> getScanHistory(String eventId) async {
    try {
      final headers = await _getAuthHeaders();

      // Build the endpoint with event_id
      final endpoint = AppConfig.scanhistory.replaceAll('{event_id}', eventId);

      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
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
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  /// Sync bulk check-ins with backend
  Future<ApiResponse<bool>> syncCheckIns(
    String eventId,
    List<Map<String, dynamic>> checkIns,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final endpoint = AppConfig.validateTicketEndpoint.replaceAll(
        '{event_id}',
        eventId,
      );

      final body = {'attendees': checkIns};

      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(true, message: 'Sync successful');
      } else {
        return ApiResponse.error(
          'Sync failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error('Sync failed: ${e.message}');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }
}
