import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String bio;
  final String profileImage;
  final int followers;
  final int following;
  final int posts;
  final List<String> followingList;
  final List<String> followersList;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.bio,
    required this.profileImage,
    required this.followers,
    required this.following,
    required this.posts,
    required this.followingList,
    required this.followersList,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'profileImage': profileImage,
      'followers': followers,
      'following': following,
      'posts': posts,
      'followingList': followingList,
      'followersList': followersList,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot['uid'] ?? '',
      email: snapshot['email'] ?? '',
      username: snapshot['username'] ?? '',
      bio: snapshot['bio'] ?? '',
      profileImage: snapshot['profileImage'] ?? '',
      followers: snapshot['followers'] ?? 0,
      following: snapshot['following'] ?? 0,
      posts: snapshot['posts'] ?? 0,
      followingList: List<String>.from(snapshot['followingList'] ?? []),
      followersList: List<String>.from(snapshot['followersList'] ?? []),
      createdAt: (snapshot['createdAt'] as Timestamp).toDate(),
      updatedAt:
          snapshot['updatedAt'] != null
              ? (snapshot['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      profileImage: map['profileImage'] ?? '',
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      posts: map['posts'] ?? 0,
      followingList: List<String>.from(map['followingList'] ?? []),
      followersList: List<String>.from(map['followersList'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'profileImage': profileImage,
      'followers': followers,
      'following': following,
      'posts': posts,
      'followingList': followingList,
      'followersList': followersList,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? bio,
    String? profileImage,
    int? followers,
    int? following,
    int? posts,
    List<String>? followingList,
    List<String>? followersList,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: posts ?? this.posts,
      followingList: followingList ?? this.followingList,
      followersList: followersList ?? this.followersList,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
