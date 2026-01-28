import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:blute_mobile/features/onboarding/data/onboarding_model.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class SubmitProfileEvent extends OnboardingEvent {
  final ProfileRequest profileData;

  const SubmitProfileEvent(this.profileData);

  @override
  List<Object> get props => [profileData];
}

class SubmitBankEvent extends OnboardingEvent {
  final BankRequest bankData;

  const SubmitBankEvent(this.bankData);

  @override
  List<Object> get props => [bankData];
}

class DocumentPayload {
  final PlatformFile file;
  final String fileType;

  const DocumentPayload({required this.file, required this.fileType});
}

class UploadDocumentsEvent extends OnboardingEvent {
  final List<DocumentPayload> documents;

  const UploadDocumentsEvent(this.documents);

  @override
  List<Object> get props => [documents];
}
