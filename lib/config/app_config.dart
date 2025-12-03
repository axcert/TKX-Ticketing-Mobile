class AppConfig {
  // API Configuration

  // https://tkxe.axcertro.dev
  // Replace with your computer's IP address from ipconfig/ifconfig

  static const String baseUrl = 'https://tkxeapi.axcertro.dev';
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';

  static const String forgotPasswordVerifyEmail =
      '/auth/gatekeeper/forgot-password';
  static const String verifyOtpEndpoint = '/auth/gatekeeper/verify-otp';
  static const String changePasswordEndpoint =
      '/auth/gatekeeper/reset-password';

  // User Endpoints
  static const String userProfileEndpoint = '/users/me';
  static const String updateProfileEndpoint = '/users/me';

  // Event Endpoints
  // get all events
  //
  static const String gateKeeperEndpoint = '/gate-keeper/my-events';
  static const String todayEventsEndpoint =
      '/public/organizers/{id}/events/today';
  static const String upcomingEventsEndpoint =
      '/public/organizers/{id}/events/upcoming';
  static const String completedEventsEndpoint =
      '/public/organizers/{id}/events/completed';

  // Get Ticket Statistics detail
  static const String eventStastics =
      '/events/{event_id}/stats/realtime-checkin';

  static const String scanhistory = '/events/{event_id}/scan-history';

  // Ticket Endpoints
  static const String ticketsEndpoint = '/tickets';
  static const String validateTicketEndpoint = '/tickets/validate';
  static const String checkInEndpoint = '/tickets/check-in';
  static const String scanHistoryEndpoint = '/tickets/scan-history';

  // Timeout Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';
  static const String isVibrateKey = 'is_vibrate';
  static const String isBeepKey = 'is_beep';
  static const String isAutoCheckInKey = 'is_auto_checkin';

  // App Configuration
  static const String appName = 'TKX Mobile';
  static const String appVersion = '1.0.0';

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
