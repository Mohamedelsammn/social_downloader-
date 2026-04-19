import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/platform_detector.dart';
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
  bool _sortNewest = true;

  static const _allPlatforms = [
    SocialPlatform.instagram,
    SocialPlatform.facebook,
    SocialPlatform.tiktok,
    SocialPlatform.youtube,
    SocialPlatform.twitter,
  ];

  List<DownloadItem> _process(List<DownloadItem> items) {
    final filtered = _filter == null
        ? List<DownloadItem>.from(items)
        : items
              .where((i) => PlatformDetector.detect(i.sourceUrl) == _filter)
              .toList();
    filtered.sort(
      (a, b) => _sortNewest
          ? b.addedAt.compareTo(a.addedAt)
          : a.addedAt.compareTo(b.addedAt),
    );
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<LibraryBloc, LibraryUiState>(
      listenWhen: (prev, curr) =>
          prev.transientMessage != curr.transientMessage &&
          curr.transientMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.transientMessage!)));
      },
      builder: (context, state) {
        final items = _process(state.items);

        return RefreshIndicator(
          color: AppColors.primaryLight,
          backgroundColor: AppColors.surfaceContainerHigh,
          onRefresh: () async =>
              context.read<LibraryBloc>().add(const LibraryLoadRequested()),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
                     
                      const SizedBox(height: 30),
                      // Sort button
                      _SortButton(
                        newest: _sortNewest,
                        onToggle: () =>
                            setState(() => _sortNewest = !_sortNewest),
                      ),
                      const SizedBox(height: 30),
                      // Filter chips
                      _FilterRow(
                        selected: _filter,
                        platforms: _allPlatforms,
                        onChanged: (p) => setState(() => _filter = p),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // ── Body ────────────────────────────────────────────────────
              ..._buildBody(context, state, items),

          
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    LibraryUiState state,
    List<DownloadItem> items,
  ) {
    if (state.status == LibraryStatus.loading && state.items.isEmpty) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
              strokeWidth: 2,
            ),
          ),
        ),
      ];
    }

    if (state.status == LibraryStatus.failure && state.items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Couldn\'t load library',
            subtitle: state.errorMessage ?? 'Something went wrong.',
          ),
        ),
      ];
    }

    if (items.isEmpty) {
      return [
        SliverFillRemaining(
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
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (ctx, i) {
            final item = items[i];
            return LibraryItemCard(
              item: item,
              onShare: () =>
                  ctx.read<LibraryBloc>().add(LibraryItemShared(item)),
              onPlay: () => Navigator.of(ctx).push(
                MaterialPageRoute(builder: (_) => VideoPlayerPage(item: item)),
              ),
              onDelete: () =>
                  ctx.read<LibraryBloc>().add(LibraryItemDeleted(item.id)),
            );
          },
        ),
      ),
    ];
  }
}

// ─── Sort button ─────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final bool newest;
  final VoidCallback onToggle;
  const _SortButton({required this.newest, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort_rounded,
              color: AppColors.onSurfaceVariant,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              newest ? 'Sort by Date ↓' : 'Sort by Date ↑',
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter chips row ────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final SocialPlatform? selected;
  final List<SocialPlatform> platforms;
  final ValueChanged<SocialPlatform?> onChanged;

  const _FilterRow({
    required this.selected,
    required this.platforms,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: selected == null,
            platform: null,
            onTap: () => onChanged(null),
          ),
          ...platforms.map(
            (p) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                label: PlatformDetector.label(p),
                selected: selected == p,
                platform: p,
                onTap: () => onChanged(selected == p ? null : p),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final SocialPlatform? platform;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.platform,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Load Vault Archives button ──────────────────────────────────────────────


// ─── Empty state ─────────────────────────────────────────────────────────────

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
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
            child: Icon(icon, size: 34, color: AppColors.onSurfaceVariant),
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
