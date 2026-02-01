import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.postId,
    required super.id,
    required super.name,
    required super.email,
    required super.body,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      postId: json['postId'] as int,
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}
