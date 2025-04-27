import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:fpdart/fpdart.dart';
import '../models/comment_model.dart';
import '../core/failure.dart';
import '../core/type_defs.dart';

class CommentService {
  final FirebaseFirestore _firestore;

  CommentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  FutureVoid createComment({
    required String postId,
    required String content,
    required String uid,
    required String username,
    required String userProfileImage,
  }) async {
    try {
      String commentId = const Uuid().v1();
      CommentModel comment = CommentModel(
        commentId: commentId,
        postId: postId,
        uid: uid,
        username: username,
        content: content,
        createdAt: DateTime.now(),
        userProfileImage: userProfileImage,
      );

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toJson());

      return right(null);
    } catch (e) {
      return left(Failure('Could not create comment: ${e.toString()}'));
    }
  }

  Stream<List<CommentModel>> getPostComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) {
      List<CommentModel> comments = [];
      for (var doc in event.docs) {
        comments.add(CommentModel.fromSnap(doc));
      }
      return comments;
    });
  }

  FutureVoid deleteComment({
    required String postId,
    required String commentId,
    required String uid,
  }) async {
    try {
      final commentDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (!commentDoc.exists) {
        return left(Failure('Comment does not exist'));
      }

      final commentData = commentDoc.data();
      if (commentData?['uid'] != uid) {
        return left(Failure('You can only delete your own comments'));
      }

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      return right(null);
    } catch (e) {
      return left(Failure('Could not delete comment: ${e.toString()}'));
    }
  }

  FutureVoid updateComment({
    required String postId,
    required String commentId,
    required String content,
    required String uid,
  }) async {
    try {
      final commentDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (!commentDoc.exists) {
        return left(Failure('Comment does not exist'));
      }

      final commentData = commentDoc.data();
      if (commentData?['uid'] != uid) {
        return left(Failure('You can only edit your own comments'));
      }

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({'content': content});

      return right(null);
    } catch (e) {
      return left(Failure('Could not update comment: ${e.toString()}'));
    }
  }
}
