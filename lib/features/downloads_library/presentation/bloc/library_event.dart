part of 'library_bloc.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();
  @override
  List<Object?> get props => [];
}

class LibraryLoadRequested extends LibraryEvent {
  const LibraryLoadRequested();
}

class LibraryItemShared extends LibraryEvent {
  final DownloadItem item;
  const LibraryItemShared(this.item);
  @override
  List<Object?> get props => [item];
}

class LibraryItemDeleted extends LibraryEvent {
  final String id;
  const LibraryItemDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
