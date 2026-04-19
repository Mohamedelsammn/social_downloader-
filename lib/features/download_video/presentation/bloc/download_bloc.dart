import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/url_validator.dart';
import '../../../downloads_library/domain/entities/download_item.dart';
import '../../domain/entities/download_progress.dart';
import '../../domain/entities/resolved_video.dart';
import '../../domain/usecases/download_video_usecase.dart';
import '../../domain/usecases/resolve_video_usecase.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadUiState> {
  final ResolveVideoUseCase _resolveVideo;
  final DownloadVideoUseCase _downloadVideo;
  final UrlValidator _validator;
  final Future<String?> Function() _clipboardReader;

  DownloadBloc({
    required ResolveVideoUseCase resolveVideo,
    required DownloadVideoUseCase downloadVideo,
    UrlValidator validator = const UrlValidator(),
    Future<String?> Function()? clipboardReader,
  }) : _resolveVideo = resolveVideo,
       _downloadVideo = downloadVideo,
       _validator = validator,
       _clipboardReader = clipboardReader ?? _defaultClipboardReader,
       super(const DownloadUiState.initial()) {
    on<UrlChanged>(_onUrlChanged);
    on<PasteFromClipboardRequested>(_onPaste);
    on<DownloadRequested>(_onDownloadRequested);
    on<DownloadReset>((_, emit) => emit(const DownloadUiState.initial()));
    on<ProgressTick>(_onProgressTick);
  }

  static Future<String?> _defaultClipboardReader() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  void _onUrlChanged(UrlChanged event, Emitter<DownloadUiState> emit) {
    emit(
      state.copyWith(
        url: event.url,
        phase: DownloadPhase.idle,
        clearError: true,
        clearTitle: true,
        clearLastSaved: true,
        progress: 0,
      ),
    );
  }

  Future<void> _onPaste(
    PasteFromClipboardRequested event,
    Emitter<DownloadUiState> emit,
  ) async {
    final text = await _clipboardReader();
    if (text == null || text.trim().isEmpty) return;
    add(UrlChanged(text.trim()));
  }

  void _onProgressTick(ProgressTick event, Emitter<DownloadUiState> emit) {
    if (state.phase != DownloadPhase.downloading) return;
    emit(state.copyWith(progress: event.ratio));
  }

  Future<void> _onDownloadRequested(
    DownloadRequested event,
    Emitter<DownloadUiState> emit,
  ) async {
    if (state.isBusy) return;

    final url = state.url.trim();
    if (!_validator.isValid(url)) {
      emit(
        state.copyWith(
          phase: DownloadPhase.failure,
          errorMessage:
              'Please paste a valid http or https URL (e.g. https://example.com/video.mp4).',
          progress: 0,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: DownloadPhase.resolving,
        clearError: true,
        progress: 0,
      ),
    );

    final resolveResult = await _resolveVideo(ResolveVideoParams(url));

    final ResolvedVideo? resolved = resolveResult.fold<ResolvedVideo?>(
      (_) => null,
      (video) => video,
    );
    final Failure? resolveFailure = resolveResult.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );

    if (resolveFailure != null || resolved == null) {
      emit(
        state.copyWith(
          phase: DownloadPhase.failure,
          errorMessage: _mapFailure(resolveFailure ?? const UnknownFailure()),
          progress: 0,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: DownloadPhase.downloading,
        resolvedTitle: resolved.title,
        progress: 0,
      ),
    );

    final download = await _downloadVideo(
      DownloadVideoParams(
        video: resolved,
        sourceUrl: url,
        onProgress: (DownloadProgress p) {
          if (!p.hasTotal) return;
          if (isClosed) return;
          add(ProgressTick(p.ratio));
        },
      ),
    );

    download.fold(
      (failure) => emit(
        state.copyWith(
          phase: DownloadPhase.failure,
          errorMessage: _mapFailure(failure),
        ),
      ),
      (item) => emit(
        state.copyWith(
          phase: DownloadPhase.success,
          progress: 1.0,
          lastSaved: item,
          clearError: true,
        ),
      ),
    );
  }

  String _mapFailure(Failure failure) => switch (failure) {
    NetworkFailure() =>
      'No internet connection. Check your network and try again.',
    TimeoutFailure() =>
      'The server took too long to respond. Try again in a moment.',
    InvalidUrlFailure(:final message) => message,
    UnsupportedMediaFailure(:final message) => message,
    DownloadFailure(:final message) => message,
    CacheFailure(:final message) => message,
    ServerFailure(:final message) => message,
    _ => failure.message,
  };
}
