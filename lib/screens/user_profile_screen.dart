import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDTO {
  final int userId;
  final String firstName;
  final String lastName;
  final String tcIdentityNumber;
  final String username;
  final String email;
  final String mobilePhone;
  final DateTime? birthDate; // null olabileceği için '?' ekledik
  final bool? gender; // null olabileceği için '?' ekledik
  final String faculty;
  final String department;
  final String grade;
  final String profilePhoto;
  final bool isActive;
  final bool isDeleted;
  final bool isPrivate;
  final String biography;
  final int popularityScore;
  final int follower;
  final int following;
  final int block;
  final int friendRequestsReceived;
  final int friendRequestsSent;
  final int posts;
  final int stories;
  final int featuredStories;
  final int likedContents;
  final int comments;

  StudentDTO.fromJson(Map<String, dynamic> json)
      : userId = json['userId'] ?? 0,
        firstName = json['firstName'] ?? 'Bilinmiyor',
        lastName = json['lastName'] ?? 'Bilinmiyor',
        tcIdentityNumber = json['tcIdentityNumber'] ?? '',
        username = json['username'] ?? '',
        email = json['email'] ?? '',
        mobilePhone = json['mobilePhone'] ?? '',
        birthDate = json['birthDate'] != null ? DateTime.tryParse(json['birthDate']) : null,
        gender = json['gender'],
        faculty = json['faculty'] ?? '',
        department = json['department'] ?? '',
        grade = json['grade'] ?? '',
        profilePhoto = json['profilePhoto'] ?? '',
        isActive = json['isActive'] ?? false,
        isDeleted = json['isDeleted'] ?? false,
        isPrivate = json['isPrivate'] ?? false,
        biography = json['biography'] ?? '',
        popularityScore = json['popularityScore'] ?? 0,
        follower = json['follower'] ?? 0,
        following = json['following'] ?? 0,
        block = json['block'] ?? 0,
        friendRequestsReceived = json['friendRequestsReceived'] ?? 0,
        friendRequestsSent = json['friendRequestsSent'] ?? 0,
        posts = json['posts'] ?? 0,
        stories = json['stories'] ?? 0,
        featuredStories = json['featuredStories'] ?? 0,
        likedContents = json['likedContents'] ?? 0,
        comments = json['comments'] ?? 0;
}

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/api/student/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userProfile = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Profil yüklenirken hata: $e');
      setState(() => isLoading = false);
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              icon: Icons.settings,
              title: 'Ayarlar',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            _buildOptionTile(
              icon: Icons.bookmark,
              title: 'Kaydedilenler',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/saved-posts');
              },
            ),
            _buildOptionTile(
              icon: Icons.favorite,
              title: 'Beğenilen İçerikler',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/liked-posts');
              },
            ),
            _buildOptionTile(
              icon: Icons.archive,
              title: 'Arşivlenmiş Gönderiler',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/archived-posts');
              },
            ),
            _buildOptionTile(
              icon: Icons.history,
              title: 'Arşivlenmiş Hikayeler',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/archived-stories');
              },
            ),
            _buildOptionTile(
              icon: Icons.comment,
              title: 'Yorumlarım',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-comments');
              },
            ),
            _buildOptionTile(
              icon: Icons.lock,
              title: 'Şifre Değiştir',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/change-password');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          userProfile?['username'] ?? '',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/create-post'),
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(userProfile?['profilePhoto'] ?? ''),
                        backgroundColor: Colors.grey[800],
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('Takipçi', userProfile?['follower'] ?? 0),
                            _buildStatColumn('Takip', userProfile?['following'] ?? 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?['fullName'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (userProfile?['bio'] != null)
                        Text(
                          userProfile!['bio'],
                          style: TextStyle(color: Colors.white70),
                        ),
                      SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit-profile');
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 40),
                          side: BorderSide(color: Colors.grey[800]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Profili Düzenle',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.bookmark_border)),
                  Tab(icon: Icon(Icons.favorite_border)),
                ],
              ),
            ),
            pinned: true,
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsGrid(),
            _buildSavedPostsGrid(),
            _buildLikedPostsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(1),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: (userProfile?['posts'] ?? []).length,
      itemBuilder: (context, index) {
        final post = userProfile!['posts'][index];
        return Image.network(
          post['content'][0],
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildSavedPostsGrid() {
    return Center(child: Text('Kaydedilen Gönderiler', style: TextStyle(color: Colors.white)));
  }

  Widget _buildLikedPostsGrid() {
    return Center(child: Text('Beğenilen Gönderiler', style: TextStyle(color: Colors.white)));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
