import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create post
  Future<void> createPost({
    required String uid,
    required String caption,
    required String imageUrl,
    required String username,
    required String userProfileImage,
  }) async {
    try {
      final post = PostModel(
        id: '',
        uid: uid,
        caption: caption,
        imageUrl: imageUrl,
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
        username: username,
        userProfileImage: userProfileImage,
      );

      // Add post and update the document with its ID
      final docRef = await _firestore
          .collection(AppConstants.postsCollection)
          .add(post.toMap());
      await docRef.update({'id': docRef.id});

      // Update user's post count
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'posts': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to create post: $e';
    }
  }

  // Delete post
  Future<void> deletePost({required String postId, required String uid}) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .delete();

      // Decrease user's post count
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'posts': FieldValue.increment(-1),
      });
    } catch (e) {
      throw 'Failed to delete post: $e';
    }
  }

  // Edit post
  Future<void> editPost({
    required String postId,
    required String caption,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'caption': caption,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to edit post: $e';
    }
  }

  // Add comment
  Future<void> addComment({
    required String postId,
    required String uid,
    required String comment,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .add({
        'uid': uid,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment comment count
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'comments': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to add comment: $e';
    }
  }

  // Toggle like
  Future<void> toggleLike({required String postId, required String uid}) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.likesCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        // Unlike
        await doc.reference.delete();
        await _firestore
            .collection(AppConstants.postsCollection)
            .doc(postId)
            .update({
          'likes': FieldValue.increment(-1),
        });
      } else {
        // Like
        await doc.reference.set({
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _firestore
            .collection(AppConstants.postsCollection)
            .doc(postId)
            .update({
          'likes': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw 'Failed to toggle like: $e';
    }
  }

  // Check if post is liked by user
  Future<bool> isLikedByUser({
    required String postId,
    required String uid,
  }) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.likesCollection)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get user posts with real-time updates
  Stream<List<PostModel>> getUserPosts(String uid) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromSnap(doc)).toList());
  }

  // Get comments count
  Future<int> getCommentsCount(String postId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .count()
          .get();
      return snapshot.count ?? 0; // Handle null case by returning 0
    } catch (e) {
      return 0; // Return 0 in case of error
    }
  }
}
