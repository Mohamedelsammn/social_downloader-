import '../../domain/entities/resolved_video.dart';

class ResolvedVideoModel extends ResolvedVideo {
  const ResolvedVideoModel({
    required super.title,
    required super.downloadUrl,
    required super.type,
    super.contentType,
    super.contentLength,
    super.httpHeaders,
  });

  factory ResolvedVideoModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String?)?.toLowerCase();
    final type = rawType == 'stream'
        ? VideoStreamType.stream
        : VideoStreamType.direct;

    final rawLength = json['contentLength'];
    final length = rawLength is int
        ? rawLength
        : (rawLength is num ? rawLength.toInt() : null);

    final rawHeaders = json['httpHeaders'];
    final headers = <String, String>{};
    if (rawHeaders is Map) {
      rawHeaders.forEach((k, v) {
        if (k is String && v is String && v.isNotEmpty) {
          headers[k] = v;
        }
      });
    }

    return ResolvedVideoModel(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled video',
      downloadUrl: json['downloadUrl'] as String,
      type: type,
      contentType: json['contentType'] as String?,
      contentLength: length,
      httpHeaders: headers,
    );
  }
}
