import 'package:servix/core/services/api/api_client.dart';
import 'package:servix/data/models/auth_models.dart';
import 'package:servix/data/models/user.dart';

/// Repository for authentication related API calls
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Login user
  Future<User> login(LoginRequest request) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response.data);

    return User(
      id: loginResponse.userId,
      email: loginResponse.email,
      role: loginResponse.role,
      accessToken: loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
      tokenType: loginResponse.tokenType,
      expiresIn: loginResponse.expiresIn,
    );
  }

  /// Register client (personal or business)
  Future<RegisterClientResponse> registerClient(
    RegisterClientRequest request,
  ) async {
    final response = await _apiClient.post(
      '/auth/register/client',
      data: request.toJson(),
    );

    return RegisterClientResponse.fromJson(response.data);
  }

  /// Register service provider
  Future<RegisterProviderResponse> registerProvider(
    RegisterProviderRequest request,
  ) async {
    final response = await _apiClient.post(
      '/auth/register/provider',
      data: request.toJson(),
    );

    return RegisterProviderResponse.fromJson(response.data);
  }

  /// Verify OTP
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    final response = await _apiClient.post(
      '/auth/verify-otp',
      data: request.toJson(),
    );

    return VerifyOtpResponse.fromJson(response.data);
  }

  /// Resend OTP
  Future<void> resendOtp(ResendOtpRequest request) async {
    await _apiClient.post('/auth/resend-otp', data: request.toJson());
  }

  /// Verify ABN
  Future<VerifyAbnResponse> verifyAbn(VerifyAbnRequest request) async {
    final response = await _apiClient.post(
      '/auth/verify-abn',
      data: request.toJson(),
    );

    return VerifyAbnResponse.fromJson(response.data);
  }

  /// Upload file
  Future<FileUploadResponse> uploadFile({
    required String filePath,
    required String fileName,
  }) async {
    final response = await _apiClient.uploadFile(
      '/files/upload',
      filePath: filePath,
      fileName: fileName,
    );

    return FileUploadResponse.fromJson(response.data);
  }
}
