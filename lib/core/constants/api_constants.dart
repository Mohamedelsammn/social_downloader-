import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class ApiConstants {
  ApiConstants._();

  /// Override at build time with:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:4000
  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Platform-aware default:
  /// - Android emulator → `http://10.0.2.2:4000` (host-loopback alias)
  /// - Web / iOS simulator / desktop → `http://localhost:4000`
  ///
  /// For a physical device, pass
  /// `--dart-define=API_BASE_URL=http://<LAN-IP>:4000`.
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  static const String resolveEndpoint = '/resolve';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
