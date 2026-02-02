import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/post.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../cubit/post_filter_cubit.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostsBloc>().add(FetchPosts());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PostFilterCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Postify')),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterOptions(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<PostsBloc>().add(RefreshPosts());
                },
                child: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, postsState) {
                    if (postsState is PostsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (postsState is PostsLoaded) {
                      return BlocBuilder<PostFilterCubit, PostFilterState>(
                        builder: (context, filterState) {
                          return BlocBuilder<FavoritesCubit, List<int>>(
                            builder: (context, favorites) {
                              final visiblePosts = _filterPosts(
                                postsState.posts,
                                filterState,
                                favorites,
                              );

                              if (visiblePosts.isEmpty) {
                                return const Center(
                                  child: Text('No posts found'),
                                );
                              }

                              return ListView.builder(
                                controller: _scrollController,
                                itemCount:
                                    visiblePosts.length +
                                    (postsState.hasReachedMax ||
                                            filterState.query.isNotEmpty ||
                                            filterState.filterType !=
                                                PostFilterType.all
                                        ? 0
                                        : 1),
                                itemBuilder: (context, index) {
                                  if (index >= visiblePosts.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  final post = visiblePosts[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${post.id}'),
                                    ),
                                    title: Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      post.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      context.push('/post_detail', extra: post);
                                    },
                                    trailing: IconButton(
                                      icon: Icon(
                                        favorites.contains(post.id)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: favorites.contains(post.id)
                                            ? Colors.red
                                            : null,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<FavoritesCubit>()
                                            .toggleFavorite(post.id);
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    } else if (postsState is PostsError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${postsState.message}'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<PostsBloc>().add(FetchPosts());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(child: Text('Welcome to Postify'));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<PostFilterCubit, PostFilterState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              context.read<PostFilterCubit>().updateSearchQuery(value);
            },
            decoration: const InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOptions() {
    return BlocBuilder<PostFilterCubit, PostFilterState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: state.filterType == PostFilterType.all,
                onSelected: () => context
                    .read<PostFilterCubit>()
                    .updateFilterType(PostFilterType.all),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Liked',
                isSelected: state.filterType == PostFilterType.liked,
                onSelected: () => context
                    .read<PostFilterCubit>()
                    .updateFilterType(PostFilterType.liked),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Not Liked',
                isSelected: state.filterType == PostFilterType.notLiked,
                onSelected: () => context
                    .read<PostFilterCubit>()
                    .updateFilterType(PostFilterType.notLiked),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Post> _filterPosts(
    List<Post> posts,
    PostFilterState filterState,
    List<int> favorites,
  ) {
    return posts.where((post) {
      final matchesQuery =
          filterState.query.isEmpty ||
          post.title.toLowerCase().contains(filterState.query.toLowerCase()) ||
          post.body.toLowerCase().contains(filterState.query.toLowerCase());

      if (!matchesQuery) return false;

      switch (filterState.filterType) {
        case PostFilterType.all:
          return true;
        case PostFilterType.liked:
          return favorites.contains(post.id);
        case PostFilterType.notLiked:
          return !favorites.contains(post.id);
      }
    }).toList();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
}
