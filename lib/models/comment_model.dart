import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final String uid;
  final String username;
  final String content;
  final DateTime createdAt;
  final String userProfileImage;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.uid,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.userProfileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'uid': uid,
      'username': username,
      'content': content,
      'createdAt': createdAt,
      'userProfileImage': userProfileImage,
    };
  }

  static CommentModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return CommentModel(
      commentId: snapshot['commentId'] ?? '',
      postId: snapshot['postId'] ?? '',
      uid: snapshot['uid'] ?? '',
      username: snapshot['username'] ?? '',
      content: snapshot['content'] ?? '',
      createdAt: (snapshot['createdAt'] as Timestamp).toDate(),
      userProfileImage: snapshot['userProfileImage'] ?? '',
    );
  }
}
