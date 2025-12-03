import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storageService = StorageService();

  // Get headers with optional authentication
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _storageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;

    try {
      final decodedBody = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        // Success response
        if (fromJson != null) {
          final data = fromJson(decodedBody['data'] ?? decodedBody);
          return ApiResponse.success(
            data,
            message:
                (decodedBody is Map ? decodedBody['message'] : null) ??
                'Success',
          );
        } else {
          return ApiResponse.success(
            decodedBody as T,
            message:
                (decodedBody is Map ? decodedBody['message'] : null) ??
                'Success',
          );
        }
      } else if (statusCode == 401) {
        return ApiResponse.error(
          decodedBody['message'] ?? 'Unauthorized access',
          statusCode: statusCode,
        );
      } else if (statusCode == 422) {
        return ApiResponse.error(
          decodedBody['message'] ?? 'Validation failed',
          statusCode: statusCode,
          errors: decodedBody['errors'],
        );
      } else {
        return ApiResponse.error(
          decodedBody['message'] ?? 'An error occurred',
          statusCode: statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse server response',
        statusCode: statusCode,
      );
    }
  }

  /// Login with email and password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(AppConfig.buildUrl(AppConfig.loginEndpoint));
      final headers = await _getHeaders(includeAuth: false);
      final body = jsonEncode({'email': email, 'password': password});

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse<Map<String, dynamic>>(response, null);
    } on SocketException catch (e) {
      return ApiResponse.error(
        'Cannot connect to server. Please check your network connection.',
      );
    } on HttpException catch (e) {
      return ApiResponse.error('Server error occurred');
    } on FormatException catch (e) {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Logout
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      final url = Uri.parse(AppConfig.buildUrl(AppConfig.logoutEndpoint));
      final headers = await _getHeaders(includeAuth: true);

      final response = await http
          .post(url, headers: headers)
          .timeout(AppConfig.connectionTimeout);

      return _handleResponse<Map<String, dynamic>>(response, null);
    } on SocketException catch (e) {
      return ApiResponse.error(
        'Cannot connect to server. Please check your network connection.',
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Forgot password - verify email
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final url = Uri.parse(
        AppConfig.buildUrl(AppConfig.forgotPasswordVerifyEmail),
      );
      final headers = await _getHeaders(includeAuth: false);
      final body = jsonEncode({'email': email});

      print('🌐 API Request: POST $url');
      print('📦 Body: $body');

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(AppConfig.connectionTimeout);

      print('✅ Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse<Map<String, dynamic>>(response, null);
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      return ApiResponse.error(
        'Cannot connect to server. Please check your network connection.',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Verify OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final url = Uri.parse(AppConfig.buildUrl(AppConfig.verifyOtpEndpoint));
      final headers = await _getHeaders(includeAuth: false);
      final body = jsonEncode({'email': email, 'otp': otp});

      print('🌐 API Request: POST $url');
      print('📦 Body: $body');

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(AppConfig.connectionTimeout);

      print('✅ Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse<Map<String, dynamic>>(response, null);
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      return ApiResponse.error(
        'Cannot connect to server. Please check your network connection.',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Reset password
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse(
        AppConfig.buildUrl(AppConfig.changePasswordEndpoint),
      );
      final headers = await _getHeaders(includeAuth: false);
      final body = jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      print('🌐 API Request: POST $url');
      print('📦 Body: $body');

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(AppConfig.connectionTimeout);

      print('✅ Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse<Map<String, dynamic>>(response, null);
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      return ApiResponse.error(
        'Cannot connect to server. Please check your network connection.',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Change password (for authenticated users)
  // Future<ApiResponse<Map<String, dynamic>>> changePassword({
  //   required String currentPassword,
  //   required String newPassword,
  //   required String passwordConfirmation,
  // }) async {
  //   try {
  //     final url = Uri.parse(
  //       AppConfig.buildUrl(AppConfig.changePasswordEndpoint),
  //     );
  //     final headers = await _getHeaders(includeAuth: true);
  //     final body = jsonEncode({
  //       'current_password': currentPassword,
  //       'new_password': newPassword,
  //       'password_confirmation': passwordConfirmation,
  //     });

  //     print('🌐 API Request: POST $url');
  //     print('📦 Body: $body');

  //     final response = await http
  //         .post(url, headers: headers, body: body)
  //         .timeout(AppConfig.connectionTimeout);

  //     print('✅ Response Status: ${response.statusCode}');
  //     print('📄 Response Body: ${response.body}');

  //     return _handleResponse<Map<String, dynamic>>(response, null);
  //   } on SocketException catch (e) {
  //     print('❌ SocketException: $e');
  //     return ApiResponse.error(
  //       'Cannot connect to server. Please check your network connection.',
  //     );
  //   } catch (e) {
  //     print('❌ Unexpected error: $e');
  //     return ApiResponse.error('Unexpected error: ${e.toString()}');
  //   }
  // }

  /// Get user profile
  Future<ApiResponse<User>> getUserProfile() async {
    try {
      final url = Uri.parse(AppConfig.buildUrl(AppConfig.userProfileEndpoint));
      final headers = await _getHeaders(includeAuth: true);

      print('🌐 API Request: GET $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(AppConfig.connectionTimeout);

      print('✅ Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final result = _handleResponse<User>(
        response,
        (json) => User.fromJson(json),
      );

      if (result.success && result.data != null) {
        print('👤 User Profile Photo: ${result.data!.profilePhoto}');
      }

      return result;
    } on SocketException catch (e) {
      return ApiResponse.error(
        'Cannot connect to server. Please check your network connection.',
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? profileImage,
  }) async {
    try {
      final url = Uri.parse(
        AppConfig.buildUrl(AppConfig.updateProfileEndpoint),
      );
      final token = await _storageService.getAuthToken();

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add text fields
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['phone_number'] = phoneNumber;

      // Add profile image if provided and is a valid local file path
      if (profileImage != null && profileImage.isNotEmpty) {
        final file = File(profileImage);
        if (await file.exists()) {
          var imageFile = await http.MultipartFile.fromPath(
            'profile_photo',
            profileImage,
          );
          request.files.add(imageFile);
        }
      }

      print('🌐 API Request: POST $url');
      print('📦 Fields: ${request.fields}');
      print('📷 Image: ${profileImage != null ? 'Included' : 'Not included'}');

      // Send request
      var streamedResponse = await request.send().timeout(
        AppConfig.connectionTimeout,
      );

      // Get response
      var response = await http.Response.fromStream(streamedResponse);

      print('✅ Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final result = _handleResponse<User>(
        response,
        (json) => User.fromJson(json),
      );

      if (result.success && result.data != null) {
        print('👤 Updated Profile Photo: ${result.data!.profilePhoto}');
      }

      return result;
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      return ApiResponse.error(
        'Cannot connect to server. Please check your network connection.',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }
}
