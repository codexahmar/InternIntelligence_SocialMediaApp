import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String uid;
  final String caption;
  final String imageUrl;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String username;
  final String userProfileImage;

  PostModel({
    required this.id,
    required this.uid,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.updatedAt,
    required this.username,
    required this.userProfileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'caption': caption,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'username': username,
      'userProfileImage': userProfileImage,
    };
  }

  static PostModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return PostModel(
      id: snapshot['id'] ?? '',
      uid: snapshot['uid'] ?? '',
      caption: snapshot['caption'] ?? '',
      imageUrl: snapshot['imageUrl'] ?? '',
      likes: snapshot['likes'] ?? 0,
      comments: snapshot['comments'] ?? 0,
      createdAt: (snapshot['createdAt'] as Timestamp).toDate(),
      updatedAt: snapshot['updatedAt'] != null
          ? (snapshot['updatedAt'] as Timestamp).toDate()
          : null,
      username: snapshot['username'] ?? '',
      userProfileImage: snapshot['userProfileImage'] ?? '',
    );
  }

  PostModel copyWith({
    String? id,
    String? uid,
    String? caption,
    String? imageUrl,
    int? likes,
    int? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? username,
    String? userProfileImage,
  }) {
    return PostModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      userProfileImage: userProfileImage ?? this.userProfileImage,
    );
  }
}
