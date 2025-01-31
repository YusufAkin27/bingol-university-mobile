import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isPrivate = false;
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileSettings();
  }

  Future<void> _loadProfileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/api/student/account-details'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isPrivate = data['data']['isPrivate'];
        _fullNameController.text = data['data']['fullName'] ?? '';
        _bioController.text = data['data']['bio'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil bilgileri yüklenemedi.')),
      );
    }
  }

  Future<void> _updateProfileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.put(
      Uri.parse('http://localhost:8080/v1/api/student/update-profile'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'fullName': _fullNameController.text,
        'bio': _bioController.text,
        'isPrivate': isPrivate,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil başarıyla güncellendi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil güncellenemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Beğendiğim İçerikler'),
            onTap: () {
              // Beğendiğim içerikler sayfasına yönlendirme
            },
          ),
          ListTile(
            title: Text('Yaptığım Yorumlar'),
            onTap: () {
              // Yaptığım yorumlar sayfasına yönlendirme
            },
          ),
          ListTile(
            title: Text('Arşivler'),
            onTap: () {
              // Arşivler sayfasına yönlendirme
            },
          ),
          ListTile(
            title: Text('Öne Çıkarılan Hikayeler'),
            onTap: () {
              // Öne çıkarılan hikayeler sayfasına yönlendirme
            },
          ),
        ],
      ),
    );
  }
} 