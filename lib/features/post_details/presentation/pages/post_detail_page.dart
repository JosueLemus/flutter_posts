import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../posts/domain/entities/post.dart';
import '../bloc/post_detail_bloc.dart';
import '../bloc/post_detail_event.dart';
import '../bloc/post_detail_state.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: [
          BlocBuilder<PostDetailBloc, PostDetailState>(
            buildWhen: (previous, current) =>
                previous.isLiked != current.isLiked,
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: state.isLiked ? Colors.red : null,
                ),
                onPressed: () {
                  context.read<PostDetailBloc>().add(ToggleLike());
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(post.body, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Text('Comments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<PostDetailBloc, PostDetailState>(
                builder: (context, state) {
                  if (state.isLoadingComments) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.error != null) {
                    return Center(child: Text(state.error!));
                  } else if (state.comments.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }

                  return ListView.separated(
                    itemCount: state.comments.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final comment = state.comments[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(
                          comment.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(comment.body),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
