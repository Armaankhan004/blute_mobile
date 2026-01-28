import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/onboarding/data/onboarding_model.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';
import 'package:blute_mobile/shared/widgets/custom_text_field.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _ifscCodeController.dispose();
    _upiIdController.dispose();
    super.dispose();
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
        if (state is OnboardingSuccess && state.step == 'bank') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/success', // Or dashboard
            (route) => false,
          );
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
            title: const Text('Enter Bank Account Details'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 3 of 3',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: AppColors.surface,
                    color: AppColors.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Bank Account Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add you bank account details or UPI details',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _accountNumberController,
                    hintText: 'Account Number',
                    validator: _requiredValidator,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _bankNameController,
                    hintText: 'Bank Name',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _branchNameController,
                    hintText: 'Branch Name',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _ifscCodeController,
                    hintText: 'IFSC Code',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _upiIdController,
                    hintText: 'UPI ID',
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Select Preferred Gigs',
                      icon: Icons.arrow_forward,
                      isLoading: state is OnboardingLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final bankRequest = BankRequest(
                            accountNumber: _accountNumberController.text,
                            bankName: _bankNameController.text,
                            branchName: _branchNameController.text,
                            ifscCode: _ifscCodeController.text,
                            upiId: _upiIdController.text.isNotEmpty
                                ? _upiIdController.text
                                : null,
                          );
                          context.read<OnboardingBloc>().add(
                            SubmitBankEvent(bankRequest),
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
          ),
        );
      },
    );
  }
}
