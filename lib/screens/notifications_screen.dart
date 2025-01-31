import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'text': 'Yeni bir takipçiniz var!',
      'image': 'https://via.placeholder.com/150'
    },
    {
      'text': 'Gönderiniz beğenildi!',
      'image': 'https://via.placeholder.com/150'
    },
    // Diğer bildirimler...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirimler'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: Image.network(notification['image']!),
            title: Text(notification['text']!),
          );
        },
      ),
    );
  }
} 