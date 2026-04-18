part of 'library_bloc.dart';

enum LibraryStatus { initial, loading, ready, failure }

class LibraryUiState extends Equatable {
  final LibraryStatus status;
  final List<DownloadItem> items;
  final String? errorMessage;
  final String? transientMessage;

  const LibraryUiState({
    required this.status,
    required this.items,
    this.errorMessage,
    this.transientMessage,
  });

  const LibraryUiState.initial()
      : status = LibraryStatus.initial,
        items = const [],
        errorMessage = null,
        transientMessage = null;

  LibraryUiState copyWith({
    LibraryStatus? status,
    List<DownloadItem>? items,
    String? errorMessage,
    String? transientMessage,
    bool clearError = false,
    bool clearTransient = false,
  }) {
    return LibraryUiState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      transientMessage:
          clearTransient ? null : (transientMessage ?? this.transientMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, transientMessage];
}
