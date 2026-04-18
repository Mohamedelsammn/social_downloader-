import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_size_formatter.dart';
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
    final textTheme = Theme.of(context).textTheme;
    const formatter = FileSizeFormatter();
    final dateLabel = _formatDate(item.addedAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(item: item),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          formatter.format(item.sizeBytes),
                          style: textTheme.labelMedium,
                        ),
                        _Dot(),
                        Text(
                          dateLabel,
                          style: textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _RoundIconButton(
                icon: Icons.share_outlined,
                onPressed: onShare,
                background: Colors.transparent,
                iconColor: AppColors.onSurface,
              ),
              const SizedBox(width: 8),
              _RoundIconButton(
                icon: Icons.play_arrow_rounded,
                onPressed: onPlay,
                background: AppColors.primary,
                iconColor: AppColors.onPrimary,
                size: 44,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    if (isToday) return 'Added Today';
    return DateFormat('MMM d, y').format(date);
  }
}

class _Thumbnail extends StatelessWidget {
  final DownloadItem item;
  const _Thumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceContainerHighest,
              AppColors.surfaceContainer,
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: Center(
                child: Icon(Icons.movie_creation_outlined,
                    color: AppColors.onSurfaceVariant, size: 40),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _truncate(item.contentType ?? 'video'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncate(String value) {
    if (value.length <= 14) return value;
    return value.substring(0, 14);
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('•',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color background;
  final Color iconColor;
  final double size;
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    required this.background,
    required this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: iconColor, size: size * 0.55),
        ),
      ),
    );
  }
}
