
class ApiConstants {
  ApiConstants._();


  /// Platform-aware default:
  /// - Android emulator → `http://10.0.2.2:4000` (host-loopback alias)
  /// - Web / iOS simulator / desktop → `http://localhost:4000`
  ///
  /// For a physical device, pass
  /// `--dart-define=API_BASE_URL=http://<LAN-IP>:4000`.
  static String get baseUrl {
    return 'https://socialdownloader-production.up.railway.app';
  }

  static const String resolveEndpoint = '/resolve';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
