import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/post_details/presentation/bloc/post_detail_bloc.dart';
import '../../features/post_details/presentation/bloc/post_detail_event.dart';
import '../../features/post_details/presentation/pages/post_detail_page.dart';
import '../../features/posts/domain/entities/post.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../../features/posts/presentation/bloc/posts_event.dart';
import '../../features/posts/presentation/pages/posts_page.dart';
import '../di/service_locator.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<PostsBloc>()..add(FetchPosts()),
          child: const PostsPage(),
        ),
      ),
      GoRoute(
        path: '/post_detail',
        builder: (context, state) {
          final post = state.extra as Post;
          return BlocProvider(
            create: (_) => getIt<PostDetailBloc>()..add(LoadPostDetail(post)),
            child: PostDetailPage(post: post),
          );
        },
      ),
    ],
  );
}
