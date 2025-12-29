import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tkx_ticketing/config/app_config.dart';
import 'package:tkx_ticketing/models/ticket_model.dart';

class TicketService {
  // Fetch tickets for offline scanning
  Future<TicketBundleResponse?> fetchTicketsForEvent(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse(
        '${AppConfig.baseUrl}${AppConfig.getAvailableTicketsEndpoint.replaceAll('{event_id}', eventId)}',
      );
      print(url);
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TicketBundleResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      return null;
    }
  }

  // Save tickets to local storage for offline use
  Future<bool> saveTicketsLocally(String eventId, List<Ticket> tickets) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert tickets to JSON
      final ticketsJson = tickets.map((ticket) => ticket.toJson()).toList();
      final ticketsString = json.encode(ticketsJson);

      // Save with event-specific key
      await prefs.setString('tickets_$eventId', ticketsString);

      // Save timestamp
      await prefs.setString(
        'tickets_${eventId}_timestamp',
        DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e) {
      print('Error saving tickets locally: $e');
      return false;
    }
  }

  // Load tickets from local storage
  Future<List<Ticket>> loadTicketsLocally(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ticketsString = prefs.getString('tickets_$eventId');

      if (ticketsString == null) {
        return [];
      }

      final ticketsJson = json.decode(ticketsString) as List<dynamic>;
      return ticketsJson.map((json) => Ticket.fromJson(json)).toList();
    } catch (e) {
      print('Error loading tickets locally: $e');
      return [];
    }
  }

  // Fetch and save tickets for offline use
  Future<bool> downloadTicketsForOffline(String eventId) async {
    try {
      final ticketBundle = await fetchTicketsForEvent(eventId);

      if (ticketBundle == null || ticketBundle.tickets.isEmpty) {
        return false;
      }

      // Save tickets locally
      final saved = await saveTicketsLocally(eventId, ticketBundle.tickets);

      return saved;
    } catch (e) {
      print('Error downloading tickets for offline: $e');
      return false;
    }
  }

  // Check if tickets are already downloaded for an event
  Future<bool> hasOfflineTickets(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('tickets_$eventId');
    } catch (e) {
      return false;
    }
  }

  // Get ticket download timestamp
  Future<DateTime?> getTicketsDownloadTime(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('tickets_${eventId}_timestamp');

      if (timestamp == null) {
        return null;
      }

      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  // Clear tickets for a specific event
  Future<void> clearTicketsForEvent(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tickets_$eventId');
      await prefs.remove('tickets_${eventId}_timestamp');
    } catch (e) {
      print('Error clearing tickets: $e');
    }
  }

  // Check in a ticket locally (with online sync if available)
  Future<Map<String, dynamic>> checkInTicket(
    String eventId,
    String ticketPublicId,
  ) async {
    try {
      // 1. Check for internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isOnline = connectivityResult.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );

      Map<String, dynamic>? onlineResult;

      if (isOnline) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null) {
            final url = Uri.parse(
              '${AppConfig.baseUrl}${AppConfig.validateTicketEndpoint.replaceAll('{event_id}', eventId)}',
            );

            final response = await http
                .post(
                  url,
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: json.encode({
                    'attendees': [
                      {'public_id': ticketPublicId, "action": "check-in"},
                    ],
                  }),
                )
                .timeout(AppConfig.connectionTimeout);

            if (response.statusCode == 200 || response.statusCode == 201) {
              final data = json.decode(response.body);
              final results = data['results'] as List<dynamic>?;

              if (results != null && results.isNotEmpty) {
                final result = results[0];
                final status =
                    result['status']; // 'success', 'duplicate', 'failed'
                final message = result['message'];

                if (status == 'success' || status == 'duplicate') {
                  onlineResult = {
                    'success': true,
                    'message': message ?? 'Check-in successful',
                    'status': status,
                  };
                } else {
                  return {
                    'success': false,
                    'message': message ?? 'Check-in failed on server',
                  };
                }
              }
            } else {
              print(
                'Online check-in failed with status: ${response.statusCode}',
              );
              // If server is unreachable or returns error, we fallback to local check-in
            }
          }
        } catch (e) {
          print('Error syncing check-in online: $e');
          // Fallback to local check-in on network error
        }
      }

      // 2. Perform local check-in
      final tickets = await loadTicketsLocally(eventId);
      final index = tickets.indexWhere(
        (t) => t.attendeePublicId == ticketPublicId,
      );

      if (index == -1) {
        if (onlineResult != null) return onlineResult;
        return {'success': false, 'message': 'Ticket not found locally'};
      }

      final ticket = tickets[index];

      // If we didn't get an online result (offline or error), check if already checked in locally
      if (onlineResult == null && ticket.isCheckedIn) {
        return {
          'success': false,
          'message': 'Ticket already checked in at ${ticket.checkedInAt}',
        };
      }

      // Create updated ticket
      final updatedTicket = Ticket(
        ticketId: ticket.ticketId,
        attendeePublicId: ticket.attendeePublicId,
        attendeeName: ticket.attendeeName,
        attendeeEmail: ticket.attendeeEmail,
        ticketType: ticket.ticketType,
        seatNumber: ticket.seatNumber,
        seatUuid: ticket.seatUuid,
        status: ticket.status,
        orderShortId: ticket.orderShortId,
        checkInStatus: 'check-in',
        checkedInAt: DateTime.now(),
      );

      // Update list
      tickets[index] = updatedTicket;

      // Save back to storage
      await saveTicketsLocally(eventId, tickets);

      if (onlineResult != null) {
        return onlineResult;
      }

      return {'success': true, 'message': 'Check-in successful (Offline)'};
    } catch (e) {
      print('Error checking in ticket: $e');
      return {'success': false, 'message': 'An error occurred during check-in'};
    }
  }
}
