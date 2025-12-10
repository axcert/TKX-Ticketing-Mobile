import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePhoto;
  final String? phone;
  final String? role;
  final bool? isVibrate;
  final bool? isBeep;
  final bool? isAutoCheckIn;
  String get fullName => '$firstName $lastName';

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profilePhoto,
    this.phone,
    this.role,
    this.isVibrate,
    this.isBeep,
    this.isAutoCheckIn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle profile photo URL - construct full URL if relative path
    String? profilePhotoUrl;
    if (json['profile_photo'] != null &&
        json['profile_photo'].toString().isNotEmpty) {
      final photoPath = json['profile_photo'].toString();
      print('🔍 Original photo path from API: "$photoPath"');

      // Check if it's already a full URL (starts with http:// or https://)
      if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
        profilePhotoUrl = photoPath;
        print('✅ Already full URL: $profilePhotoUrl');
      } else {
        // It's a relative path, construct full URL
        // Ensure exactly one slash between base URL and path
        final baseUrl = AppConfig.baseUrl;
        final cleanPath = photoPath.startsWith('/') ? photoPath : '/$photoPath';
        profilePhotoUrl = '$baseUrl/storage/$cleanPath';
        print('🔧 Constructed URL: $profilePhotoUrl');
      }
    }

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePhoto: profilePhotoUrl,
      phone: json['phone_number'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_photo': profilePhoto,
      'phone': phone,
      'role': role,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePhoto,
    String? phone,
    String? role,
    bool? isVibrate,
    bool? isBeep,
    bool? isAutoCheckIn,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVibrate: isVibrate ?? this.isVibrate,
      isBeep: isBeep ?? this.isBeep,
      isAutoCheckIn: isAutoCheckIn ?? this.isAutoCheckIn,
    );
  }
}
