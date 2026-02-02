import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/constants/app_constants.dart';
import 'package:servix/core/services/api/api_exception.dart';
import 'package:servix/data/models/signup_data.dart';
import 'package:servix/data/repositories/auth_repository.dart';
import 'package:servix/features/auth/providers/auth_provider.dart';
import 'package:servix/features/signup/providers/signup_provider.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';
import 'package:servix/shared/widgets/step_indicator.dart';

/// Provider signup step 3 - Document Uploads
class ProviderStep3Screen extends ConsumerStatefulWidget {
  const ProviderStep3Screen({super.key});

  @override
  ConsumerState<ProviderStep3Screen> createState() =>
      _ProviderStep3ScreenState();
}

class _ProviderStep3ScreenState extends ConsumerState<ProviderStep3Screen> {
  final Map<String, bool> _uploadingDocs = {};
  String? _errorMessage;

  Future<void> _pickAndUploadDocument(DocumentType docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      setState(() {
        _uploadingDocs[docType.key] = true;
        _errorMessage = null;
      });

      final repository = ref.read(authRepositoryProvider);
      final response = await repository.uploadFile(
        filePath: file.path!,
        fileName: file.name,
      );

      // Create document metadata
      final document = ProviderDocumentMeta(
        documentType: docType.key,
        filePath: response.data.fileUrl,
        fileName: file.name,
        fileSize: response.data.size,
        fileKey: response.data.fileKey,
        expiryTime: DateTime.now()
            .add(Duration(seconds: response.data.expiresIn))
            .millisecondsSinceEpoch,
        documentFormat: _getDocumentFormat(file.extension ?? ''),
        isMandatory: docType.isMandatory,
      );

      ref.read(signupProvider.notifier).addDocument(document);
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to upload document. Please try again.';
      });
    } finally {
      setState(() {
        _uploadingDocs[docType.key] = false;
      });
    }
  }

  String _getDocumentFormat(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'IMAGE';
      default:
        return 'FILE';
    }
  }

  void _handleNext() {
    // Ensure the required documents shown on this step are uploaded
    final uploadedTypes = ref
        .read(signupProvider)
        .providerDocuments
        .map((d) => d.documentType)
        .toSet();

    final requiredKeys = [
      DocumentType.policeCheck.key,
      DocumentType.wwcc.key,
      DocumentType.insurance.key,
    ];

    final missing = requiredKeys.where((k) => !uploadedTypes.contains(k));
    if (missing.isNotEmpty) {
      setState(() {
        _errorMessage =
            'Please upload all required documents (Police Check, WWCC, Insurance)';
      });
      return;
    }

    context.go('/provider-signup/step4');
  }

  @override
  Widget build(BuildContext context) {
    final signupData = ref.watch(signupProvider);

    // Required documents
    final requiredDocs = [
      DocumentType.policeCheck,
      DocumentType.wwcc,
      DocumentType.insurance,
    ];

    // Optional documents
    final optionalDocs = [
      DocumentType.tradeCertification,
      DocumentType.education,
      DocumentType.experience,
    ];

    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/provider-signup/step2'),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const StepIndicator(currentStep: 3, totalSteps: 6),
            const SizedBox(height: 20),
            // Header
            const Text(
              'Document Verification',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload required verification documents',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 30),
            // Document List
            Expanded(
              child: WhiteRoundedContainer(
                child: SingleChildScrollView(
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
                      // Required Documents Section
                      const Text(
                        'Required Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...requiredDocs.map(
                        (docType) => _buildDocumentTile(
                          docType: docType,
                          signupData: signupData,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Optional Documents Section
                      const Text(
                        'Optional Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...optionalDocs.map(
                        (docType) => _buildDocumentTile(
                          docType: docType,
                          signupData: signupData,
                          isRequired: false,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Next Button
                      PrimaryButton(text: 'Next', onPressed: _handleNext),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile({
    required DocumentType docType,
    required SignupData signupData,
    required bool isRequired,
  }) {
    ProviderDocumentMeta? uploadedDoc;
    try {
      uploadedDoc = signupData.providerDocuments.firstWhere(
        (d) => d.documentType == docType.key,
      );
    } catch (_) {
      uploadedDoc = null;
    }
    final isUploading = _uploadingDocs[docType.key] ?? false;
    final isUploaded = uploadedDoc != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isUploaded ? AppColors.success : AppColors.grey300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.success.withOpacity(0.1)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isUploaded ? Icons.check_circle : Icons.description_outlined,
            color: isUploaded ? AppColors.success : AppColors.grey500,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                docType.displayName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: isUploaded
            ? Text(
                uploadedDoc.fileName,
                style: const TextStyle(fontSize: 12, color: AppColors.success),
                overflow: TextOverflow.ellipsis,
              )
            : const Text(
                'Tap to upload',
                style: TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
        trailing: isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: Icon(
                  isUploaded ? Icons.refresh : Icons.upload_file,
                  color: isUploaded ? AppColors.grey500 : AppColors.primaryBlue,
                ),
                onPressed: () => _pickAndUploadDocument(docType),
              ),
        onTap: isUploading ? null : () => _pickAndUploadDocument(docType),
      ),
    );
  }
}
