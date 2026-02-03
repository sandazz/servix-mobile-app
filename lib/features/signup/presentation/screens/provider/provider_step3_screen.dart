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

  void _openDocumentSheet({
    required List<DocumentType> docs,
    required String title,
    bool optional = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                            ),
                          ),
                          if (optional) ...[
                            const SizedBox(width: 6),
                            const Text(
                              '(optional)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final isUploading = _uploadingDocs[doc.key] ?? false;
                    ProviderDocumentMeta? uploaded;
                    try {
                      uploaded = ref
                          .read(signupProvider)
                          .providerDocuments
                          .firstWhere((d) => d.documentType == doc.key);
                    } catch (_) {
                      uploaded = null;
                    }
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      tileColor: const Color(0xFFF8F8F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      title: Text(
                        doc.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: uploaded != null
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: uploaded != null
                              ? const Color(0xFF15803D)
                              : AppColors.grey800,
                        ),
                      ),
                      trailing: isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: Icon(
                                uploaded != null
                                    ? Icons.check_circle
                                    : Icons.cloud_upload_outlined,
                                color: uploaded != null
                                    ? const Color(0xFF15803D)
                                    : AppColors.grey600,
                              ),
                              onPressed: () => _pickAndUploadDocument(doc),
                            ),
                      onTap: isUploading
                          ? null
                          : () => _pickAndUploadDocument(doc),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: docs.length,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
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
            const SizedBox(height: 40),
            // Header
            Image.asset(
              'assets/images/servix-logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              'Document Verification',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: WhiteRoundedContainer(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      const SizedBox(height: 8),
                      _buildUploadPanel(
                        title: 'Upload Documents',
                        docs: requiredDocs,
                        onTap: () => _openDocumentSheet(
                          docs: requiredDocs,
                          title: 'Upload Documents',
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildUploadPanel(
                        title: 'Upload Documents',
                        optional: true,
                        docs: optionalDocs,
                        onTap: () => _openDocumentSheet(
                          docs: optionalDocs,
                          title: 'Upload Documents',
                          optional: true,
                        ),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(text: 'Next', onPressed: _handleNext),
                      const SizedBox(height: 20),
                      const StepIndicator(currentStep: 3, totalSteps: 6),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'If you have a account, so',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: AppColors.white,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildUploadPanel({
    required String title,
    required List<DocumentType> docs,
    bool optional = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (optional) ...[
                  const SizedBox(width: 6),
                  Text(
                    '(optional)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload Document',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...docs.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc.displayName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
