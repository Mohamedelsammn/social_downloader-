import 'package:equatable/equatable.dart';

enum VideoStreamType { direct, stream }

class ResolvedVideo extends Equatable {
  final String title;
  final String downloadUrl;
  final VideoStreamType type;
  final String? contentType;
  final int? contentLength;

  /// Extra HTTP headers the upstream (e.g. YouTube via yt-dlp) expects on the
  /// download request. Empty for plain direct URLs.
  final Map<String, String> httpHeaders;

  const ResolvedVideo({
    required this.title,
    required this.downloadUrl,
    required this.type,
    this.contentType,
    this.contentLength,
    this.httpHeaders = const {},
  });

  @override
  List<Object?> get props =>
      [title, downloadUrl, type, contentType, contentLength, httpHeaders];
}
