import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';

class UserTile extends StatelessWidget {
  final String userId;
  final bool showFollowButton;

  const UserTile({
    Key? key,
    required this.userId,
    this.showFollowButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;
    final userService = UserService();

    return StreamBuilder<UserModel?>(
      stream: userService.getUserStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final isCurrentUser = currentUser?.uid == user.uid;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.profileImage),
            backgroundColor: Colors.grey[200],
          ),
          title: Text(user.username),
          subtitle: Text(user.bio),
          trailing: showFollowButton && !isCurrentUser
              ? StreamBuilder<bool>(
                  stream: FirebaseFirestore.instance
                      .collection(AppConstants.usersCollection)
                      .doc(currentUser?.uid)
                      .snapshots()
                      .map((snapshot) =>
                          (snapshot.data()?['followingList'] as List<dynamic>?)
                              ?.contains(user.uid) ??
                          false),
                  builder: (context, followSnapshot) {
                    final isFollowing = followSnapshot.data ?? false;
                    return ElevatedButton(
                      onPressed: () async {
                        if (currentUser != null) {
                          await userService.toggleFollow(
                              currentUser.uid, user.uid);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? Colors.grey[300]
                            : AppColors.primaryColor,
                        foregroundColor:
                            isFollowing ? Colors.black : Colors.white,
                      ),
                      child: Text(isFollowing ? 'Following' : 'Follow'),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}
