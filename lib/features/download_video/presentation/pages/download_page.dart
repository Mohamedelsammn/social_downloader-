import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/platform_detector.dart';
import '../../../../core/widgets/platform_badge.dart';
import '../../../downloads_library/domain/entities/download_item.dart';
import '../../../downloads_library/presentation/bloc/library_bloc.dart';
import '../../../downloads_library/presentation/pages/video_player_page.dart';
import '../bloc/download_bloc.dart';
import '../widgets/download_button.dart';
import '../widgets/download_status.dart';
import '../widgets/url_input_field.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DownloadBloc, DownloadUiState>(
      listenWhen: (prev, curr) =>
          prev.phase != curr.phase || prev.url != curr.url,
      listener: (context, state) {
        if (_controller.text != state.url) {
          _controller.value = TextEditingValue(
            text: state.url,
            selection: TextSelection.collapsed(offset: state.url.length),
          );
        }
        if (state.phase == DownloadPhase.success && state.lastSaved != null) {
          context.read<LibraryBloc>().add(const LibraryLoadRequested());
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),

                    _buildInputCard(context, state),
                    const SizedBox(height: 24),
                    Center(child: const PlatformSupportRow()),

                    const SizedBox(height: 50),
                    DownloadButton(
                      enabled: state.url.trim().isNotEmpty,
                      loading: state.isBusy,
                      onPressed: () => context.read<DownloadBloc>().add(
                        const DownloadRequested(),
                      ),
                    ),
                    DownloadStatus(state: state),

                    const SizedBox(height: 32),

                    _RecentVault(currentPhase: state.phase),
                  ],
                ),
              ),
              if (state.phase == DownloadPhase.downloading ||
                  state.phase == DownloadPhase.resolving)
                _DownloadingOverlay(state: state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'The Kinetic Vault',
          style: TextStyle(
            color: AppColors.primaryLight,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          textAlign: TextAlign.center,
          "Paste your link below to securely download\nhigh-quality media from your favorite\nplatforms.",
        ),
      ],
    );
  }

  Widget _buildInputCard(BuildContext context, DownloadUiState state) {
    return UrlInputField(
      controller: _controller,
      enabled: !state.isBusy,
      onChanged: (v) => context.read<DownloadBloc>().add(UrlChanged(v)),
      onPastePressed: () =>
          context.read<DownloadBloc>().add(const PasteFromClipboardRequested()),
    );
  }
}

class _RecentVault extends StatelessWidget {
  final DownloadPhase currentPhase;
  const _RecentVault({required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryUiState>(
      builder: (context, libState) {
        final items = libState.items.take(3).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Vault',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'See all →',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecentCard(item: item),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecentCard extends StatelessWidget {
  final DownloadItem item;
  const _RecentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final platform = PlatformDetector.detect(item.sourceUrl);

    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => VideoPlayerPage(item: item))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.primaryLight,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (platform != SocialPlatform.unknown)
                    PlatformBadge(platform: platform),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadingOverlay extends StatelessWidget {
  final DownloadUiState state;
  const _DownloadingOverlay({required this.state});

  @override
  Widget build(BuildContext context) {
    final isResolving = state.phase == DownloadPhase.resolving;
    final percent = (state.progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Container(
      color: AppColors.background.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: isResolving ? null : state.progress.clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryLight,
                    ),
                  ),
                  if (!isResolving)
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isResolving ? 'Fetching video info…' : 'Downloading…',
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (state.resolvedTitle != null && state.resolvedTitle!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
                child: Text(
                  state.resolvedTitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
