import 'package:equatable/equatable.dart';

class DownloadItem extends Equatable {
  final String id;
  final String title;
  final String localPath;
  final String sourceUrl;
  final int sizeBytes;
  final DateTime addedAt;
  final String? contentType;

  const DownloadItem({
    required this.id,
    required this.title,
    required this.localPath,
    required this.sourceUrl,
    required this.sizeBytes,
    required this.addedAt,
    this.contentType,
  });

  @override
  List<Object?> get props =>
      [id, title, localPath, sourceUrl, sizeBytes, addedAt, contentType];
}
