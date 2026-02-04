import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:blute_mobile/features/profile/data/upload_remote_datasource.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final List<String> _uploadedImages = [];
  String? _selectedPartner;
  final UploadRemoteDataSource _dataSource;

  UploadBloc({UploadRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? UploadRemoteDataSource(),
      super(UploadInitial()) {
    on<PickUploadImages>(_onPickUploadImages);
    on<RemoveUploadImage>(_onRemoveUploadImage);
    on<TogglePartnerSelection>(_onTogglePartnerSelection);
    on<SubmitUploadImages>(_onSubmitUploadImages);
  }

  Future<void> _onPickUploadImages(
    PickUploadImages event,
    Emitter<UploadState> emit,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        _uploadedImages.addAll(result.paths.whereType<String>());
        emit(
          UploadUpdated(
            images: List.from(_uploadedImages),
            selectedPartner: _selectedPartner,
          ),
        );
      }
    } catch (e) {
      emit(UploadError('Error picking images: $e'));
    }
  }

  void _onRemoveUploadImage(
    RemoveUploadImage event,
    Emitter<UploadState> emit,
  ) {
    if (event.index >= 0 && event.index < _uploadedImages.length) {
      _uploadedImages.removeAt(event.index);
      emit(
        UploadUpdated(
          images: List.from(_uploadedImages),
          selectedPartner: _selectedPartner,
        ),
      );
    }
  }

  void _onTogglePartnerSelection(
    TogglePartnerSelection event,
    Emitter<UploadState> emit,
  ) {
    _selectedPartner = event.partner;
    emit(
      UploadUpdated(
        images: List.from(_uploadedImages),
        selectedPartner: _selectedPartner,
      ),
    );
  }

  Future<void> _onSubmitUploadImages(
    SubmitUploadImages event,
    Emitter<UploadState> emit,
  ) async {
    if (_selectedPartner == null) {
      emit(const UploadError('Please select a partner'));
      emit(
        UploadUpdated(
          images: List.from(_uploadedImages),
          selectedPartner: _selectedPartner,
        ),
      );
      return;
    }

    if (_uploadedImages.isEmpty) {
      emit(const UploadError('Please upload at least one screenshot'));
      emit(
        UploadUpdated(
          images: List.from(_uploadedImages),
          selectedPartner: _selectedPartner,
        ),
      );
      return;
    }

    emit(UploadLoading());

    try {
      // Upload all screenshots with partner data
      final coinsEarned = await _dataSource.uploadScreenshots(
        partner: _selectedPartner!,
        date: event.date,
        deliveryCount: event.deliveryCount,
        filePaths: _uploadedImages,
      );

      _uploadedImages.clear();
      _selectedPartner = null;

      emit(UploadSuccess(coinsEarned));
    } catch (e) {
      emit(UploadError('Upload failed: ${e.toString()}'));
      emit(
        UploadUpdated(
          images: List.from(_uploadedImages),
          selectedPartner: _selectedPartner,
        ),
      );
    }
  }
}
