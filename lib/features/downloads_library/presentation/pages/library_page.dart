import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/library_bloc.dart';
import '../widgets/library_item_card.dart';
import 'video_player_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

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
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceContainerHigh,
            onRefresh: () async {
              context.read<LibraryBloc>().add(const LibraryLoadRequested());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Library',
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your securely archived media collection.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _buildBody(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LibraryUiState state) {
    if (state.status == LibraryStatus.loading && state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.status == LibraryStatus.failure && state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyMessage(
          title: 'Couldn\'t load library',
          subtitle: state.errorMessage ?? 'Something went wrong.',
        ),
      );
    }

    if (state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyMessage(
          title: 'Your vault is empty',
          subtitle:
              'Saved videos will appear here. Head to the Download tab to start.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      sliver: SliverList.separated(
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return LibraryItemCard(
            item: item,
            onShare: () => context
                .read<LibraryBloc>()
                .add(LibraryItemShared(item)),
            onPlay: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideoPlayerPage(item: item),
              ),
            ),
            onDelete: () => context
                .read<LibraryBloc>()
                .add(LibraryItemDeleted(item.id)),
          );
        },
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyMessage({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_outlined,
              size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            title,
            style: textTheme.headlineSmall,
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
