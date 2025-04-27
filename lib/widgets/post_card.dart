import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constants/app_constants.dart';
import '../models/post_model.dart';
import '../providers/user_provider.dart';
import '../services/post_service.dart';
import '../screens/post/comments_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onPostUpdated;

  const PostCard({
    Key? key,
    required this.post,
    this.onPostUpdated,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  final TextEditingController _captionController = TextEditingController();
  bool _isLiked = false;
  bool _isLoadingLike = false;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _loadCommentsCount();
  }

  Future<void> _loadCommentsCount() async {
    try {
      final count = await _postService.getCommentsCount(widget.post.id);
      if (mounted) {
        setState(() => _commentsCount = count);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _checkIfLiked() async {
    try {
      final currentUser = context.read<UserProvider>().user;
      if (currentUser != null) {
        bool isLiked = await _postService.isLikedByUser(
          postId: widget.post.id,
          uid: currentUser.uid,
        );
        if (mounted) setState(() => _isLiked = isLiked);
      }
    } catch (e) {
      print(e);
    }
  }

  void _showEditDialog() {
    _captionController.text = widget.post.caption;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Post',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    onPressed: () async {
                      try {
                        await _postService.editPost(
                          postId: widget.post.id,
                          caption: _captionController.text.trim(),
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          widget.onPostUpdated?.call();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _postService.deletePost(
                  postId: widget.post.id,
                  uid: widget.post.uid,
                );
                if (mounted) {
                  Navigator.pop(context);
                  widget.onPostUpdated?.call();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserProvider>().user;
    final isOwner = currentUser?.uid == widget.post.uid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.post.userProfileImage),
            ),
            title: Text(
              widget.post.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: widget.post.updatedAt != null
                ? Text('Edited ${timeago.format(widget.post.updatedAt!)}')
                : Text(timeago.format(widget.post.createdAt)),
            trailing: isOwner
                ? PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => Future(() => _showEditDialog()),
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                        onTap: () => Future(() => _showDeleteDialog()),
                      ),
                    ],
                  )
                : null,
          ),
          if (widget.post.imageUrl.isNotEmpty)
            Image.network(
              widget.post.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.post.caption),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? AppColors.error : null,
                ),
                onPressed: _isLoadingLike
                    ? null
                    : () async {
                        if (currentUser != null) {
                          setState(() => _isLoadingLike = true);
                          await _postService.toggleLike(
                            postId: widget.post.id,
                            uid: currentUser.uid,
                          );
                          setState(() {
                            _isLiked = !_isLiked;
                            _isLoadingLike = false;
                          });
                          widget.onPostUpdated?.call();
                        }
                      },
              ),
              Text('${widget.post.likes}'),
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.post.id,
                        postAuthorId: widget.post.uid,
                      ),
                    ),
                  ).then((_) => _loadCommentsCount());
                },
              ),
              Text('$_commentsCount'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
