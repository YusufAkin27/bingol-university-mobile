import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<LogDTO> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/api/logs/logs'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          setState(() {
            notifications = (data['data'] as List)
                .map((log) => LogDTO.fromJson(log))
                .toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Bildirimler yüklenirken hata: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteNotification(String logId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/v1/api/logs/$logId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications.removeWhere((notification) => notification.logId == logId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bildirim silindi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildirim silinirken bir hata oluştu')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Bildirimler',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(child: Text('Bildirim bulunmuyor'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key(notification.logId),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteNotification(notification.logId);
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            _formatDateTime(notification.sentAt),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () => _deleteNotification(notification.logId),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class LogDTO {
  final String logId;
  final String message;
  final DateTime sentAt;

  LogDTO({
    required this.logId,
    required this.message,
    required this.sentAt,
  });

  factory LogDTO.fromJson(Map<String, dynamic> json) {
    return LogDTO(
      logId: json['logId'].toString(),
      message: json['message'] ?? '',
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
} 