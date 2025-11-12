class AppConfig {
  // API Configuration
  // IMPORTANT: Update baseUrl based on your environment:
  // - Android Emulator: Use 'http://10.0.2.2:8000'
  // - iOS Simulator: Use 'http://localhost:8000' or 'http://127.0.0.1:8000'
  // - Physical Device: Use 'http://[YOUR_COMPUTER_IP]:8000' (e.g., 'http://192.168.1.100:8000')
  // - Production: Use your actual server URL

  // https://tkxe.axcertro.dev
  // Replace with your computer's IP address from ipconfig/ifconfig

  static const String baseUrl = 'https://tkxeapi.axcertro.dev';
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';

  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String refreshTokenEndpoint = '/auth/refresh-token';

  // User Endpoints
  static const String userProfileEndpoint = '/users/me';
  static const String updateProfileEndpoint = '/user/update';

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

  // App Configuration
  static const String appName = 'TKX Mobile';
  static const String appVersion = '1.0.0';

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
