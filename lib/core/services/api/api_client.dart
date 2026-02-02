import 'package:dio/dio.dart';
import 'package:servix/core/config/app_config.dart';
import 'package:servix/core/services/api/api_exception.dart';

/// API client for making HTTP requests
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 API Request: ${options.method} ${options.uri}');
          print('📤 Request Body: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 Response Status: ${response.statusCode}');
          print('📥 Response Body: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file with multipart form data
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    required String fileName,
    Map<String, dynamic>? additionalData,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?additionalData,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle DioException and convert to ApiException
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please try again.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final data = error.response?.data;
        String message = 'An error occurred';

        if (data is Map<String, dynamic>) {
          message = data['message'] ?? data['error'] ?? message;
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          error: data?.toString(),
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled', statusCode: 0);
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Network error. Please check your connection.',
          statusCode: 0,
        );
      default:
        return ApiException(
          message: error.message ?? 'An unexpected error occurred',
          statusCode: 500,
        );
    }
  }
}
