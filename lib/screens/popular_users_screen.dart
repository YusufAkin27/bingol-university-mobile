import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PopularUsersScreen extends StatefulWidget {
  const PopularUsersScreen({Key? key}) : super(key: key);

  @override
  _PopularUsersScreenState createState() => _PopularUsersScreenState();
}

class _PopularUsersScreenState extends State<PopularUsersScreen> {
  List<dynamic> popularUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchPopularUsers();
  }

  Future<void> _fetchPopularUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/api/student/best-popularity'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Popüler kullanıcılar yüklenemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('En Popüler Kullanıcılar'),
      ),
      body: ListView.builder(
        itemCount: popularUsers.length,
        itemBuilder: (context, index) {
          final user = popularUsers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user['profilePhoto']),
            ),
            title: Text(user['username']),
            subtitle: Text('Takipçi: ${user['followerCount']}'),
            onTap: () {
              Navigator.pushNamed(context, '/profile', arguments: user['id']);
            },
          );
        },
      ),
    );
  }
} 