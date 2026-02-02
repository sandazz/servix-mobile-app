import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/constants/app_constants.dart';
import 'package:servix/core/services/api/api_exception.dart';
import 'package:servix/data/models/auth_models.dart';
import 'package:servix/data/models/signup_data.dart';
import 'package:servix/data/repositories/auth_repository.dart';
import 'package:servix/features/auth/providers/auth_provider.dart';
import 'package:servix/features/signup/providers/signup_provider.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';
import 'package:servix/shared/widgets/step_indicator.dart';
import 'package:servix/shared/widgets/text_fields.dart';

/// Provider signup step 4 - Profile Picture & Description
class ProviderStep4Screen extends ConsumerStatefulWidget {
  const ProviderStep4Screen({super.key});

  @override
  ConsumerState<ProviderStep4Screen> createState() =>
      _ProviderStep4ScreenState();
}

class _ProviderStep4ScreenState extends ConsumerState<ProviderStep4Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    final signupData = ref.read(signupProvider);
    _descriptionController = TextEditingController(
      text: signupData.description ?? '',
    );
    _profileImageUrl = signupData.profileImageUrl;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingImage = true;
        _errorMessage = null;
      });

      final repository = ref.read(authRepositoryProvider);
      final response = await repository.uploadFile(
        filePath: image.path,
        fileName: image.name,
      );

      setState(() {
        _profileImageUrl = response.data.fileUrl;
      });

      // Add as document
      final document = ProviderDocumentMeta(
        documentType: 'PHOTO',
        filePath: response.data.fileUrl.split('?').first,
        fileName: image.name,
        fileSize: response.data.size,
        fileKey: response.data.fileKey,
        expiryTime: DateTime.now()
            .add(Duration(seconds: response.data.expiresIn))
            .millisecondsSinceEpoch,
        documentFormat: 'IMAGE',
        isMandatory: true,
      );

      ref.read(signupProvider.notifier).addDocument(document);
      ref
          .read(signupProvider.notifier)
          .setProfileImageUrl(response.data.fileUrl.split('?').first);
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to upload image. Please try again.';
      });
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImageUrl == null) {
      setState(() {
        _errorMessage = 'Please upload a profile picture';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final signupData = ref.read(signupProvider);

      // Update description
      ref
          .read(signupProvider.notifier)
          .setDescription(_descriptionController.text.trim());

      // Create registration request
      final request = RegisterProviderRequest(
        firstName: signupData.firstName,
        lastName: signupData.lastName,
        email: signupData.email,
        phoneNumber: signupData.mobileNumber,
        password: signupData.password,
        address: signupData.address,
        providerType: signupData.providerType ?? 'PROFESSIONAL',
        serviceCategories: signupData.serviceCategories,
        providerDocuments: signupData.providerDocuments
            .map((d) => d.toJson())
            .toList(),
        isMainCategory: true,
        description: signupData.description,
        profileImageUrl: signupData.profileImageUrl,
      );

      final repository = ref.read(authRepositoryProvider);
      final response = await repository.registerProvider(request);

      // Update signup data with user ID and OTP
      ref.read(signupProvider.notifier).setUserId(response.userId);
      if (response.otp != null) {
        ref.read(signupProvider.notifier).setOtp(response.otp!);
      }

      if (mounted) {
        context.go('/provider-signup/step5');
      }
    } on ApiException catch (e) {
      print(e);
      setState(() {
        _errorMessage = e.message;
      });
    } on SocketException catch (e) {
      setState(() {
        _errorMessage =
            'Network error: failed to reach host. Check your internet or DNS settings.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/provider-signup/step3'),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const StepIndicator(currentStep: 4, totalSteps: 6),
            const SizedBox(height: 20),
            // Header
            const Text(
              'Your Profile',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // Form
            Expanded(
              child: WhiteRoundedContainer(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error Message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Profile Picture
                        const Text(
                          'Profile Picture *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: _isUploadingImage
                                ? null
                                : _pickAndUploadImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey100,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _profileImageUrl != null
                                          ? AppColors.success
                                          : AppColors.grey300,
                                      width: 2,
                                    ),
                                    image: _profileImageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              _profileImageUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _profileImageUrl == null
                                      ? Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppColors.grey400,
                                        )
                                      : null,
                                ),
                                if (_isUploadingImage)
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Tap to upload your profile picture',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Description
                        CustomTextField(
                          label: 'About You *',
                          hint:
                              'Tell clients about your experience, skills, and what makes you stand out...',
                          controller: _descriptionController,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Minimum 50 characters',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Submit Button
                        PrimaryButton(
                          text: 'Create Account',
                          onPressed: _handleSubmit,
                          isLoading: _isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
