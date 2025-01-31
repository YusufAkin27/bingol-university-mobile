import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> stories = [];
  List<dynamic> posts = [];
  List<dynamic> popularUsers = [];
  bool isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _fetchStories();
    _fetchPosts();
    _fetchPopularUsers();
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

  Future<void> _fetchStories() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/api/student/home/stories'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        stories = data['data'];
      });
    } else {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hikayeler yüklenemedi.')),
      );
    }
  }

  Future<void> _fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/api/student/home/posts'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        posts = data['data'];
      });
    } else {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderiler yüklenemedi.')),
      );
    }
  }

  Future<void> _fetchPopularUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/api/student/popular'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        popularUsers = data['data'];
      });
    } else {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Popüler kullanıcılar yüklenemedi.')),
      );
    }
  }

  void _showDevelopmentMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Geliştirme aşamasındayız, bunun için üzgünüz.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Instagram Clone', style: TextStyle(fontFamily: 'Cursive')),
          actions: [
            IconButton(
              icon: FaIcon(FontAwesomeIcons.plusSquare),
              onPressed: () {
                // Gönderi ekleme sayfasına yönlendirme
              },
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.heart),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.comment),
              onPressed: _showDevelopmentMessage,
            ),
          ],
        ),
        body: Column(
          children: [
            // Hikaye Alanı
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return GestureDetector(
                    onTap: () {
                      // Hikaye görüntüleme işlemi
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(story['photo']),
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                        ),
                        SizedBox(height: 5),
                        Text(story['username'], style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Gönderi Akışı
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/profile', arguments: post['username']);
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(post['content'][0]),
                            ),
                          ),
                          title: Text(post['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(post['location']),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              // Daha fazla seçenekler
                            },
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(post['content'][0], fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(post['description'] ?? '', style: TextStyle(fontSize: 14)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.heart),
                                    onPressed: () {
                                      // Beğeni işlemi
                                    },
                                  ),
                                  Text('${post['like']}', style: TextStyle(fontSize: 12)),
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.comment),
                                    onPressed: () {
                                      // Yorum yapma işlemi
                                    },
                                  ),
                                  Text('${post['comment']}', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.share),
                                onPressed: () {
                                  // Paylaşma işlemi
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Ara',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: 'Ekle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Bildirimler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.blue,
          onTap: (index) {
            // Navigasyon işlemleri
          },
        ),
      ),
    );
  }
} 