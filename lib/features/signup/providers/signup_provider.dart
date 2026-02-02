import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servix/core/constants/app_constants.dart';
import 'package:servix/data/models/signup_data.dart';

/// Signup state notifier for managing registration flow
class SignupNotifier extends Notifier<SignupData> {
  @override
  SignupData build() {
    return SignupData.initial();
  }

  /// Update user type (service-provider or contractor)
  void setUserType(UserType userType) {
    state = state.copyWith(userType: userType);
  }

  /// Update client type (personal or business)
  void setClientType(ClientType clientType) {
    state = state.copyWith(clientType: clientType);
  }

  /// Update personal information
  void updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? companyName,
    String? userPosition,
  }) {
    state = state.copyWith(
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      email: email ?? state.email,
      address: address ?? state.address,
      companyName: companyName ?? state.companyName,
      userPosition: userPosition ?? state.userPosition,
    );
  }

  /// Update contact information
  void updateContactInfo({String? mobileNumber, String? secondaryPhoneNumber}) {
    state = state.copyWith(
      mobileNumber: mobileNumber ?? state.mobileNumber,
      secondaryPhoneNumber: secondaryPhoneNumber ?? state.secondaryPhoneNumber,
    );
  }

  /// Update password
  void updatePassword({String? password, String? confirmPassword}) {
    state = state.copyWith(
      password: password ?? state.password,
      confirmPassword: confirmPassword ?? state.confirmPassword,
    );
  }

  /// Update user ID from server response
  void setUserId(int userId) {
    state = state.copyWith(userId: userId);
  }

  /// Update OTP
  void setOtp(String otp) {
    state = state.copyWith(otp: otp);
  }

  /// Update ABN
  void setAbn(String abn) {
    state = state.copyWith(abnNumber: abn);
  }

  /// Update provider type
  void setProviderType(String providerType) {
    state = state.copyWith(providerType: providerType);
  }

  /// Update service categories
  void setServiceCategories(List<String> categories) {
    state = state.copyWith(serviceCategories: categories);
  }

  /// Add service category
  void addServiceCategory(String category) {
    final updated = List<String>.from(state.serviceCategories)..add(category);
    state = state.copyWith(serviceCategories: updated);
  }

  /// Remove service category
  void removeServiceCategory(String category) {
    final updated = List<String>.from(state.serviceCategories)
      ..remove(category);
    state = state.copyWith(serviceCategories: updated);
  }

  /// Add provider document
  void addDocument(ProviderDocumentMeta document) {
    // Remove existing document of same type if exists
    final updated = List<ProviderDocumentMeta>.from(state.providerDocuments)
      ..removeWhere((d) => d.documentType == document.documentType)
      ..add(document);
    state = state.copyWith(providerDocuments: updated);
  }

  /// Remove provider document
  void removeDocument(String documentType) {
    final updated = List<ProviderDocumentMeta>.from(state.providerDocuments)
      ..removeWhere((d) => d.documentType == documentType);
    state = state.copyWith(providerDocuments: updated);
  }

  /// Update profile image URL
  void setProfileImageUrl(String url) {
    state = state.copyWith(profileImageUrl: url);
  }

  /// Update description
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Set server errors
  void setServerErrors(Map<String, String?> errors) {
    state = state.copyWith(serverErrors: errors);
  }

  /// Clear server errors
  void clearServerErrors() {
    state = state.copyWith(serverErrors: {});
  }

  /// Reset signup data
  void reset() {
    state = SignupData.initial();
  }

  /// Get document by type
  ProviderDocumentMeta? getDocument(String documentType) {
    try {
      return state.providerDocuments.firstWhere(
        (d) => d.documentType == documentType,
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if all required documents are uploaded
  bool hasAllRequiredDocuments() {
    final requiredTypes = ['POLICE_CHECK', 'WWCC', 'INSURANCE', 'PHOTO'];
    final uploadedTypes = state.providerDocuments
        .map((d) => d.documentType)
        .toSet();
    return requiredTypes.every((type) => uploadedTypes.contains(type));
  }
}

// Signup Provider
final signupProvider = NotifierProvider<SignupNotifier, SignupData>(() {
  return SignupNotifier();
});

// Total steps provider
final signupTotalStepsProvider = Provider<int>((ref) {
  final signupData = ref.watch(signupProvider);
  return signupData.isServiceProvider ? 6 : 5;
});
