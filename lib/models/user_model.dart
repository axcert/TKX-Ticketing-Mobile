class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
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
    this.phone,
    this.role,
    this.isVibrate,
    this.isBeep,
    this.isAutoCheckIn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': role,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
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
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVibrate: isVibrate ?? this.isVibrate,
      isBeep: isBeep ?? this.isBeep,
      isAutoCheckIn: isAutoCheckIn ?? this.isAutoCheckIn,
    );
  }
}
