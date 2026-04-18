import 'package:equatable/equatable.dart';

class DownloadProgress extends Equatable {
  final int received;
  final int total;

  const DownloadProgress({required this.received, required this.total});

  double get ratio => total <= 0 ? 0.0 : (received / total).clamp(0.0, 1.0);
  bool get hasTotal => total > 0;

  @override
  List<Object?> get props => [received, total];
}
