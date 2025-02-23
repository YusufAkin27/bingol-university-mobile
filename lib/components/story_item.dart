import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StoryItem extends StatefulWidget {
  final Map<String, dynamic> story;
  final Function? onStoryTap;

  const StoryItem({
    Key? key,
    required this.story,
    this.onStoryTap,
  }) : super(key: key);

  @override
  _StoryItemState createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  Future<void> _likeStory(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/v1/api/likes/story/$storyId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hikaye beğenildi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hikaye beğenilirken bir hata oluştu')),
      );
    }
  }

  Future<void> _addComment(String storyId, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/v1/api/comments/story/$storyId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        body: {
          'content': comment,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yorum eklendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum eklenirken bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onStoryTap?.call(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.story['isVisited'] == false
                  ? LinearGradient(
                      colors: [Colors.purple, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                border: widget.story['isVisited'] == true
                  ? Border.all(color: Colors.grey, width: 2)
                  : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.story['profilePhoto'] ?? ''),
                  radius: 30,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              widget.story['username'] ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 