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
    const formatter = FileSizeFormatter();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPlay,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _Thumbnail(platform: platform),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (platform != SocialPlatform.unknown) ...[
                            PlatformBadge(platform: platform),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            formatter.format(item.sizeBytes),
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '·',
                            style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(item.addedAt),
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _MenuButton(
                  onShare: onShare,
                  onPlay: onPlay,
                  onDelete: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    if (isToday) return 'Today';
    return DateFormat('MMM d').format(date);
  }
}

class _Thumbnail extends StatelessWidget {
  final SocialPlatform platform;
  const _Thumbnail({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh,
            AppColors.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: AppColors.primaryLight,
              size: 30,
            ),
          ),
          if (platform != SocialPlatform.unknown)
            Positioned(
              right: 5,
              bottom: 5,
              child: PlatformBadge(platform: platform, showLabel: false),
            ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _MenuButton({
    required this.onShare,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          color: AppColors.onSurfaceVariant, size: 20),
      color: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'play',
          child: _MenuItem(
              icon: Icons.play_arrow_rounded,
              label: 'Play',
              color: AppColors.primaryLight),
        ),
        const PopupMenuItem(
          value: 'share',
          child: _MenuItem(
              icon: Icons.share_rounded,
              label: 'Share',
              color: AppColors.onSurface),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: _MenuItem(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppColors.error),
        ),
      ],
      onSelected: (value) {
        switch (value) {
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
        Text(label, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }
}
