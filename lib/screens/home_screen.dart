import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_media/components/story_item.dart';
import 'package:social_media/components/post_item.dart';
import 'package:social_media/screens/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> stories = [];
  List<dynamic> posts = [];
  List<dynamic> suggestedUsers = [];
  bool isDarkTheme = false;
  bool isLoading = true;
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _loadThemePreference();
    _loadData();
    _fetchSuggestedUsers();

    // Sonsuz scroll için dinleyici
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = !isDarkTheme;
      prefs.setBool('isDarkTheme', isDarkTheme);
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchStories(),
      _fetchPosts(),
    ]);
    _animationController.forward();
    setState(() => isLoading = false);
  }

  Future<void> _fetchStories() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/api/student/home/stories'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stories = data['data'] ?? [];
        });
      }
    } catch (e) {
      print('Hikayeler yüklenirken hata: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/api/student/home/posts'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          posts = data['data'] ?? [];
        });
      }
    } catch (e) {
      print('Gönderiler yüklenirken hata: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchSuggestedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/api/student/suggested-connections'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        suggestedUsers = List<Map<String, dynamic>>.from(data['data'].map((user) => {
          'id': user['id'],
          'fullName': user['fullName'],
          'profilePhoto': user['profilePhoto'],
          'username': user['username'],
        }));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Önerilen kullanıcılar yüklenemedi.')),
      );
    }
  }

  Future<void> _loadMorePosts() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/api/student/home/posts?page=${posts.length ~/ 10}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          posts.addAll(data['data'] ?? []);
        });
      }
    } catch (e) {
      print('Daha fazla gönderi yüklenirken hata: $e');
    }
  }

  void _showDevelopmentMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Geliştirme aşamasındayız, bunun için üzgünüz.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Campus',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/explore'),
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none_outlined, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.send_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/messages'),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                slivers: [
                  // Hikayeler
                  SliverToBoxAdapter(
                    child: Container(
                      height: 110,
                      margin: EdgeInsets.only(bottom: 10),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          itemCount: stories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildAddStoryItem();
                            }
                            return StoryItem(story: stories[index - 1]);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Ayırıcı
                  SliverToBoxAdapter(
                    child: Divider(
                      color: Colors.grey[900],
                      height: 1,
                    ),
                  ),

                  // Gönderiler
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: PostItem(post: posts[index]),
                        );
                      },
                      childCount: posts.length,
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAddStoryItem() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Hikaye Ekle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[900]!,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: 'Paylaş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Aktivite',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage('KULLANICI_PROFIL_FOTO_URL'),
              ),
            ),
            label: 'Profil',
          ),
        ],
        currentIndex: 0,
        onTap: _onNavigationTap,
      ),
    );
  }

  void _onNavigationTap(int index) {
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/explore');
        break;
      case 2:
        Navigator.pushNamed(context, '/create-post');
        break;
      case 3:
        Navigator.pushNamed(context, '/activity');
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
        break;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}