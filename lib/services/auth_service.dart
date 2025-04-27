import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up user
  Future<UserModel?> signUpUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        uid: cred.user!.uid,
        email: email,
        username: username,
        bio: AppConstants.defaultBio,
        profileImage: AppConstants.defaultProfileImage,
        followers: 0,
        following: 0,
        posts: 0,
        followingList: [],
        followersList: [],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(cred.user!.uid)
          .set(user.toJson());

      // Set logged in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in user
  Future<UserModel?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(cred.user!.uid)
          .get();

      // Set logged in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return UserModel.fromSnap(userDoc);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get user details
  Future<UserModel?> getUserDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .get();
      return UserModel.fromSnap(userDoc);
    }
    return null;
  }
}
