import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF1DA1F2);
  static const Color secondaryColor = Color(0xFF14171A);
  static const Color accentColor = Color(0xFF657786);
  static const Color backgroundColor = Color(0xFFE1E8ED);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color error = Colors.red;
  static const Color success = Colors.green;
}

class AppConstants {
  // Route Names
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/edit-profile';
  static const String searchRoute = '/search';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String followersCollection = 'followers';
  static const String followingCollection = 'following';

  // Default Values
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String defaultBio = 'Hey there! I am using Social Media App';
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.black,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.accentColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}
