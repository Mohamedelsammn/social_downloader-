import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/platform_detector.dart';
import '../../../../core/widgets/platform_badge.dart';
import '../../domain/entities/download_item.dart';
import '../bloc/library_bloc.dart';
import '../widgets/library_item_card.dart';
import 'video_player_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  SocialPlatform? _filter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: BlocConsumer<LibraryBloc, LibraryUiState>(
        listenWhen: (prev, curr) =>
            prev.transientMessage != curr.transientMessage &&
            curr.transientMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.transientMessage!)));
        },
        builder: (context, state) {
          final filtered = _applyFilter(state.items);
          return RefreshIndicator(
            color: AppColors.primaryLight,
            backgroundColor: AppColors.surfaceContainerHigh,
            onRefresh: () async =>
                context.read<LibraryBloc>().add(const LibraryLoadRequested()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Downloads',
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your securely archived media collection.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        _FilterChips(
                          selected: _filter,
                          onChanged: (p) =>
                              setState(() => _filter = p),
                          availablePlatforms:
                              _detectPlatforms(state.items),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _buildBody(context, state, filtered),
              ],
            ),
          );
        },
      ),
    );
  }

  List<DownloadItem> _applyFilter(List<DownloadItem> items) {
    if (_filter == null) return items;
    return items
        .where((i) => PlatformDetector.detect(i.sourceUrl) == _filter)
        .toList();
  }

  Set<SocialPlatform> _detectPlatforms(List<DownloadItem> items) {
    return items
        .map((i) => PlatformDetector.detect(i.sourceUrl))
        .where((p) => p != SocialPlatform.unknown)
        .toSet();
  }

  Widget _buildBody(
      BuildContext context, LibraryUiState state, List<DownloadItem> items) {
    if (state.status == LibraryStatus.loading && state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.primaryLight, strokeWidth: 2),
        ),
      );
    }

    if (state.status == LibraryStatus.failure && state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load library',
          subtitle: state.errorMessage ?? 'Something went wrong.',
        ),
      );
    }

    if (items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(
          icon: Icons.folder_open_outlined,
          title: _filter != null
              ? 'No ${PlatformDetector.label(_filter!)} videos'
              : 'Your vault is empty',
          subtitle: _filter != null
              ? 'Try selecting a different filter.'
              : 'Saved videos will appear here.\nHead to the Home tab to start.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = items[index];
          return LibraryItemCard(
            item: item,
            onShare: () =>
                context.read<LibraryBloc>().add(LibraryItemShared(item)),
            onPlay: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(item: item)),
            ),
            onDelete: () =>
                context.read<LibraryBloc>().add(LibraryItemDeleted(item.id)),
          );
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final SocialPlatform? selected;
  final ValueChanged<SocialPlatform?> onChanged;
  final Set<SocialPlatform> availablePlatforms;

  const _FilterChips({
    required this.selected,
    required this.onChanged,
    required this.availablePlatforms,
  });

  @override
  Widget build(BuildContext context) {
    if (availablePlatforms.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          ...availablePlatforms.map((p) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _Chip(
                  label: PlatformDetector.label(p),
                  selected: selected == p,
                  platform: p,
                  onTap: () => onChanged(selected == p ? null : p),
                ),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final SocialPlatform? platform;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    this.platform,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (platform != null && !selected) ...[
              PlatformBadge(platform: platform!, showLabel: false),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : AppColors.onSurfaceVariant,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.outlineVariant, width: 0.5),
            ),
            child:
                Icon(icon, size: 34, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
