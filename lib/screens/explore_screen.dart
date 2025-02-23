import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media/screens/profile_screen.dart';
import 'dart:async';

class SearchAccountDTO {
  final int id;
  final String fullName;
  final String profilePhoto;
  final String username;

  SearchAccountDTO({
    required this.id,
    required this.fullName,
    required this.profilePhoto,
    required this.username,
  });

  factory SearchAccountDTO.fromJson(Map<String, dynamic> json) {
    return SearchAccountDTO(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchAccountDTO> searchResults = [];
  bool isLoading = false;
  int currentPage = 0;
  bool hasMoreData = true;
  ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (hasMoreData && !isLoading) {
        currentPage++;
        _searchUsers(_searchController.text);
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        return;
      });
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () async {
      if (isLoading) return;

      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      try {
        final response = await http.get(
          Uri.parse('http://localhost:8080/v1/api/student/search?query=$query&page=$currentPage'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<SearchAccountDTO> newResults = (data['data'] as List)
              .map((user) => SearchAccountDTO.fromJson(user))
              .toList();

          setState(() {
            if (currentPage == 0) {
              searchResults = newResults;
            } else {
              searchResults.addAll(newResults);
            }
            hasMoreData = newResults.isNotEmpty;
            isLoading = false;
          });
        }
      } catch (e) {
        print('Arama yapılırken hata: $e');
        setState(() => isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              currentPage = 0;
              _searchUsers(query);
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: searchResults.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == searchResults.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final user = searchResults[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900]!.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(username: user.username),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(user.profilePhoto),
                      backgroundColor: Colors.grey[800],
                    ),
                    title: Text(
                      user.fullName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '@${user.username}',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading && searchResults.isEmpty)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
} 