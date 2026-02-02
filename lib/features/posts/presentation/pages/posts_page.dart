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
        backgroundColor: Colors.grey[100],
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildFilterOptions(),
                    ],
                  ),
                ),
              ),

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
                                  padding: const EdgeInsets.all(16),
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
                                          padding: EdgeInsets.all(24.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    final post = visiblePosts[index];
                                    final isFavorite = favorites.contains(
                                      post.id,
                                    );

                                    return _buildPostCard(
                                      context,
                                      post,
                                      isFavorite,
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
                              const SizedBox(height: 16),
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
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<PostFilterCubit, PostFilterState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            onChanged: (value) {
              context.read<PostFilterCubit>().updateSearchQuery(value);
            },
            decoration: const InputDecoration(
              hintText: 'Search posts by title or content',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              fillColor: Colors.transparent,
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
          child: Row(
            children: [
              _buildFilterPill(
                context,
                label: 'All',
                isSelected: state.filterType == PostFilterType.all,
                onTap: () => context.read<PostFilterCubit>().updateFilterType(
                  PostFilterType.all,
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                context,
                label: 'Liked',
                isSelected: state.filterType == PostFilterType.liked,
                onTap: () => context.read<PostFilterCubit>().updateFilterType(
                  PostFilterType.liked,
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                context,
                label: 'Not Liked',
                isSelected: state.filterType == PostFilterType.notLiked,
                onTap: () => context.read<PostFilterCubit>().updateFilterType(
                  PostFilterType.notLiked,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPill(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF87CEEB) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.black54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post, bool isFavorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/post_detail', extra: post),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  'https://picsum.photos/seed/post_${post.id}/600/400',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            context.read<FavoritesCubit>().toggleFavorite(
                              post.id,
                            );
                          },
                          child: Icon(
                            Icons.favorite,
                            color: isFavorite
                                ? const Color(0xFF00E5FF)
                                : Colors.grey[300],
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
