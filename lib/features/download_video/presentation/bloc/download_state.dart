part of 'download_bloc.dart';

enum DownloadPhase { idle, resolving, downloading, success, failure }

class DownloadUiState extends Equatable {
  final String url;
  final DownloadPhase phase;
  final double progress;
  final String? resolvedTitle;
  final String? errorMessage;
  final DownloadItem? lastSaved;

  const DownloadUiState({
    required this.url,
    required this.phase,
    required this.progress,
    this.resolvedTitle,
    this.errorMessage,
    this.lastSaved,
  });

  const DownloadUiState.initial()
      : url = '',
        phase = DownloadPhase.idle,
        progress = 0.0,
        resolvedTitle = null,
        errorMessage = null,
        lastSaved = null;

  bool get isBusy =>
      phase == DownloadPhase.resolving || phase == DownloadPhase.downloading;

  DownloadUiState copyWith({
    String? url,
    DownloadPhase? phase,
    double? progress,
    String? resolvedTitle,
    String? errorMessage,
    DownloadItem? lastSaved,
    bool clearError = false,
    bool clearTitle = false,
    bool clearLastSaved = false,
  }) {
    return DownloadUiState(
      url: url ?? this.url,
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      resolvedTitle:
          clearTitle ? null : (resolvedTitle ?? this.resolvedTitle),
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      lastSaved: clearLastSaved ? null : (lastSaved ?? this.lastSaved),
    );
  }

  @override
  List<Object?> get props =>
      [url, phase, progress, resolvedTitle, errorMessage, lastSaved];
}
