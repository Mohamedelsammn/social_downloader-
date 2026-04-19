enum SocialPlatform { instagram, facebook, tiktok, youtube, twitter, unknown }

class PlatformDetector {
  const PlatformDetector._();

  static SocialPlatform detect(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('instagram.com')) return SocialPlatform.instagram;
    if (lower.contains('facebook.com') ||
        lower.contains('fb.watch') ||
        lower.contains('fb.com')) {
      return SocialPlatform.facebook;
    }
    if (lower.contains('tiktok.com') || lower.contains('vm.tiktok')) {
      return SocialPlatform.tiktok;
    }
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return SocialPlatform.youtube;
    }
    if (lower.contains('twitter.com') || lower.contains('x.com')) {
      return SocialPlatform.twitter;
    }
    return SocialPlatform.unknown;
  }

  static String label(SocialPlatform platform) => switch (platform) {
        SocialPlatform.instagram => 'Instagram',
        SocialPlatform.facebook => 'Facebook',
        SocialPlatform.tiktok => 'TikTok',
        SocialPlatform.youtube => 'YouTube',
        SocialPlatform.twitter => 'X (Twitter)',
        SocialPlatform.unknown => 'Video',
      };
}
