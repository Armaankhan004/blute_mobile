import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final List<String> _uploadedImages = [];
  String? _selectedPartner;

  UploadBloc() : super(UploadInitial()) {
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
      // Re-emit state so UI doesn't stay in error if needed, or just let UI handle it.
      // Ideally we want to show snackbar but keep "Updated" state visible.
      // For simplicity, we emit Updated again after a momentary error could be tricky without listener.
      // We'll rely on BlocListener in UI to show snackbar for Error state, and then we might need to verify if we lost state.
      // Better: Emit error, let UI show it, UI stays on screen. But if we emit Error, build might change.
      // We should probably emit state update after error if we want to preserve UI.
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
      // Re-emit state to reset UI from error state?
      // We will emit Updated right after so the UI rebuilds correctly if it was replaced by error widget
      // But usually we use Listener for errors.
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

    // Simulate upload
    await Future.delayed(const Duration(seconds: 1));

    emit(UploadSuccess(_uploadedImages.length));

    // Clear after success? Or keep?
    // Usually we navigate away or show dialog. State stays Success until reset.
  }
}
