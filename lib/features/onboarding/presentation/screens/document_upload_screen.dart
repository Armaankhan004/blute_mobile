import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  PlatformFile? _aadharFile;
  PlatformFile? _panFile;
  PlatformFile? _otherFile;

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          switch (type) {
            case 'aadhar':
              _aadharFile = result.files.first;
              break;
            case 'pan':
              _panFile = result.files.first;
              break;
            case 'other':
              _otherFile = result.files.first;
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  void _removeFile(String type) {
    setState(() {
      switch (type) {
        case 'aadhar':
          _aadharFile = null;
          break;
        case 'pan':
          _panFile = null;
          break;
        case 'other':
          _otherFile = null;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upload Documents for KYC'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2 of 3',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.66,
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 32),
            Text(
              'Upload Documents',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload a clear image of your Documents. Ensure all details are visible.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aadhaar Card',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildUploadCard(
              context,
              'Upload Aadhar Card',
              'Tap to upload your Aadhaar card',
              'aadhar',
              _aadharFile,
            ),
            const SizedBox(height: 24),
            const Text(
              'PAN Card',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildUploadCard(
              context,
              'Upload PAN Card',
              'Tap to upload your PAN Card',
              'pan',
              _panFile,
            ),
            const SizedBox(height: 24),
            const Text(
              'Other Documents',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildUploadCard(
              context,
              'Upload Other Documents',
              'Tap to upload other supporting docs',
              'other',
              _otherFile,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Next: Add Bank Details',
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (_aadharFile != null && _panFile != null) {
                    Navigator.pushNamed(context, '/bank-details');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please upload Aadhar and PAN card.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                child: const Text('Skip & do it later'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(
    BuildContext context,
    String title,
    String subtitle,
    String type,
    PlatformFile? file,
  ) {
    bool isFileSelected = file != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isFileSelected ? AppColors.primary : AppColors.border,
          style: isFileSelected ? BorderStyle.solid : BorderStyle.none,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isFileSelected) ...[
            const Icon(Icons.check_circle, color: AppColors.primary, size: 40),
            const SizedBox(height: 8),
            Text(
              file.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${(file.size / 1024).toStringAsFixed(2)} KB',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                onPressed: () => _removeFile(type),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => _pickFile(type),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
