import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/platform_detector.dart';

class PlatformBadge extends StatelessWidget {
  final SocialPlatform platform;
  final bool showLabel;

  const PlatformBadge({
    super.key,
    required this.platform,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _gradient(platform);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 20 : 90,
        vertical: showLabel ? 8 : 5,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),

      child: showLabel
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    color: gradient == null ? _solidColor(platform) : null,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon(platform),
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  PlatformDetector.label(platform),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            )
          : const SizedBox(width: 8, height: 8),
    );
  }

  static LinearGradient? _gradient(SocialPlatform p) => switch (p) {
    SocialPlatform.instagram => AppColors.instagramGradient,
    _ => null,
  };

  static Color _solidColor(SocialPlatform p) => switch (p) {
    SocialPlatform.facebook => AppColors.facebookBlue,
    SocialPlatform.youtube => AppColors.youtubeRed,
    SocialPlatform.tiktok => const Color.fromARGB(255, 0, 0, 0),
    SocialPlatform.twitter => const Color.fromARGB(255, 0, 0, 0),
    _ => AppColors.surfaceContainerHigh,
  };

  static IconData _icon(SocialPlatform p) => switch (p) {
    SocialPlatform.instagram => Icons.camera_alt_outlined,
    SocialPlatform.facebook => Icons.facebook,
    SocialPlatform.tiktok => Icons.tiktok,
    SocialPlatform.youtube => Icons.play_arrow_rounded,
    SocialPlatform.twitter => Icons.close_rounded,
    _ => Icons.link,
  };
}

/// A row of platform support chips shown on the download screen.
class PlatformSupportRow extends StatelessWidget {
  const PlatformSupportRow({super.key});

  static const _platforms = [
    SocialPlatform.instagram,
    SocialPlatform.facebook,
    SocialPlatform.tiktok,
    SocialPlatform.youtube,
    SocialPlatform.twitter,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlatformBadge(platform: _platforms[0]),
            const SizedBox(width: 15),
            PlatformBadge(platform: _platforms[1]),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlatformBadge(platform: _platforms[2]),
            const SizedBox(width: 15),
            PlatformBadge(platform: _platforms[3]),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [PlatformBadge(platform: _platforms[4])],
        ),
      ],
    );
  }
}
