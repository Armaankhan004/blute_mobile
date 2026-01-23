part of 'upload_bloc.dart';

abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object> get props => [];
}

class UploadInitial extends UploadState {}

class UploadUpdated extends UploadState {
  final List<String> images;
  final String? selectedPartner;

  const UploadUpdated({required this.images, this.selectedPartner});

  @override
  List<Object> get props => [
    images,
    if (selectedPartner != null) selectedPartner!,
  ];
}

class UploadLoading extends UploadState {}

class UploadSuccess extends UploadState {
  final int coinsEarned;
  const UploadSuccess(this.coinsEarned);

  @override
  List<Object> get props => [coinsEarned];
}

class UploadError extends UploadState {
  final String message;
  const UploadError(this.message);

  @override
  List<Object> get props => [message];
}
