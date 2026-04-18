import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../downloads_library/presentation/bloc/library_bloc.dart';
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
    final textTheme = Theme.of(context).textTheme;

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
          context
              .read<LibraryBloc>()
              .add(const LibraryLoadRequested());
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video Saver',
                  style: textTheme.displaySmall?.copyWith(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Paste a link to download video',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                _ActionCard(
                  child: Column(
                    children: [
                      UrlInputField(
                        controller: _controller,
                        enabled: !state.isBusy,
                        onChanged: (value) => context
                            .read<DownloadBloc>()
                            .add(UrlChanged(value)),
                        onPastePressed: () => context
                            .read<DownloadBloc>()
                            .add(const PasteFromClipboardRequested()),
                      ),
                      const SizedBox(height: 24),
                      DownloadButton(
                        enabled: state.url.trim().isNotEmpty,
                        loading: state.isBusy,
                        onPressed: () => context
                            .read<DownloadBloc>()
                            .add(const DownloadRequested()),
                      ),
                      DownloadStatus(state: state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Widget child;
  const _ActionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.ambientShadow.withValues(alpha: 0.6),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
