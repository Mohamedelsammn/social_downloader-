import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../downloads_library/presentation/pages/video_player_page.dart';
import '../bloc/download_bloc.dart';

class DownloadStatus extends StatelessWidget {
  final DownloadUiState state;
  const DownloadStatus({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state.phase) {
      DownloadPhase.resolving => const _Row(
        icon: _SpinningRing(),
        label: 'Fetching video...',
        color: AppColors.onSurfaceVariant,
      ),
      DownloadPhase.downloading => _DownloadingRow(progress: state.progress),
      DownloadPhase.success => _SuccessRow(item: state.lastSaved!),
      DownloadPhase.failure => _Row(
        icon: const Icon(
          Icons.error_outline,
          color: Color(0xFFFF8A8A),
          size: 18,
        ),
        label: state.errorMessage ?? 'Something went wrong.',
        color: const Color(0xFFFF8A8A),
        multiline: true,
      ),
      DownloadPhase.idle => const SizedBox(height: 20),
    };
  }
}

class _Row extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final bool multiline;
  const _Row({
    required this.icon,
    required this.label,
    required this.color,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: multiline ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadingRow extends StatelessWidget {
  final double progress;
  const _DownloadingRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: const ColoredBox(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Downloading… $percent%',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinningRing extends StatefulWidget {
  const _SpinningRing();
  @override
  State<_SpinningRing> createState() => _SpinningRingState();
}

class _SpinningRingState extends State<_SpinningRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final dynamic item;
  const _SuccessRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          const _Row(
            icon: Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            label: 'Ready to watch!',
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Share.shareXFiles([
                    XFile(item.localPath),
                  ], text: item.title),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerPage(item: item),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Watch now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
