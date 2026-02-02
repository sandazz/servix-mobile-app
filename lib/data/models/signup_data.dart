import 'package:equatable/equatable.dart';
import 'package:servix/core/constants/app_constants.dart';

/// Signup data model that holds all registration information
class SignupData extends Equatable {
  // User type selection
  final UserType? userType;
  final ClientType? clientType;

  // User ID from server after registration
  final int? userId;

  // Personal Information
  final String firstName;
  final String lastName;
  final String email;
  final String address;

  // Business Information (for business clients)
  final String? companyName;
  final String? userPosition;

  // Contact Information
  final String mobileNumber;
  final String? secondaryPhoneNumber;

  // Security
  final String password;
  final String confirmPassword;

  // Verification
  final String otp;
  final String abnNumber;

  // Provider Specific
  final String? providerType;
  final List<String> serviceCategories;
  final List<ProviderDocumentMeta> providerDocuments;
  final String? profileImageUrl;
  final String? description;

  // Server Errors
  final Map<String, String?> serverErrors;

  const SignupData({
    this.userType,
    this.clientType,
    this.userId,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.address = '',
    this.companyName,
    this.userPosition,
    this.mobileNumber = '',
    this.secondaryPhoneNumber,
    this.password = '',
    this.confirmPassword = '',
    this.otp = '',
    this.abnNumber = '',
    this.providerType,
    this.serviceCategories = const [],
    this.providerDocuments = const [],
    this.profileImageUrl,
    this.description,
    this.serverErrors = const {},
  });

  bool get isBusinessClient => clientType == ClientType.business;
  bool get isPersonalClient => clientType == ClientType.personal;
  bool get isServiceProvider => userType == UserType.serviceProvider;
  bool get isClient => userType == UserType.contractor;

  SignupData copyWith({
    UserType? userType,
    ClientType? clientType,
    int? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? companyName,
    String? userPosition,
    String? mobileNumber,
    String? secondaryPhoneNumber,
    String? password,
    String? confirmPassword,
    String? otp,
    String? abnNumber,
    String? providerType,
    List<String>? serviceCategories,
    List<ProviderDocumentMeta>? providerDocuments,
    String? profileImageUrl,
    String? description,
    Map<String, String?>? serverErrors,
  }) {
    return SignupData(
      userType: userType ?? this.userType,
      clientType: clientType ?? this.clientType,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
      userPosition: userPosition ?? this.userPosition,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      secondaryPhoneNumber: secondaryPhoneNumber ?? this.secondaryPhoneNumber,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      otp: otp ?? this.otp,
      abnNumber: abnNumber ?? this.abnNumber,
      providerType: providerType ?? this.providerType,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      providerDocuments: providerDocuments ?? this.providerDocuments,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      description: description ?? this.description,
      serverErrors: serverErrors ?? this.serverErrors,
    );
  }

  /// Reset to initial state
  factory SignupData.initial() => const SignupData();

  @override
  List<Object?> get props => [
    userType,
    clientType,
    userId,
    firstName,
    lastName,
    email,
    address,
    companyName,
    userPosition,
    mobileNumber,
    secondaryPhoneNumber,
    password,
    confirmPassword,
    otp,
    abnNumber,
    providerType,
    serviceCategories,
    providerDocuments,
    profileImageUrl,
    description,
    serverErrors,
  ];
}

/// Provider document metadata
class ProviderDocumentMeta extends Equatable {
  final String documentType;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String fileKey;
  final int expiryTime;
  final String documentFormat;
  final bool isMandatory;

  const ProviderDocumentMeta({
    required this.documentType,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.fileKey,
    required this.expiryTime,
    required this.documentFormat,
    required this.isMandatory,
  });

  factory ProviderDocumentMeta.fromJson(Map<String, dynamic> json) {
    return ProviderDocumentMeta(
      documentType: json['documentType'] ?? '',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      fileKey: json['fileKey'] ?? '',
      expiryTime: json['expiryTime'] ?? 0,
      documentFormat: json['documentFormat'] ?? 'FILE',
      isMandatory: json['isMandatory'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileKey': fileKey,
      'expiryTime': expiryTime,
      'documentFormat': documentFormat,
      'isMandatory': isMandatory,
    };
  }

  @override
  List<Object?> get props => [
    documentType,
    filePath,
    fileName,
    fileSize,
    fileKey,
    expiryTime,
    documentFormat,
    isMandatory,
  ];
}
