part of 'download_bloc.dart';

sealed class DownloadEvent extends Equatable {
  const DownloadEvent();
  @override
  List<Object?> get props => [];
}

class UrlChanged extends DownloadEvent {
  final String url;
  const UrlChanged(this.url);
  @override
  List<Object?> get props => [url];
}

class PasteFromClipboardRequested extends DownloadEvent {
  const PasteFromClipboardRequested();
}

class DownloadRequested extends DownloadEvent {
  const DownloadRequested();
}

class DownloadReset extends DownloadEvent {
  const DownloadReset();
}

class ProgressTick extends DownloadEvent {
  final double ratio;
  const ProgressTick(this.ratio);
  @override
  List<Object?> get props => [ratio];
}
