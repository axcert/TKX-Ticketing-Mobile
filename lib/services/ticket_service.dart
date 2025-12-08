import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
}
