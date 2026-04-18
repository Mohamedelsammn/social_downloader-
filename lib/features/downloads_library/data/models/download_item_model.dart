import '../../domain/entities/download_item.dart';

class DownloadItemModel extends DownloadItem {
  const DownloadItemModel({
    required super.id,
    required super.title,
    required super.localPath,
    required super.sourceUrl,
    required super.sizeBytes,
    required super.addedAt,
    super.contentType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'localPath': localPath,
        'sourceUrl': sourceUrl,
        'sizeBytes': sizeBytes,
        'addedAt': addedAt.toIso8601String(),
        'contentType': contentType,
      };

  factory DownloadItemModel.fromJson(Map<String, dynamic> json) {
    return DownloadItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      localPath: json['localPath'] as String,
      sourceUrl: json['sourceUrl'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      addedAt: DateTime.parse(json['addedAt'] as String),
      contentType: json['contentType'] as String?,
    );
  }

  factory DownloadItemModel.fromEntity(DownloadItem e) {
    return DownloadItemModel(
      id: e.id,
      title: e.title,
      localPath: e.localPath,
      sourceUrl: e.sourceUrl,
      sizeBytes: e.sizeBytes,
      addedAt: e.addedAt,
      contentType: e.contentType,
    );
  }
}
