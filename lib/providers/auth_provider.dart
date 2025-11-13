import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      setLoading(true);
      clearError();

      // Check internet connectivity
      if (_connectivityService.isOffline) {
        setError('No internet connection. Please check your network.');
        setLoading(false);
        return false;
      }

      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        // Extract token, expires_in, and user data from response
        final token = response.data!['token'] ?? response.data!['access_token'];
        final expiresIn = response.data!['expires_in'];
        final userData = response.data!['user'] ?? response.data!;

        // Save authentication data
        if (token != null) {
          await _storageService.saveAuthToken(token);
        }

        // Save token expiration time
        if (expiresIn != null) {
          await _storageService.saveTokenExpiration(expiresIn as int);
        }

        // Save user data
        _user = User.fromJson(userData);
        await _storageService.saveUserData(
          userId: _user!.id,
          email: _user!.email,
        );

        _isAuthenticated = true;
        setLoading(false);
        return true;
      } else {
        setError(response.message ?? 'Login failed');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      setLoading(true);
      clearError();

      // Call logout endpoint (optional)
      await _authService.logout();

      // Clear local data
      await _storageService.clearUserData();

      _isAuthenticated = false;
      _user = null;
      setLoading(false);
    } catch (e) {
      // Even if API call fails, clear local data
      await _storageService.clearUserData();
      _isAuthenticated = false;
      _user = null;
      setError(e.toString());
      setLoading(false);
    }
  }

  /// Check if user is authenticated on app start
  Future<void> checkAuthStatus() async {
    try {
      final token = await _storageService.getAuthToken();
      final userId = await _storageService.getUserId();
      final email = await _storageService.getUserEmail();

      if (token != null && userId != null && email != null) {
        // Check if token is expired
        final isExpired = await _storageService.isTokenExpired();

        if (isExpired) {
          // Token expired, clear data and logout
          print('🔒 Token expired, logging out');
          await _storageService.clearUserData();
          _isAuthenticated = false;
          _user = null;
        } else {
          // User has valid token, fetch user profile
          final response = await _authService.getUserProfile();

          if (response.success && response.data != null) {
            _user = response.data!;
            _isAuthenticated = true;
          } else {
            // Token might be invalid, clear data
            await _storageService.clearUserData();
            _isAuthenticated = false;
          }
        }
      } else {
        _isAuthenticated = false;
      }

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
    }
  }

  /// Forgot Password - Send reset code
  Future<bool> forgotPassword(String email) async {
    try {
      setLoading(true);
      clearError();

      // Check internet connectivity
      if (_connectivityService.isOffline) {
        setError('No internet connection. Please check your network.');
        setLoading(false);
        return false;
      }

      final response = await _authService.forgotPassword(email: email);

      if (response.success) {
        setLoading(false);
        return true;
      } else {
        setError(response.message ?? 'Failed to send reset code');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      setLoading(true);
      clearError();

      // Check internet connectivity
      if (_connectivityService.isOffline) {
        setError('No internet connection. Please check your network.');
        setLoading(false);
        return false;
      }

      final response = await _authService.verifyOtp(email: email, otp: otp);

      if (response.success) {
        setLoading(false);
        return true;
      } else {
        setError(response.message ?? 'Invalid verification code');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  /// Reset Password
  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      setLoading(true);
      clearError();

      // Check internet connectivity
      if (_connectivityService.isOffline) {
        setError('No internet connection. Please check your network.');
        setLoading(false);
        return false;
      }

      final response = await _authService.resetPassword(
        email: email,
        otp: otp,
        password: newPassword,
        passwordConfirmation: newPassword,
      );

      if (response.success) {
        setLoading(false);
        return true;
      } else {
        setError(response.message ?? 'Failed to reset password');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }
}
