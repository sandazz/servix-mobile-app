import 'package:equatable/equatable.dart';

/// User data model
class User extends Equatable {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String role;
  final String? status;
  final String? profileImageUrl;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.role,
    this.status,
    this.profileImageUrl,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? email;
  }

  bool get isClient => role == 'CLIENT';
  bool get isProvider => role == 'PROVIDER';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] ?? json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'CLIENT',
      status: json['status'],
      profileImageUrl: json['profileImageUrl'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenType: json['tokenType'],
      expiresIn: json['expiresIn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? role,
    String? status,
    String? profileImageUrl,
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phoneNumber,
    role,
    status,
    profileImageUrl,
    accessToken,
    refreshToken,
    tokenType,
    expiresIn,
  ];
}
