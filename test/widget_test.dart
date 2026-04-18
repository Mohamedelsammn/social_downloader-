import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:social_downloader/core/utils/file_size_formatter.dart';
import 'package:social_downloader/core/utils/url_validator.dart';

void main() {
  group('UrlValidator', () {
    const validator = UrlValidator();

    test('accepts http/https URLs', () {
      expect(validator.isValid('https://example.com/video.mp4'), isTrue);
      expect(validator.isValid('http://10.0.2.2:4000/x.mp4'), isTrue);
    });

    test('rejects empty / malformed / non-http URLs', () {
      expect(validator.isValid(''), isFalse);
      expect(validator.isValid('not a url'), isFalse);
      expect(validator.isValid('ftp://example.com/x'), isFalse);
      expect(validator.isValid('example.com/x.mp4'), isFalse);
    });
  });

  group('FileSizeFormatter', () {
    const f = FileSizeFormatter();

    test('formats sizes across units', () {
      expect(f.format(null), '—');
      expect(f.format(0), '—');
      expect(f.format(512), '512 B');
      expect(f.format(2048), '2.0 KB');
      expect(f.format(1024 * 1024 * 3), '3.0 MB');
    });
  });

  testWidgets('TextButton is pressable (sanity)', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tap me'));
    expect(tapped, isTrue);
  });
}
