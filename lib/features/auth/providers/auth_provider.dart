import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servix/core/services/api/api_client.dart';
import 'package:servix/core/services/storage/storage_service.dart';
import 'package:servix/data/models/auth_models.dart';
import 'package:servix/data/models/user.dart';
import 'package:servix/data/repositories/auth_repository.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

/// Authentication state
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth state notifier
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Initialize storage
    final storage = ref.read(storageServiceProvider);
    await storage.init();

    // Check for existing user
    final userData = storage.getUser();
    if (userData != null) {
      final user = User.fromJson(userData);
      if (user.accessToken != null) {
        // Set auth token in API client
        ref.read(apiClientProvider).setAuthToken(user.accessToken!);
        return AuthState(user: user, isAuthenticated: true);
      }
    }

    return const AuthState();
  }

  /// Sign in with username and password
  Future<void> signIn(String username, String password) async {
    state = AsyncValue.data(
      state.value!.copyWith(isLoading: true, error: null),
    );

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(
        LoginRequest(username: username, password: password),
      );

      // Save user data
      final storage = ref.read(storageServiceProvider);
      await storage.saveUser(user.toJson());
      if (user.accessToken != null) {
        await storage.saveAccessToken(user.accessToken!);
        ref.read(apiClientProvider).setAuthToken(user.accessToken!);
      }
      if (user.refreshToken != null) {
        await storage.saveRefreshToken(user.refreshToken!);
      }

      state = AsyncValue.data(AuthState(user: user, isAuthenticated: true));
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(isLoading: false, error: e.toString()),
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearAll();
    ref.read(apiClientProvider).clearAuthToken();
    state = const AsyncValue.data(AuthState());
  }

  /// Update user after registration
  void updateUser(User user) {
    state = AsyncValue.data(state.value!.copyWith(user: user));
  }
}

// Auth State Provider
final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
