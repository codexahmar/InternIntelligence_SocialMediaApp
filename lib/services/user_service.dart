import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String?> _uploadProfileImage(File imageFile, String uid) async {
    try {
      final fileName =
          '${uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('profile_images/$fileName');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload profile image: $e';
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String uid,
    required String username,
    required String bio,
    File? imageFile,
  }) async {
    try {
      final updateData = {
        'username': username,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageFile != null) {
        final imageUrl = await _uploadProfileImage(imageFile, uid);
        if (imageUrl != null) {
          updateData['profileImage'] = imageUrl;
        }
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updateData);
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Toggle follow user with real-time updates
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(
          _firestore
              .collection(AppConstants.usersCollection)
              .doc(currentUserId),
        );
        final targetUserDoc = await transaction.get(
          _firestore.collection(AppConstants.usersCollection).doc(targetUserId),
        );

        if (!userDoc.exists || !targetUserDoc.exists) {
          throw 'User not found';
        }

        final currentUser = UserModel.fromSnap(userDoc);
        final isFollowing = currentUser.followingList.contains(targetUserId);

        if (isFollowing) {
          // Unfollow
          transaction.update(userDoc.reference, {
            'followingList': FieldValue.arrayRemove([targetUserId]),
            'following': FieldValue.increment(-1),
          });
          transaction.update(targetUserDoc.reference, {
            'followersList': FieldValue.arrayRemove([currentUserId]),
            'followers': FieldValue.increment(-1),
          });
        } else {
          // Follow
          transaction.update(userDoc.reference, {
            'followingList': FieldValue.arrayUnion([targetUserId]),
            'following': FieldValue.increment(1),
          });
          transaction.update(targetUserDoc.reference, {
            'followersList': FieldValue.arrayUnion([currentUserId]),
            'followers': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      throw 'Failed to toggle follow: $e';
    }
  }

  // Get user by ID with stream for real-time updates
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromSnap(doc) : null);
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromSnap(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  // Get user's followers with real-time updates
  Stream<List<UserModel>> getFollowersStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return [];
      final user = UserModel.fromSnap(doc);
      List<UserModel> followers = [];

      for (String followerId in user.followersList) {
        final follower = await getUserById(followerId);
        if (follower != null) {
          followers.add(follower);
        }
      }

      return followers;
    });
  }

  // Get user's following with real-time updates
  Stream<List<UserModel>> getFollowingStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return [];
      final user = UserModel.fromSnap(doc);
      List<UserModel> following = [];

      for (String followingId in user.followingList) {
        final followingUser = await getUserById(followingId);
        if (followingUser != null) {
          following.add(followingUser);
        }
      }

      return following;
    });
  }
}
