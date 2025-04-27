import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../widgets/user_tile.dart';
import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _userIds = []; // Store user IDs instead of UserModel

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _userIds = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final currentUser = context.read<UserProvider>().user;
      // Convert query to lowercase for case-insensitive search
      String lowercaseQuery = query.toLowerCase();

      final QuerySnapshot results = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .get();

      List<String> userIds = [];
      for (var doc in results.docs) {
        UserModel user = UserModel.fromSnap(doc);
        // Exclude current user from search results
        if (user.username.toLowerCase().contains(lowercaseQuery) &&
            user.uid != currentUser?.uid) {
          userIds.add(user.uid);
        }
      }

      if (mounted) {
        setState(() {
          _userIds = userIds;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _searchUsers('');
                      },
                    )
                  : null,
              hintStyle: AppTextStyles.bodyText.copyWith(color: AppColors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: AppTextStyles.bodyText,
            onChanged: _searchUsers,
          ),
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _userIds.isEmpty && _searchController.text.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : _searchController.text.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: AppColors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for users',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _userIds.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        return UserTile(
                          userId: _userIds[index],
                          showFollowButton: true,
                        );
                      },
                    ),
    );
  }
}
