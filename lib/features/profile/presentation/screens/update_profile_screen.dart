import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:blute_mobile/features/profile/data/user_model.dart';
import 'package:blute_mobile/features/onboarding/data/onboarding_model.dart';
import 'package:intl/intl.dart';

class UpdateProfileScreen extends StatefulWidget {
  final UserResponse user;

  const UpdateProfileScreen({super.key, required this.user});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _educationController;
  late TextEditingController _localityController;
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    final profile = widget.user.profile;
    _firstNameController = TextEditingController(text: profile?.firstName);
    _lastNameController = TextEditingController(text: profile?.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _educationController = TextEditingController(
      text: profile?.educationQualification,
    );
    _localityController = TextEditingController(text: profile?.locality);
    if (profile?.dob != null) {
      _selectedDob = DateTime.tryParse(profile!.dob!);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDob == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Date of Birth')),
        );
        return;
      }

      final profileRequest = ProfileRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        dob: _selectedDob!.toIso8601String().split('T')[0],
        educationQualification: _educationController.text.trim(),
        locality: _localityController.text.trim(),
        address: _localityController.text.trim(), // Reuse locality for address
      );

      context.read<OnboardingBloc>().add(SubmitProfileEvent(profileRequest));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSuccess && state.step == 'profile') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  hint: 'Enter first name',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  hint: 'Enter last name',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Date of Birth',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDob != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDob!)
                              : 'Select Date of Birth',
                          style: TextStyle(
                            color: _selectedDob != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Education Qualification',
                  controller: _educationController,
                  hint: 'e.g. Graduate',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Locality/Area',
                  controller: _localityController,
                  hint: 'Enter your locality',
                ),
                const SizedBox(height: 40),
                BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'Update Profile',
                      isLoading: state is OnboardingLoading,
                      onPressed: _submitUpdate,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
