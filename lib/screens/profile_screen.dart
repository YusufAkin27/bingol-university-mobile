import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isRequestSent = false;
  bool isFollowing = false;
  int? requestId;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/api/student/account-details/${widget.userId}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userProfile = data['data'];
        isFollowing = userProfile!['follow'];
        // Eğer istek gönderildiyse, requestId'yi al
        if (userProfile!['requestId'] != null) {
          isRequestSent = true;
          requestId = userProfile!['requestId'];
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil bilgileri yüklenemedi.')),
      );
    }
  }

  Future<void> _sendFriendRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.post(
      Uri.parse('http://localhost:8080/v1/api/friendsRequest/send/${widget.userId}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          isRequestSent = true;
          // requestId'yi güncelle
          requestId = data['requestId'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arkadaşlık isteği gönderilemedi.')),
      );
    }
  }

  Future<void> _cancelFriendRequest() async {
    if (requestId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.delete(
      Uri.parse('http://localhost:8080/v1/api/friendsRequest/cancel/$requestId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          isRequestSent = false;
          requestId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arkadaşlık isteği iptal edilemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profil'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(userProfile!['username']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(userProfile!['profilePhoto']),
              radius: 50,
            ),
            Text(userProfile!['fullName'] ?? ''),
            Text(userProfile!['bio'] ?? ''),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Takipçi'),
                    Text('${userProfile!['followerCount']}'),
                  ],
                ),
                Column(
                  children: [
                    Text('Takip'),
                    Text('${userProfile!['followingCount']}'),
                  ],
                ),
                Column(
                  children: [
                    Text('Gönderi'),
                    Text('${userProfile!['postCount']}'),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: isFollowing
                  ? null
                  : isRequestSent
                      ? _cancelFriendRequest
                      : _sendFriendRequest,
              style: ElevatedButton.styleFrom(
                primary: isFollowing
                    ? Colors.green
                    : isRequestSent
                        ? Colors.orange
                        : Colors.blue,
              ),
              child: Text(
                isFollowing
                    ? 'Takiptesin'
                    : isRequestSent
                        ? 'İstek Gönderildi'
                        : 'Takip Et',
              ),
            ),
            if (userProfile!['isPrivate'] == false && userProfile!['posts'] != null)
              ...userProfile!['posts'].map<Widget>((post) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(post['content'][0]),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(post['description'] ?? ''),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
} 