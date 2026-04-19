import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/usecases/delete_download_usecase.dart';
import '../../domain/usecases/get_downloads_usecase.dart';
import '../../domain/usecases/share_download_usecase.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryUiState> {
  final GetDownloadsUseCase _getDownloads;
  final DeleteDownloadUseCase _deleteDownload;
  final ShareDownloadUseCase _shareDownload;

  LibraryBloc({
    required GetDownloadsUseCase getDownloads,
    required DeleteDownloadUseCase deleteDownload,
    required ShareDownloadUseCase shareDownload,
  }) : _getDownloads = getDownloads,
       _deleteDownload = deleteDownload,
       _shareDownload = shareDownload,
       super(const LibraryUiState.initial()) {
    on<LibraryLoadRequested>(_onLoad);
    on<LibraryItemShared>(_onShare);
    on<LibraryItemDeleted>(_onDelete);
  }

  Future<void> _onLoad(
    LibraryLoadRequested event,
    Emitter<LibraryUiState> emit,
  ) async {
    emit(state.copyWith(status: LibraryStatus.loading, clearError: true));
    final result = await _getDownloads(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: _map(failure),
        ),
      ),
      (items) => emit(
        state.copyWith(
          status: LibraryStatus.ready,
          items: items,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onShare(
    LibraryItemShared event,
    Emitter<LibraryUiState> emit,
  ) async {
    final result = await _shareDownload(ShareDownloadParams(event.item));
    result.fold(
      (failure) => emit(state.copyWith(transientMessage: _map(failure))),
      (_) {},
    );
  }

  Future<void> _onDelete(
    LibraryItemDeleted event,
    Emitter<LibraryUiState> emit,
  ) async {
    final result = await _deleteDownload(DeleteDownloadParams(event.id));
    result.fold(
      (failure) => emit(state.copyWith(transientMessage: _map(failure))),
      (_) {
        final next = state.items.where((e) => e.id != event.id).toList();
        emit(state.copyWith(items: next, clearTransient: true));
      },
    );
  }

  String _map(Failure failure) => switch (failure) {
    CacheFailure(:final message) => message,
    NetworkFailure(:final message) => message,
    _ => failure.message,
  };
}
