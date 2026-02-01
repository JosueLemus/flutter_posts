import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Postify')),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PostsBloc>().add(RefreshPosts());
        },
        child: BlocBuilder<PostsBloc, PostsState>(
          builder: (context, state) {
            if (state is PostsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PostsLoaded) {
              if (state.posts.isEmpty) {
                return const Center(child: Text('No posts found'));
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.posts.length
                    : state.posts.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.posts.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final post = state.posts[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${post.id}')),
                    title: Text(
                      post.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      context.push('/post_detail', extra: post);
                    },
                  );
                },
              );
            } else if (state is PostsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
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
    );
  }
}
