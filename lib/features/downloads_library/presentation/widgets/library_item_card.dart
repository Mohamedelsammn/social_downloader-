import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../../core/utils/platform_detector.dart';
import '../../../../core/widgets/platform_badge.dart';
import '../../domain/entities/download_item.dart';

class LibraryItemCard extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback onShare;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const LibraryItemCard({
    super.key,
    required this.item,
    required this.onShare,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final platform = PlatformDetector.detect(item.sourceUrl);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPlay,
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            highlightColor: Colors.white.withValues(alpha: 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(
                  platform: platform,
                  onShare: onShare,
                  onPlay: onPlay,
                  onDelete: onDelete,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateStatusRow(date: item.addedAt),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MetaChipsRow(item: item),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Thumbnail ──────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final SocialPlatform platform;
  final VoidCallback onShare;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _Thumbnail({
    required this.platform,
    required this.onShare,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(gradient: _platformGradient(platform)),
          ),
          Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: Colors.white.withValues(alpha: 0.12),
              size: 80,
            ),
          ),
          // Subtle vignette at bottom
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x66000000)],
                stops: [0.5, 1.0],
              ),
            ),
          ),
          // Platform badge — top-left
          Positioned(
            top: 10,
            left: 10,
            child: PlatformBadge(platform: platform),
          ),
          // 3-dot menu — top-right
          Positioned(
            top: 4,
            right: 4,
            child: _ThumbMenu(
              onShare: onShare,
              onPlay: onPlay,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }

  static LinearGradient _platformGradient(SocialPlatform p) => switch (p) {
        SocialPlatform.youtube => const LinearGradient(
            colors: [Color(0xFF1A0808), Color(0xFF3B0F0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        SocialPlatform.instagram => const LinearGradient(
            colors: [Color(0xFF18001E), Color(0xFF2E0635)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        SocialPlatform.tiktok => const LinearGradient(
            colors: [Color(0xFF05050F), Color(0xFF10102A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        SocialPlatform.facebook => const LinearGradient(
            colors: [Color(0xFF030D1F), Color(0xFF08204A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        SocialPlatform.twitter => const LinearGradient(
            colors: [Color(0xFF060608), Color(0xFF10101C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        _ => const LinearGradient(
            colors: [Color(0xFF0E0E1A), Color(0xFF1C1C2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      };
}

// ─── Thumbnail 3-dot menu ───────────────────────────────────────────────────

class _ThumbMenu extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _ThumbMenu({
    required this.onShare,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_vert_rounded,
            color: Colors.white, size: 18),
      ),
      color: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'play',
          child: _MenuItem(
            icon: Icons.play_arrow_rounded,
            label: 'Play',
            color: AppColors.primaryLight,
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: _MenuItem(
            icon: Icons.share_rounded,
            label: 'Share',
            color: AppColors.onSurface,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: _MenuItem(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            color: AppColors.error,
          ),
        ),
      ],
      onSelected: (v) {
        switch (v) {
          case 'play':
            onPlay();
          case 'share':
            onShare();
          case 'delete':
            onDelete();
        }
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuItem(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Date + status row ──────────────────────────────────────────────────────

class _DateStatusRow extends StatelessWidget {
  final DateTime date;
  const _DateStatusRow({required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today_outlined,
            color: AppColors.onSurfaceVariant, size: 12),
        const SizedBox(width: 4),
        Text(
          _label(date),
          style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(width: 6),
        const Text('·',
            style: TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 12)),
        const SizedBox(width: 6),
        const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 12),
        const SizedBox(width: 4),
        const Text(
          'Completed',
          style: TextStyle(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  static String _label(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    final time = DateFormat('h:mm a').format(date);
    if (d == today) return 'Today, $time';
    if (d == yesterday) return 'Yesterday, $time';
    return DateFormat('MMM d, yyyy').format(date);
  }
}

// ─── Meta chips ─────────────────────────────────────────────────────────────

class _MetaChipsRow extends StatelessWidget {
  final DownloadItem item;
  const _MetaChipsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    const formatter = FileSizeFormatter();
    final fmt = _fmt(item.contentType);

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _MetaChip(icon: Icons.sd_storage_rounded,
            label: formatter.format(item.sizeBytes)),
        _MetaChip(icon: Icons.movie_creation_outlined, label: fmt),
      ],
    );
  }

  static String _fmt(String? ct) {
    if (ct == null) return 'MP4';
    final l = ct.toLowerCase();
    if (l.contains('mp4')) return 'MP4';
    if (l.contains('webm')) return 'WEBM';
    if (l.contains('avi')) return 'AVI';
    if (l.contains('mkv')) return 'MKV';
    if (l.contains('mpegurl') || l.contains('m3u')) return 'HLS';
    if (l.contains('video')) return 'VIDEO';
    return 'MP4';
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.06), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
