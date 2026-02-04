import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/core/services/location_service.dart';
import 'package:blute_mobile/features/onboarding/data/onboarding_model.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';
import 'package:blute_mobile/shared/widgets/custom_text_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final LocationService _locationService = LocationService();
  bool _isCheckingLocation = true;

  String? _selectedEducation;
  final List<String> _educationOptions = [
    'High School',
    'Bachelor Degree',
    'Master Degree',
    'PhD',
    'Diploma',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await _locationService.handlePermission();
    if (!hasPermission) {
      if (mounted) {
        _showLocationDeniedDialog();
      }
    } else {
      // Auto-fill locality if possible
      final city = await _locationService.getCurrentCity();
      if (city != null && mounted) {
        setState(() {
          _localityController.text = city;
        });
      }
    }
    if (mounted) {
      setState(() {
        _isCheckingLocation = false;
      });
    }
  }

  void _showLocationDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Access Required'),
        content: const Text(
          'We need your location to show relevant gigs near you. Please allow "While using the app" or "Always" access.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _checkLocationPermission();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _localityController.dispose();

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime tempPickedDate = DateTime.now().subtract(
      const Duration(days: 365 * 18),
    );
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _dobController.text =
                            "${tempPickedDate.day}/${tempPickedDate.month}/${tempPickedDate.year}";
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempPickedDate,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSuccess && state.step == 'profile') {
          Navigator.pushNamed(context, '/document-upload');
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Profile Setup',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: _isCheckingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 1 of 3',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: 0.33,
                          backgroundColor: AppColors.surface,
                          color: AppColors.primary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _firstNameController,
                                hintText: 'First Name',
                                validator: _requiredValidator,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _lastNameController,
                                hintText: 'Last Name',
                                validator: _requiredValidator,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email ID',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: _dobController,
                              hintText: 'Date Of Birth',
                              validator: _requiredValidator,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _addressController,
                          hintText: 'Address',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _localityController,
                          hintText: 'Locality',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedEducation,
                          decoration: InputDecoration(
                            hintText: 'Education Qualification',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _educationOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedEducation = newValue;
                            });
                          },
                          validator: _requiredValidator,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                          ),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          dropdownColor: Colors.white,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Next: Upload Documents',
                            icon: Icons.arrow_forward,
                            isLoading: state is OnboardingLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final profileRequest = ProfileRequest(
                                  firstName: _firstNameController.text,
                                  lastName: _lastNameController.text,
                                  dob: _dobController
                                      .text, // Assuming format matches YYYY-MM-DD or backend handles it?
                                  // Backend note: backend expects YYYY-MM-DD but frontend sends DD/MM/YYYY.
                                  // I should fix format here or backend. Let's fix here.
                                  address: _addressController.text,
                                  locality: _localityController.text,
                                  email: _emailController.text,
                                  educationQualification: _selectedEducation!,
                                );
                                // Fix date format
                                // Fix date format
                                final dateParts = _dobController.text.split(
                                  '/',
                                );
                                if (dateParts.length == 3) {
                                  // Convert DD/MM/YYYY to YYYY-MM-DD
                                  final day = dateParts[0].padLeft(2, '0');
                                  final month = dateParts[1].padLeft(2, '0');
                                  final year = dateParts[2];
                                  final formattedDate = "$year-$month-$day";
                                  // Create new request with formatted date
                                  final finalRequest = ProfileRequest(
                                    firstName: profileRequest.firstName,
                                    lastName: profileRequest.lastName,
                                    dob: formattedDate,
                                    address: profileRequest.address,
                                    locality: profileRequest.locality,
                                    email: profileRequest.email,
                                    educationQualification:
                                        profileRequest.educationQualification,
                                  );
                                  context.read<OnboardingBloc>().add(
                                    SubmitProfileEvent(finalRequest),
                                  );
                                } else {
                                  context.read<OnboardingBloc>().add(
                                    SubmitProfileEvent(profileRequest),
                                  );
                                }
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
                            child: Text(
                              'Skip & do it later',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
