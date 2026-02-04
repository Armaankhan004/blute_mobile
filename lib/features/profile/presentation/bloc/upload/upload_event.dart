part of 'upload_bloc.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object> get props => [];
}

class PickUploadImages extends UploadEvent {
  const PickUploadImages();
}

class RemoveUploadImage extends UploadEvent {
  final int index;
  const RemoveUploadImage(this.index);

  @override
  List<Object> get props => [index];
}

class TogglePartnerSelection extends UploadEvent {
  final String partner;
  const TogglePartnerSelection(this.partner);

  @override
  List<Object> get props => [partner];
}

class SubmitUploadImages extends UploadEvent {
  final DateTime date;
  final int deliveryCount;

  const SubmitUploadImages({required this.date, required this.deliveryCount});

  @override
  List<Object> get props => [date, deliveryCount];
}
