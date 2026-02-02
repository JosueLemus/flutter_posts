import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PostFilterType { all, liked, notLiked }

class PostFilterState extends Equatable {
  final String query;
  final PostFilterType filterType;

  const PostFilterState({
    this.query = '',
    this.filterType = PostFilterType.all,
  });

  PostFilterState copyWith({String? query, PostFilterType? filterType}) {
    return PostFilterState(
      query: query ?? this.query,
      filterType: filterType ?? this.filterType,
    );
  }

  @override
  List<Object?> get props => [query, filterType];
}

class PostFilterCubit extends Cubit<PostFilterState> {
  PostFilterCubit() : super(const PostFilterState());

  void updateSearchQuery(String query) {
    emit(state.copyWith(query: query));
  }

  void updateFilterType(PostFilterType filterType) {
    emit(state.copyWith(filterType: filterType));
  }
}
