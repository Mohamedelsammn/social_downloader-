import 'dart:math' as math;

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
                    const SizedBox(height: 32),
                    DownloadStatus(state: state),
                  ],
                ),
              ),
              if (state.phase == DownloadPhase.downloading ||
                  state.phase == DownloadPhase.resolving)
                _DownloadingOverlay(
                  state: state,
                  onCancel: () =>
                      context.read<DownloadBloc>().add(const DownloadReset()),
                ),
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

// ─── Downloading full-screen overlay ────────────────────────────────────────

class _DownloadingOverlay extends StatefulWidget {
  final DownloadUiState state;
  final VoidCallback onCancel;
  const _DownloadingOverlay({required this.state, required this.onCancel});

  @override
  State<_DownloadingOverlay> createState() => _DownloadingOverlayState();
}

class _DownloadingOverlayState extends State<_DownloadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isResolving = state.phase == DownloadPhase.resolving;
    final platform = PlatformDetector.detect(state.url);
    final pct = (state.progress * 100).clamp(0, 100).round();

    return Container(
      color: const Color(0xFF09090F),
      child: SafeArea(
        child: Column(
          children: [
            // URL bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _UrlPill(url: state.url),
            ),
            // Main card
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111118),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Platform detection label
                        _PlatformDetectedLabel(
                          platform: platform,
                          isResolving: isResolving,
                        ),
                        const SizedBox(height: 6),
                        // Filename / title
                        if (state.resolvedTitle != null &&
                            state.resolvedTitle!.isNotEmpty)
                          Text(
                            state.resolvedTitle!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        const SizedBox(height: 32),
                        // Glowing ring
                        AnimatedBuilder(
                          animation: _spinCtrl,
                          builder: (_, _) => SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(200, 200),
                                  painter: _GlowRingPainter(
                                    progress: isResolving
                                        ? 0.0
                                        : state.progress.clamp(0.0, 1.0),
                                    isIndeterminate: isResolving,
                                    spinValue: _spinCtrl.value,
                                  ),
                                ),
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1A1A28),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.video_collection_rounded,
                                    color: AppColors.primaryLight,
                                    size: 42,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Percentage
                        if (!isResolving)
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$pct',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 76,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    letterSpacing: -2,
                                  ),
                                ),
                                const TextSpan(
                                  text: '%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isResolving)
                          const Text(
                            'Detecting video…',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          isResolving ? 'Please wait…' : 'Downloading…',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Cancel button
                        GestureDetector(
                          onTap: widget.onCancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── URL pill ────────────────────────────────────────────────────────────────

class _UrlPill extends StatelessWidget {
  final String url;
  const _UrlPill({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A28),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.onSurfaceVariant,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Platform detected label ─────────────────────────────────────────────────

class _PlatformDetectedLabel extends StatelessWidget {
  final SocialPlatform platform;
  final bool isResolving;
  const _PlatformDetectedLabel({
    required this.platform,
    required this.isResolving,
  });

  @override
  Widget build(BuildContext context) {
    final text = isResolving
        ? 'DETECTING PLATFORM…'
        : '${PlatformDetector.label(platform).toUpperCase()} VIDEO DETECTED';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.play_circle_outline_rounded,
          color: AppColors.primaryLight,
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─── Glowing ring painter ────────────────────────────────────────────────────

class _GlowRingPainter extends CustomPainter {
  final double progress;
  final bool isIndeterminate;
  final double spinValue;

  const _GlowRingPainter({
    required this.progress,
    required this.isIndeterminate,
    required this.spinValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2A1845)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    double arcStart;
    double arcSweep;

    if (isIndeterminate) {
      arcStart = startAngle + spinValue * 2 * math.pi;
      arcSweep = math.pi * 1.4;
    } else {
      arcStart = startAngle;
      arcSweep = 2 * math.pi * progress;
      if (arcSweep < 0.02) return;
    }

    // Outer glow
    canvas.drawArc(
      rect,
      arcStart,
      arcSweep,
      false,
      Paint()
        ..color = const Color(0xFF7C3AED).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Inner glow
    canvas.drawArc(
      rect,
      arcStart,
      arcSweep,
      false,
      Paint()
        ..color = const Color(0xFFD2BBFF).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Crisp arc
    canvas.drawArc(
      rect,
      arcStart,
      arcSweep,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD2BBFF), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GlowRingPainter old) =>
      old.progress != progress || old.spinValue != spinValue;
}
