/// Login request model
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

/// Login response model
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final int userId;
  final String email;
  final String role;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.email,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 3600,
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? 'CLIENT',
    );
  }
}

/// Register client request model
class RegisterClientRequest {
  final String clientType;
  final String firstName;
  final String lastName;
  final String? companyName;
  final String? userPosition;
  final String email;
  final String phoneNumber;
  final String? secondaryPhoneNumber;
  final String password;
  final String address;

  const RegisterClientRequest({
    required this.clientType,
    required this.firstName,
    required this.lastName,
    this.companyName,
    this.userPosition,
    required this.email,
    required this.phoneNumber,
    this.secondaryPhoneNumber,
    required this.password,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'clientType': clientType,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'address': address,
    };

    if (companyName != null && companyName!.isNotEmpty) {
      map['companyName'] = companyName;
    }
    if (userPosition != null && userPosition!.isNotEmpty) {
      map['userPosition'] = userPosition;
    }
    if (secondaryPhoneNumber != null && secondaryPhoneNumber!.isNotEmpty) {
      map['secondaryPhoneNumber'] = secondaryPhoneNumber;
    }

    return map;
  }
}

/// Register client response model
class RegisterClientResponse {
  final String message;
  final bool success;
  final int userId;
  final String? otp;

  const RegisterClientResponse({
    required this.message,
    required this.success,
    required this.userId,
    this.otp,
  });

  factory RegisterClientResponse.fromJson(Map<String, dynamic> json) {
    return RegisterClientResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      userId: json['userId'] ?? 0,
      otp: json['otp'],
    );
  }
}

/// Register provider request model
class RegisterProviderRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String address;
  final String providerType;
  final List<String> serviceCategories;
  final List<Map<String, dynamic>> providerDocuments;
  final bool? isMainCategory;
  final String? description;
  final String? profileImageUrl;

  const RegisterProviderRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.address,
    required this.providerType,
    required this.serviceCategories,
    required this.providerDocuments,
    this.isMainCategory,
    this.description,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'address': address,
      'providerType': providerType,
      'serviceCategories': serviceCategories,
      'providerDocuments': providerDocuments,
      if (isMainCategory != null) 'isMainCategory': isMainCategory,
      if (description != null) 'description': description,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }
}

/// Register provider response model
class RegisterProviderResponse {
  final int userId;
  final String? otp;
  final String status;
  final String message;

  const RegisterProviderResponse({
    required this.userId,
    this.otp,
    required this.status,
    required this.message,
  });

  factory RegisterProviderResponse.fromJson(Map<String, dynamic> json) {
    return RegisterProviderResponse(
      userId: json['userId'] ?? 0,
      otp: json['otp'],
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

/// Verify OTP request model
class VerifyOtpRequest {
  final int userId;
  final String otp;

  const VerifyOtpRequest({required this.userId, required this.otp});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'otp': otp};
  }
}

/// Verify OTP response model
class VerifyOtpResponse {
  final bool success;
  final String message;

  const VerifyOtpResponse({required this.success, required this.message});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

/// Resend OTP request model
class ResendOtpRequest {
  final int userId;

  const ResendOtpRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }
}

/// Verify ABN request model
class VerifyAbnRequest {
  final int userId;
  final String abn;

  const VerifyAbnRequest({required this.userId, required this.abn});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'abn': abn};
  }
}

/// Verify ABN response model
class VerifyAbnResponse {
  final bool success;
  final String message;
  final String? companyName;
  final String? abnStatus;

  const VerifyAbnResponse({
    required this.success,
    required this.message,
    this.companyName,
    this.abnStatus,
  });

  factory VerifyAbnResponse.fromJson(Map<String, dynamic> json) {
    return VerifyAbnResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      companyName: json['companyName'],
      abnStatus: json['abnStatus'],
    );
  }
}

/// File upload response model
class FileUploadResponse {
  final String status;
  final FileUploadData data;

  const FileUploadResponse({required this.status, required this.data});

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      status: json['status'] ?? '',
      data: FileUploadData.fromJson(json['data'] ?? {}),
    );
  }
}

/// File upload data model
class FileUploadData {
  final String fileUrl;
  final String fileKey;
  final int size;
  final String mimeType;
  final int expiresIn;

  const FileUploadData({
    required this.fileUrl,
    required this.fileKey,
    required this.size,
    required this.mimeType,
    required this.expiresIn,
  });

  factory FileUploadData.fromJson(Map<String, dynamic> json) {
    return FileUploadData(
      fileUrl: json['fileUrl'] ?? '',
      fileKey: json['fileKey'] ?? '',
      size: json['size'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      expiresIn: json['expiresIn'] ?? 86400,
    );
  }
}
